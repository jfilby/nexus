import chronicles, db_postgres, strutils
import nexus/core/data_access/account_user_data
import nexus/core/data_access/invite_data
import nexus/core/service/account/verify_account_fields
import nexus/core/types/model_types


proc verifyInviteFields*(
       dbContext: NexusCoreDbContext,
       fromName: string,
       fromEmail: string,
       toName: string,
       toEmail: string): (bool, string) =

  var docuiReturn =
        verifyEmailAddress(
          dbContext,
          fromEmail,
          "From email",
          checkExists = false)

  if docuiReturn.isVerified == false:
    return (false,
            docUIReturn.errorMessage)

  # Verify that fromName is not blank
  if fromName == "":
    return (false,
            "From name must be specified.")

  # Verify the to email
  docuiReturn =
    verifyEmailAddress(
      dbContext,
      toEmail,
      "To email",
      checkExists = false)

  if docuiReturn.isVerified == false:
    return (false,
            docuiReturn.errorMessage)

  # Verify that toName is not blank
  if fromName == "":
    return (false,
            "To name must be specified.")

  # Verify that the to email hasn't yet had an invite
  let toEmail_exists =
        existsInviteByToEmail(
          dbContext,
          toEmail)

  if toEmail_exists == true:
    return (false,
            "The email address to send the invite to has already been sent an invite.")

  # Return OK
  return (true, "")

