import chronicles, db_postgres, os, streams, strformat, times, yaml
import nexus/core/service/format/type_utils
import nexus/core_extras/data_access/menu_item_data
import nexus/core_extras/service/lists/list_utils
import nexus/core_extras/types/context_type
import nexus/core_extras/types/model_types


# Types
type
  MenuRoleYAML = object
    roleType: string
    roleNames: seq[string]


  MenuRolesYAML = seq[MenuRoleYAML]


  MenuYAML* = object
    name*: string
    url*: string
    screen*: string
    roles*: MenuRolesYAML
    items*: seq[MenuYAML]


  MenusYAML* = seq[MenuYAML]


# Forward declarations
proc loadMenuYAML*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       filename: string)
proc loadMenusYAML(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       parentMenuItemId: Option[int64],
       menusYAML: MenusYAML,
       level: int)


# Code
proc loadMenuFiles*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       path: string) =

  for kind, filename in walkDir(path,
                                relative = true):

    if kind == pcFile and
       filename[0] != '.':
    
      loadMenuYAML(nexusCoreExtrasContext,
                   &"{path}{DirSep}{filename}")


proc truncateAndLoadMenuFiles*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       dataLoadPath: string,
       truncate: bool = false) =

  # Truncate
  if truncate == true:

    truncateMenuItem(nexusCoreExtrasContext.db)

  # Load files
  info "truncateAndLoadMenuFiles()",
    dataLoadPath = dataLoadPath

  loadMenuFiles(nexusCoreExtrasContext,
                dataLoadPath)


proc loadMenuYAML*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       filename: string) =

  info "loadMenuYAML()",
    filename = filename

  # Load YAML
  var
    menusYAML: MenusYAML
    s = newFileStream(filename)

  load(s, menusYAML)
  s.close()

  # Create menu items
  loadMenusYAML(nexusCoreExtrasContext,
                none(int64),
                menusYAML,
                level = 1)


proc loadMenusYAML(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       parentMenuItemId: Option[int64],
       menusYAML: MenusYAML,
       level: int) =

  var position = 1

  for menuYAML in menusYAML:

    info "loadMenusYAML()",
      menuYAML = menuYAML

    # Get role ids
    var roleIds: seq[int64]

    for menuRoleYAML in menuYAML.roles:

      for roleName in menuRoleYAML.roleNames:

        let roleListItemId =
              getListItemIdByParentNameAndDisplayName(
                nexusCoreExtrasContext,
                &"User Roles: {menuRoleYAML.roleType}",
                roleName)

        roleIds.add(roleListItemId.get)

    # Create menu
    let menu = getOrCreateMenuItemByNameAndURLAndScreen(
                 nexusCoreExtrasContext.db,
                 parentMenuItemId,
                 menuYAML.name,
                 menuYAML.url,
                 menuYAML.screen,
                 level,
                 position,
                 int64sWithOption(roleIds),
                 now())

    # Create menu items
    loadMenusYAML(nexusCoreExtrasContext,
                  some(menu.menu_itemId),
                  menuYaml.items,
                  level = level + 1)

    # Inc position
    position += 1

