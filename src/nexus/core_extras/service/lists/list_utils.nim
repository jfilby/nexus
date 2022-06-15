import chronicles, options, sequtils, strformat, tables
import nexus/core/service/format/type_utils
import nexus/core_extras/data_access/list_item_data
import nexus/core_extras/types/model_types


# Forward declarations
proc getListItemsByParentListId*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       parentListId: int64): ListItems
proc getListItemsByParentListName*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       parentListName: string): ListItems


# Code
proc getListItemDisplayNames*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       listItemIds: seq[int64]): seq[string] =

  var strs: seq[string]

  for listItemId in listItemIds:

    let listItem = getListItemByPk(nexusCoreExtrasModule,
                                   listItemId)

    strs.add(listItem.get.displayName)

  return strs


proc getListItemDisplayNames*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       listItemIds: Option[seq[int64]]): seq[string] =

  if listItemIds != none(seq[int64]):

    getListItemDisplayNames(
      nexusCoreExtrasModule,
      listItemIds.get)

  else:
    return @[]


proc getListItemByNameAndParentName*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       listName: string,
       parentListName: Option[string]): ListItem =

  var listItems: ListItems

  listItems = filterListItem(
                nexusCoreExtrasModule,
                whereFields = @[ "name" ],
                whereValues = @[ listName ])

  if parentListName != none(string):

    var filteredListItems: ListItems

    for listItem in listItems:

      if listItem.parentListItemId != none(int64):

        let parentlistItem = getListItemByPk(
                               nexusCoreExtrasModule,
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
      nexusCoreExtrasModule: NexusCoreExtrasModule,
      listItemId: int64): ListItems =

  # Filter list items
  let listItems =
    filterListItem(nexusCoreExtrasModule,
                   whereFields = @[ "list_item_id" ],
                   whereValues = @[ $listItemId ],
                   orderByFields = @[ "list_item_id" ])

  return listItems


proc getListItemsByListItemIds*(
      nexusCoreExtrasModule: NexusCoreExtrasModule,
      listItemIds: seq[int64]): ListItems =

  var listItems: ListItems

  for listItemId in listItemIds:

    let listItem =
          getListItemByPk(
            nexusCoreExtrasModule,
            listItemId)

    if listItem == none(ListItem):

      raise newException(
              ValueError,
              "ListItem record not found for listItemId: " &
              $listItemId)

    listItems.add(listItem.get)

  return listItems


proc getListItemsByParentListId*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       parentListId: int64): ListItems =

  # Filter list items
  return filterListItem(
           nexusCoreExtrasModule,
           whereFields = @[ "parent_list_item_id" ],
           whereValues = @[ $parentListId ],
           orderByFields = @[ "list_item_id" ])


proc getListItemsByParentListName*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       parentListName: string): ListItems =

  # Get list id
  let parentListItem = getListItemByName(nexusCoreExtrasModule,
                                         parentListName)

  if parentListItem == none(ListItem):

    raise newException(
            ValueError,
            &"List not found for name: \"{parentListName}\"")

  # Filter list items
  return getListItemsByParentListId(
           nexusCoreExtrasModule,
           parentListItem.get.listItemId)


proc getIdsAndDisplayNames*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
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

  let listItems = getListItemsByParentListId(
                    nexusCoreExtrasModule,
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
              nexusCoreExtrasModule,
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
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       parentListId: int64,
       cascade: bool = false,
       indent: int = 0):
       (seq[string],
        seq[string]) =

  # Get categories
  var
    optionIds: seq[string]
    options: seq[string]

  let listItems = getListItemsByParentListId(
                    nexusCoreExtrasModule,
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
              nexusCoreExtrasModule,
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
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       parentListName: string,
       cascade: bool = false,
       indent: int = 0):
       (seq[string],
        seq[string]) =

  # Get categories
  var
    optionIds: seq[string]
    options: seq[string]

  let listItems = getListItemsByParentListName(
                    nexusCoreExtrasModule,
                    parentListName)

  for listItem in listItems:

    optionIds.add($listItem.listItemId)
    options.add(listItem.displayName)

    if cascade == true:

      let (childOptionIds,
           childOptions) =
            getIdsAsStringsAndDisplayNames(
              nexusCoreExtrasModule,
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
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       listItemId: int64): seq[int64] =

  var listItemIds = @[ listItemId ]

  let listItems =
        getListItemsByParentListId(
          nexusCoreExtrasModule,
          listItemId)

  for listItem in listItems:

    let listItemIdsToAdd =
          getListItemIdsCascade(
            nexusCoreExtrasModule,
            listItem.listItemId)

    listItemIds.add(listItemIdsToAdd)

  return listItemIds


proc getListItemByParentNameAndDisplayName*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       parentName: string,
       displayName: string): Option[ListItem] =

  # Get ListItems by parent name
  let listItems =
        getListItemsByParentListName(
          nexusCoreExtrasModule,
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
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       parentName: string,
       displayName: string): Option[ListItem] =

  # Get ListItems by parent name
  let parentListItem =
        getListItemByName(
          nexusCoreExtrasModule,
          parentName)

  # Return the matching id for the display name
  let (ids,
       displayNames) = getIdsAndDisplayNames(
                         nexusCoreExtrasModule,
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
              nexusCoreExtrasModule,
              ids[i])

      return listItem

  # Finally return none
  return none(ListItem)


proc getListItemIdByParentNameAndDisplayName*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       parentName: string,
       displayName: string): Option[int64] =

  let listItem = getListItemByParentNameAndDisplayName(
                   nexusCoreExtrasModule,
                   parentName,
                   displayName)

  if listItem != none(ListItem):

    return some(listItem.get.listItemId)

  # Finally return none
  return none(int64)


proc getListItemIdByParentNameAndDisplayNameCascade*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       parentName: string,
       displayName: string): Option[int64] =

  let listItem = getListItemByParentNameAndDisplayNameCascade(
                   nexusCoreExtrasModule,
                   parentName,
                   displayName)

  if listItem != none(ListItem):

    return some(listItem.get.listItemId)

  # Finally return none
  return none(int64)


proc getListItemDisplayNameById*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       listItemId: int64): Option[string] =

  let listItem = getListItemByPk(nexusCoreExtrasModule,
                                  listItemId)

  if listItem == none(ListItem):
    return none(string)

  return some(listItem.get.displayName)


proc getListItemIdAsStringAndDisplayNameMap*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       parentListName: string):
         OrderedTable[string, string] =

  # Get categories
  var
    options: OrderedTable[string, string]

  let listItems = getListItemsByParentListName(
                    nexusCoreExtrasModule,
                    parentListName)

  for listItem in listItems:

    options[$listItem.listItemId] = listItem.displayName

  return options


proc getListItemNames*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       listItemIds: seq[int64]): seq[string] =

  var strs: seq[string]

  for listItemId in listItemIds:

    let listItem = getListItemByPk(nexusCoreExtrasModule,
                                   listItemId)

    strs.add(listItem.get.name)

  return strs


proc getListItemNamesAsString*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
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
          nexusCoreExtrasModule,
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
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       listItemIds: seq[int64],
       delimiter: string = "\n",
       prefix: string = ""):
       (string, int) =

  let strs = getListItemDisplayNames(
               nexusCoreExtrasModule,
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
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       listItemIds: Option[seq[int64]],
       delimiter: string = "\n",
       prefix: string = "",
       textOnNone: string = "None"):
       (string, int) =

  if listItemIds != none(seq[int64]):

    return getTextAndLinesFromItemListIds(
             nexusCoreExtrasModule,
             listItemIds.get,
             delimiter,
             prefix)

  else:
    return (textOnNone, 0)

