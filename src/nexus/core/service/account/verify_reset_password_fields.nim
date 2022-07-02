import options, json, tables
import docui/service/sdk/docui_elements
import docui/service/sdk/docui_types
import docui/service/sdk/docui_utils
import nexus/core/data_access/account_user_data
import nexus/core/types/model_types
import send_user_emails, verify_account_fields, verify_sign_up_fields


proc returnForm(children: seq[JsonNode]): JsonNode =

  return form("return",
              "reset_password_form",
              children)


proc verifyResetPasswordRequestFields*(
       email: string,
       accountUser: Option[AccountUser]): DocUIReturn =

  var errorMessage = ""

  # Verify email is specified
  if email == "":

    errorMessage = "Email must be specified."

    let form = returnForm(@[
                 fieldError("email",
                            errorMessage) ])

    return newDocUIReturn(isVerified = false,
                          errorMessage = errorMessage,
                          results = form)

  # Verify that the account exists
  if accountUser == none(AccountUser):

    errorMessage = "An account doesn't exist for the specified email."

    let form = returnForm(@[
                 fieldError("email",
                            errorMessage) ])

    return newDocUIReturn(isVerified = false,
                          errorMessage = errorMessage,
                          results = form)

  # Return OK
  return newDocUIReturn(true)


proc verifyChangePasswordFields*(
       email: string,
       passwordResetCode: string,
       password1: string,
       password2: string,
       accountUser: Option[AccountUser]): DocUIReturn =

  # Verify email is specified
  if email == "":

    let form = returnForm(@[
                 fieldError("email",
                            "Email must be specified.") ])

    return newDocUIReturn(false,
                          form)

  # Verify reset code
  if passwordResetCode == "":

    let form = returnForm(@[
                 fieldError("passwordResetCode",
                            "Please enter the password reset code sent you by email.") ])

    return newDocUIReturn(false,
                          form)

  if accountUser.get.passwordResetCode.get != passwordResetCode:

    let form = returnForm(@[
                 fieldError("passwordResetCode",
                            "Password reset code not as expected.") ])

    return newDocUIReturn(false,
                          form)

  # Verify that the account exists
  if accountUser == none(AccountUser):

    let form = returnForm(@[
                 fieldError("email",
                            "An account doesn't exist for the specified email.") ])

    return newDocUIReturn(false,
                          form)

  # Verify password
  let docuiReturn =
        verifyPasswordFields(
          password1,
          password2)

  if docuiReturn.isVerified == false:

    return docuiReturn

  # Return OK
  return newDocUIReturn(true)

