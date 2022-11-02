import db_postgres, options, times
import nexus/core/data_access/account_user_data
import nexus/core/data_access/account_user_role_data
import nexus/core/service/account/encrypt
import nexus/core/types/context_type as nexus_core_context_type
import nexus/core/types/model_types as nexus_core_model_types
import nexus/core_extras/types/context_type as nexus_core_extras_context_type
import nexus/core_extras/types/model_types
import engine/types/context_type
import assign_admin_role


proc getOrCreateAdminUser*(
       nexusCoreContext: NexusCoreContext,
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       email: string,
       password: string): AccountUser =

  # Get or create the user account
  var accountUser: Option[AccountUser]

  if existsAccountUserByEmail(
       nexusCoreContext.db,
       email) == false:

    # Get the passwordHash and salt
    var
      passwordHash: string
      salt: string

    (passwordHash,
     salt) = hashPassword(password,
                          inSalt = "")

    let
      apiKey = generateAPIKey()
      signUpCode = generateSignUpCode()

    # Insert into accountUser
    accountUser =
      some(createAccountUser(
             nexusCoreContext.db,
             accountId = none(int64),
             name = "Admin User",
             email = email,
             passwordHash = passwordHash,
             passwordSalt = salt,
             apiKey = apiKey,
             signUpCode = "",
             signUpDate = now(),
             passwordResetCode = none(string),
             passwordResetDate = none(DateTime),
             isActive = true,
             isAdmin = true,
             isVerified = true,
             last_login = none(DateTime),
             last_update = none(DateTime),
             created = now()))

  else:
    accountUser =
      getAccountUserByEmail(
        nexusCoreContext.db,
        email)

  # Verify the user
  accountUser.get.is_active = true
  accountUser.get.isVerified = true

  var rowsUpdated: int64

  rowsUpdated =
    updateAccountUserByPk(
      nexusCoreContext.db,
      accountUser.get,
      setFields = @[ "is_active",
                     "is_verified" ])

  # Create the Admin role for the user
  assignAdminRole(
    nexusCoreContext,
    nexusCoreExtrasContext,
    accountUser.get.accountUserId)

  return accountUser.get

