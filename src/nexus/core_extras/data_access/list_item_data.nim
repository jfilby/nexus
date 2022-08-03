# Nexus generated file
import db_postgres, options, sequtils, strutils, times
import nexus/core/data_access/data_utils
import nexus/core/data_access/pg_try_insert_id
import nexus/core_extras/types/model_types


# Forward declarations
proc rowToListItem*(row: seq[string]):
       ListItem {.gcsafe.}


# Code
proc countListItem*(
       nexusCoreExtrasDbContext: NexusCoreExtrasDbContext,
       whereFields: seq[string] = @[],
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from list_item"
  var first = true

  for whereField in whereFields:

    var whereClause: string

    if first == false:
      whereClause = "   and " & whereField & " = ?"
    else:
      first = false
      whereClause = " where " & whereField & " = ?"

    selectStatement &= whereClause

  let row = getRow(nexusCoreExtrasDbContext.dbConn,
                   sql(selectStatement),
                   whereValues)

  return parseBiggestInt(row[0])


proc countListItem*(
       nexusCoreExtrasDbContext: NexusCoreExtrasDbContext,
       whereClause: string,
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from list_item"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  let row = getRow(nexusCoreExtrasDbContext.dbConn,
                   sql(selectStatement),
                   whereValues)

  return parseBiggestInt(row[0])


proc createListItemReturnsPk*(
       nexusCoreExtrasDbContext: NexusCoreExtrasDbContext,
       parentListItemId: Option[int64] = none(int64),
       seqNo: int,
       name: string,
       displayName: string,
       description: Option[string] = none(string),
       created: DateTime,
       ignoreExistingPk: bool = false): int64 {.gcsafe.} =

  # Formulate insertStatement and insertValues
  var
    insertValues: seq[string]
    insertStatement = "insert into list_item ("
    valuesClause = ""

  # Field: Parent List Item Id
  if parentListItemId != none(int64):
    insertStatement &= "parent_list_item_id, "
    valuesClause &= "?, "
    insertValues.add($parentListItemId.get)

  # Field: Seq No
  insertStatement &= "seq_no, "
  valuesClause &= "?, "
  insertValues.add($seqNo)

  # Field: Name
  insertStatement &= "name, "
  valuesClause &= "?" & ", "
  insertValues.add(name)

  # Field: Display Name
  insertStatement &= "display_name, "
  valuesClause &= "?" & ", "
  insertValues.add(displayName)

  # Field: Description
  if description != none(string):
    insertStatement &= "description, "
    valuesClause &= "?" & ", "
    insertValues.add(description.get)

  # Field: Created
  insertStatement &= "created, "
  valuesClause &= pgToDateTimeString(created) & ", "

  # Remove trailing commas and finalize insertStatement
  if insertStatement[len(insertStatement) - 2 .. len(insertStatement) - 1] == ", ":
    insertStatement = insertStatement[0 .. len(insertStatement) - 3]

  if valuesClause[len(valuesClause) - 2 .. len(valuesClause) - 1] == ", ":
    valuesClause = valuesClause[0 .. len(valuesClause) - 3]

  # Finalize insertStatement
  insertStatement &=
    ") values (" & valuesClause & ")"

  if ignoreExistingPk == true:
    insertStatement &= " on conflict (list_item_id) do nothing"

  # Execute the insert statement and return the sequence values
  return tryInsertNamedID(
    nexusCoreExtrasDbContext.dbConn,
    sql(insertStatement),
    "list_item_id",
    insertValues)


proc createListItem*(
       nexusCoreExtrasDbContext: NexusCoreExtrasDbContext,
       parentListItemId: Option[int64] = none(int64),
       seqNo: int,
       name: string,
       displayName: string,
       description: Option[string] = none(string),
       created: DateTime,
       ignoreExistingPk: bool = false,
       copyAllStringFields: bool = true,
       convertToRawTypes: bool = true): ListItem {.gcsafe.} =

  var listItem = ListItem()

  listItem.listItemId =
    createListItemReturnsPk(
      nexusCoreExtrasDbContext,
      parentListItemId,
      seqNo,
      name,
      displayName,
      description,
      created,
      ignoreExistingPk)

  # Copy all fields as strings
  listItem.parentListItemId = parentListItemId
  listItem.seqNo = seqNo
  listItem.name = name
  listItem.displayName = displayName
  listItem.description = description
  listItem.created = created

  return listItem


proc deleteListItemByPk*(
       nexusCoreExtrasDbContext: NexusCoreExtrasDbContext,
       listItemId: int64): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from list_item" &
    " where list_item_id = ?"

  return execAffectedRows(
           nexusCoreExtrasDbContext.dbConn,
           sql(deleteStatement),
           listItemId)


proc deleteListItem*(
       nexusCoreExtrasDbContext: NexusCoreExtrasDbContext,
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from list_item" &
    " where " & whereClause

  return execAffectedRows(
           nexusCoreExtrasDbContext.dbConn,
           sql(deleteStatement),
           whereValues)


proc deleteListItem*(
       nexusCoreExtrasDbContext: NexusCoreExtrasDbContext,
       whereFields: seq[string],
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from list_item"

  var first = true

  for whereField in whereFields:

    var whereClause: string

    if first == false:
      whereClause = "   and " & whereField & " = ?"
    else:
      first = false
      whereClause = " where " & whereField & " = ?"

    deleteStatement &= whereClause

  return execAffectedRows(
           nexusCoreExtrasDbContext.dbConn,
           sql(deleteStatement),
           whereValues)


proc existsListItemByPk*(
       nexusCoreExtrasDbContext: NexusCoreExtrasDbContext,
       listItemId: int64): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from list_item" &
    " where list_item_id = ?"

  let row = getRow(
              nexusCoreExtrasDbContext.dbConn,
              sql(selectStatement),
              $listItemId)

  if row[0] == "":
    return false
  else:
    return true


proc existsListItemByName*(
       nexusCoreExtrasDbContext: NexusCoreExtrasDbContext,
       name: string): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from list_item" &
    " where name = ?"

  let row = getRow(
              nexusCoreExtrasDbContext.dbConn,
              sql(selectStatement),
              name)

  if row[0] == "":
    return false
  else:
    return true


proc filterListItem*(
       nexusCoreExtrasDbContext: NexusCoreExtrasDbContext,
       whereClause: string = "",
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): ListItems {.gcsafe.} =

  var selectStatement =
    "select list_item_id, parent_list_item_id, seq_no, name, display_name, description, created" & 
    "  from list_item"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  if len(orderByFields) > 0:
    selectStatement &= " order by " & orderByFields.join(", ")

  if limit != none(int):
    selectStatement &= " limit " & $limit.get

  var listItems: ListItems

  for row in fastRows(nexusCoreExtrasDbContext.dbConn,
                      sql(selectStatement),
                      whereValues):

    listItems.add(rowToListItem(row))

  return listItems


proc filterListItem*(
       nexusCoreExtrasDbContext: NexusCoreExtrasDbContext,
       whereFields: seq[string],
       whereValues: seq[string],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): ListItems {.gcsafe.} =

  var selectStatement =
    "select list_item_id, parent_list_item_id, seq_no, name, display_name, description, created" & 
    "  from list_item"

  var first = true

  for whereField in whereFields:

    var whereClause: string

    if first == false:
      whereClause = "   and " & whereField & " = ?"
    else:
      first = false
      whereClause = " where " & whereField & " = ?"

    selectStatement &= whereClause

  if len(orderByFields) > 0:
    selectStatement &= " order by " & orderByFields.join(", ")

  if limit != none(int):
    selectStatement &= " limit " & $limit.get

  var listItems: ListItems

  for row in fastRows(nexusCoreExtrasDbContext.dbConn,
                      sql(selectStatement),
                      whereValues):

    listItems.add(rowToListItem(row))

  return listItems


proc getListItemByPk*(
       nexusCoreExtrasDbContext: NexusCoreExtrasDbContext,
       listItemId: int64): Option[ListItem] {.gcsafe.} =

  var selectStatement =
    "select list_item_id, parent_list_item_id, seq_no, name, display_name, description, created" & 
    "  from list_item" &
    " where list_item_id = ?"

  let row = getRow(
              nexusCoreExtrasDbContext.dbConn,
              sql(selectStatement),
              listItemId)

  if row[0] == "":
    return none(ListItem)

  return some(rowToListItem(row))


proc getListItemByPk*(
       nexusCoreExtrasDbContext: NexusCoreExtrasDbContext,
       listItemId: string): Option[ListItem] {.gcsafe.} =

  var selectStatement =
    "select list_item_id, parent_list_item_id, seq_no, name, display_name, description, created" & 
    "  from list_item" &
    " where list_item_id = ?"

  let row = getRow(
              nexusCoreExtrasDbContext.dbConn,
              sql(selectStatement),
              listItemId)

  if row[0] == "":
    return none(ListItem)

  return some(rowToListItem(row))


proc getListItemByName*(
       nexusCoreExtrasDbContext: NexusCoreExtrasDbContext,
       name: string): Option[ListItem] {.gcsafe.} =

  var selectStatement =
    "select list_item_id, parent_list_item_id, seq_no, name, display_name, description, created" & 
    "  from list_item" &
    " where name = ?"

  let row = getRow(
              nexusCoreExtrasDbContext.dbConn,
              sql(selectStatement),
              name)

  if row[0] == "":
    return none(ListItem)

  return some(rowToListItem(row))


proc getOrCreateListItemByName*(
       nexusCoreExtrasDbContext: NexusCoreExtrasDbContext,
       parentListItemId: Option[int64],
       seqNo: int,
       name: string,
       displayName: string,
       description: Option[string],
       created: DateTime): ListItem {.gcsafe.} =

  let listItem =
        getListItemByName(
          nexusCoreExtrasDbContext,
          name)

  if listItem != none(ListItem):
    return listItem.get

  return createListItem(
           nexusCoreExtrasDbContext,
           parentListItemId,
           seqNo,
           name,
           displayName,
           description,
           created)


proc rowToListItem*(row: seq[string]):
       ListItem {.gcsafe.} =

  var listItem = ListItem()

  listItem.listItemId = parseBiggestInt(row[0])

  if row[1] != "":
    listItem.parentListItemId = some(parseBiggestInt(row[1]))
  else:
    listItem.parentListItemId = none(int64)

  listItem.seqNo = parseInt(row[2])
  listItem.name = row[3]
  listItem.displayName = row[4]

  if row[5] != "":
    listItem.description = some(row[5])
  else:
    listItem.description = none(string)

  listItem.created = parsePgTimestamp(row[6])

  return listItem


proc truncateListItem*(
       nexusCoreExtrasDbContext: NexusCoreExtrasDbContext,
       cascade: bool = false) =

  if cascade == false:
    exec(nexusCoreExtrasDbContext.dbConn,
         sql("truncate table list_item restart identity;"))

  else:
    exec(nexusCoreExtrasDbContext.dbConn,
         sql("truncate table list_item restart identity cascade;"))


proc updateListItemSetClause*(
       listItem: ListItem,
       setFields: seq[string],
       updateStatement: var string,
       updateValues: var seq[string]) {.gcsafe.} =

  updateStatement =
    "update list_item" &
    "   set "

  for field in setFields:

    if field == "list_item_id":
      updateStatement &= "       list_item_id = ?,"
      updateValues.add($listItem.listItemId)

    elif field == "parent_list_item_id":
      if listItem.parentListItemId != none(int64):
        updateStatement &= "       parent_list_item_id = ?,"
        updateValues.add($listItem.parentListItemId.get)
      else:
        updateStatement &= "       parent_list_item_id = null,"

    elif field == "seq_no":
      updateStatement &= "       seq_no = ?,"
      updateValues.add($listItem.seqNo)

    elif field == "name":
      updateStatement &= "       name = ?,"
      updateValues.add(listItem.name)

    elif field == "display_name":
      updateStatement &= "       display_name = ?,"
      updateValues.add(listItem.displayName)

    elif field == "description":
      if listItem.description != none(string):
        updateStatement &= "       description = ?,"
        updateValues.add(listItem.description.get)
      else:
        updateStatement &= "       description = null,"

    elif field == "created":
        updateStatement &= "       created = " & pgToDateTimeString(listItem.created) & ","

  updateStatement[len(updateStatement) - 1] = ' '



proc updateListItemByPk*(
       nexusCoreExtrasDbContext: NexusCoreExtrasDbContext,
       listItem: ListItem,
       setFields: seq[string],
       exceptionOnNRowsUpdated: bool = true): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateListItemSetClause(
    list_item,
    setFields,
    updateStatement,
    updateValues)

  updateStatement &= " where list_item_id = ?"

  updateValues.add($listItem.listItemId)

  let rowsUpdated = 
        execAffectedRows(
          nexusCoreExtrasDbContext.dbConn,
          sql(updateStatement),
          updateValues)

  # Exception on no rows updated
  if rowsUpdated == 0 and
     exceptionOnNRowsUpdated == true:

    raise newException(ValueError,
                       "no rows updated")

  # Return rows updated
  return rowsUpdated


proc updateListItemByWhereClause*(
       nexusCoreExtrasDbContext: NexusCoreExtrasDbContext,
       listItem: ListItem,
       setFields: seq[string],
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateListItemSetClause(
    list_item,
    setFields,
    updateStatement,
    updateValues)

  if whereClause != "":
    updateStatement &= " where " & whereClause

  return execAffectedRows(
           nexusCoreExtrasDbContext.dbConn,
           sql(updateStatement),
           concat(updateValues,
                  whereValues))


proc updateListItemByWhereEqOnly*(
       nexusCoreExtrasDbContext: NexusCoreExtrasDbContext,
       listItem: ListItem,
       setFields: seq[string],
       whereFields: seq[string],
       whereValues: seq[string]): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateListItemSetClause(
    list_item,
    setFields,
    updateStatement,
    updateValues)

  var first = true

  for whereField in whereFields:

    var whereClause: string

    if first == false:
      whereClause = "   and " & whereField & " = ?"
    else:
      first = false
      whereClause = " where " & whereField & " = ?"

    updateStatement &= whereClause

  return execAffectedRows(
           nexusCoreExtrasDbContext.dbConn,
           sql(updateStatement),
           concat(updateValues,
                  whereValues))


