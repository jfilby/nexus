import chronicles, jester, json, options, tables
import db_connector/db_postgres
import docui/service/sdk/docui_elements
import docui/service/sdk/docui_types
import docui/service/sdk/docui_utils
import nexus/core/service/account/encrypt
import nexus/core/types/model_types


proc returnForm(children: seq[JsonNode]): JsonNode =

  return form("return",
              "login_form",
              children)


proc verifyLoginFields*(
       email: string,
       password: string,
       accountUser: Option[AccountUser]):
         (DocUIReturn,
          string,
          string) =

  var
    errorMessage = ""
    docuiReturn = newDocUIReturn(true)
    noAccountUserId = ""

  # Verify that email is not blank
  if email == "":

    errorMessage = "Email address must be specified."

    docUiReturn.isVerified = false
    docUiReturn.results = some(returnForm(@[
                                 fieldError("email",
                                 errorMessage) ]))

    return (docUiReturn,
            noAccountUserId,
            errorMessage)

  # Verify that a row was found (otherwise the email is not found)
  if accountUser.isNone:

    errorMessage = "The email address specified is not found in the system."

    docUiReturn.isVerified = false
    docUiReturn.results = some(returnForm(@[
                                 fieldError("email",
                                 errorMessage) ]))

    return (docUiReturn,
            noAccountUserId,
            errorMessage)

  # Verify that the user is verified in the system
  if accountUser.get.isVerified == false:

    errorMessage = "The user isn't verified in the system."

    docUiReturn.isVerified = false
    docUiReturn.results = some(returnForm(@[
                                 fieldError("email",
                                 errorMessage) ]))

    return (docUiReturn,
            noAccountUserId,
            errorMessage)

  # Verify that the user is active in the system
  if accountUser.get.isActive == false:

    errorMessage = "The user isn't active in the system."

    docUiReturn.isVerified = false
    docUiReturn.results = some(returnForm(@[
                                 fieldError("email",
                                 errorMessage) ]))

    return (docUiReturn,
            noAccountUserId,
            errorMessage)

  # Verify that password is not blank
  if password == "":

    errorMessage = "The password must be specified."

    docUiReturn.isVerified = false
    docUiReturn.results = some(returnForm(@[
                                 fieldError("password",
                                 errorMessage) ]))

    return (docUiReturn,
            noAccountUserId,
            errorMessage)

  # Get the passwordHash for the given password. A stored salt that argon2
  # cannot use makes the hash uncomputable; report it as a failed password
  # rather than raising out of the login handler.
  var
    inPasswordHash = ""
    salt = accountUser.get.passwordSalt

  try:

    (inPasswordHash,
     salt) = hashPassword(password,
                          accountUser.get.passwordSalt)

  except ValueError as e:

    error "verifyLoginFields(): stored password salt is unusable",
      errorMessage = e.msg

    errorMessage = "The password is incorrect."

    docUiReturn.isVerified = false
    docUiReturn.results = some(returnForm(@[
                                 fieldError("password",
                                 errorMessage) ]))

    return (docUiReturn,
            noAccountUserId,
            errorMessage)

  # Verify the passwordHashes match
  if inPasswordHash != accountUser.get.passwordHash:

    errorMessage = "The password is incorrect."

    docUiReturn.isVerified = false
    docUiReturn.results = some(returnForm(@[
                                 fieldError("password",
                                 errorMessage) ]))

    return (docUiReturn,
            noAccountUserId,
            errorMessage)

  # Login OK
  debug "verifyLoginFields(): returning OK"

  return (docUiReturn,
          accountUser.get.id,
          "")

