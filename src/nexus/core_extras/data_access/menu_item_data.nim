# Nexus generated file
import db_postgres, options, sequtils, strutils, times, uuids
import nexus/core/data_access/data_utils
import nexus/core_extras/types/model_types


# Forward declarations
proc rowToMenuItem*(row: seq[string]):
       MenuItem {.gcsafe.}


# Code
proc countMenuItem*(
       dbContext: NexusCoreExtrasDbContext,
       whereFields: seq[string] = @[],
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from menu_item"
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


proc countMenuItem*(
       dbContext: NexusCoreExtrasDbContext,
       whereClause: string,
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from menu_item"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  let row = getRow(dbContext.dbConn,
                   sql(selectStatement),
                   whereValues)

  return parseBiggestInt(row[0])


proc createMenuItemReturnsPk*(
       dbContext: NexusCoreExtrasDbContext,
       parentId: Option[string] = none(string),
       name: string,
       url: string,
       screen: string,
       level: int,
       position: int,
       roleIds: Option[seq[string]] = none(seq[string]),
       created: DateTime,
       ignoreExistingPk: bool = false): string {.gcsafe.} =

  # Formulate insertStatement and insertValues
  var
    insertValues: seq[string]
    insertStatement = "insert into menu_item ("
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

  # Field: Name
  insertStatement &= "name, "
  valuesClause &= "?, "
  insertValues.add(name)

  # Field: URL
  insertStatement &= "url, "
  valuesClause &= "?, "
  insertValues.add(url)

  # Field: Screen
  insertStatement &= "screen, "
  valuesClause &= "?, "
  insertValues.add(screen)

  # Field: Level
  insertStatement &= "level, "
  valuesClause &= "?, "
  insertValues.add($level)

  # Field: Position
  insertStatement &= "position, "
  valuesClause &= "?, "
  insertValues.add($position)

  # Field: Role Ids
  if roleIds != none(seq[string]):
    insertStatement &= "role_ids, "
    valuesClause &= "'" & getSeqStringAsPgArrayString(roleIds.get) & "'" & ", "

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


proc createMenuItem*(
       dbContext: NexusCoreExtrasDbContext,
       parentId: Option[string] = none(string),
       name: string,
       url: string,
       screen: string,
       level: int,
       position: int,
       roleIds: Option[seq[string]] = none(seq[string]),
       created: DateTime,
       ignoreExistingPk: bool = false,
       copyAllStringFields: bool = true,
       convertToRawTypes: bool = true): MenuItem {.gcsafe.} =

  var menuItem = MenuItem()

  menuItem.id =
    createMenuItemReturnsPk(
      dbContext,
      parentId,
      name,
      url,
      screen,
      level,
      position,
      roleIds,
      created,
      ignoreExistingPk)

  # Copy all fields as strings
  menuItem.parentId = parentId
  menuItem.name = name
  menuItem.url = url
  menuItem.screen = screen
  menuItem.level = level
  menuItem.position = position
  menuItem.roleIds = roleIds
  menuItem.created = created

  return menuItem


proc deleteMenuItemByPk*(
       dbContext: NexusCoreExtrasDbContext,
       id: string): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from menu_item" &
    " where id = ?"

  return execAffectedRows(
           dbContext.dbConn,
           sql(deleteStatement),
           id)


proc deleteMenuItem*(
       dbContext: NexusCoreExtrasDbContext,
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from menu_item" &
    " where " & whereClause

  return execAffectedRows(
           dbContext.dbConn,
           sql(deleteStatement),
           whereValues)


proc deleteMenuItem*(
       dbContext: NexusCoreExtrasDbContext,
       whereFields: seq[string],
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from menu_item"

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


proc existsMenuItemByPk*(
       dbContext: NexusCoreExtrasDbContext,
       id: string): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from menu_item" &
    " where id = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              id)

  if row[0] == "":
    return false
  else:
    return true


proc existsMenuItemByNameAndURLAndScreen*(
       dbContext: NexusCoreExtrasDbContext,
       name: string,
       url: string,
       screen: string): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from menu_item" &
    " where name = ?" &
    "   and url = ?" &
    "   and screen = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              name,
              url,
              screen)

  if row[0] == "":
    return false
  else:
    return true


proc filterMenuItem*(
       dbContext: NexusCoreExtrasDbContext,
       whereClause: string = "",
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): MenuItems {.gcsafe.} =

  var selectStatement =
    "select id, parent_id, name, url, screen, level, position, role_ids, created" & 
    "  from menu_item"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  if len(orderByFields) > 0:
    selectStatement &= " order by " & orderByFields.join(", ")

  if limit != none(int):
    selectStatement &= " limit " & $limit.get

  var menuItems: MenuItems

  for row in fastRows(dbContext.dbConn,
                      sql(selectStatement),
                      whereValues):

    menuItems.add(rowToMenuItem(row))

  return menuItems


proc filterMenuItem*(
       dbContext: NexusCoreExtrasDbContext,
       whereFields: seq[string],
       whereValues: seq[string],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): MenuItems {.gcsafe.} =

  var selectStatement =
    "select id, parent_id, name, url, screen, level, position, role_ids, created" & 
    "  from menu_item"

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

  var menuItems: MenuItems

  for row in fastRows(dbContext.dbConn,
                      sql(selectStatement),
                      whereValues):

    menuItems.add(rowToMenuItem(row))

  return menuItems


proc getMenuItemByPk*(
       dbContext: NexusCoreExtrasDbContext,
       id: string): Option[MenuItem] {.gcsafe.} =

  var selectStatement =
    "select id, parent_id, name, url, screen, level, position, role_ids, created" & 
    "  from menu_item" &
    " where id = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              id)

  if row[0] == "":
    return none(MenuItem)

  return some(rowToMenuItem(row))


proc getMenuItemByNameAndURLAndScreen*(
       dbContext: NexusCoreExtrasDbContext,
       name: string,
       url: string,
       screen: string): Option[MenuItem] {.gcsafe.} =

  var selectStatement =
    "select id, parent_id, name, url, screen, level, position, role_ids, created" & 
    "  from menu_item" &
    " where name = ?" &
    "   and url = ?" &
    "   and screen = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              name,
              url,
              screen)

  if row[0] == "":
    return none(MenuItem)

  return some(rowToMenuItem(row))


proc getOrCreateMenuItemByNameAndURLAndScreen*(
       dbContext: NexusCoreExtrasDbContext,
       parentId: Option[string],
       name: string,
       url: string,
       screen: string,
       level: int,
       position: int,
       roleIds: Option[seq[string]],
       created: DateTime): MenuItem {.gcsafe.} =

  let menuItem =
        getMenuItemByNameAndURLAndScreen(
          dbContext,
          name,
          url,
          screen)

  if menuItem != none(MenuItem):
    return menuItem.get

  return createMenuItem(
           dbContext,
           parentId,
           name,
           url,
           screen,
           level,
           position,
           roleIds,
           created)


proc rowToMenuItem*(row: seq[string]):
       MenuItem {.gcsafe.} =

  var menuItem = MenuItem()

  menuItem.id = row[0]

  if row[1] != "":
    menuItem.parentId = some(row[1])
  else:
    menuItem.parentId = none(string)

  menuItem.name = row[2]
  menuItem.url = row[3]
  menuItem.screen = row[4]
  menuItem.level = parseInt(row[5])
  menuItem.position = parseInt(row[6])

  if row[7] != "":
    menuItem.roleIds = some(getPgArrayStringAsSeqString(row[7]))
  else:
    menuItem.roleIds = none(seq[string])

  menuItem.created = parsePgTimestamp(row[8])

  return menuItem


proc truncateMenuItem*(
       dbContext: NexusCoreExtrasDbContext,
       cascade: bool = false) =

  if cascade == false:
    exec(dbContext.dbConn,
         sql("truncate table menu_item restart identity;"))

  else:
    exec(dbContext.dbConn,
         sql("truncate table menu_item restart identity cascade;"))


proc updateMenuItemSetClause*(
       menuItem: MenuItem,
       setFields: seq[string],
       updateStatement: var string,
       updateValues: var seq[string]) {.gcsafe.} =

  updateStatement =
    "update menu_item" &
    "   set "

  for field in setFields:

    if field == "id":
      updateStatement &= "       id = ?,"
      updateValues.add(menuItem.id)

    elif field == "parent_id":
      if menuItem.parentId != none(string):
        updateStatement &= "       parent_id = ?,"
        updateValues.add(menuItem.parentId.get)
      else:
        updateStatement &= "       parent_id = null,"

    elif field == "name":
      updateStatement &= "       name = ?,"
      updateValues.add(menuItem.name)

    elif field == "url":
      updateStatement &= "       url = ?,"
      updateValues.add(menuItem.url)

    elif field == "screen":
      updateStatement &= "       screen = ?,"
      updateValues.add(menuItem.screen)

    elif field == "level":
      updateStatement &= "       level = ?,"
      updateValues.add($menuItem.level)

    elif field == "position":
      updateStatement &= "       position = ?,"
      updateValues.add($menuItem.position)

    elif field == "role_ids":
      if menuItem.roleIds != none(seq[string]):
        updateStatement &= "       role_ids = '" & getSeqStringAsPgArrayString(menuItem.roleIds.get) & "',"
      else:
        updateStatement &= "       role_ids = null,"

    elif field == "created":
        updateStatement &= "       created = " & pgToDateTimeString(menuItem.created) & ","

  updateStatement[len(updateStatement) - 1] = ' '



proc updateMenuItemByPk*(
       dbContext: NexusCoreExtrasDbContext,
       menuItem: MenuItem,
       setFields: seq[string],
       exceptionOnNRowsUpdated: bool = true): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateMenuItemSetClause(
    menu_item,
    setFields,
    updateStatement,
    updateValues)

  updateStatement &= " where id = ?"

  updateValues.add($menuItem.id)

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


proc updateMenuItemByWhereClause*(
       dbContext: NexusCoreExtrasDbContext,
       menuItem: MenuItem,
       setFields: seq[string],
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateMenuItemSetClause(
    menu_item,
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


proc updateMenuItemByWhereEqOnly*(
       dbContext: NexusCoreExtrasDbContext,
       menuItem: MenuItem,
       setFields: seq[string],
       whereFields: seq[string],
       whereValues: seq[string]): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateMenuItemSetClause(
    menu_item,
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


