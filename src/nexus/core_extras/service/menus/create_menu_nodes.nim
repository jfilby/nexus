import options
import nexus/core_extras/types/model_types
import nexus/core_extras/types/ui_types


# Forward declarations
proc getMenuParentNode(menuItem: MenuItem,
                       menuItems: MenuItems): Option[MenuNode]
proc setParentNodes(rootMenuNode: var MenuNode): MenuNode


# Code
proc createMenuNodes*(parentMenuNode: MenuNode,
                      menuItems: MenuItems): MenuNode =

  # Create menu nodes
  var menuNodes: MenuNodes

  for menuItem in menuItems:

    var menuNode = MenuNode()

    menuNode.name = menuItem.name
    menuNode.url = menuItem.url
    menuNode.screen = menuItem.screen

    menuNodes.add(menuNode)

  # Set parent nodes and return root node
  return setParentNodes(menuNodes)


proc getMenuParentNode(menuNode: MenuNode,
                       menuNodes: MenuNodes): Option[MenuNode] =

  for menuNodeIter in menuNodes:

    if menuNodeIter.name == menuNode.parentItemName:

      return some(menuNodes)

  return none(MenuNode)


proc setParentNodes(menuNodes: var MenuNodes): MenuNode =

  # Root node
  var rootMenuNode: MenuNode

  # Set parent nodes
  for menuNode in menuNodes:

    # Match parent node with parent menu item
    let parentNode = getMenuParentNode(menuNode,
                                       menuNodes)

    # Set parent node
    menuNode.parentNode = parentNode

    # Set root node if no parent found
    if parentNode == none(MenuNode):
      rootMenuNode = menuNode

  # Return
  return rootMenuNode

