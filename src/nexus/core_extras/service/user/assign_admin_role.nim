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
       coreDbContext: NexusCoreDbContext,
       coreExtrasDbContext: NexusCoreExtrasDbContext,
       accountUserId: string) =

  # Get admin user role
  let adminRoleId =
        getAdminRoleId(coreExtrasDbContext)

  # Create user/role assignment
  discard getOrCreateAccountUserRoleByAccountUserIdAndRoleId(
            coreDbContext,
            accountUserId,
            adminRoleId,
            now())


proc assignDefaultAdminRoles*(
       coreDbContext: NexusCoreDbContext,
       coreExtrasDbContext: NexusCoreExtrasDbContext) =

  # Get users that should have the admin role by email
  let accountUsers =
        filterAccountUser(
          coreDbContext,
          whereFields = @[ "is_admin" ],
          whereValues = @[ $true ])


  # Verify that at least 1 user is returned
  if len(accountUsers) == 0:

    raise newException(ValueError,
                       "Users expected to be found")

  # Assign admin role per user
  for accountUser in accountUsers:

    assignAdminRole(coreDbContext,
                    coreExtrasDbContext,
                    accountUser.id)

