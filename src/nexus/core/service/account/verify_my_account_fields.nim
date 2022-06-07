import db_postgres
import docui/service/sdk/docui_types
import docui/service/sdk/docui_utils
import nexus/core/types/model_types
import verify_account_fields


proc verifyMyAccountFields*(nexusCoreModule: NexusCoreModule,
                            name: string,
                            email: string,
                            password1: string,
                            password2: string): DocUIReturn =

  var
    verified: bool
    errorMessage: string

  # Verify first name
  if name == "":
    return newDocUIReturn(
             false,
             errorMessage = "Name must be specified.")

  # Verify email address
  if password1 != "" and
     password2 != "":

    var docUIReturn: DocUIReturn

    docUIReturn =
      verifyEmailAddress(
        nexusCoreModule,
        email)

    if docUIReturn.isVerified == false:
      return docUIReturn

    # Verify password
    docUIReturn = verifyPassword("password1",
                                 password1)

    if docUIReturn.isVerified == false:
      return docUIReturn

    # Verify passwords match
    if password1 != password2:

      return newDocUIReturn(
               false,
               errorMessage = "The initial and retyped passwords don't match.")

  # Return OK
  return newDocUIReturn(true)

