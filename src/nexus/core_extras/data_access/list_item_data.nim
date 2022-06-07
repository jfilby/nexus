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
       nexusCoreExtrasModule: NexusCoreExtrasModule,
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

  let row = getRow(nexusCoreExtrasModule.db,
                   sql(selectStatement),
                   whereValues)

  return parseBiggestInt(row[0])


proc countListItem*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       whereClause: string,
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from list_item"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  let row = getRow(nexusCoreExtrasModule.db,
                   sql(selectStatement),
                   whereValues)

  return parseBiggestInt(row[0])


proc createListItemReturnsPK*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       parentListItemId: Option[int64] = none(int64),
       seqNo: int,
       name: string,
       displayName: string,
       description: Option[string] = none(string),
       created: DateTime): int64 {.gcsafe.} =

  # Formulate insertStatement and insertValues
  var
    insertValues: seq[string]
    insertStatement = "insert into list_item ("
    valuesClause = ""

  # Field: Parent List Item Id
  if parent_list_item_id != none(int64):
    insertStatement &= "parent_list_item_id, "
    valuesClause &= "?, "
    insertValues.add($parent_list_item_id.get)

  # Field: Seq No
  insertStatement &= "seq_no, "
  valuesClause &= "?, "
  insertValues.add($seq_no)

  # Field: Name
  insertStatement &= "name, "
  valuesClause &= "?, "
  insertValues.add(name)

  # Field: Display Name
  insertStatement &= "display_name, "
  valuesClause &= "?, "
  insertValues.add(display_name)

  # Field: Description
  if description != none(string):
    insertStatement &= "description, "
    valuesClause &= "?, "
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
  insertStatement &= ") values (" & valuesClause & ")"

  # Execute the insert statement and return the sequence values
  return tryInsertNamedID(
    nexusCoreExtrasModule.db,
    sql(insertStatement),
    "list_item_id",
    insertValues)


proc createListItem*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       parentListItemId: Option[int64] = none(int64),
       seqNo: int,
       name: string,
       displayName: string,
       description: Option[string] = none(string),
       created: DateTime,
       copyAllStringFields: bool = true,
       convertToRawTypes: bool = true): ListItem {.gcsafe.} =

  var listItem = ListItem()

  listItem.listItemId =
    createListItemReturnsPK(
      nexusCoreExtrasModule,
      parentListItemId,
      seqNo,
      name,
      displayName,
      description,
      created)

  # Copy all fields as strings
  listItem.parentListItemId = parentListItemId
  listItem.seqNo = seqNo
  listItem.name = name
  listItem.displayName = displayName
  listItem.description = description
  listItem.created = created

  return listItem


proc deleteListItemByPK*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       listItemId: int64): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from list_item" &
    " where list_item_id = ?"

  return execAffectedRows(
           nexusCoreExtrasModule.db,
           sql(deleteStatement),
           listItemId)


proc deleteListItem*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from list_item" &
    " where " & whereClause

  return execAffectedRows(
           nexusCoreExtrasModule.db,
           sql(deleteStatement),
           whereValues)


proc existsListItemByPK*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       listItemId: int64): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from list_item" &
    " where list_item_id = ?"

  let row = getRow(
              nexusCoreExtrasModule.db,
              sql(selectStatement),
              listItemId)

  if row[0] == "":
    return false
  else:
    return true


proc existsListItemByName*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       name: string): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from list_item" &
    " where name = ?"

  let row = getRow(
              nexusCoreExtrasModule.db,
              sql(selectStatement),
              name)

  if row[0] == "":
    return false
  else:
    return true


proc filterListItem*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       whereClause: string = "",
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[]): ListItems {.gcsafe.} =

  var selectStatement =
    "select list_item_id, parent_list_item_id, seq_no, name, display_name, description, created" & 
    "  from list_item"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  if len(orderByFields) > 0:
    selectStatement &= " order by " & orderByFields.join(", ")

  var listItems: ListItems

  for row in fastRows(nexusCoreExtrasModule.db,
                      sql(selectStatement),
                      whereValues):

    listItems.add(rowToListItem(row))

  return listItems


proc filterListItem*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       whereFields: seq[string],
       whereValues: seq[string],
       orderByFields: seq[string] = @[]): ListItems {.gcsafe.} =

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

  var listItems: ListItems

  for row in fastRows(nexusCoreExtrasModule.db,
                      sql(selectStatement),
                      whereValues):

    listItems.add(rowToListItem(row))

  return listItems


proc getListItemByPK*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       listItemId: int64): Option[ListItem] {.gcsafe.} =

  var selectStatement =
    "select list_item_id, parent_list_item_id, seq_no, name, display_name, description, created" & 
    "  from list_item" &
    " where list_item_id = ?"

  let row = getRow(
              nexusCoreExtrasModule.db,
              sql(selectStatement),
              listItemId)

  if row[0] == "":
    return none(ListItem)

  return some(rowToListItem(row))


proc getListItemByPK*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       listItemId: string): Option[ListItem] {.gcsafe.} =

  var selectStatement =
    "select list_item_id, parent_list_item_id, seq_no, name, display_name, description, created" & 
    "  from list_item" &
    " where list_item_id = ?"

  let row = getRow(
              nexusCoreExtrasModule.db,
              sql(selectStatement),
              listItemId)

  if row[0] == "":
    return none(ListItem)

  return some(rowToListItem(row))


proc getListItemByName*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       name: string): Option[ListItem] {.gcsafe.} =

  var selectStatement =
    "select list_item_id, parent_list_item_id, seq_no, name, display_name, description, created" & 
    "  from list_item" &
    " where name = ?"

  let row = getRow(
              nexusCoreExtrasModule.db,
              sql(selectStatement),
              name)

  if row[0] == "":
    return none(ListItem)

  return some(rowToListItem(row))


proc getOrCreateListItemByName*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       parentListItemId: Option[int64],
       seqNo: int,
       name: string,
       displayName: string,
       description: Option[string],
       created: DateTime): ListItem {.gcsafe.} =

  let listItem =
        getListItemByName(
          nexusCoreExtrasModule,
          name)

  if listItem != none(ListItem):
    return listItem.get

  return createListItem(
           nexusCoreExtrasModule,
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
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       cascade: bool = false) =

  if cascade == false:
    exec(nexusCoreExtrasModule.db,
         sql("truncate table list_item restart identity;"))

  else:
    exec(nexusCoreExtrasModule.db,
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
      updateValues.add($listItem.name)

    elif field == "display_name":
      updateStatement &= "       display_name = ?,"
      updateValues.add($listItem.displayName)

    elif field == "description":
      if listItem.description != none(string):
        updateStatement &= "       description = ?,"
        updateValues.add($listItem.description.get)
      else:
        updateStatement &= "       description = null,"

    elif field == "created":
      updateStatement &= "       created = ?,"
      updateValues.add($listItem.created)

  updateStatement[len(updateStatement) - 1] = ' '



proc updateListItemByPK*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
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
          nexusCoreExtrasModule.db,
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
       nexusCoreExtrasModule: NexusCoreExtrasModule,
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
           nexusCoreExtrasModule.db,
           sql(updateStatement),
           concat(updateValues,
                  whereValues))


proc updateListItemByWhereEqOnly*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
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
           nexusCoreExtrasModule.db,
           sql(updateStatement),
           concat(updateValues,
                  whereValues))


