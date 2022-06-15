import chronicles, jester, json, options
import docui/service/sdk/docui_types
import docui/service/sdk/docui_utils
import nexus/core/data_access/account_user_data
import nexus/core/service/account/jwt_utils
import nexus/core/service/account/login_action
import nexus/core/service/account/reset_password_action
import nexus/core/service/account/sign_up_action
import nexus/core/service/account/verify_sign_up_action
import nexus/core/types/model_types
import nexus/core/types/module_globals
import nexus/core/types/view_types


proc loginJSONPost*(
       request: Request,
       webContext: WebContext): string =

  debug "loginJSONPost(): request",
    body = request.body,
    headers = request.headers

  # Decode JSON
  let jsonRequest = parseJson(request.body)

  # Login action
  let
    docuiReturn = loginAction(request,
                              webContext,
                              some(jsonRequest))

    returnJson = $toJson(docuiReturn)

  # Debug
  debug "loginJSONPost()",
    returnJson = returnJson

  # Return values as JSON
  return returnJson


proc logoutJSON*(
       request: Request,
       webContext: WebContext): string =

  # Get AccountUser record
  var accountUser =
        getAccountUserByPk(
          nexusCoreModule,
          webContext.accountUserId)

  if accountUser == none(AccountUser):

    raise newException(
            ValueError,
            "AccountUser record not found for accountUserId: " &
            $webContext.accountUserId)

  # Update AccountUser.lastToken
  accountUser.get.lastToken = none(string)

  discard updateAccountUserByPk(
            nexusCoreModule,
            accountUser.get,
            setFields = @[ "last_token" ])

  # Log out with JWT
  logoutJWT(request,
            nexusCoreModule,
            useCookie = true)

  # Return values as JSON
  let docuiReturn = newDocUIReturn(true)

  return $toJson(docuiReturn)


proc profileJSON*(
       request: Request,
       webContext: WebContext): string =

  let docuiReturn = newDocUIReturn(false,
                                   "",
                                   "unimplemented")

  # Return values as JSON
  return $toJson(docuiReturn)


proc profileJSONPost*(
       request: Request,
       webContext: WebContext): string =

  let docuiReturn =
        newDocUIReturn(
          false,
          "",
          "unimplemented")

  # Return values as JSON
  return $toJson(docuiReturn)


proc resetPasswordRequestJSONPost*(
       request: Request,
       webContext: WebContext): string =

  var docuiReturn = resetPasswordRequestAction(request)

  # Return values as JSON
  return $toJson(docuiReturn)


proc resetPasswordChangeJSONPost*(
       request: Request,
       webContext: WebContext): string =

  var docuiReturn = resetPasswordChangeAction(request)

  # Return values as JSON
  return $toJson(docuiReturn)


proc signUpJSONPost*(
       request: Request,
       webContext: WebContext): string =

  # Sign-up action
  let docuiReturn = signUpAction(request)

  # Return values as JSON
  return $toJson(docuiReturn)


proc signUpVerifyJSONPost*(
       request: Request,
       webContext: WebContext): string =

  # Verify sign-up
  let docuiReturn = verifySignUpAction(request)

  # Return values as JSON
  return $toJson(docuiReturn)

