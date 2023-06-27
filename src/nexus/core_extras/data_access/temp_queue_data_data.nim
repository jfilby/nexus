# Nexus generated file
import db_postgres, options, sequtils, strutils, times
import nexus/core/data_access/data_utils
import nexus/core_extras/types/model_types


# Forward declarations
proc rowToTempQueueData*(row: seq[string]):
       TempQueueData {.gcsafe.}


# Code
proc countTempQueueData*(
       dbContext: NexusCoreExtrasDbContext,
       whereFields: seq[string] = @[],
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from temp_queue_data"
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


proc countTempQueueData*(
       dbContext: NexusCoreExtrasDbContext,
       whereClause: string,
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from temp_queue_data"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  let row = getRow(dbContext.dbConn,
                   sql(selectStatement),
                   whereValues)

  return parseBiggestInt(row[0])


proc createTempQueueDataReturnsPk*(
       dbContext: NexusCoreExtrasDbContext,
       format: string,
       dataIn: string,
       dataOut: Option[string] = none(string),
       created: DateTime,
       fulfilled: DateTime,
       ignoreExistingPk: bool = false) {.gcsafe.} =

  # Formulate insertStatement and insertValues
  var
    insertValues: seq[string]
    insertStatement = "insert into temp_queue_data ("
    valuesClause = ""

  # Field: Temp Queue Data Id
  insertStatement &= "temp_queue_data_id, "
  valuesClause &= "?, "

  let tempQueueDataId = $genUUID()
  insertValues.add(tempQueueDataId)

  # Field: Format
  insertStatement &= "format, "
  valuesClause &= "?, "
  insertValues.add(format)

  # Field: Data In
  insertStatement &= "data_in, "
  valuesClause &= "?, "
  insertValues.add(dataIn)

  # Field: Data Out
  if dataOut != none(string):
    insertStatement &= "data_out, "
    valuesClause &= "?, "
    insertValues.add(dataOut.get)

  # Field: Created
  insertStatement &= "created, "
  valuesClause &= pgToDateTimeString(created) & ", "

  # Field: Fulfilled
  insertStatement &= "fulfilled, "
  valuesClause &= pgToDateTimeString(fulfilled) & ", "

  # Remove trailing commas and finalize insertStatement
  if insertStatement[len(insertStatement) - 2 .. len(insertStatement) - 1] == ", ":
    insertStatement = insertStatement[0 .. len(insertStatement) - 3]

  if valuesClause[len(valuesClause) - 2 .. len(valuesClause) - 1] == ", ":
    valuesClause = valuesClause[0 .. len(valuesClause) - 3]

  # Finalize insertStatement
  insertStatement &=
    ") values (" & valuesClause & ")"

  # Execute the insert statement and return the sequence values
  exec(
    dbContext.dbConn,
    sql(insertStatement),
    insertValues)

  return 


proc createTempQueueData*(
       dbContext: NexusCoreExtrasDbContext,
       format: string,
       dataIn: string,
       dataOut: Option[string] = none(string),
       created: DateTime,
       fulfilled: DateTime,
       ignoreExistingPk: bool = false,
       copyAllStringFields: bool = true,
       convertToRawTypes: bool = true): TempQueueData {.gcsafe.} =

  var tempQueueData = TempQueueData()

  createTempQueueDataReturnsPk(
    dbContext,
    format,
    dataIn,
    dataOut,
    created,
    fulfilled,
    ignoreExistingPk)

  # Copy all fields as strings
  tempQueueData.tempQueueDataId = tempQueueDataId
  tempQueueData.format = format
  tempQueueData.dataIn = dataIn
  tempQueueData.dataOut = dataOut
  tempQueueData.created = created
  tempQueueData.fulfilled = fulfilled

  return tempQueueData


proc deleteTempQueueData*(
       dbContext: NexusCoreExtrasDbContext,
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from temp_queue_data" &
    " where " & whereClause

  return execAffectedRows(
           dbContext.dbConn,
           sql(deleteStatement),
           whereValues)


proc deleteTempQueueData*(
       dbContext: NexusCoreExtrasDbContext,
       whereFields: seq[string],
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from temp_queue_data"

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


proc filterTempQueueData*(
       dbContext: NexusCoreExtrasDbContext,
       whereClause: string = "",
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): TempQueueDatas {.gcsafe.} =

  var selectStatement =
    "select temp_queue_data_id, format, data_in, data_out, created, fulfilled" & 
    "  from temp_queue_data"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  if len(orderByFields) > 0:
    selectStatement &= " order by " & orderByFields.join(", ")

  if limit != none(int):
    selectStatement &= " limit " & $limit.get

  var tempQueueDatas: TempQueueDatas

  for row in fastRows(dbContext.dbConn,
                      sql(selectStatement),
                      whereValues):

    tempQueueDatas.add(rowToTempQueueData(row))

  return tempQueueDatas


proc filterTempQueueData*(
       dbContext: NexusCoreExtrasDbContext,
       whereFields: seq[string],
       whereValues: seq[string],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): TempQueueDatas {.gcsafe.} =

  var selectStatement =
    "select temp_queue_data_id, format, data_in, data_out, created, fulfilled" & 
    "  from temp_queue_data"

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

  var tempQueueDatas: TempQueueDatas

  for row in fastRows(dbContext.dbConn,
                      sql(selectStatement),
                      whereValues):

    tempQueueDatas.add(rowToTempQueueData(row))

  return tempQueueDatas


proc rowToTempQueueData*(row: seq[string]):
       TempQueueData {.gcsafe.} =

  var tempQueueData = TempQueueData()

  tempQueueData.tempQueueDataId = row[0]
  tempQueueData.format = row[1]
  tempQueueData.dataIn = row[2]

  if row[3] != "":
    tempQueueData.dataOut = some(row[3])
  else:
    tempQueueData.dataOut = none(string)

  tempQueueData.created = parsePgTimestamp(row[4])
  tempQueueData.fulfilled = parsePgTimestamp(row[5])

  return tempQueueData


proc truncateTempQueueData*(
       dbContext: NexusCoreExtrasDbContext,
       cascade: bool = false) =

  if cascade == false:
    exec(dbContext.dbConn,
         sql("truncate table temp_queue_data restart identity;"))

  else:
    exec(dbContext.dbConn,
         sql("truncate table temp_queue_data restart identity cascade;"))


proc updateTempQueueDataSetClause*(
       tempQueueData: TempQueueData,
       setFields: seq[string],
       updateStatement: var string,
       updateValues: var seq[string]) {.gcsafe.} =

  updateStatement =
    "update temp_queue_data" &
    "   set "

  for field in setFields:

    if field == "temp_queue_data_id":
      updateStatement &= "       temp_queue_data_id = ?,"
      updateValues.add(tempQueueData.tempQueueDataId)

    elif field == "format":
      updateStatement &= "       format = ?,"
      updateValues.add(tempQueueData.format)

    elif field == "data_in":
      updateStatement &= "       data_in = ?,"
      updateValues.add(tempQueueData.dataIn)

    elif field == "data_out":
      if tempQueueData.dataOut != none(string):
        updateStatement &= "       data_out = ?,"
        updateValues.add(tempQueueData.dataOut.get)
      else:
        updateStatement &= "       data_out = null,"

    elif field == "created":
        updateStatement &= "       created = " & pgToDateTimeString(tempQueueData.created) & ","

    elif field == "fulfilled":
        updateStatement &= "       fulfilled = " & pgToDateTimeString(tempQueueData.fulfilled) & ","

  updateStatement[len(updateStatement) - 1] = ' '



proc updateTempQueueDataByWhereClause*(
       dbContext: NexusCoreExtrasDbContext,
       tempQueueData: TempQueueData,
       setFields: seq[string],
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateTempQueueDataSetClause(
    temp_queue_data,
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


proc updateTempQueueDataByWhereEqOnly*(
       dbContext: NexusCoreExtrasDbContext,
       tempQueueData: TempQueueData,
       setFields: seq[string],
       whereFields: seq[string],
       whereValues: seq[string]): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateTempQueueDataSetClause(
    temp_queue_data,
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


