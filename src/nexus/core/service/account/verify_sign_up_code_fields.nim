import db_postgres, options, json, tables
import docui/service/sdk/docui_elements
import docui/service/sdk/docui_types
import docui/service/sdk/docui_utils
import nexus/core/data_access/account_user_data
import nexus/core/types/model_types
import verify_account_fields


proc returnForm(children: seq[JsonNode]): JsonNode =

  return form("return",
              "verify_signup_code_form",
              children)


proc verifySignUpCodeFields*(
       nexusCoreDbContext: NexusCoreDbContext,
       email: string,
       signUpCode: string,
       accountUser: Option[AccountUser]): DocUIReturn =

  # Verify email is specified
  if email == "":

    let form = returnForm(@[
                 fieldError("email",
                            "Email must be specified.") ])

    return newDocUIReturn(false,
                          form)

  # Verify email address
  let docuiReturnVerifyEmail =
        verifyEmailAddress(
          nexusCoreDbContext,
          email)

  if docuiReturnVerifyEmail.isVerified == false:
    return docuiReturnVerifyEmail

  # Verify that the email is in the system
  if accountUser == none(AccountUser):

    let form = returnForm(@[
                 fieldError("email",
                            "That email address is not in the system.") ])

    return newDocUIReturn(false,
                          form)

  # sign_up code
  if signUpCode == "":

    let form = returnForm(@[
                 fieldError("signUpCode",
                            "The sign up code must be specified.") ])

    return newDocUIReturn(false,
                          form)

  # Return OK
  return newDocUIReturn(true)

