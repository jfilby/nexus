import json, options
import docui/service/sdk/docui_elements
import nexus/core/data_access/account_user_role_data
import nexus/core/types/context_type as nexus_core_context_type
import nexus/core/types/model_types as nexus_core_model_types
import nexus/core_extras/data_access/menu_item_data
import nexus/core_extras/types/context_type
import nexus/core_extras/types/model_types


# Forward declarations
proc verifyMenuItemRoles*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       menuItem: MenuItem,
       accountUserId: int64): bool


# Code
proc loadMenuItems*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       accountUserId: int64,
       excludeMenuURLs: seq[string]):
         seq[JsonNode] =

  # Load from Menu Item in the order it was loaded
  let listItems =
        filterMenuItem(nexusCoreExtrasContext.db,
                       orderByFields = @[ "id" ])

  var menuItemsJsonNodes: seq[JsonNode]

  for menuItem in listItems:

    # Exclude specific menu URLs
    if excludeMenuURLs.contains(menuItem.url):
      continue

    # Check MenuItemRoles
    let verified =
          verifyMenuItemRoles(nexusCoreExtrasContext,
                              menuItem,
                              accountUserId)

    # Add MenuItem
    menuItemsJsonNodes.add(
      menuItem(menuItem.name,
               menuItem.url,
               menuItem.level))

  return menuItemsJsonNodes


proc verifyMenuItemRole(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       roleId: int64,
       accountUserId: int64): bool =

  # Get NexusCoreContext
  let nexusCoreContext =
        NexusCoreContext(
          db: NexusCoreDbContext(
            dbConn: nexusCoreExtrasContext.db.dbConn))

  # Check for AccountUserRole record
  let accountUserRole =
        getAccountUserRoleByAccountUserIdAndRoleId(
          nexusCoreContext.db,
          accountUserId,
          roleId)

  if accountUserRole != none(AccountUserRole):
    return true

  else:
    return false


proc verifyMenuItemRoles*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       menuItem: MenuItem,
       accountUserId: int64): bool =

  # Return true if no rolesIds for the menuItem
  if menuItem.roleIds == none(seq[int64]):
    return true

  # Verify each roleId for the menuItem, for the user
  var verified = true

  for roleId in menuItem.roleIds.get:

    if verifyMenuItemRole(
         nexusCoreExtrasContext,
         roleId,
         accountUserId) == false:

      return false

  return verified

