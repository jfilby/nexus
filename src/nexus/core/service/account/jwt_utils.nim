import chronicles, jester, json, options, quickjwt, strformat, strutils, times
import docui/service/sdk/docui_types
import nexus/core/data_access/account_user_data
import nexus/core/data_access/account_user_token_data
import nexus/core/types/model_types
import utils


# Constants
const jwtAlgorithm = "HS512"
const expiryMinutes = 60 * 12  # Tokens expire after 12 hours
const renewMinutes = 15        # Renew tokens every 15 minutes


# Forward declarations
proc readJWT*(token: string):
       (bool, string, string) {.gcsafe.}
proc setJWTDeleted*(
       nexusCoreModule: NexusCoreModule,
       token: string) {.gcsafe.}
proc verifyJWTByAPIKey*(
       nexusCoreModule: NexusCoreModule,
       accountUserId: string,
       token: string): (bool, string) {.gcsafe.}


# Code
proc connectWithJWT*(
       request: Request,
       nexusCoreModule: NexusCoreModule,
       inToken: string = "",
       useCookie: bool = true,
       verifyUserIsActive: bool = false):
         (bool, string, string, string, string) {.gcsafe.} =

  # Returns: (verified, errorMessage, secret (apiKey), accountUserId, mobile)

  debug "connectWithJWT()"

  # Try to get token, exit if no token is set in the request
  var token: string

  if inToken != "":
    token = inToken

  else:
    try:
      if use_cookie == true:
        # Web app
        token = request.cookies["token"]
      else:
        # Web service
        token = request.params["token"]

    except:
      debug "connectWithJWT(): except"

      return (false,
              "Failed to get token",
              "",
              "",
              "")

    if token == "":
      debug "connectWithJWT(): token not found"

      return (false,
              "Token is empty",
              "",
              "",
              "")

  # Read the token
  var
    verified = false
    accountUserId: string
    mobile: string
    errorMessage: string

  (verified,
   accountUserId,
   mobile) = readJWT(token)

  debug "connectWithJWT()",
    mobile = mobile

  if verified == false and
     accountUserId == "" and
     verifyUserIsActive == true:

    return (false,
            "Invalid token (1)",
            "",
            accountUserId,
            "")

  debug "connectWithJWT()",
    accountUserId = $accountUserId

  var apiKey = ""

  if accountUserId != "":

    # Get accountUser
    let accountUser =
          getAccountUserByPk(
            nexusCoreModule,
            accountUserId)

    if accountUser == none(AccountUser):
      return (false,
              "Invalid token (2)",
              "",
              accountUserId,
              "")

    # Verify that the user is active in the system
    if verifyUserIsActive == true:

      if accountUser.get.isActive == false:
        return (false,
                &"User is not activated in the system ({accountUserId})",
                "",
                accountUserId,
                mobile)

      else:
        apiKey = accountUser.get.apiKey

    # Verify the token against the API key (expected secret for a logged in user)
    (verified,
     errorMessage) = verifyJWTByAPIKey(
                       nexusCoreModule,
                       accountUserId,
                       token)

    if verified == false:
      return (false,
              "Invalid token (3)",
              accountUser.get.apiKey,
              accountUserId,
              "")

  # Return connected OK
  return (true,
          "",
          apiKey,
          accountUserId,
          mobile)


proc createJWT*(nexusCoreModule: NexusCoreModule,
                accountUserId: string,
                inSecret: string = "",
                mobile: string = ""): string =

  debug "createJWT()",
    accountUserId = accountUserId,
    mobile = mobile,
    inSecret = inSecret

  # Default secret to "logged out"
  var secret = inSecret

  if secret == "":
    secret = "logged out"

  # Verify fields
  if accountUserId == "":
    debug("accountUserId is blank")

  # Define token
  let
    unix_time = toUnix(getTime()) + (60 * expiryMinutes)

    token = sign(
      header = %*{
        "typ": "JWT",
        "alg": jwt_algorithm
      },
      claim = %*{
        # Standard fields
        "sub": accountUserId,
        "exp": int(unix_time),
        # Custom fields
        "mbl": $mobile
      },
      secret = secret
    )

  # Verify the token
  if accountUserId != "":
    var
      verified: bool
      errorMessage: string

    (verified,
     errorMessage) = verifyJWTByAPIKey(nexusCoreModule,
                                        accountUserId,
                                        token)

    debug "createJWT(): token verified ok",
      accountUserId = accountUserId,
      secret = secret,
      token = token

    if verified == false:
      error "token generated could not be verified!"

  return token


# getJWT(): returns (sub: accountUserId, newJwtToken (if any))
proc getJWT*(nexusCoreModule: NexusCoreModule,
             token: string,
             secret: string): (string, string) =

  # Verify the token
  if not token.verify(secret,
                      @[ jwt_algorithm ]):

    warn "getJWT: token verification failed",
      token = token,
      secret = secret

    return ("", "")

  # Get the accountUserId
  let
    accountUserId = token.claim["sub"].getStr()
    expiryTime = token.claim["exp"].getInt()
    mobile = token.claim["mbl"].getStr()

  # Check the expiry time:
  # The token is renewed if this one has expired recently (within 10 minutes after the initial expiry time).
  let
    unixTime = toUnix(getTime())
    expiredTime = unixTime + (60 * expiryMinutes)
    renewTime = unixTime + (60 * renewMinutes)

  if unixTime > renewTime:

    if unixTime < expiredTime:

      # Expired, but within the time to renew
      let token = createJWT(nexusCoreModule,
                            accountUserId,
                            secret)

      return (accountUserId, token)

    else:

      # Expired, too late to renew
      return ("", "")

  # Return the accountUserId and the original token
  return (accountUserId,
          token)


proc logoutJWT*(
       request: Request,
       nexusCoreModule: NexusCoreModule,
       useCookie: bool) {.gcsafe.} =

  let contentType = getContentType(request)

  debug "logoutJWT()",
    contentType = contentType

  # Try to get token, exit if no token is set in the request
  var token = ""

  # Try cookie
  if useCookie == true:
    # Web app
    if request.cookies.hasKey("token"):
      token = request.cookies["token"]

  if token == "":

    if contentType == ContentType.Form:

      # Web service
      if request.params.hasKey("token"):
        token = request.params["token"]

    # Handle JSON post
    elif contentType == ContentType.JSON:
      let json = parseJson(request.body)

      debug "loginAction()",
        json = json

      if json.hasKey(DocUI_Token):
        token = json[DocUI_Token].getStr()

  debug "logoutJWT()",
    token = token

  # Set the token as deleted
  setJWTDeleted(nexusCoreModule,
                token)


proc purgeDeletedJWTs*(nexusCoreModule: NexusCoreModule) {.gcsafe.} =

  # Delete tokens after 1 day
  let accountUserTokens =
        filterAccountUserToken(
          nexusCoreModule,
          whereClause = "created < NOW() - INTERVAL '1 day'")

  for accountUserToken in accountUserTokens:

    discard deleteAccountUserTokenByPk(
              nexusCoreModule,
              accountUserToken.accountUserId)


proc readJWT*(token: string):
       (bool, string, string) {.gcsafe.} =

  debug "readJWT()",
    token = token

  if len(token) == 0:
    return (false,
            "",
            "")

  let
    # Get the claim
    claimJson = token.claim

    # Get the accountUserId
    accountUserId = claimJson["sub"].getStr()

    # Get mobile indicator
    mobile = claimJson["mbl"].getStr()

  debug "readJWT()",
    accountUserId = accountUserId,
    mobile = mobile

  return (true,
          accountUserId,
          mobile)


proc setJWTDeleted*(
       nexusCoreModule: NexusCoreModule,
       token: string) {.gcsafe.} =

  debug "setJWTDeleted()",
    token = token

  var accountUserToken =
        getAccountUserTokenByToken(
          nexusCoreModule,
          token)

  if accountUserToken == none(AccountUserToken):
    warn "setJWTDeleted(): token not found"
    return

  accountUserToken.get.deleted = some(now())

  discard updateAccountUserTokenByPk(
            nexusCoreModule,
            accountUserToken.get,
            setFields = @[ "deleted" ])

  debug "setJWTDeleted(): set deleted field for AccountUserToken"


proc verifyJWTByAPIKey*(
       nexusCoreModule: NexusCoreModule,
       accountUserId: string,
       token: string): (bool, string) {.gcsafe.} =

  debug "verifyJWTByAPIKey()",
    accountUserId = accountUserId

  # Get API key for the specified user
  let apiKey = getAPIKeyFromAccountUserByPk(
                 nexusCoreModule,
                 parseBiggestInt(accountUserId))

  if apiKey == none(string):

    debug "verifyJWTByAPIKey(): apiKey not found"

    return (false,
            "token verification failed (api key not found)")

  # Verify token
  if not token.verify(apiKey.get,
                      @[ jwtAlgorithm ]):

    debug "verifyJWTByAPIKey(): token failed to verify"

    return (false,
            "token verification failed (invalid token)")

  return (true,
          "")

