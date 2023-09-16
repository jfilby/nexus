import chronicles, options, sequtils, strformat, tables
import nexus/core/service/format/type_utils
import nexus/core_extras/data_access/list_item_data
import nexus/core_extras/types/context_type
import nexus/core_extras/types/model_types


# Forward declarations
proc getListItemsByParentListId*(
       dbContext: NexusCoreExtrasDbContext,
       parentListId: string): ListItems
proc getListItemsByParentListName*(
       dbContext: NexusCoreExtrasDbContext,
       parentListName: string): ListItems


# Code
proc getListItemDisplayNames*(
       dbContext: NexusCoreExtrasDbContext,
       listItemIds: seq[string]): seq[string] =

  var strs: seq[string]

  for listItemId in listItemIds:

    let listItem =
          getListItemByPk(dbContext,
                          listItemId)

    strs.add(listItem.get.displayName)

  return strs


proc getListItemDisplayNames*(
       dbContext: NexusCoreExtrasDbContext,
       listItemIds: Option[seq[string]]): seq[string] =

  if listItemIds != none(seq[string]):

    getListItemDisplayNames(
      dbContext,
      listItemIds.get)

  else:
    return @[]


proc getListItemByNameAndParentName*(
       dbContext: NexusCoreExtrasDbContext,
       listName: string,
       parentListName: Option[string]): ListItem =

  var listItems: ListItems

  listItems = filterListItem(
                dbContext,
                whereFields = @[ "name" ],
                whereValues = @[ listName ])

  if parentListName != none(string):

    var filteredListItems: ListItems

    for listItem in listItems:

      if listItem.parentId != none(string):

        let parentlistItem =
              getListItemByPk(
                dbContext,
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
      dbContext: NexusCoreExtrasDbContext,
      listItemId: string): ListItems =

  # Filter list items
  let listItems =
        filterListItem(
          dbContext,
          whereFields = @[ "list_item_id" ],
          whereValues = @[ $listItemId ],
          orderByFields = @[ "display_name" ])

  return listItems


proc getListItemsByListItemIds*(
      dbContext: NexusCoreExtrasDbContext,
      listItemIds: seq[string]): ListItems =

  var listItems: ListItems

  for listItemId in listItemIds:

    let listItem =
          getListItemByPk(
            dbContext,
            listItemId)

    if listItem == none(ListItem):

      raise newException(
              ValueError,
              "ListItem record not found for listItemId: " &
              $listItemId)

    listItems.add(listItem.get)

  return listItems


proc getListItemsByParentListId*(
       dbContext: NexusCoreExtrasDbContext,
       parentListId: string): ListItems =

  # Filter list items
  return filterListItem(
           dbContext,
           whereFields = @[ "parent_id" ],
           whereValues = @[ $parentListId ],
           orderByFields = @[ "display_name" ])


proc getListItemsByParentListName*(
       dbContext: NexusCoreExtrasDbContext,
       parentListName: string): ListItems =

  # Get list id
  let parentListItem =
        getListItemByName(
          dbContext,
          parentListName)

  if parentListItem == none(ListItem):

    raise newException(
            ValueError,
            &"List not found for name: \"{parentListName}\"")

  # Filter list items
  return getListItemsByParentListId(
           dbContext,
           parentListItem.get.id)


proc getIdsAndDisplayNames*(
       dbContext: NexusCoreExtrasDbContext,
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
          dbContext,
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
              dbContext,
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
       dbContext: NexusCoreExtrasDbContext,
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
          dbContext,
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
              dbContext,
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
       dbContext: NexusCoreExtrasDbContext,
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
          dbContext,
          parentListName)

  for listItem in listItems:

    optionIds.add($listItem.id)
    options.add(listItem.displayName)

    if cascade == true:

      let (childOptionIds,
           childOptions) =
            getIdsAsStringsAndDisplayNames(
              dbContext,
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
       dbContext: NexusCoreExtrasDbContext,
       listItemId: string): seq[string] =

  var listItemIds = @[ listItemId ]

  let listItems =
        getListItemsByParentListId(
          dbContext,
          listItemId)

  for listItem in listItems:

    let listItemIdsToAdd =
          getListItemIdsCascade(
            dbContext,
            listItem.id)

    listItemIds.add(listItemIdsToAdd)

  return listItemIds


proc getListItemByParentNameAndDisplayName*(
       dbContext: NexusCoreExtrasDbContext,
       parentName: string,
       displayName: string): Option[ListItem] =

  # Get ListItems by parent name
  let listItems =
        getListItemsByParentListName(
          dbContext,
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
       dbContext: NexusCoreExtrasDbContext,
       parentName: string,
       displayName: string): Option[ListItem] =

  # Get ListItems by parent name
  let parentListItem =
        getListItemByName(
          dbContext,
          parentName)

  # Return the matching id for the display name
  let (ids,
       displayNames) = getIdsAndDisplayNames(
                         dbContext,
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
              dbContext,
              ids[i])

      return listItem

  # Finally return none
  return none(ListItem)


proc getListItemIdByParentNameAndDisplayName*(
       dbContext: NexusCoreExtrasDbContext,
       parentName: string,
       displayName: string): Option[string] =

  let listItem = getListItemByParentNameAndDisplayName(
                   dbContext,
                   parentName,
                   displayName)

  if listItem != none(ListItem):

    return some(listItem.get.id)

  # Finally return none
  return none(string)


proc getListItemIdByParentNameAndDisplayNameCascade*(
       dbContext: NexusCoreExtrasDbContext,
       parentName: string,
       displayName: string): Option[string] =

  let listItem = getListItemByParentNameAndDisplayNameCascade(
                   dbContext,
                   parentName,
                   displayName)

  if listItem != none(ListItem):

    return some(listItem.get.id)

  # Finally return none
  return none(string)


proc getListItemDisplayNameById*(
       dbContext: NexusCoreExtrasDbContext,
       listItemId: string): Option[string] =

  let listItem =
        getListItemByPk(dbContext,
                        listItemId)

  if listItem == none(ListItem):
    return none(string)

  return some(listItem.get.displayName)


proc getListItemIdAsStringAndDisplayNameMap*(
       dbContext: NexusCoreExtrasDbContext,
       parentListName: string):
         OrderedTable[string, string] =

  # Get categories
  var
    options: OrderedTable[string, string]

  let listItems =
        getListItemsByParentListName(
          dbContext,
          parentListName)

  for listItem in listItems:

    options[$listItem.id] = listItem.displayName

  return options


proc getListItemNames*(
       dbContext: NexusCoreExtrasDbContext,
       listItemIds: seq[string]): seq[string] =

  var strs: seq[string]

  for listItemId in listItemIds:

    let listItem =
          getListItemByPk(dbContext,
                          listItemId)

    strs.add(listItem.get.name)

  return strs


proc getListItemNamesAsString*(
       dbContext: NexusCoreExtrasDbContext,
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
          dbContext,
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
       dbContext: NexusCoreExtrasDbContext,
       listItemIds: seq[string],
       delimiter: string = "\n",
       prefix: string = ""):
       (string, int) =

  let strs = getListItemDisplayNames(
               dbContext,
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
       dbContext: NexusCoreExtrasDbContext,
       listItemIds: Option[seq[string]],
       delimiter: string = "\n",
       prefix: string = "",
       textOnNone: string = "None"):
       (string, int) =

  if listItemIds != none(seq[string]):

    return getTextAndLinesFromItemListIds(
             dbContext,
             listItemIds.get,
             delimiter,
             prefix)

  else:
    return (textOnNone, 0)

