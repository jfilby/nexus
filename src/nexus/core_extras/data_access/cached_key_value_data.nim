# Nexus generated file
import db_postgres, options, sequtils, strutils, times, uuids
import nexus/core/data_access/data_utils
import nexus/core_extras/types/model_types


# Forward declarations
proc rowToCachedKeyValue*(row: seq[string]):
       CachedKeyValue {.gcsafe.}


# Code
proc countCachedKeyValue*(
       dbContext: NexusCoreExtrasDbContext,
       whereFields: seq[string] = @[],
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from cached_key_value"
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


proc countCachedKeyValue*(
       dbContext: NexusCoreExtrasDbContext,
       whereClause: string,
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from cached_key_value"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  let row = getRow(dbContext.dbConn,
                   sql(selectStatement),
                   whereValues)

  return parseBiggestInt(row[0])


proc createCachedKeyValueReturnsPk*(
       dbContext: NexusCoreExtrasDbContext,
       key: string,
       value: string,
       created: DateTime,
       updated: Option[DateTime] = none(DateTime),
       expires: Option[DateTime] = none(DateTime),
       ignoreExistingPk: bool = false): string {.gcsafe.} =

  # Formulate insertStatement and insertValues
  var
    insertValues: seq[string]
    insertStatement = "insert into cached_key_value ("
    valuesClause = ""

  # Field: Id
  insertStatement &= "id, "
  valuesClause &= "?, "

  let id = $genUUID()
  insertValues.add(id)

  # Field: Key
  insertStatement &= "key, "
  valuesClause &= "?, "
  insertValues.add(key)

  # Field: Value
  insertStatement &= "value, "
  valuesClause &= "?, "
  insertValues.add(value)

  # Field: Created
  insertStatement &= "created, "
  valuesClause &= pgToDateTimeString(created) & ", "

  # Field: Updated
  if updated != none(DateTime):
    insertStatement &= "updated, "
    valuesClause &= pgToDateTimeString(updated.get) & ", "

  # Field: Expires
  if expires != none(DateTime):
    insertStatement &= "expires, "
    valuesClause &= pgToDateTimeString(expires.get) & ", "

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


proc createCachedKeyValue*(
       dbContext: NexusCoreExtrasDbContext,
       key: string,
       value: string,
       created: DateTime,
       updated: Option[DateTime] = none(DateTime),
       expires: Option[DateTime] = none(DateTime),
       ignoreExistingPk: bool = false,
       copyAllStringFields: bool = true,
       convertToRawTypes: bool = true): CachedKeyValue {.gcsafe.} =

  var cachedKeyValue = CachedKeyValue()

  cachedKeyValue.id =
    createCachedKeyValueReturnsPk(
      dbContext,
      key,
      value,
      created,
      updated,
      expires,
      ignoreExistingPk)

  # Copy all fields as strings
  cachedKeyValue.key = key
  cachedKeyValue.value = value
  cachedKeyValue.created = created
  cachedKeyValue.updated = updated
  cachedKeyValue.expires = expires

  return cachedKeyValue


proc deleteCachedKeyValueByPk*(
       dbContext: NexusCoreExtrasDbContext,
       id: string): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from cached_key_value" &
    " where id = ?"

  return execAffectedRows(
           dbContext.dbConn,
           sql(deleteStatement),
           id)


proc deleteCachedKeyValue*(
       dbContext: NexusCoreExtrasDbContext,
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from cached_key_value" &
    " where " & whereClause

  return execAffectedRows(
           dbContext.dbConn,
           sql(deleteStatement),
           whereValues)


proc deleteCachedKeyValue*(
       dbContext: NexusCoreExtrasDbContext,
       whereFields: seq[string],
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from cached_key_value"

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


proc existsCachedKeyValueByPk*(
       dbContext: NexusCoreExtrasDbContext,
       id: string): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from cached_key_value" &
    " where id = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              id)

  if row[0] == "":
    return false
  else:
    return true


proc existsCachedKeyValueByKey*(
       dbContext: NexusCoreExtrasDbContext,
       key: string): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from cached_key_value" &
    " where key = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              key)

  if row[0] == "":
    return false
  else:
    return true


proc filterCachedKeyValue*(
       dbContext: NexusCoreExtrasDbContext,
       whereClause: string = "",
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): CachedKeyValues {.gcsafe.} =

  var selectStatement =
    "select id, key, value, created, updated, expires" & 
    "  from cached_key_value"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  if len(orderByFields) > 0:
    selectStatement &= " order by " & orderByFields.join(", ")

  if limit != none(int):
    selectStatement &= " limit " & $limit.get

  var cachedKeyValues: CachedKeyValues

  for row in fastRows(dbContext.dbConn,
                      sql(selectStatement),
                      whereValues):

    cachedKeyValues.add(rowToCachedKeyValue(row))

  return cachedKeyValues


proc filterCachedKeyValue*(
       dbContext: NexusCoreExtrasDbContext,
       whereFields: seq[string],
       whereValues: seq[string],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): CachedKeyValues {.gcsafe.} =

  var selectStatement =
    "select id, key, value, created, updated, expires" & 
    "  from cached_key_value"

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

  var cachedKeyValues: CachedKeyValues

  for row in fastRows(dbContext.dbConn,
                      sql(selectStatement),
                      whereValues):

    cachedKeyValues.add(rowToCachedKeyValue(row))

  return cachedKeyValues


proc getCachedKeyValueByPk*(
       dbContext: NexusCoreExtrasDbContext,
       id: string): Option[CachedKeyValue] {.gcsafe.} =

  var selectStatement =
    "select id, key, value, created, updated, expires" & 
    "  from cached_key_value" &
    " where id = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              id)

  if row[0] == "":
    return none(CachedKeyValue)

  return some(rowToCachedKeyValue(row))


proc getCachedKeyValueByKey*(
       dbContext: NexusCoreExtrasDbContext,
       key: string): Option[CachedKeyValue] {.gcsafe.} =

  var selectStatement =
    "select id, key, value, created, updated, expires" & 
    "  from cached_key_value" &
    " where key = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              key)

  if row[0] == "":
    return none(CachedKeyValue)

  return some(rowToCachedKeyValue(row))


proc getOrCreateCachedKeyValueByKey*(
       dbContext: NexusCoreExtrasDbContext,
       key: string,
       value: string,
       created: DateTime,
       updated: Option[DateTime],
       expires: Option[DateTime]): CachedKeyValue {.gcsafe.} =

  let cachedKeyValue =
        getCachedKeyValueByKey(
          dbContext,
          key)

  if cachedKeyValue != none(CachedKeyValue):
    return cachedKeyValue.get

  return createCachedKeyValue(
           dbContext,
           key,
           value,
           created,
           updated,
           expires)


proc rowToCachedKeyValue*(row: seq[string]):
       CachedKeyValue {.gcsafe.} =

  var cachedKeyValue = CachedKeyValue()

  cachedKeyValue.id = row[0]
  cachedKeyValue.key = row[1]
  cachedKeyValue.value = row[2]
  cachedKeyValue.created = parsePgTimestamp(row[3])

  if row[4] != "":
    cachedKeyValue.updated = some(parsePgTimestamp(row[4]))
  else:
    cachedKeyValue.updated = none(DateTime)

  if row[5] != "":
    cachedKeyValue.expires = some(parsePgTimestamp(row[5]))
  else:
    cachedKeyValue.expires = none(DateTime)


  return cachedKeyValue


proc truncateCachedKeyValue*(
       dbContext: NexusCoreExtrasDbContext,
       cascade: bool = false) =

  if cascade == false:
    exec(dbContext.dbConn,
         sql("truncate table cached_key_value restart identity;"))

  else:
    exec(dbContext.dbConn,
         sql("truncate table cached_key_value restart identity cascade;"))


proc updateCachedKeyValueSetClause*(
       cachedKeyValue: CachedKeyValue,
       setFields: seq[string],
       updateStatement: var string,
       updateValues: var seq[string]) {.gcsafe.} =

  updateStatement =
    "update cached_key_value" &
    "   set "

  for field in setFields:

    if field == "id":
      updateStatement &= "       id = ?,"
      updateValues.add(cachedKeyValue.id)

    elif field == "key":
      updateStatement &= "       key = ?,"
      updateValues.add(cachedKeyValue.key)

    elif field == "value":
      updateStatement &= "       value = ?,"
      updateValues.add(cachedKeyValue.value)

    elif field == "created":
        updateStatement &= "       created = " & pgToDateTimeString(cachedKeyValue.created) & ","

    elif field == "updated":
      if cachedKeyValue.updated != none(DateTime):
        updateStatement &= "       updated = " & pgToDateTimeString(cachedKeyValue.updated.get) & ","
      else:
        updateStatement &= "       updated = null,"

    elif field == "expires":
      if cachedKeyValue.expires != none(DateTime):
        updateStatement &= "       expires = " & pgToDateTimeString(cachedKeyValue.expires.get) & ","
      else:
        updateStatement &= "       expires = null,"

  updateStatement[len(updateStatement) - 1] = ' '



proc updateCachedKeyValueByPk*(
       dbContext: NexusCoreExtrasDbContext,
       cachedKeyValue: CachedKeyValue,
       setFields: seq[string],
       exceptionOnNRowsUpdated: bool = true): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateCachedKeyValueSetClause(
    cached_key_value,
    setFields,
    updateStatement,
    updateValues)

  updateStatement &= " where id = ?"

  updateValues.add($cachedKeyValue.id)

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


proc updateCachedKeyValueByWhereClause*(
       dbContext: NexusCoreExtrasDbContext,
       cachedKeyValue: CachedKeyValue,
       setFields: seq[string],
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateCachedKeyValueSetClause(
    cached_key_value,
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


proc updateCachedKeyValueByWhereEqOnly*(
       dbContext: NexusCoreExtrasDbContext,
       cachedKeyValue: CachedKeyValue,
       setFields: seq[string],
       whereFields: seq[string],
       whereValues: seq[string]): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateCachedKeyValueSetClause(
    cached_key_value,
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


