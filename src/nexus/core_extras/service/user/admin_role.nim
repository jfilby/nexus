import chronicles, options, times
import nexus/core/data_access/account_user_data
import nexus/core/data_access/account_user_role_data
import nexus/core/types/context_type as nexus_core_context_type
import nexus/core/types/model_types as nexus_core_model_types
import nexus/core_extras/service/lists/list_utils
import nexus/core_extras/types/context_type
import nexus/core_extras/types/model_types


proc getAdminRoleId*(coreExtrasDbContext: NexusCoreExtrasDbContext): string =

  # Get admin user role
  let adminListItemId =
        getListItemIdByParentNameAndDisplayName(
          coreExtrasDbContext,
          "User Roles: Account User",
          "Admin")

  if adminListItemId == none(string):

    raise newException(ValueError,
                       "No ListItem record found for Admin role")

  return adminListItemId.get


proc userHasAdminRole*(
       coreDbContext: NexusCoreDbContext,
       coreExtrasDbContext: NexusCoreExtrasDbContext,
       accountUser: AccountUser): bool =

  # Get adminRoleId
  let adminRoleId = getAdminRoleId(coreExtrasDbContext)

  # Check for user/role
  let accountUserRole =
        getAccountUserRoleByAccountUserIdAndRoleId(
          coreDbContext,
          accountUser.id,
          adminRoleId)

  var hasAdminRole = false

  if accountUserRole != none(AccountUserRole):
    hasAdminRole = true

  info "userHasAdminRole()",
    accountUserId = accountUser.id,
    hasAdminRole = $hasAdminRole

  return hasAdminRole

