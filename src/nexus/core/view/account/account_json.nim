import chronicles, jester, json, options
import docui/service/sdk/docui_types
import docui/service/sdk/docui_utils
import nexus/core/data_access/account_user_data
import nexus/core/service/account/jwt_utils
import nexus/core/service/account/login_action
import nexus/core/service/account/reset_password_action
import nexus/core/service/account/sign_up_action
import nexus/core/service/account/verify_sign_up_action
import nexus/core/types/context_type
import nexus/core/types/model_types
import nexus/core/types/view_types


proc loginJSONPost*(nexusCoreContext: NexusCoreContext): string =

  debug "loginJSONPost(): request",
    body = request.body,
    headers = request.headers

  # Validate
  if nexusCoreContext.web == none(WebContext):

    raise newException(
            ValueError,
            "nexusCoreContext.web == none")

  # Initial vars
  template request: untyped = nexusCoreContext.web.get.request

  # Decode JSON
  let jsonRequest = parseJson(request.body)

  # Login action
  let
    docuiReturn =
      loginAction(nexusCoreContext,
                  some(jsonRequest))

    returnJson = $toJson(docuiReturn)

  # Debug
  debug "loginJSONPost()",
    returnJson = returnJson

  # Return values as JSON
  return returnJson


proc logoutJSON*(nexusCoreContext: NexusCoreContext): string =

  # Validate
  if nexusCoreContext.web == none(WebContext):

    raise newException(
            ValueError,
            "nexusCoreContext.web == none")

  # Initial vars
  template webContext: untyped = nexusCoreContext.web.get

  # Get AccountUser record
  var accountUser =
        getAccountUserByPk(
          nexusCoreContext.db,
          webContext.accountUserId)

  if accountUser == none(AccountUser):

    raise newException(
            ValueError,
            "AccountUser record not found for accountUserId: " &
            $webContext.accountUserId)

  # Update AccountUser.lastToken
  accountUser.get.lastToken = none(string)

  discard updateAccountUserByPk(
            nexusCoreContext.db,
            accountUser.get,
            setFields = @[ "last_token" ])

  # Log out with JWT
  logoutJWT(webContext.request,
            nexusCoreContext.db,
            useCookie = true)

  # Return values as JSON
  let docuiReturn = newDocUIReturn(true)

  return $toJson(docuiReturn)


proc profileJSON*(nexusCoreContext: NexusCoreContext): string =

  let docuiReturn =
        newDocUIReturn(
          false,
          "",
          "unimplemented")

  # Return values as JSON
  return $toJson(docuiReturn)


proc profileJSONPost*(nexusCoreContext: NexusCoreContext): string =

  let docuiReturn =
        newDocUIReturn(
          false,
          "",
          "unimplemented")

  # Return values as JSON
  return $toJson(docuiReturn)


proc resetPasswordRequestJSONPost*(
       nexusCoreContext: NexusCoreContext): string =

  var docuiReturn = resetPasswordRequestAction(nexusCoreContext)

  # Return values as JSON
  return $toJson(docuiReturn)


proc resetPasswordChangeJSONPost*(
       nexusCoreContext: NexusCoreContext): string =

  var docuiReturn = resetPasswordChangeAction(nexusCoreContext)

  # Return values as JSON
  return $toJson(docuiReturn)


proc signUpJSONPost*(nexusCoreContext: NexusCoreContext): string =

  # Sign-up action
  let docuiReturn = signUpAction(nexusCoreContext)

  # Return values as JSON
  return $toJson(docuiReturn)


proc signUpVerifyJSONPost*(nexusCoreContext: NexusCoreContext): string =

  # Verify sign-up
  let docuiReturn = verifySignUpAction(nexusCoreContext)

  # Return values as JSON
  return $toJson(docuiReturn)

