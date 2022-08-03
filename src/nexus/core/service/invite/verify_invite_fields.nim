import chronicles, db_postgres, strutils
import nexus/core/data_access/account_user_data
import nexus/core/data_access/invite_data
import nexus/core/service/account/verify_account_fields
import nexus/core/types/model_types


proc verifyInviteFields*(nexusCoreDbContext: NexusCoreDbContext,
                         from_name: string,
                         from_email: string,
                         to_name: string,
                         to_email: string): (bool, string) =

  var docuiReturn = verifyEmailAddress(nexusCoreDbContext,
                                       from_email,
                                       "From email",
                                       checkExists = false)

  if docuiReturn.isVerified == false:
    return (false,
            docUIReturn.errorMessage)

  # Verify that from_name is not blank
  if from_name == "":
    return (false,
            "From name must be specified.")

  # Verify the to email
  docuiReturn = verifyEmailAddress(nexusCoreDbContext,
                                   to_email,
                                   "To email",
                                   checkExists = false)

  if docuiReturn.isVerified == false:
    return (false,
            docuiReturn.errorMessage)

  # Verify that to_name is not blank
  if from_name == "":
    return (false,
            "To name must be specified.")

  # Verify that the to email hasn't yet had an invite
  let to_email_exists = existsInviteByToEmail(nexusCoreDbContext,
                                              to_email)

  if to_email_exists == true:
    return (false,
            "The email address to send the invite to has already been sent an invite.")

  # Return OK
  return (true, "")

