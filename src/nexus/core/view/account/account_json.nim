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


proc loginJSONPost*(context: NexusCoreContext): string =

  debug "loginJSONPost(): request",
    body = request.body,
    headers = request.headers

  # Validate
  if context.web == none(WebContext):

    raise newException(
            ValueError,
            "context.web == none")

  # Initial vars
  template request: untyped = context.web.get.request

  # Decode JSON
  let jsonRequest = parseJson(request.body)

  # Login action
  let
    docuiReturn =
      loginAction(context,
                  some(jsonRequest))

    returnJson = $toJson(docuiReturn)

  # Debug
  debug "loginJSONPost()",
    returnJson = returnJson

  # Return values as JSON
  return returnJson


proc logoutJSON*(context: NexusCoreContext): string =

  # Validate
  if context.web == none(WebContext):

    raise newException(
            ValueError,
            "context.web == none")

  # Initial vars
  template webContext: untyped = context.web.get

  # Get AccountUser record
  var accountUser =
        getAccountUserByPk(
          context.db,
          webContext.accountUserId)

  if accountUser == none(AccountUser):

    raise newException(
            ValueError,
            "AccountUser record not found for accountUserId: " &
            $webContext.accountUserId)

  # Update AccountUser.lastToken
  accountUser.get.lastToken = none(string)

  discard updateAccountUserByPk(
            context.db,
            accountUser.get,
            setFields = @[ "last_token" ])

  # Log out with JWT
  logoutJWT(webContext.request,
            context.db,
            useCookie = true)

  # Return values as JSON
  let docuiReturn = newDocUIReturn(true)

  return $toJson(docuiReturn)


proc profileJSON*(context: NexusCoreContext): string =

  let docuiReturn =
        newDocUIReturn(
          false,
          "",
          "unimplemented")

  # Return values as JSON
  return $toJson(docuiReturn)


proc profileJSONPost*(context: NexusCoreContext): string =

  let docuiReturn =
        newDocUIReturn(
          false,
          "",
          "unimplemented")

  # Return values as JSON
  return $toJson(docuiReturn)


proc resetPasswordRequestJSONPost*(
       context: NexusCoreContext): string =

  var docuiReturn = resetPasswordRequestAction(context)

  # Return values as JSON
  return $toJson(docuiReturn)


proc resetPasswordChangeJSONPost*(
       context: NexusCoreContext): string =

  var docuiReturn = resetPasswordChangeAction(context)

  # Return values as JSON
  return $toJson(docuiReturn)


proc signUpJSONPost*(context: NexusCoreContext): string =

  # Sign-up action
  let docuiReturn = signUpAction(context)

  # Return values as JSON
  return $toJson(docuiReturn)


proc signUpVerifyJSONPost*(context: NexusCoreContext): string =

  # Verify sign-up
  let docuiReturn = verifySignUpAction(context)

  # Return values as JSON
  return $toJson(docuiReturn)

