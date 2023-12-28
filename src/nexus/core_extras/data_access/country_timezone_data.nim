# Nexus generated file
import db_connector/db_postgres, options, sequtils, strutils, times
import nexus/core/data_access/data_utils
import nexus/core_extras/types/model_types


# Forward declarations
proc rowToCountryTimezone*(row: seq[string]):
       CountryTimezone {.gcsafe.}


# Code
proc countCountryTimezone*(
       dbContext: NexusCoreExtrasDbContext,
       whereFields: seq[string] = @[],
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from country_timezone"
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


proc countCountryTimezone*(
       dbContext: NexusCoreExtrasDbContext,
       whereClause: string,
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from country_timezone"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  let row = getRow(dbContext.dbConn,
                   sql(selectStatement),
                   whereValues)

  return parseBiggestInt(row[0])


proc createCountryTimezoneReturnsPk*(
       dbContext: NexusCoreExtrasDbContext,
       countryCode: string,
       timezone: string,
       created: DateTime,
       ignoreExistingPk: bool = false) {.gcsafe.} =

  # Formulate insertStatement and insertValues
  var
    insertValues: seq[string]
    insertStatement = "insert into country_timezone ("
    valuesClause = ""

  # Field: Country Code
  insertStatement &= "country_code, "
  valuesClause &= "?, "
  insertValues.add(countryCode)

  # Field: Timezone
  insertStatement &= "timezone, "
  valuesClause &= "?, "
  insertValues.add(timezone)

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

  # Execute the insert statement and return the sequence values
  exec(
    dbContext.dbConn,
    sql(insertStatement),
    insertValues)

  return 


proc createCountryTimezone*(
       dbContext: NexusCoreExtrasDbContext,
       countryCode: string,
       timezone: string,
       created: DateTime,
       ignoreExistingPk: bool = false,
       copyAllStringFields: bool = true,
       convertToRawTypes: bool = true): CountryTimezone {.gcsafe.} =

  var countryTimezone = CountryTimezone()

  createCountryTimezoneReturnsPk(
    dbContext,
    countryCode,
    timezone,
    created,
    ignoreExistingPk)

  # Copy all fields as strings
  countryTimezone.countryCode = countryCode
  countryTimezone.timezone = timezone
  countryTimezone.created = created

  return countryTimezone


proc deleteCountryTimezone*(
       dbContext: NexusCoreExtrasDbContext,
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from country_timezone" &
    " where " & whereClause

  return execAffectedRows(
           dbContext.dbConn,
           sql(deleteStatement),
           whereValues)


proc deleteCountryTimezone*(
       dbContext: NexusCoreExtrasDbContext,
       whereFields: seq[string],
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from country_timezone"

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


proc existsCountryTimezoneByCountryCodeAndTimezone*(
       dbContext: NexusCoreExtrasDbContext,
       countryCode: string,
       timezone: string): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from country_timezone" &
    " where country_code = ?" &
    "   and timezone = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              countryCode,
              timezone)

  if row[0] == "":
    return false
  else:
    return true


proc filterCountryTimezone*(
       dbContext: NexusCoreExtrasDbContext,
       whereClause: string = "",
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): CountryTimezones {.gcsafe.} =

  var selectStatement =
    "select country_code, timezone, created" & 
    "  from country_timezone"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  if len(orderByFields) > 0:
    selectStatement &= " order by " & orderByFields.join(", ")

  if limit != none(int):
    selectStatement &= " limit " & $limit.get

  var countryTimezones: CountryTimezones

  for row in fastRows(dbContext.dbConn,
                      sql(selectStatement),
                      whereValues):

    countryTimezones.add(rowToCountryTimezone(row))

  return countryTimezones


proc filterCountryTimezone*(
       dbContext: NexusCoreExtrasDbContext,
       whereFields: seq[string],
       whereValues: seq[string],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): CountryTimezones {.gcsafe.} =

  var selectStatement =
    "select country_code, timezone, created" & 
    "  from country_timezone"

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

  var countryTimezones: CountryTimezones

  for row in fastRows(dbContext.dbConn,
                      sql(selectStatement),
                      whereValues):

    countryTimezones.add(rowToCountryTimezone(row))

  return countryTimezones


proc getCountryTimezoneByCountryCodeAndTimezone*(
       dbContext: NexusCoreExtrasDbContext,
       countryCode: string,
       timezone: string): Option[CountryTimezone] {.gcsafe.} =

  var selectStatement =
    "select country_code, timezone, created" & 
    "  from country_timezone" &
    " where country_code = ?" &
    "   and timezone = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              countryCode,
              timezone)

  if row[0] == "":
    return none(CountryTimezone)

  return some(rowToCountryTimezone(row))


proc getOrCreateCountryTimezoneByCountryCodeAndTimezone*(
       dbContext: NexusCoreExtrasDbContext,
       countryCode: string,
       timezone: string,
       created: DateTime): CountryTimezone {.gcsafe.} =

  let countryTimezone =
        getCountryTimezoneByCountryCodeAndTimezone(
          dbContext,
          countryCode,
          timezone)

  if countryTimezone != none(CountryTimezone):
    return countryTimezone.get

  return createCountryTimezone(
           dbContext,
           countryCode,
           timezone,
           created)


proc rowToCountryTimezone*(row: seq[string]):
       CountryTimezone {.gcsafe.} =

  var countryTimezone = CountryTimezone()

  countryTimezone.countryCode = row[0]
  countryTimezone.timezone = row[1]
  countryTimezone.created = parsePgTimestamp(row[2])

  return countryTimezone


proc truncateCountryTimezone*(
       dbContext: NexusCoreExtrasDbContext,
       cascade: bool = false) =

  if cascade == false:
    exec(dbContext.dbConn,
         sql("truncate table country_timezone restart identity;"))

  else:
    exec(dbContext.dbConn,
         sql("truncate table country_timezone restart identity cascade;"))


proc updateCountryTimezoneSetClause*(
       countryTimezone: CountryTimezone,
       setFields: seq[string],
       updateStatement: var string,
       updateValues: var seq[string]) {.gcsafe.} =

  updateStatement =
    "update country_timezone" &
    "   set "

  for field in setFields:

    if field == "country_code":
      updateStatement &= "       country_code = ?,"
      updateValues.add(countryTimezone.countryCode)

    elif field == "timezone":
      updateStatement &= "       timezone = ?,"
      updateValues.add(countryTimezone.timezone)

    elif field == "created":
        updateStatement &= "       created = " & pgToDateTimeString(countryTimezone.created) & ","

  updateStatement[len(updateStatement) - 1] = ' '



proc updateCountryTimezoneByWhereClause*(
       dbContext: NexusCoreExtrasDbContext,
       countryTimezone: CountryTimezone,
       setFields: seq[string],
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateCountryTimezoneSetClause(
    country_timezone,
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


proc updateCountryTimezoneByWhereEqOnly*(
       dbContext: NexusCoreExtrasDbContext,
       countryTimezone: CountryTimezone,
       setFields: seq[string],
       whereFields: seq[string],
       whereValues: seq[string]): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateCountryTimezoneSetClause(
    country_timezone,
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


