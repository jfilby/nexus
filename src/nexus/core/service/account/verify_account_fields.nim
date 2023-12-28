import chronicles, json, strformat, strutils, tables
import db_connector/db_postgres
import docui/service/sdk/docui_elements
import docui/service/sdk/docui_types
import docui/service/sdk/docui_utils
import nexus/core/data_access/account_user_data
import nexus/core/types/model_types


proc returnForm(children: seq[JsonNode]): JsonNode =

  return form("return",
              "account_form",
              children)


proc verifyEmailAddress*(
       dbContext: NexusCoreDbContext,
       email: string,
       emailFieldName: string = "Email address",
       checkExists: bool = false): DocUIReturn =

  var errorMessage = ""

  # Verify that email is not blank
  if email == "":

    errorMessage = &"{emailFieldName} must be specified."

    let form = returnForm(@[
                 fieldError("email",
                            errorMessage) ])

    return newDocUIReturn(false,
                          errorMessage = errorMessage,
                          results = form)

  # Locate the position of the @ symbol
  let atPos = find(email,
                   "@")

  # Does the email address have an @ symbol? Fail if it doesn't.
  if atPos == -1:

    errorMessage = "Emails must contain an @ symbol."

    let form = returnForm(@[
                 fieldError("email",
                            errorMessage) ])

    return newDocUIReturn(false,
                          errorMessage = errorMessage,
                          results = form)

  # Does the email address have at least one position before the @ symbol? Fail if it doesn't.
  if at_pos == 0:

    errorMessage = "Emails must contain a username before the @ symbol."

    let form = returnForm(@[
                 fieldError("email",
                            errorMessage) ])

    return newDocUIReturn(false,
                          errorMessage = errorMessage,
                          results = form)

  # Does the email address have a dot one position after the @ symbol? Fail if it doesn't.
  if find(email,
          ".",
          at_pos + 1) == -1:

    errorMessage = "Emails must contain a domain name after the @ symbol, which must contain a dot."

    let form = returnForm(@[
                 fieldError("email",
                            errorMessage) ])

    return newDocUIReturn(false,
                          errorMessage = errorMessage,
                          results = form)

  # Does the email address have a space? Fail if it does.
  if find(email,
          " ") >= 0:

    errorMessage = "No spaces are allowed within the email address."

    let form = returnForm(@[
                 fieldError("email",
                            errorMessage) ])

    return newDocUIReturn(false,
                          errorMessage = errorMessage,
                          results = form)

  # Verify that the email address doesn't already exist in the account table
  if checkExists == true:
    if existsAccountUserByEmail(dbContext,
                                email) == true:

      var errorMessage = "The email specified already exists for a user in the system."

      let form = returnForm(@[
                   fieldError("email",
                              errorMessage) ])

      return newDocUIReturn(false,
                            errorMessage = errorMessage,
                            results = form)

  # Return OK
  return newDocUIReturn(true)


proc verifyPassword*(fieldName: string,
                     password: string): DocUIReturn =

  var errorMessage = ""

  # Is the password long enough?
  if len(password) < 10:

    errorMessage = "The password must be at least 10 characters in length."

    let form = returnForm(@[
                 fieldError(fieldName,
                            errorMessage) ])

    return newDocUIReturn(false,
                          errorMessage = errorMessage,
                          results = form)

  # Is there at least one lowercase alpha char?
  var passed = false

  for c in password:

    if isLowerAscii(c) == true:
      passed = true
      break

  if passed == false:

    errorMessage = "The password must contain at least 1 lowercase character."

    let form = returnForm(@[
                 fieldError(fieldName,
                            errorMessage) ])

    return newDocUIReturn(false,
                          errorMessage = errorMessage,
                          results = form)

  # Is there at least one uppercase alpha char?
  passed = false

  for c in password:

    if isUpperAscii(c) == true:
      passed = true
      break

  if passed == false:

    errorMessage = "The password must contain at least 1 uppercase character."

    let form = returnForm(@[
                 fieldError(fieldName,
                            errorMessage) ])

    return newDocUIReturn(false,
                          errorMessage = errorMessage,
                          results = form)

  # Is there at least one numeric char?
  passed = false

  for c in password:

    if isDigit(c) == true:
      passed = true
      break

  if passed == false:

    errorMessage = "The password must contain at least 1 numeric character."

    let form = returnForm(@[
                 fieldError(fieldName,
                            errorMessage) ])

    return newDocUIReturn(false,
                          errorMessage = errorMessage,
                          results = form)

  # Return OK
  return newDocUIReturn(true)

