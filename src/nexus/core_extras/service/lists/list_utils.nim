import chronicles, options, sequtils, strformat, tables
import nexus/core/service/format/type_utils
import nexus/core_extras/data_access/list_item_data
import nexus/core_extras/types/context_type
import nexus/core_extras/types/model_types


# Forward declarations
proc getListItemsByParentListId*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       parentListId: string): ListItems
proc getListItemsByParentListName*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       parentListName: string): ListItems


# Code
proc getListItemDisplayNames*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       listItemIds: seq[string]): seq[string] =

  var strs: seq[string]

  for listItemId in listItemIds:

    let listItem =
          getListItemByPk(nexusCoreExtrasContext.db,
                          listItemId)

    strs.add(listItem.get.displayName)

  return strs


proc getListItemDisplayNames*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       listItemIds: Option[seq[string]]): seq[string] =

  if listItemIds != none(seq[string]):

    getListItemDisplayNames(
      nexusCoreExtrasContext,
      listItemIds.get)

  else:
    return @[]


proc getListItemByNameAndParentName*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       listName: string,
       parentListName: Option[string]): ListItem =

  var listItems: ListItems

  listItems = filterListItem(
                nexusCoreExtrasContext.db,
                whereFields = @[ "name" ],
                whereValues = @[ listName ])

  if parentListName != none(string):

    var filteredListItems: ListItems

    for listItem in listItems:

      if listItem.parentId != none(string):

        let parentlistItem =
              getListItemByPk(
                nexusCoreExtrasContext.db,
                listItem.parentId.get)

        if parentlistItem != none(ListItem):
          filteredListItems.add(listItem)

    listItems = filteredListItems

  # Validate
  if len(listItems) == 0:
    raise newException(ValueError,
                       "len(listItems) == 0")

  elif len(listItems) > 1:
    raise newException(ValueError,
                       "len(listItems) > 1")

  # Return
  return listItems[0]


proc getListItemsByListItemId*(
      nexusCoreExtrasContext: NexusCoreExtrasContext,
      listItemId: string): ListItems =

  # Filter list items
  let listItems =
        filterListItem(
          nexusCoreExtrasContext.db,
          whereFields = @[ "list_item_id" ],
          whereValues = @[ $listItemId ],
          orderByFields = @[ "display_name" ])

  return listItems


proc getListItemsByListItemIds*(
      nexusCoreExtrasContext: NexusCoreExtrasContext,
      listItemIds: seq[string]): ListItems =

  var listItems: ListItems

  for listItemId in listItemIds:

    let listItem =
          getListItemByPk(
            nexusCoreExtrasContext.db,
            listItemId)

    if listItem == none(ListItem):

      raise newException(
              ValueError,
              "ListItem record not found for listItemId: " &
              $listItemId)

    listItems.add(listItem.get)

  return listItems


proc getListItemsByParentListId*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       parentListId: string): ListItems =

  # Filter list items
  return filterListItem(
           nexusCoreExtrasContext.db,
           whereFields = @[ "parent_id" ],
           whereValues = @[ $parentListId ],
           orderByFields = @[ "display_name" ])


proc getListItemsByParentListName*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       parentListName: string): ListItems =

  # Get list id
  let parentListItem =
        getListItemByName(
          nexusCoreExtrasContext.db,
          parentListName)

  if parentListItem == none(ListItem):

    raise newException(
            ValueError,
            &"List not found for name: \"{parentListName}\"")

  # Filter list items
  return getListItemsByParentListId(
           nexusCoreExtrasContext,
           parentListItem.get.id)


proc getIdsAndDisplayNames*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       parentListId: string,
       cascade: bool = false,
       indents: bool = true,
       indent: int = 0):
       (seq[string],
        seq[string]) =

  # Get categories
  var
    optionIds: seq[string]
    options: seq[string]

  let listItems =
        getListItemsByParentListId(
          nexusCoreExtrasContext,
          parentListId)

  debug "getIdsAsStringsAndDisplayNames()",
    parentListId = $parentListId,
    lenListItems = $len(listItems)

  for listItem in listItems:

    optionIds.add(listItem.id)
    options.add(getIndentByLen(indent) &
                listItem.displayName)

    if cascade == true:

      var newIndent = 0

      if indents == true:
        newIndent = indent + 2

      let (childOptionIds,
           childOptions) =
            getIdsAndDisplayNames(
              nexusCoreExtrasContext,
              parentListId = listItem.id,
              cascade,
              indents,
              newIndent)

      optionIds = concat(optionIds,
                         childOptionIds)

      options = concat(options,
                       childOptions)

  return (optionIds,
          options)


proc getIdsAsStringsAndDisplayNames*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       parentListId: string,
       cascade: bool = false,
       indent: int = 0):
       (seq[string],
        seq[string]) =

  # Get categories
  var
    optionIds: seq[string]
    options: seq[string]

  let listItems =
        getListItemsByParentListId(
          nexusCoreExtrasContext,
          parentListId)

  debug "getIdsAsStringsAndDisplayNames()",
    parentListId = $parentListId,
    lenListItems = $len(listItems)

  for listItem in listItems:

    optionIds.add($listItem.id)
    options.add(getIndentByLen(indent) &
                listItem.displayName)

    if cascade == true:

      let (childOptionIds,
           childOptions) =
            getIdsAsStringsAndDisplayNames(
              nexusCoreExtrasContext,
              parentListId = listItem.id,
              cascade,
              indent + 2)

      optionIds = concat(optionIds,
                         childOptionIds)

      options = concat(options,
                       childOptions)

  return (optionIds,
          options)


proc getIdsAsStringsAndDisplayNames*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       parentListName: string,
       cascade: bool = false,
       indent: int = 0):
       (seq[string],
        seq[string]) =

  # Get categories
  var
    optionIds: seq[string]
    options: seq[string]

  let listItems =
        getListItemsByParentListName(
          nexusCoreExtrasContext,
          parentListName)

  for listItem in listItems:

    optionIds.add($listItem.id)
    options.add(listItem.displayName)

    if cascade == true:

      let (childOptionIds,
           childOptions) =
            getIdsAsStringsAndDisplayNames(
              nexusCoreExtrasContext,
              parentListId = listItem.id,
              cascade,
              indent + 4)

      optionIds = concat(optionIds,
                         childOptionIds)

      options = concat(options,
                       childOptions)

  return (optionIds,
          options)


proc getListItemIdsCascade*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       listItemId: string): seq[string] =

  var listItemIds = @[ listItemId ]

  let listItems =
        getListItemsByParentListId(
          nexusCoreExtrasContext,
          listItemId)

  for listItem in listItems:

    let listItemIdsToAdd =
          getListItemIdsCascade(
            nexusCoreExtrasContext,
            listItem.id)

    listItemIds.add(listItemIdsToAdd)

  return listItemIds


proc getListItemByParentNameAndDisplayName*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       parentName: string,
       displayName: string): Option[ListItem] =

  # Get ListItems by parent name
  let listItems =
        getListItemsByParentListName(
          nexusCoreExtrasContext,
          parentName)

  debug "getListItemByParentNameAndDisplayName()",
    lenListItems = len(listItems)

  # Return the matching id for the display name
  for listItem in listItems:

    if listItem.displayName == displayName:

      return some(listItem)

  # Finally return none
  return none(ListItem)


proc getListItemByParentNameAndDisplayNameCascade*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       parentName: string,
       displayName: string): Option[ListItem] =

  # Get ListItems by parent name
  let parentListItem =
        getListItemByName(
          nexusCoreExtrasContext.db,
          parentName)

  # Return the matching id for the display name
  let (ids,
       displayNames) = getIdsAndDisplayNames(
                         nexusCoreExtrasContext,
                         parentListItem.get.id,
                         indents = false,
                         cascade = true)

  debug "getListItemByParentNameAndDisplayNameCascade()",
    ids = ids,
    displayNames = displayNames

  for i in 0 .. len(ids) - 1:

    if displayNames[i] == displayName:

      let listItem =
            getListItemByPk(
              nexusCoreExtrasContext.db,
              ids[i])

      return listItem

  # Finally return none
  return none(ListItem)


proc getListItemIdByParentNameAndDisplayName*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       parentName: string,
       displayName: string): Option[string] =

  let listItem = getListItemByParentNameAndDisplayName(
                   nexusCoreExtrasContext,
                   parentName,
                   displayName)

  if listItem != none(ListItem):

    return some(listItem.get.id)

  # Finally return none
  return none(string)


proc getListItemIdByParentNameAndDisplayNameCascade*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       parentName: string,
       displayName: string): Option[string] =

  let listItem = getListItemByParentNameAndDisplayNameCascade(
                   nexusCoreExtrasContext,
                   parentName,
                   displayName)

  if listItem != none(ListItem):

    return some(listItem.get.id)

  # Finally return none
  return none(string)


proc getListItemDisplayNameById*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       listItemId: string): Option[string] =

  let listItem =
        getListItemByPk(nexusCoreExtrasContext.db,
                        listItemId)

  if listItem == none(ListItem):
    return none(string)

  return some(listItem.get.displayName)


proc getListItemIdAsStringAndDisplayNameMap*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       parentListName: string):
         OrderedTable[string, string] =

  # Get categories
  var
    options: OrderedTable[string, string]

  let listItems =
        getListItemsByParentListName(
          nexusCoreExtrasContext,
          parentListName)

  for listItem in listItems:

    options[$listItem.id] = listItem.displayName

  return options


proc getListItemNames*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       listItemIds: seq[string]): seq[string] =

  var strs: seq[string]

  for listItemId in listItemIds:

    let listItem =
          getListItemByPk(nexusCoreExtrasContext.db,
                          listItemId)

    strs.add(listItem.get.name)

  return strs


proc getListItemNamesAsString*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       listItemIds: seq[string],
       display_names: bool = false): string =

  # If no list items
  if len(listItemIds) == 0:
    return "None"

  # Where clause for filter query
  var
    first = true
    whereClause = "list_item_id in ("
    whereValues: seq[string]

  for list_itemId in list_itemIds:

    if first == false:
      whereClause &= ", "

    else:
      first = false

    whereClause &= "?"
    whereValues.add($listItemId)

  whereClause &= ")"

  debug "getListItemNamesAsString()",
    whereClause = whereClause,
    whereValues = whereValues

  # Get list items as a string
  let listItems =
        filterListItem(
          nexusCoreExtrasContext.db,
          whereClause,
          whereValues,
          orderByFields = @[ "list_item_id" ])

  # Join the names
  var str = ""

  first = true

  for listItem in listItems:

    if first == false:
      str &= ", "
    else:
      first = false

    if display_names == false:
      str &= list_item.name
    else:
      str &= list_item.display_name

  # Return
  return str


proc getTextAndLinesFromItemListIds*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       listItemIds: seq[string],
       delimiter: string = "\n",
       prefix: string = ""):
       (string, int) =

  let strs = getListItemDisplayNames(
               nexusCoreExtrasContext,
               listItemIds)

  var
    first = true
    text = ""

  for str in strs:

    if first == false:
      text &= delimiter

    else:
      first = false

    text &= prefix & str

  return (text,
          len(strs))


proc getTextAndLinesFromItemListIds*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       listItemIds: Option[seq[string]],
       delimiter: string = "\n",
       prefix: string = "",
       textOnNone: string = "None"):
       (string, int) =

  if listItemIds != none(seq[string]):

    return getTextAndLinesFromItemListIds(
             nexusCoreExtrasContext,
             listItemIds.get,
             delimiter,
             prefix)

  else:
    return (textOnNone, 0)

