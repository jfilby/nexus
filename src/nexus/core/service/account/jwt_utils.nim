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
  ## Reads the claims out of a JWT.
  ##
  ## The returned flag reports whether the token could be *parsed*, NOT whether
  ## it is authentic. The signature can only be checked against the account's
  ## api_key, and finding that key requires the accountUserId returned here, so
  ## the caller must run verifyJWTByAPIKey() before trusting any of this. Callers
  ## must never treat a true result as an authenticated identity.
proc setJWTDeleted*(
       nexusCoreDbContext: NexusCoreDbContext,
       token: string) {.gcsafe.}
proc verifyJWTByAPIKey*(
       nexusCoreDbContext: NexusCoreDbContext,
       accountUserId: string,
       token: string): (bool, string) {.gcsafe.}


# Code
proc connectWithJWT*(
       request: Request,
       nexusCoreDbContext: NexusCoreDbContext,
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

  # readJWT() only parses the claims, it does not verify them, so the
  # accountUserId read above is an unverified claim: it must not be treated as
  # an authenticated identity, and nothing derived from it may be handed back
  # to the caller unless the signature check below succeeds.
  if verified == false:

    return (false,
            "Invalid token (1)",
            "",
            "",
            "")

  # A token with no "sub" claim identifies nobody, so it can never be
  # connected: the signature check below needs an accountUserId to look up.
  if accountUserId == "":

    return (false,
            "Invalid token (1)",
            "",
            "",
            "")

  debug "connectWithJWT()",
    accountUserId = $accountUserId

  var apiKey = ""

  if accountUserId != "":

    # Get accountUser
    let accountUser =
          getAccountUserByPk(
            nexusCoreDbContext,
            accountUserId)

    if accountUser.isNone:
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
                       nexusCoreDbContext,
                       accountUserId,
                       token)

    if verified == false:

      # Never return the api_key (the JWT signing secret) or the accountUserId
      # on this path: the caller signs a new token with them, which would turn
      # a failed verification into a valid session for the claimed account.
      return (false,
              "Invalid token (3)",
              "",
              "",
              "")

  # Return connected OK
  return (true,
          "",
          apiKey,
          accountUserId,
          mobile)


proc createJWT*(nexusCoreDbContext: NexusCoreDbContext,
                accountUserId: string,
                inSecret: string = "",
                mobile: string = ""): string =

  debug "createJWT()",
    accountUserId = accountUserId,
    mobile = mobile

  # The signing secret is the account's api_key. Never fall back to a fixed
  # value: anyone reading the source would then be able to mint a valid token.
  if inSecret == "":

    raise newException(ValueError,
                       "createJWT(): a signing secret is required")

  let secret = inSecret

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
     errorMessage) = verifyJWTByAPIKey(nexusCoreDbContext,
                                        accountUserId,
                                        token)

    debug "createJWT(): token verified ok",
      accountUserId = accountUserId

    if verified == false:

      # A token we just signed that does not verify means the api_key changed
      # underneath us. Returning it would hand out an unusable credential, so
      # fail instead of returning a token that cannot be authenticated.
      raise newException(ValueError,
                         "createJWT(): the generated token could not be verified")

  return token


# getJWT(): returns (sub: accountUserId, newJwtToken (if any))
proc getJWT*(nexusCoreDbContext: NexusCoreDbContext,
             token: string,
             secret: string): (string, string) =

  # Verify the token
  if not token.verify(secret,
                      @[ jwt_algorithm ]):

    warn "getJWT(): token verification failed"

    return ("", "")

  # Get the accountUserId
  let
    accountUserId = token.claim["sub"].getStr()
    expiryTime = token.claim["exp"].getInt()
    mobile = token.claim["mbl"].getStr()

  # Renew the token only if it expired within the renewal window. The
  # comparison has to be against the token's own "exp" claim: comparing the
  # current time against a time derived from the current time can never be
  # true, so expired tokens were never rejected.
  let
    unixTime = toUnix(getTime())
    renewTime = expiryTime + (60 * renewMinutes)

  if unixTime > expiryTime:

    if unixTime < renewTime:

      # Expired, but within the time to renew
      let newToken = createJWT(nexusCoreDbContext,
                               accountUserId,
                               secret)

      return (accountUserId, newToken)

    else:

      # Expired, too late to renew
      return ("", "")

  # Return the accountUserId and the original token
  return (accountUserId,
          token)


proc logoutJWT*(
       request: Request,
       nexusCoreDbContext: NexusCoreDbContext,
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

      # The body is attacker-controlled: a malformed or non-object body must not
      # raise out of logout.
      try:

        let json = parseJson(request.body)

        if json.kind == JObject and
           json.hasKey(DocUI_Token):

          token = json[DocUI_Token].getStr("")

      except CatchableError as e:

        debug "logoutJWT(): request body could not be parsed",
          errorMessage = e.msg

  debug "logoutJWT()",
    token = token

  # Set the token as deleted
  setJWTDeleted(nexusCoreDbContext,
                token)


proc purgeDeletedJWTs*(nexusCoreDbContext: NexusCoreDbContext) {.gcsafe.} =

  # Delete tokens that were revoked (logged out) more than a day ago. Filtering
  # on `created` instead reaped live sessions: created is never refreshed on
  # re-login, and the primary key is account_user_id, so each nightly run
  # destroyed the only token row of anyone whose session was over 24h old.
  let accountUserTokens =
        filterAccountUserToken(
          nexusCoreDbContext,
          whereClause = "deleted is not null and" &
                        " deleted < NOW() - INTERVAL '1 day'")

  for accountUserToken in accountUserTokens:

    discard deleteAccountUserTokenByPk(
              nexusCoreDbContext,
              accountUserToken.accountUserId)


proc readJWT*(token: string):
       (bool, string, string) {.gcsafe.} =

  debug "readJWT()",
    token = token

  # A malformed token is a normal condition: the token arrives in a
  # client-controlled cookie, so anyone can send anything. token.claim raises
  # an uncatchable Defect when the token is not three dot-separated parts, so
  # check the shape before parsing.
  if token.count(".") != 2:

    debug "readJWT(): token is not a JWT (expected 2 '.' separators)"

    return (false,
            "",
            "")

  var
    claimJson: JsonNode
    accountUserId = ""
    mobile = ""

  try:

    # Get the claim
    claimJson = token.claim

  except CatchableError as e:

    debug "readJWT(): token claim could not be parsed",
      errorMessage = e.msg

    return (false,
            "",
            "")

  # Get the accountUserId, defaulting to "" when the claim is absent or is not
  # a string, so a hand-crafted claim cannot raise here either
  accountUserId = claimJson{"sub"}.getStr("")

  # Get mobile indicator
  mobile = claimJson{"mbl"}.getStr("")

  debug "readJWT()",
    accountUserId = accountUserId,
    mobile = mobile

  return (true,
          accountUserId,
          mobile)


proc setJWTDeleted*(
       nexusCoreDbContext: NexusCoreDbContext,
       token: string) {.gcsafe.} =

  debug "setJWTDeleted()",
    token = token

  var accountUserToken =
        getAccountUserTokenByToken(
          nexusCoreDbContext,
          token)

  if accountUserToken.isNone:
    warn "setJWTDeleted(): token not found"
    return

  accountUserToken.get.deleted = some(now())

  discard updateAccountUserTokenByPk(
            nexusCoreDbContext,
            accountUserToken.get,
            setFields = @[ "deleted" ])

  debug "setJWTDeleted(): set deleted field for AccountUserToken"


proc verifyJWTByAPIKey*(
       nexusCoreDbContext: NexusCoreDbContext,
       accountUserId: string,
       token: string): (bool, string) {.gcsafe.} =

  debug "verifyJWTByAPIKey()",
    accountUserId = accountUserId

  # Get API key for the specified user
  let apiKey = getAPIKeyFromAccountUserByPk(
                 nexusCoreDbContext,
                 accountUserId)

  if apiKey.isNone:

    debug "verifyJWTByAPIKey(): apiKey not found"

    return (false,
            "token verification failed (api key not found)")

  # Verify token
  if not token.verify(apiKey.get,
                      @[ jwtAlgorithm ]):

    debug "verifyJWTByAPIKey(): token failed to verify"

    return (false,
            "token verification failed (invalid token)")

  # A valid signature is not enough: the token must not have been revoked.
  # Without this check a token stays valid for its full 12 hour lifetime after
  # logout, since the signature is computed from the account's api_key.
  let accountUserToken =
        getAccountUserTokenByToken(
          nexusCoreDbContext,
          token)

  if accountUserToken.isSome and
     accountUserToken.get.deleted.isSome:

    debug "verifyJWTByAPIKey(): token was revoked (logged out)"

    return (false,
            "token verification failed (token revoked)")

  return (true,
          "")

