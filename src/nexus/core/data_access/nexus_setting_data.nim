# Nexus generated file
import db_postgres, options, sequtils, strutils, times, uuids
import nexus/core/data_access/data_utils
import nexus/core/types/model_types


# Forward declarations
proc rowToNexusSetting*(row: seq[string]):
       NexusSetting {.gcsafe.}


# Code
proc countNexusSetting*(
       dbContext: NexusCoreDbContext,
       whereFields: seq[string] = @[],
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from nexus_setting"
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


proc countNexusSetting*(
       dbContext: NexusCoreDbContext,
       whereClause: string,
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from nexus_setting"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  let row = getRow(dbContext.dbConn,
                   sql(selectStatement),
                   whereValues)

  return parseBiggestInt(row[0])


proc createNexusSettingReturnsPk*(
       dbContext: NexusCoreDbContext,
       module: string,
       key: string,
       value: Option[string] = none(string),
       created: DateTime,
       ignoreExistingPk: bool = false): string {.gcsafe.} =

  # Formulate insertStatement and insertValues
  var
    insertValues: seq[string]
    insertStatement = "insert into nexus_setting ("
    valuesClause = ""

  # Field: Id
  insertStatement &= "id, "
  valuesClause &= "?, "

  let id = $genUUID()
  insertValues.add(id)

  # Field: Module
  insertStatement &= "module, "
  valuesClause &= "?, "
  insertValues.add(module)

  # Field: Key
  insertStatement &= "key, "
  valuesClause &= "?, "
  insertValues.add(key)

  # Field: Value
  if value != none(string):
    insertStatement &= "value, "
    valuesClause &= "?, "
    insertValues.add(value.get)

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


proc createNexusSetting*(
       dbContext: NexusCoreDbContext,
       module: string,
       key: string,
       value: Option[string] = none(string),
       created: DateTime,
       ignoreExistingPk: bool = false,
       copyAllStringFields: bool = true,
       convertToRawTypes: bool = true): NexusSetting {.gcsafe.} =

  var nexusSetting = NexusSetting()

  nexusSetting.id =
    createNexusSettingReturnsPk(
      dbContext,
      module,
      key,
      value,
      created,
      ignoreExistingPk)

  # Copy all fields as strings
  nexusSetting.module = module
  nexusSetting.key = key
  nexusSetting.value = value
  nexusSetting.created = created

  return nexusSetting


proc deleteNexusSettingByPk*(
       dbContext: NexusCoreDbContext,
       id: string): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from nexus_setting" &
    " where id = ?"

  return execAffectedRows(
           dbContext.dbConn,
           sql(deleteStatement),
           id)


proc deleteNexusSetting*(
       dbContext: NexusCoreDbContext,
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from nexus_setting" &
    " where " & whereClause

  return execAffectedRows(
           dbContext.dbConn,
           sql(deleteStatement),
           whereValues)


proc deleteNexusSetting*(
       dbContext: NexusCoreDbContext,
       whereFields: seq[string],
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from nexus_setting"

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


proc existsNexusSettingByPk*(
       dbContext: NexusCoreDbContext,
       id: string): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from nexus_setting" &
    " where id = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              id)

  if row[0] == "":
    return false
  else:
    return true


proc existsNexusSettingByModuleAndKey*(
       dbContext: NexusCoreDbContext,
       module: string,
       key: string): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from nexus_setting" &
    " where module = ?" &
    "   and key = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              module,
              key)

  if row[0] == "":
    return false
  else:
    return true


proc filterNexusSetting*(
       dbContext: NexusCoreDbContext,
       whereClause: string = "",
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): NexusSettings {.gcsafe.} =

  var selectStatement =
    "select id, module, key, value, created" & 
    "  from nexus_setting"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  if len(orderByFields) > 0:
    selectStatement &= " order by " & orderByFields.join(", ")

  if limit != none(int):
    selectStatement &= " limit " & $limit.get

  var nexusSettings: NexusSettings

  for row in fastRows(dbContext.dbConn,
                      sql(selectStatement),
                      whereValues):

    nexusSettings.add(rowToNexusSetting(row))

  return nexusSettings


proc filterNexusSetting*(
       dbContext: NexusCoreDbContext,
       whereFields: seq[string],
       whereValues: seq[string],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): NexusSettings {.gcsafe.} =

  var selectStatement =
    "select id, module, key, value, created" & 
    "  from nexus_setting"

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

  var nexusSettings: NexusSettings

  for row in fastRows(dbContext.dbConn,
                      sql(selectStatement),
                      whereValues):

    nexusSettings.add(rowToNexusSetting(row))

  return nexusSettings


proc getNexusSettingByPk*(
       dbContext: NexusCoreDbContext,
       id: string): Option[NexusSetting] {.gcsafe.} =

  var selectStatement =
    "select id, module, key, value, created" & 
    "  from nexus_setting" &
    " where id = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              id)

  if row[0] == "":
    return none(NexusSetting)

  return some(rowToNexusSetting(row))


proc getNexusSettingByModuleAndKey*(
       dbContext: NexusCoreDbContext,
       module: string,
       key: string): Option[NexusSetting] {.gcsafe.} =

  var selectStatement =
    "select id, module, key, value, created" & 
    "  from nexus_setting" &
    " where module = ?" &
    "   and key = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              module,
              key)

  if row[0] == "":
    return none(NexusSetting)

  return some(rowToNexusSetting(row))


proc getOrCreateNexusSettingByModuleAndKey*(
       dbContext: NexusCoreDbContext,
       module: string,
       key: string,
       value: Option[string],
       created: DateTime): NexusSetting {.gcsafe.} =

  let nexusSetting =
        getNexusSettingByModuleAndKey(
          dbContext,
          module,
          key)

  if nexusSetting != none(NexusSetting):
    return nexusSetting.get

  return createNexusSetting(
           dbContext,
           module,
           key,
           value,
           created)


proc rowToNexusSetting*(row: seq[string]):
       NexusSetting {.gcsafe.} =

  var nexusSetting = NexusSetting()

  nexusSetting.id = row[0]
  nexusSetting.module = row[1]
  nexusSetting.key = row[2]

  if row[3] != "":
    nexusSetting.value = some(row[3])
  else:
    nexusSetting.value = none(string)

  nexusSetting.created = parsePgTimestamp(row[4])

  return nexusSetting


proc truncateNexusSetting*(
       dbContext: NexusCoreDbContext,
       cascade: bool = false) =

  if cascade == false:
    exec(dbContext.dbConn,
         sql("truncate table nexus_setting restart identity;"))

  else:
    exec(dbContext.dbConn,
         sql("truncate table nexus_setting restart identity cascade;"))


proc updateNexusSettingSetClause*(
       nexusSetting: NexusSetting,
       setFields: seq[string],
       updateStatement: var string,
       updateValues: var seq[string]) {.gcsafe.} =

  updateStatement =
    "update nexus_setting" &
    "   set "

  for field in setFields:

    if field == "id":
      updateStatement &= "       id = ?,"
      updateValues.add(nexusSetting.id)

    elif field == "module":
      updateStatement &= "       module = ?,"
      updateValues.add(nexusSetting.module)

    elif field == "key":
      updateStatement &= "       key = ?,"
      updateValues.add(nexusSetting.key)

    elif field == "value":
      if nexusSetting.value != none(string):
        updateStatement &= "       value = ?,"
        updateValues.add(nexusSetting.value.get)
      else:
        updateStatement &= "       value = null,"

    elif field == "created":
        updateStatement &= "       created = " & pgToDateTimeString(nexusSetting.created) & ","

  updateStatement[len(updateStatement) - 1] = ' '



proc updateNexusSettingByPk*(
       dbContext: NexusCoreDbContext,
       nexusSetting: NexusSetting,
       setFields: seq[string],
       exceptionOnNRowsUpdated: bool = true): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateNexusSettingSetClause(
    nexus_setting,
    setFields,
    updateStatement,
    updateValues)

  updateStatement &= " where id = ?"

  updateValues.add($nexusSetting.id)

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


proc updateNexusSettingByWhereClause*(
       dbContext: NexusCoreDbContext,
       nexusSetting: NexusSetting,
       setFields: seq[string],
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateNexusSettingSetClause(
    nexus_setting,
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


proc updateNexusSettingByWhereEqOnly*(
       dbContext: NexusCoreDbContext,
       nexusSetting: NexusSetting,
       setFields: seq[string],
       whereFields: seq[string],
       whereValues: seq[string]): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateNexusSettingSetClause(
    nexus_setting,
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


