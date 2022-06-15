# Nexus generated file
import db_postgres, options, sequtils, strutils, times
import nexus/core/data_access/data_utils
import nexus/core/data_access/pg_try_insert_id
import nexus/core/types/model_types


# Forward declarations
proc rowToNexusSetting*(row: seq[string]):
       NexusSetting {.gcsafe.}


# Code
proc countNexusSetting*(
       nexusCoreModule: NexusCoreModule,
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

  let row = getRow(nexusCoreModule.db,
                   sql(selectStatement),
                   whereValues)

  return parseBiggestInt(row[0])


proc countNexusSetting*(
       nexusCoreModule: NexusCoreModule,
       whereClause: string,
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from nexus_setting"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  let row = getRow(nexusCoreModule.db,
                   sql(selectStatement),
                   whereValues)

  return parseBiggestInt(row[0])


proc createNexusSettingReturnsPK*(
       nexusCoreModule: NexusCoreModule,
       module: string,
       key: string,
       value: Option[string] = none(string),
       created: DateTime): int64 {.gcsafe.} =

  # Formulate insertStatement and insertValues
  var
    insertValues: seq[string]
    insertStatement = "insert into nexus_setting ("
    valuesClause = ""

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
  insertStatement &= ") values (" & valuesClause & ")"

  # Execute the insert statement and return the sequence values
  return tryInsertNamedID(
    nexusCoreModule.db,
    sql(insertStatement),
    "nexus_setting_id",
    insertValues)


proc createNexusSetting*(
       nexusCoreModule: NexusCoreModule,
       module: string,
       key: string,
       value: Option[string] = none(string),
       created: DateTime,
       copyAllStringFields: bool = true,
       convertToRawTypes: bool = true): NexusSetting {.gcsafe.} =

  var nexusSetting = NexusSetting()

  nexusSetting.nexusSettingId =
    createNexusSettingReturnsPK(
      nexusCoreModule,
      module,
      key,
      value,
      created)

  # Copy all fields as strings
  nexusSetting.module = module
  nexusSetting.key = key
  nexusSetting.value = value
  nexusSetting.created = created

  return nexusSetting


proc deleteNexusSettingByPk*(
       nexusCoreModule: NexusCoreModule,
       nexusSettingId: int64): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from nexus_setting" &
    " where nexus_setting_id = ?"

  return execAffectedRows(
           nexusCoreModule.db,
           sql(deleteStatement),
           nexusSettingId)


proc deleteNexusSetting*(
       nexusCoreModule: NexusCoreModule,
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from nexus_setting" &
    " where " & whereClause

  return execAffectedRows(
           nexusCoreModule.db,
           sql(deleteStatement),
           whereValues)


proc existsNexusSettingByPk*(
       nexusCoreModule: NexusCoreModule,
       nexusSettingId: int64): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from nexus_setting" &
    " where nexus_setting_id = ?"

  let row = getRow(
              nexusCoreModule.db,
              sql(selectStatement),
              nexusSettingId)

  if row[0] == "":
    return false
  else:
    return true


proc existsNexusSettingByModuleAndKey*(
       nexusCoreModule: NexusCoreModule,
       module: string,
       key: string): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from nexus_setting" &
    " where module = ?" &
    "   and key = ?"

  let row = getRow(
              nexusCoreModule.db,
              sql(selectStatement),
              module,
              key)

  if row[0] == "":
    return false
  else:
    return true


proc filterNexusSetting*(
       nexusCoreModule: NexusCoreModule,
       whereClause: string = "",
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[]): NexusSettings {.gcsafe.} =

  var selectStatement =
    "select nexus_setting_id, module, key, value, created" & 
    "  from nexus_setting"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  if len(orderByFields) > 0:
    selectStatement &= " order by " & orderByFields.join(", ")

  var nexusSettings: NexusSettings

  for row in fastRows(nexusCoreModule.db,
                      sql(selectStatement),
                      whereValues):

    nexusSettings.add(rowToNexusSetting(row))

  return nexusSettings


proc filterNexusSetting*(
       nexusCoreModule: NexusCoreModule,
       whereFields: seq[string],
       whereValues: seq[string],
       orderByFields: seq[string] = @[]): NexusSettings {.gcsafe.} =

  var selectStatement =
    "select nexus_setting_id, module, key, value, created" & 
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

  var nexusSettings: NexusSettings

  for row in fastRows(nexusCoreModule.db,
                      sql(selectStatement),
                      whereValues):

    nexusSettings.add(rowToNexusSetting(row))

  return nexusSettings


proc getNexusSettingByPk*(
       nexusCoreModule: NexusCoreModule,
       nexusSettingId: int64): Option[NexusSetting] {.gcsafe.} =

  var selectStatement =
    "select nexus_setting_id, module, key, value, created" & 
    "  from nexus_setting" &
    " where nexus_setting_id = ?"

  let row = getRow(
              nexusCoreModule.db,
              sql(selectStatement),
              nexusSettingId)

  if row[0] == "":
    return none(NexusSetting)

  return some(rowToNexusSetting(row))


proc getNexusSettingByPk*(
       nexusCoreModule: NexusCoreModule,
       nexusSettingId: string): Option[NexusSetting] {.gcsafe.} =

  var selectStatement =
    "select nexus_setting_id, module, key, value, created" & 
    "  from nexus_setting" &
    " where nexus_setting_id = ?"

  let row = getRow(
              nexusCoreModule.db,
              sql(selectStatement),
              nexusSettingId)

  if row[0] == "":
    return none(NexusSetting)

  return some(rowToNexusSetting(row))


proc getNexusSettingByModuleAndKey*(
       nexusCoreModule: NexusCoreModule,
       module: string,
       key: string): Option[NexusSetting] {.gcsafe.} =

  var selectStatement =
    "select nexus_setting_id, module, key, value, created" & 
    "  from nexus_setting" &
    " where module = ?" &
    "   and key = ?"

  let row = getRow(
              nexusCoreModule.db,
              sql(selectStatement),
              module,
              key)

  if row[0] == "":
    return none(NexusSetting)

  return some(rowToNexusSetting(row))


proc getOrCreateNexusSettingByModuleAndKey*(
       nexusCoreModule: NexusCoreModule,
       module: string,
       key: string,
       value: Option[string],
       created: DateTime): NexusSetting {.gcsafe.} =

  let nexusSetting =
        getNexusSettingByModuleAndKey(
          nexusCoreModule,
          module,
          key)

  if nexusSetting != none(NexusSetting):
    return nexusSetting.get

  return createNexusSetting(
           nexusCoreModule,
           module,
           key,
           value,
           created)


proc rowToNexusSetting*(row: seq[string]):
       NexusSetting {.gcsafe.} =

  var nexusSetting = NexusSetting()

  nexusSetting.nexusSettingId = parseBiggestInt(row[0])
  nexusSetting.module = row[1]
  nexusSetting.key = row[2]

  if row[3] != "":
    nexusSetting.value = some(row[3])
  else:
    nexusSetting.value = none(string)

  nexusSetting.created = parsePgTimestamp(row[4])

  return nexusSetting


proc truncateNexusSetting*(
       nexusCoreModule: NexusCoreModule,
       cascade: bool = false) =

  if cascade == false:
    exec(nexusCoreModule.db,
         sql("truncate table nexus_setting restart identity;"))

  else:
    exec(nexusCoreModule.db,
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

    if field == "nexus_setting_id":
      updateStatement &= "       nexus_setting_id = ?,"
      updateValues.add($nexusSetting.nexusSettingId)

    elif field == "module":
      updateStatement &= "       module = ?,"
      updateValues.add($nexusSetting.module)

    elif field == "key":
      updateStatement &= "       key = ?,"
      updateValues.add($nexusSetting.key)

    elif field == "value":
      if nexusSetting.value != none(string):
        updateStatement &= "       value = ?,"
        updateValues.add($nexusSetting.value.get)
      else:
        updateStatement &= "       value = null,"

    elif field == "created":
      updateStatement &= "       created = ?,"
      updateValues.add($nexusSetting.created)

  updateStatement[len(updateStatement) - 1] = ' '



proc updateNexusSettingByPk*(
       nexusCoreModule: NexusCoreModule,
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

  updateStatement &= " where nexus_setting_id = ?"

  updateValues.add($nexusSetting.nexusSettingId)

  let rowsUpdated = 
        execAffectedRows(
          nexusCoreModule.db,
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
       nexusCoreModule: NexusCoreModule,
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
           nexusCoreModule.db,
           sql(updateStatement),
           concat(updateValues,
                  whereValues))


proc updateNexusSettingByWhereEqOnly*(
       nexusCoreModule: NexusCoreModule,
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
           nexusCoreModule.db,
           sql(updateStatement),
           concat(updateValues,
                  whereValues))


