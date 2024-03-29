# Nexus generated file
import db_connector/db_postgres, options, sequtils, strutils, times, uuids
import nexus/core/data_access/data_utils
import nexus/core_extras/types/model_types


# Forward declarations
proc rowToListItem*(row: seq[string]):
       ListItem {.gcsafe.}


# Code
proc countListItem*(
       dbContext: NexusCoreExtrasDbContext,
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

  let row = getRow(dbContext.dbConn,
                   sql(selectStatement),
                   whereValues)

  return parseBiggestInt(row[0])


proc countListItem*(
       dbContext: NexusCoreExtrasDbContext,
       whereClause: string,
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from list_item"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  let row = getRow(dbContext.dbConn,
                   sql(selectStatement),
                   whereValues)

  return parseBiggestInt(row[0])


proc createListItemReturnsPk*(
       dbContext: NexusCoreExtrasDbContext,
       parentId: Option[string] = none(string),
       seqNo: int,
       name: string,
       displayName: string,
       description: Option[string] = none(string),
       created: DateTime,
       ignoreExistingPk: bool = false): string {.gcsafe.} =

  # Formulate insertStatement and insertValues
  var
    insertValues: seq[string]
    insertStatement = "insert into list_item ("
    valuesClause = ""

  # Field: Id
  insertStatement &= "id, "
  valuesClause &= "?, "

  let id = $genUUID()
  insertValues.add(id)

  # Field: Parent Id
  if parentId != none(string):
    insertStatement &= "parent_id, "
    valuesClause &= "?, "
    insertValues.add(parentId.get)

  # Field: Seq No
  insertStatement &= "seq_no, "
  valuesClause &= "?, "
  insertValues.add($seqNo)

  # Field: Name
  insertStatement &= "name, "
  valuesClause &= "?, "
  insertValues.add(name)

  # Field: Display Name
  insertStatement &= "display_name, "
  valuesClause &= "?, "
  insertValues.add(displayName)

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
  insertStatement &=
    ") values (" & valuesClause & ")"

  if ignoreExistingPk == true:
    insertStatement &= " on conflict (id) do nothing"

  # Execute the insert statement and return the sequence values
  exec(
    dbContext.dbConn,
    sql(insertStatement),
    insertValues)

  return id


proc createListItem*(
       dbContext: NexusCoreExtrasDbContext,
       parentId: Option[string] = none(string),
       seqNo: int,
       name: string,
       displayName: string,
       description: Option[string] = none(string),
       created: DateTime,
       ignoreExistingPk: bool = false,
       copyAllStringFields: bool = true,
       convertToRawTypes: bool = true): ListItem {.gcsafe.} =

  var listItem = ListItem()

  listItem.id =
    createListItemReturnsPk(
      dbContext,
      parentId,
      seqNo,
      name,
      displayName,
      description,
      created,
      ignoreExistingPk)

  # Copy all fields as strings
  listItem.parentId = parentId
  listItem.seqNo = seqNo
  listItem.name = name
  listItem.displayName = displayName
  listItem.description = description
  listItem.created = created

  return listItem


proc deleteListItemByPk*(
       dbContext: NexusCoreExtrasDbContext,
       id: string): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from list_item" &
    " where id = ?"

  return execAffectedRows(
           dbContext.dbConn,
           sql(deleteStatement),
           id)


proc deleteListItem*(
       dbContext: NexusCoreExtrasDbContext,
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from list_item" &
    " where " & whereClause

  return execAffectedRows(
           dbContext.dbConn,
           sql(deleteStatement),
           whereValues)


proc deleteListItem*(
       dbContext: NexusCoreExtrasDbContext,
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
           dbContext.dbConn,
           sql(deleteStatement),
           whereValues)


proc existsListItemByPk*(
       dbContext: NexusCoreExtrasDbContext,
       id: string): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from list_item" &
    " where id = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              id)

  if row[0] == "":
    return false
  else:
    return true


proc existsListItemByName*(
       dbContext: NexusCoreExtrasDbContext,
       name: string): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from list_item" &
    " where name = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              name)

  if row[0] == "":
    return false
  else:
    return true


proc filterListItem*(
       dbContext: NexusCoreExtrasDbContext,
       whereClause: string = "",
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): ListItems {.gcsafe.} =

  var selectStatement =
    "select id, parent_id, seq_no, name, display_name, description, created" & 
    "  from list_item"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  if len(orderByFields) > 0:
    selectStatement &= " order by " & orderByFields.join(", ")

  if limit != none(int):
    selectStatement &= " limit " & $limit.get

  var listItems: ListItems

  for row in fastRows(dbContext.dbConn,
                      sql(selectStatement),
                      whereValues):

    listItems.add(rowToListItem(row))

  return listItems


proc filterListItem*(
       dbContext: NexusCoreExtrasDbContext,
       whereFields: seq[string],
       whereValues: seq[string],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): ListItems {.gcsafe.} =

  var selectStatement =
    "select id, parent_id, seq_no, name, display_name, description, created" & 
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

  for row in fastRows(dbContext.dbConn,
                      sql(selectStatement),
                      whereValues):

    listItems.add(rowToListItem(row))

  return listItems


proc getListItemByPk*(
       dbContext: NexusCoreExtrasDbContext,
       id: string): Option[ListItem] {.gcsafe.} =

  var selectStatement =
    "select id, parent_id, seq_no, name, display_name, description, created" & 
    "  from list_item" &
    " where id = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              id)

  if row[0] == "":
    return none(ListItem)

  return some(rowToListItem(row))


proc getListItemByName*(
       dbContext: NexusCoreExtrasDbContext,
       name: string): Option[ListItem] {.gcsafe.} =

  var selectStatement =
    "select id, parent_id, seq_no, name, display_name, description, created" & 
    "  from list_item" &
    " where name = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              name)

  if row[0] == "":
    return none(ListItem)

  return some(rowToListItem(row))


proc getOrCreateListItemByName*(
       dbContext: NexusCoreExtrasDbContext,
       parentId: Option[string],
       seqNo: int,
       name: string,
       displayName: string,
       description: Option[string],
       created: DateTime): ListItem {.gcsafe.} =

  let listItem =
        getListItemByName(
          dbContext,
          name)

  if listItem != none(ListItem):
    return listItem.get

  return createListItem(
           dbContext,
           parentId,
           seqNo,
           name,
           displayName,
           description,
           created)


proc rowToListItem*(row: seq[string]):
       ListItem {.gcsafe.} =

  var listItem = ListItem()

  listItem.id = row[0]

  if row[1] != "":
    listItem.parentId = some(row[1])
  else:
    listItem.parentId = none(string)

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
       dbContext: NexusCoreExtrasDbContext,
       cascade: bool = false) =

  if cascade == false:
    exec(dbContext.dbConn,
         sql("truncate table list_item restart identity;"))

  else:
    exec(dbContext.dbConn,
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

    if field == "id":
      updateStatement &= "       id = ?,"
      updateValues.add(listItem.id)

    elif field == "parent_id":
      if listItem.parentId != none(string):
        updateStatement &= "       parent_id = ?,"
        updateValues.add(listItem.parentId.get)
      else:
        updateStatement &= "       parent_id = null,"

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
       dbContext: NexusCoreExtrasDbContext,
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

  updateStatement &= " where id = ?"

  updateValues.add($listItem.id)

  let rowsUpdated = 
        execAffectedRows(
          dbContext.dbConn,
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
       dbContext: NexusCoreExtrasDbContext,
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
           dbContext.dbConn,
           sql(updateStatement),
           concat(updateValues,
                  whereValues))


proc updateListItemByWhereEqOnly*(
       dbContext: NexusCoreExtrasDbContext,
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
           dbContext.dbConn,
           sql(updateStatement),
           concat(updateValues,
                  whereValues))


