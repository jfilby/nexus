import chronicles, db_postgres, jester, json, options, strformat, tables, times
import docui/service/sdk/docui_elements
import docui/service/sdk/docui_types
import docui/service/sdk/docui_utils
import nexus/core/data_access/account_user_data
import nexus/core/data_access/account_user_token_data
import nexus/core/service/account/jwt_utils
import nexus/core/service/account/utils
import nexus/core/service/account/verify_login_fields
import nexus/core/service/nexus_settings/get
import nexus/core/types/context_type
import nexus/core/types/model_types
import nexus/core/types/types
import nexus/core/types/view_types
import nexus/core/view/account/logout_page
import nexus/core_extras/service/format/hash


# Forward declarations
proc loginActionVerified*(
       nexusCoreContext: NexusCoreContext,
       accountUserId: int64,
       loginHash: string): DocUIReturn


# Code

# Copied from Jester's jester.nim file (required by myRedirect proc)
template setHeader(headers: var Option[RawHeaders], key, value: string): typed =
  bind isNone
  if isNone(headers):
    headers = some(@({key: value}))
  else:
    block outer:
      # Overwrite key if it exists.
      var h = headers.get()
      for i in 0 ..< h.len:
        if h[i][0] == key:
          h[i][1] = value
          headers = some(h)
          break outer

      # Add key if it doesn't exist.
      headers = some(h & @({key: value}))


# Copied (and modified) from Jester's jester.nim file (as the currect redirect proc breaks when used outside of the
# route macro)
template myRedirect*(url: string): typed =
  ## Redirects to ``url``. Returns from this request handler immediately.
  ##
  ## If ``halt`` is true, skips executing future handlers, too.
  ##
  ## Any set response headers are preserved for this request.
  bind TCActionSend, newHttpHeaders
  result[0] = TCActionSend
  result[1] = Http303
  setHeader(result[2], "Location", url)
  result[3] = ""
  result.matched = true
  break route


# Used by the Nexus Admin web-service
proc loginAction*(nexusCoreContext: NexusCoreContext,
                  json: Option[JsonNode]): DocUIReturn =

  # Validate
  if nexusCoreContext.web == none(WebContext):

    raise newException(
            ValueError,
            "nexusCoreContext.web == none")

  # Initial vars
  let contentType = getContentType(nexusCoreContext.web.get.request)

  debug "loginAction()",
    contentType = contentType

  var
    email = ""
    password = ""
    loginHash = ""
    formValues: JsonNode

  template request: untyped = nexusCoreContext.web.get.request

  # Handle form post
  if contentType == ContentType.Form:
    if request.params.hasKey("email"):
      email = request.params["email"]

    if request.params.hasKey("password"):
      password = request.params["password"]

    if request.params.hasKey("loginHash"):
      loginHash = request.params["loginHash"]

  # Handle JSON post
  elif contentType == ContentType.JSON:
    let json = parseJson(request.body)

    debug "loginAction()",
      json = json

    if json.hasKey(DocUI_Form):
      if json[DocUI_Form].hasKey(DocUI_Children):

        formValues = json[DocUI_Form][DocUI_Children]

        if formValues.hasKey("email"):
          email = formValues["email"].getStr()

        if formValues.hasKey("password"):
          password = formValues["password"].getStr()

        if formValues.hasKey("loginHash"):
          loginHash = formValues["loginHash"].getStr()

  # If loginHash is specified
  if loginHash != "":

    # Get AccountUserToken record
    let accountUserToken =
          getAccountUserTokenByUniqueHash(
            nexusCoreContext.db,
            loginHash)

    if accountUserToken == none(AccountUserToken):
      return newDocUIReturn(
               false,
               errorMessage = "Login Hash is invalid.")

    # Commented out, if the login has
    if accountUserToken.get.deleted != none(DateTime):
      return newDocUIReturn(
               false,
               errorMessage = "Login Hash has expired.")

    # Successfully found
    return loginActionVerified(
             nexusCoreContext,
             accountUserToken.get.accountUserId,
             loginHash)

  # Check for required fields
  if email == "":
    return newDocUIReturn(
             false,
             errorMessage = "Email not specified")

  if password == "":
    return newDocUIReturn(
             false,
             errorMessage = "Password not specified")

  # Get accountUser record
  debug "loginAction(): get and verify AccountUser record"

  let accountUser =
        getAccountUserByEmail(
          nexusCoreContext.db,
          email)

  if accountUser == none(AccountUser):
    debug "loginAction(): email not found"

    return newDocUIReturn(
             false,
             errorMessage = "Email not found. Please verify or sign-up.")

  if accountUser.get.isVerified == false:

    return newDocUIReturn(
             false,
             errorMessage = AccountNotVerifiedByEmail)

  # Verify the input
  debug "loginAction(): calling: verifyLoginFields().."

  var
    (docuiReturn,
     accountUserId,
     errorMessage) = verifyLoginFields(
                       email,
                       password,
                       accountUser)

  # HTML only (not for the web-service that sends UI to Flutter)
  if contentType == ContentType.Form:
    docUIReturn.errorMessage = errorMessage

  if docuiReturn.isVerified == false:

    debug "loginAction(): verifyLoginFields() failed"

    return docUiReturn

  if accountUser.get.isVerified == false:

    debug "loginAction(): email/password failed verification"

    return newDocUIReturn(
             false,
             errorCode = LoginFailedAccountNotVerified,
             errorMessage = "Failed to login. Account not verified.")

  # Login
  return loginActionVerified(
           nexusCoreContext,
           accountUserId,
           loginHash)


proc loginActionByEmailVerified*(
       nexusCoreContext: NexusCoreContext,
       email: string): DocUIReturn =

  # Get Account User by email
  let accountUser =
        getAccountUserByEmail(
          nexusCoreContext.db,
          email)

  if accountUser == none(AccountUser):

    raise newException(
            ValueError,
            &"AccountUser record not found for email: {email}")

  return loginActionVerified(
           nexusCoreContext,
           accountUser.get.accountUserId,
           "")


proc loginActionVerified*(
       nexusCoreContext: NexusCoreContext,
       accountUserId: int64,
       loginHash: string): DocUIReturn =

  # Validate
  if nexusCoreContext.web == none(WebContext):

    raise newException(
            ValueError,
            "nexusCoreContext.web == none")

  # Login OK
  debug "loginAction(): login verified OK"

  # Set lastLogin
  let rowsUpdated =
        updateAccountUserSetLastLoginByPk(
          nexusCoreContext.db,
          lastLogin = some(now()),
          accountUserId)

  # Get API key
  let apiKey =
        getAPIKeyFromAccountUserByPk(
          nexusCoreContext.db,
          accountUserId)

  # New DocUIReturn
  var docUIReturn = newDocUIReturn(true)

  # Get AccountUserToken record
  var accountUserToken =
        getAccountUserTokenByPk(
          nexusCoreContext.db,
          accountUserId)

  # TODO: if loginHash is specified, then try to use the existing token
  # Check if it has expired, and only create a new token if it has

  # Create token
  docUIReturn.token =
    createJWT(
      nexusCoreContext.db,
      $accountUserId,
      apiKey.get,
      mobile = $nexusCoreContext.web.get.mobileDefault)

  # New AccountUserToken record required
  if accountUserToken == none(AccountUserToken):

    discard createAccountUserToken(
              nexusCoreContext.db,
              accountUserId,
              getUniqueHash(@[ docUIReturn.token ]),
              docUIReturn.token,
              created = now(),
              deleted = none(DateTime))

  else:
    # Update existing AccountUserToken record with a new token
    accountUserToken.get.token = docUIReturn.token
    accountUserToken.get.deleted = none(DateTime)

    discard updateAccountUserTokenByPk(
              nexusCoreContext.db,
              accountUserToken.get,
              setFields = @[ "token",
                             "deleted" ])

  # Get AccountUser record
  var accountUser =
        getAccountUserByPk(
          nexusCoreContext.db,
          accountUserId)

  if accountUser == none(AccountUser):

    raise newException(
            ValueError,
            &"AccountUser record not found for accountUserId: {accountUserId}")

  # Update AccountUser.lastToken
  accountUser.get.lastToken = some(docUIReturn.token)

  discard updateAccountUserByPk(
            nexusCoreContext.db,
            accountUser.get,
            setFields = @[ "last_token" ])

  # Add email address (if a loginHash was used it needs to be sent)
  docUIReturn.results =
    some(
      form("return",
           "loginForm",
           @[ fieldValue(
                "email",
                some(accountUser.get.email)) ]))

  # Return
  return docuiReturn


template logoutAction*(nexusCoreContext: NexusCoreContext,
                       redirect: string = "") =

  # Validate
  if nexusCoreContext.web == none(WebContext):

    raise newException(
            ValueError,
            "nexusCoreContext.web == none")

  # Logout page
  logoutPage(nexusCoreContext)

  # Get AccountUser record
  var accountUser =
        getAccountUserByPk(
          nexusCoreContext.db,
          nexusCoreContext.web.get.webContext.accountUserId)

  if accountUser == none(AccountUser):

    raise newException(
            ValueError,
            "AccountUser record not found for accountUserId: " &
            $accountUser.get.accountUserId)

  # Update AccountUser.lastToken
  accountUser.get.lastToken = none(string)

  discard updateAccountUserByPk(
            nexusCoreContext.db,
            accountUser.get,
            setFields = @[ "last_token" ])

  # Unset cookie
  setCookie("token",
            "",
            daysForward(5),
            path = "/")

  if redirect == "":
    myRedirect "/"
  else:
    myRedirect "/?redirect=" & redirect

  # resp Http307, @[("Location", "/")], ""


template postLoginAction*(nexusCoreContext: NexusCoreContext) =

  var
    verified: bool
    loginURL: string
    token: string

  (verified,
   loginURL,
   token) = loginPagePost(nexusCoreContext)

  if verified == true:

    debug "postLoginAction(): verified; setting logged in cookie"

    # Set cookie
    setCookie("token",
              token,
              daysForward(5),
              path = "/")

    # Get 'Nexus Pay subscriptions enabled' setting
    let nexusPaySubscriptionsEnabled =
          getNexusSettingValue(
            nexusCoreContext.db,
            module = "Nexus Core",
            key = "Nexus Pay subscriptions enabled")

    # Get AccountUser record and redirect URL
    var
      email = ""
      redirectToURL = "/?first_homepage=t"

    if request.params.hasKey("email"):
      email = request.params["email"]

    let accountUser =
          getAccountUserByEmail(
            nexusCoreContext.db,
            email)

    if accountUser != none(AccountUser):

      if nexusPaySubscriptionsEnabled.get == "Y" and
         accountUser.get.subscriptionStatus == none(char):

        redirectToURL = "/account/subscription"

    # Redirect to the homepage
    myRedirect redirectToURL
    #resp Http307, @[("Location", "/")], ""

  else:
    # echo "Responding with loginMessage: " & loginURL

    myRedirect loginURL

