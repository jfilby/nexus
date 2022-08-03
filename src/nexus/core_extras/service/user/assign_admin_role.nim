import options, times
import nexus/core/data_access/account_user_data
import nexus/core/data_access/account_user_role_data
import nexus/core/types/model_types as nexus_core_model_types
import nexus/core_extras/service/lists/list_utils
import nexus/core_extras/types/model_types
import admin_role


# Code
proc assignAdminRole*(nexusCoreExtrasModule: NexusCoreExtrasModule,
                      accountUserId: int64) =

  # Get NexusCoreDbContext
  let nexusCoreDbContext = NexusCoreDbContext(db: nexusCoreExtrasModule.db)

  # Get admin user role
  let adminRoleId = getAdminRoleId(nexusCoreExtrasModule)

  # Create user/role assignment
  discard getOrCreateAccountUserRoleByAccountUserIdAndRoleId(
            nexusCoreDbContext,
            accountUserId,
            adminRoleId,
            now())


proc assignDefaultAdminRoles*(
       nexusCoreExtrasModule: NexusCoreExtrasModule) =

  # Get NexusCoreDbContext
  let nexusCoreDbContext =
        NexusCoreDbContext(db: nexusCoreExtrasModule.db)

  # Get users that should have the admin role by email
  let accountUsers =
        filterAccountUser(
          nexusCoreDbContext,
          whereFields = @[ "is_admin" ],
          whereValues = @[ $true ])


  # Verify that at least 1 user is returned
  if len(accountUsers) == 0:

    raise newException(ValueError,
                       "Users expected to be found")

  # Assign admin role per user
  for accountUser in accountUsers:

    assignAdminRole(nexusCoreExtrasModule,
                    accountUser.accountUserId)

