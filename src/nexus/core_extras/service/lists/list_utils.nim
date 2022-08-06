import chronicles, options, sequtils, strformat, tables
import nexus/core/service/format/type_utils
import nexus/core_extras/data_access/list_item_data
import nexus/core_extras/types/context_type
import nexus/core_extras/types/model_types


# Forward declarations
proc getListItemsByParentListId*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       parentListId: int64): ListItems
proc getListItemsByParentListName*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       parentListName: string): ListItems


# Code
proc getListItemDisplayNames*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       listItemIds: seq[int64]): seq[string] =

  var strs: seq[string]

  for listItemId in listItemIds:

    let listItem =
          getListItemByPk(nexusCoreExtrasContext.db,
                          listItemId)

    strs.add(listItem.get.displayName)

  return strs


proc getListItemDisplayNames*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       listItemIds: Option[seq[int64]]): seq[string] =

  if listItemIds != none(seq[int64]):

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

      if listItem.parentListItemId != none(int64):

        let parentlistItem =
              getListItemByPk(
                nexusCoreExtrasContext.db,
                listItem.parentListItemId.get)

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
      listItemId: int64): ListItems =

  # Filter list items
  let listItems =
        filterListItem(
          nexusCoreExtrasContext.db,
          whereFields = @[ "list_item_id" ],
          whereValues = @[ $listItemId ],
          orderByFields = @[ "list_item_id" ])

  return listItems


proc getListItemsByListItemIds*(
      nexusCoreExtrasContext: NexusCoreExtrasContext,
      listItemIds: seq[int64]): ListItems =

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
       parentListId: int64): ListItems =

  # Filter list items
  return filterListItem(
           nexusCoreExtrasContext.db,
           whereFields = @[ "parent_list_item_id" ],
           whereValues = @[ $parentListId ],
           orderByFields = @[ "list_item_id" ])


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
           parentListItem.get.listItemId)


proc getIdsAndDisplayNames*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       parentListId: int64,
       cascade: bool = false,
       indents: bool = true,
       indent: int = 0):
       (seq[int64],
        seq[string]) =

  # Get categories
  var
    optionIds: seq[int64]
    options: seq[string]

  let listItems =
        getListItemsByParentListId(
          nexusCoreExtrasContext,
          parentListId)

  debug "getIdsAsStringsAndDisplayNames()",
    parentListId = $parentListId,
    lenListItems = $len(listItems)

  for listItem in listItems:

    optionIds.add(listItem.listItemId)
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
              parentListId = listItem.listItemId,
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
       parentListId: int64,
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

    optionIds.add($listItem.listItemId)
    options.add(getIndentByLen(indent) &
                listItem.displayName)

    if cascade == true:

      let (childOptionIds,
           childOptions) =
            getIdsAsStringsAndDisplayNames(
              nexusCoreExtrasContext,
              parentListId = listItem.listItemId,
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

    optionIds.add($listItem.listItemId)
    options.add(listItem.displayName)

    if cascade == true:

      let (childOptionIds,
           childOptions) =
            getIdsAsStringsAndDisplayNames(
              nexusCoreExtrasContext,
              parentListId = listItem.listItemId,
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
       listItemId: int64): seq[int64] =

  var listItemIds = @[ listItemId ]

  let listItems =
        getListItemsByParentListId(
          nexusCoreExtrasContext,
          listItemId)

  for listItem in listItems:

    let listItemIdsToAdd =
          getListItemIdsCascade(
            nexusCoreExtrasContext,
            listItem.listItemId)

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
                         parentListItem.get.listItemId,
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
       displayName: string): Option[int64] =

  let listItem = getListItemByParentNameAndDisplayName(
                   nexusCoreExtrasContext,
                   parentName,
                   displayName)

  if listItem != none(ListItem):

    return some(listItem.get.listItemId)

  # Finally return none
  return none(int64)


proc getListItemIdByParentNameAndDisplayNameCascade*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       parentName: string,
       displayName: string): Option[int64] =

  let listItem = getListItemByParentNameAndDisplayNameCascade(
                   nexusCoreExtrasContext,
                   parentName,
                   displayName)

  if listItem != none(ListItem):

    return some(listItem.get.listItemId)

  # Finally return none
  return none(int64)


proc getListItemDisplayNameById*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       listItemId: int64): Option[string] =

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

    options[$listItem.listItemId] = listItem.displayName

  return options


proc getListItemNames*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       listItemIds: seq[int64]): seq[string] =

  var strs: seq[string]

  for listItemId in listItemIds:

    let listItem =
          getListItemByPk(nexusCoreExtrasContext.db,
                          listItemId)

    strs.add(listItem.get.name)

  return strs


proc getListItemNamesAsString*(
       nexusCoreExtrasContext: NexusCoreExtrasContext,
       listItemIds: seq[int64],
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
       listItemIds: seq[int64],
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
       listItemIds: Option[seq[int64]],
       delimiter: string = "\n",
       prefix: string = "",
       textOnNone: string = "None"):
       (string, int) =

  if listItemIds != none(seq[int64]):

    return getTextAndLinesFromItemListIds(
             nexusCoreExtrasContext,
             listItemIds.get,
             delimiter,
             prefix)

  else:
    return (textOnNone, 0)

