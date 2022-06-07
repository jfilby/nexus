# Nexus generated file
import db_postgres, options, sequtils, strutils, times
import nexus/core/data_access/data_utils
import nexus/core_extras/types/model_types


# Forward declarations
proc rowToTempFormData*(row: seq[string]):
       TempFormData {.gcsafe.}


# Code
proc countTempFormData*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       whereFields: seq[string] = @[],
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from temp_form_data"
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


proc countTempFormData*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       whereClause: string,
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from temp_form_data"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  let row = getRow(nexusCoreExtrasModule.db,
                   sql(selectStatement),
                   whereValues)

  return parseBiggestInt(row[0])


proc createTempFormDataReturnsPK*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       token: string,
       format: string,
       data: string,
       created: DateTime): string {.gcsafe.} =

  # Formulate insertStatement and insertValues
  var
    insertValues: seq[string]
    insertStatement = "insert into temp_form_data ("
    valuesClause = ""

  # Field: Token
  insertStatement &= "token, "
  valuesClause &= "?, "
  insertValues.add(token)

  # Field: Format
  insertStatement &= "format, "
  valuesClause &= "?, "
  insertValues.add(format)

  # Field: Data
  insertStatement &= "data, "
  valuesClause &= "?, "
  insertValues.add(data)

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
  exec(
    nexusCoreExtrasModule.db,
    sql(insertStatement),
    insertValues)

  return token


proc createTempFormData*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       token: string,
       format: string,
       data: string,
       created: DateTime,
       copyAllStringFields: bool = true,
       convertToRawTypes: bool = true): TempFormData {.gcsafe.} =

  var tempFormData = TempFormData()

  tempFormData.token =
    createTempFormDataReturnsPK(
      nexusCoreExtrasModule,
      token,
      format,
      data,
      created)

  # Copy all fields as strings
  tempFormData.format = format
  tempFormData.data = data
  tempFormData.created = created

  return tempFormData


proc deleteTempFormDataByPK*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       token: string): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from temp_form_data" &
    " where token = ?"

  return execAffectedRows(
           nexusCoreExtrasModule.db,
           sql(deleteStatement),
           token)


proc deleteTempFormData*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from temp_form_data" &
    " where " & whereClause

  return execAffectedRows(
           nexusCoreExtrasModule.db,
           sql(deleteStatement),
           whereValues)


proc existsTempFormDataByPK*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       token: string): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from temp_form_data" &
    " where token = ?"

  let row = getRow(
              nexusCoreExtrasModule.db,
              sql(selectStatement),
              token)

  if row[0] == "":
    return false
  else:
    return true


proc filterTempFormData*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       whereClause: string = "",
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[]): TempFormDatas {.gcsafe.} =

  var selectStatement =
    "select token, format, data, created" & 
    "  from temp_form_data"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  if len(orderByFields) > 0:
    selectStatement &= " order by " & orderByFields.join(", ")

  var tempFormDatas: TempFormDatas

  for row in fastRows(nexusCoreExtrasModule.db,
                      sql(selectStatement),
                      whereValues):

    tempFormDatas.add(rowToTempFormData(row))

  return tempFormDatas


proc filterTempFormData*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       whereFields: seq[string],
       whereValues: seq[string],
       orderByFields: seq[string] = @[]): TempFormDatas {.gcsafe.} =

  var selectStatement =
    "select token, format, data, created" & 
    "  from temp_form_data"

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

  var tempFormDatas: TempFormDatas

  for row in fastRows(nexusCoreExtrasModule.db,
                      sql(selectStatement),
                      whereValues):

    tempFormDatas.add(rowToTempFormData(row))

  return tempFormDatas


proc getTempFormDataByPK*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       token: string): Option[TempFormData] {.gcsafe.} =

  var selectStatement =
    "select token, format, data, created" & 
    "  from temp_form_data" &
    " where token = ?"

  let row = getRow(
              nexusCoreExtrasModule.db,
              sql(selectStatement),
              token)

  if row[0] == "":
    return none(TempFormData)

  return some(rowToTempFormData(row))


proc getOrCreateTempFormDataByPK*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       token: string,
       format: string,
       data: string,
       created: DateTime): TempFormData {.gcsafe.} =

  let tempFormData =
        getTempFormDataByPK(
          nexusCoreExtrasModule,
          token)

  if tempFormData != none(TempFormData):
    return tempFormData.get

  return createTempFormData(
           nexusCoreExtrasModule,
           token,
           format,
           data,
           created)


proc rowToTempFormData*(row: seq[string]):
       TempFormData {.gcsafe.} =

  var tempFormData = TempFormData()

  tempFormData.token = row[0]
  tempFormData.format = row[1]
  tempFormData.data = row[2]
  tempFormData.created = parsePgTimestamp(row[3])

  return tempFormData


proc truncateTempFormData*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       cascade: bool = false) =

  if cascade == false:
    exec(nexusCoreExtrasModule.db,
         sql("truncate table temp_form_data restart identity;"))

  else:
    exec(nexusCoreExtrasModule.db,
         sql("truncate table temp_form_data restart identity cascade;"))


proc updateTempFormDataSetClause*(
       tempFormData: TempFormData,
       setFields: seq[string],
       updateStatement: var string,
       updateValues: var seq[string]) {.gcsafe.} =

  updateStatement =
    "update temp_form_data" &
    "   set "

  for field in setFields:

    if field == "token":
      updateStatement &= "       token = ?,"
      updateValues.add($tempFormData.token)

    elif field == "format":
      updateStatement &= "       format = ?,"
      updateValues.add($tempFormData.format)

    elif field == "data":
      updateStatement &= "       data = ?,"
      updateValues.add($tempFormData.data)

    elif field == "created":
      updateStatement &= "       created = ?,"
      updateValues.add($tempFormData.created)

  updateStatement[len(updateStatement) - 1] = ' '



proc updateTempFormDataByPK*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       tempFormData: TempFormData,
       setFields: seq[string],
       exceptionOnNRowsUpdated: bool = true): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateTempFormDataSetClause(
    temp_form_data,
    setFields,
    updateStatement,
    updateValues)

  updateStatement &= " where token = ?"

  updateValues.add($tempFormData.token)

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


proc updateTempFormDataByWhereClause*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       tempFormData: TempFormData,
       setFields: seq[string],
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateTempFormDataSetClause(
    temp_form_data,
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


proc updateTempFormDataByWhereEqOnly*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       tempFormData: TempFormData,
       setFields: seq[string],
       whereFields: seq[string],
       whereValues: seq[string]): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateTempFormDataSetClause(
    temp_form_data,
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


