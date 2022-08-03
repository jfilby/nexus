import db_postgres, json, tables
import docui/service/sdk/docui_elements
import docui/service/sdk/docui_types
import docui/service/sdk/docui_utils
import nexus/core/data_access/account_user_data
import nexus/core/types/model_types
import verify_account_fields


proc returnForm(children: seq[JsonNode]): JsonNode =

  return form("return",
              "sign_up_form",
              children)


proc verifyPasswordFields*(
       password1: string,
       password2: string): DocUIReturn =

  var errorMessage = ""

  # Verify the password 1
  var docuiReturn = verifyPassword("password1",
                                   password1)

  if docuiReturn.isVerified == false:
    return docuiReturn

  # Verify passwords match
  if password1 != password2:

    errorMessage = "The initial and retyped passwords don't match."

    let form = returnForm(@[
                 fieldError(password1,
                            errorMessage),
                 fieldError(password2,
                            errorMessage) ])

    return newDocUIReturn(false,
                          errorMessage = errorMessage,
                          results = form)

  # Return OK
  return newDocUIReturn(true)


proc verifySignUpFields*(
       nexusCoreDbContext: NexusCoreDbContext,
       name: string,
       email: string,
       password1: string,
       password2: string): DocUIReturn =

  var errorMessage = ""

  # Verify name is specified
  if name == "":

    errorMessage = "Name must be specified."

    let form = returnForm(@[
                 fieldError("name",
                            errorMessage) ])

    return newDocUIReturn(false,
                          errorMessage = errorMessage,
                          results = form)

  # Verify email is specified
  if email == "":

    errorMessage = "Email must be specified."

    let form = returnForm(@[
                 fieldError("email",
                            errorMessage) ])

    return newDocUIReturn(false,
                          errorMessage = errorMessage,
                          results = form)

  # Verify that the email is not already signed up
  let emailExists =
        existsAccountUserByEmail(
          nexusCoreDbContext,
          email)

  if email_exists == true:

    errorMessage = "An account with that email address has already signed up."

    let form = returnForm(@[
                 fieldError("email",
                            errorMessage) ])      

    return newDocUIReturn(false,
                          errorMessage = errorMessage,
                          results = form)

  # Verify email address
  var docuiReturn =
        verifyEmailAddress(
          nexusCoreDbContext,
          email)

  if docuiReturn.isVerified == false:
    return docuiReturn

  # Verify password
  docuiReturn =
    verifyPasswordFields(
      password1,
      password2)

  if docuiReturn.isVerified == false:
    return docuiReturn

  # Return OK
  return newDocUIReturn(true)

