import chronicles, options, times
import nexus/core/data_access/account_user_data
import nexus/core/data_access/account_user_role_data
import nexus/core/types/context_type as nexus_core_context_type
import nexus/core/types/model_types as nexus_core_model_types
import nexus/core_extras/service/lists/list_utils
import nexus/core_extras/types/context_type
import nexus/core_extras/types/model_types


proc getAdminRoleId*(nexusCoreExtrasContext: NexusCoreExtrasContext): int64 =

  # Get admin user role
  let adminListItemId =
        getListItemIdByParentNameAndDisplayName(
          nexusCoreExtrasContext,
          "User Roles: Account User",
          "Admin")

  if adminListItemId == none(int64):

    raise newException(ValueError,
                       "No ListItem record found for Admin role")

  return adminListItemId.get


proc userHasAdminRole*(
       context: NexusCoreContext,
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       accountUser: AccountUser): bool =

  # Get adminRoleId
  let adminRoleId = getAdminRoleId(nexusCoreExtrasContext)

  # Check for user/role
  let accountUserRole =
        getAccountUserRoleByAccountUserIdAndRoleId(
          context.db,
          accountUser.accountUserId,
          adminRoleId)

  var hasAdminRole = false

  if accountUserRole != none(AccountUserRole):
    hasAdminRole = true

  info "userHasAdminRole()",
    accountUserId = accountUser.accountUserId,
    hasAdminRole = $hasAdminRole

  return hasAdminRole

