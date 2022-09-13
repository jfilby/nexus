import options, times
import nexus/core/data_access/account_user_data
import nexus/core/data_access/account_user_role_data
import nexus/core/types/context_type as nexus_core_context_type
import nexus/core/types/model_types as nexus_core_model_types
import nexus/core_extras/service/lists/list_utils
import nexus/core_extras/types/context_type as nexus_core_extras_context_type
import nexus/core_extras/types/model_types
import engine/types/context_type
import admin_role


# Code
proc assignAdminRole*(
       nexusCoreContext: NexusCoreContext,
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       accountUserId: int64) =

  # Get admin user role
  let adminRoleId =
        getAdminRoleId(nexusCoreExtrasContext)

  # Create user/role assignment
  discard getOrCreateAccountUserRoleByAccountUserIdAndRoleId(
            nexusCoreContext.db,
            accountUserId,
            adminRoleId,
            now())


proc assignDefaultAdminRoles*(
       nexusCoreContext: NexusCoreContext,
       nexusCoreExtrasContext: NexusCoreExtrasContext) =

  # Get users that should have the admin role by email
  let accountUsers =
        filterAccountUser(
          nexusCoreContext.db,
          whereFields = @[ "is_admin" ],
          whereValues = @[ $true ])


  # Verify that at least 1 user is returned
  if len(accountUsers) == 0:

    raise newException(ValueError,
                       "Users expected to be found")

  # Assign admin role per user
  for accountUser in accountUsers:

    assignAdminRole(nexusCoreContext,
                    nexusCoreExtrasContext,
                    accountUser.accountUserId)

