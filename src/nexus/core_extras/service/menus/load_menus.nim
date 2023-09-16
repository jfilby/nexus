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
       dbContext: NexusCoreExtrasDbContext,
       filename: string)
proc loadMenusYAML(
       dbContext: NexusCoreExtrasDbContext,
       parentMenuItemId: Option[string],
       menusYAML: MenusYAML,
       level: int)


# Code
proc loadMenuFiles*(
       dbContext: NexusCoreExtrasDbContext,
       path: string) =

  for kind, filename in walkDir(path,
                                relative = true):

    if kind == pcFile and
       filename[0] != '.':
    
      loadMenuYAML(dbContext,
                   &"{path}{DirSep}{filename}")


proc truncateAndLoadMenuFiles*(
       dbContext: NexusCoreExtrasDbContext,
       dataLoadPath: string,
       truncate: bool = false) =

  # Truncate
  if truncate == true:

    truncateMenuItem(dbContext)

  # Load files
  info "truncateAndLoadMenuFiles()",
    dataLoadPath = dataLoadPath

  loadMenuFiles(dbContext,
                dataLoadPath)


proc loadMenuYAML*(
       dbContext: NexusCoreExtrasDbContext,
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
  loadMenusYAML(dbContext,
                none(string),
                menusYAML,
                level = 1)


proc loadMenusYAML(
       dbContext: NexusCoreExtrasDbContext,
       parentMenuItemId: Option[string],
       menusYAML: MenusYAML,
       level: int) =

  var position = 1

  for menuYAML in menusYAML:

    info "loadMenusYAML()",
      menuYAML = menuYAML

    # Get role ids
    var roleIds: seq[string]

    for menuRoleYAML in menuYAML.roles:

      for roleName in menuRoleYAML.roleNames:

        let roleListItemId =
              getListItemIdByParentNameAndDisplayName(
                dbContext,
                &"User Roles: {menuRoleYAML.roleType}",
                roleName)

        roleIds.add(roleListItemId.get)

    # Create menu
    let menuItem =
          getOrCreateMenuItemByNameAndURLAndScreen(
            dbContext,
            parentMenuItemId,
            menuYAML.name,
            menuYAML.url,
            menuYAML.screen,
            level,
            position,
            stringsWithOption(roleIds),
            now())

    # Create menu items
    loadMenusYAML(dbContext,
                  some(menuItem.id),
                  menuYaml.items,
                  level = level + 1)

    # Inc position
    position += 1

