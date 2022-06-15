import db_postgres, options, times
import nexus/core/data_access/account_user_data
import nexus/core/data_access/account_user_role_data
import nexus/core/service/account/encrypt
import nexus/core/types/model_types as nexus_core_model_types
import nexus/core/types/module_globals
import nexus/core_extras/types/model_types
import assign_admin_role


proc getOrCreateAdminUser*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       email: string,
       password: string): AccountUser =

  # Get module
  var nexusCoreModule = NexusCoreModule()

  nexusCoreModule.db = nexusCoreExtrasModule.db

  # Get or create the user account
  var accountUser: Option[AccountUser]

  if existsAccountUserByEmail(
       nexusCoreModule,
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
    accountUser = some(createAccountUser(
                         nexusCoreModule,
                         accountId = none(int64),
                         name = "Admin User",
                         email = email,
                         passwordHash = passwordHash,
                         passwordSalt = salt,
                         apiKey = apiKey,
                         signUpCode = "",
                         signUpDate = now(),
                         passwordResetCode = none(string),
                         password_reset_date = none(DateTime),
                         isActive = true,
                         isAdmin = true,
                         isVerified = true,
                         last_login = none(DateTime),
                         last_update = none(DateTime),
                         created = now()))

  else:
    accountUser =
      getAccountUserByEmail(
        nexusCoreModule,
        email)

  # Verify the user
  accountUser.get.is_active = true
  accountUser.get.isVerified = true

  var rowsUpdated: int64

  rowsUpdated =
    updateAccountUserByPk(
      nexusCoreModule,
      accountUser.get,
      setFields = @[ "is_active",
                     "isVerified" ])

  # Create the Admin role for the user
  assignAdminRole(
    nexusCoreExtrasModule,
    accountUser.get.accountUserId)

  return accountUser.get

