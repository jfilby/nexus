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
import nexus/core/types/model_types
import nexus/core/types/module_globals
import nexus/core/types/types
import nexus/core/types/view_types
import nexus/core/view/account/logout_page
import nexus/core_extras/service/format/hash


# Forward declarations
proc loginActionVerified*(
       nexusCoreModule: NexusCoreModule,
       webContext: WebContext,
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
proc loginAction*(request: Request,
                  webContext: WebContext,
                  json: Option[JsonNode]): DocUIReturn =

  let contentType = getContentType(request)

  debug "loginAction()",
    contentType = contentType

  var
    email = ""
    password = ""
    loginHash = ""
    formValues: JsonNode

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
            nexusCoreModule,
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
             nexusCoreModule,
             webContext,
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
          nexusCoreModule,
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
           nexusCoreModule,
           webContext,
           accountUserId,
           loginHash)


proc loginActionByEmailVerified*(
       nexusCoreModule: NexusCoreModule,
       webContext: WebContext,
       email: string): DocUIReturn =

  # Get Account User by email
  let accountUser =
        getAccountUserByEmail(
          nexusCoreModule,
          email)

  if accountUser == none(AccountUser):

    raise newException(
            ValueError,
            &"AccountUser record not found for email: {email}")

  return loginActionVerified(
           nexusCoreModule,
           webContext,
           accountUser.get.accountUserId,
           "")


proc loginActionVerified*(
       nexusCoreModule: NexusCoreModule,
       webContext: WebContext,
       accountUserId: int64,
       loginHash: string): DocUIReturn =

  # Login OK
  debug "loginAction(): login verified OK"

  # Set lastLogin
  let rowsUpdated =
        updateAccountUserSetLastLoginByPK(
          nexusCoreModule,
          lastLogin = some(now()),
          accountUserId)

  # Get API key
  let apiKey =
        getAPIKeyFromAccountUserByPK(
          nexusCoreModule,
          accountUserId)

  # New DocUIReturn
  var docUIReturn = newDocUIReturn(true)

  # Get AccountUserToken record
  var accountUserToken =
        getAccountUserTokenByPK(
          nexusCoreModule,
          accountUserId)

  # TODO: if loginHash is specified, then try to use the existing token
  # Check if it has expired, and only create a new token if it has

  # Create token
  docUIReturn.token =
    createJWT(
      nexusCoreModule,
      $accountUserId,
      apiKey.get,
      mobile = $webContext.mobileDefault)

  # New AccountUserToken record required
  if accountUserToken == none(AccountUserToken):

    discard createAccountUserToken(
              nexusCoreModule,
              accountUserId,
              getUniqueHash(@[ docUIReturn.token ]),
              docUIReturn.token,
              created = now(),
              deleted = none(DateTime))

  else:
    # Update existing AccountUserToken record with a new token
    accountUserToken.get.token = docUIReturn.token
    accountUserToken.get.deleted = none(DateTime)

    discard updateAccountUserTokenByPK(
              nexusCoreModule,
              accountUserToken.get,
              setFields = @[ "token",
                             "deleted" ])

  # Get AccountUser record
  var accountUser =
        getAccountUserByPK(
          nexusCoreModule,
          accountUserId)

  if accountUser == none(AccountUser):

    raise newException(
            ValueError,
            &"AccountUser record not found for accountUserId: {accountUserId}")

  # Update AccountUser.lastToken
  accountUser.get.lastToken = some(docUIReturn.token)

  discard updateAccountUserByPK(
            nexusCoreModule,
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


template logoutAction*(request: Request,
                       webContext: WebContext,
                       redirect: string = "") =

  logoutPage(request,
             webContext)

  # Get AccountUser record
  var accountUser =
        getAccountUserByPK(
          nexusCoreModule,
          webContext.accountUserId)

  if accountUser == none(AccountUser):

    raise newException(
            ValueError,
            "AccountUser record not found for accountUserId: " &
            $accountUser.get.accountUserId)

  # Update AccountUser.lastToken
  accountUser.get.lastToken = none(string)

  discard updateAccountUserByPK(
            nexusCoreModule,
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


template postLoginAction*(
           request: Request,
           webContext: WebContext) =

  var
    verified: bool
    loginURL: string
    token: string

  (verified,
   loginURL,
   token) = loginPagePost(request,
                          webContext)

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
            nexusCoreModule,
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
            nexusCoreModule,
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

