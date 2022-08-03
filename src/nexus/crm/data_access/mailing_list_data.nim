# Nexus generated file
import db_postgres, options, sequtils, strutils, times
import nexus/core/data_access/data_utils
import nexus/core/data_access/pg_try_insert_id
import nexus/crm/types/model_types


# Forward declarations
proc rowToMailingList*(row: seq[string]):
       MailingList {.gcsafe.}


# Code
proc countMailingList*(
       nexusCRMDbContext: NexusCRMDbContext,
       whereFields: seq[string] = @[],
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from mailing_list"
  var first = true

  for whereField in whereFields:

    var whereClause: string

    if first == false:
      whereClause = "   and " & whereField & " = ?"
    else:
      first = false
      whereClause = " where " & whereField & " = ?"

    selectStatement &= whereClause

  let row = getRow(nexusCRMDbContext.dbConn,
                   sql(selectStatement),
                   whereValues)

  return parseBiggestInt(row[0])


proc countMailingList*(
       nexusCRMDbContext: NexusCRMDbContext,
       whereClause: string,
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from mailing_list"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  let row = getRow(nexusCRMDbContext.dbConn,
                   sql(selectStatement),
                   whereValues)

  return parseBiggestInt(row[0])


proc createMailingListReturnsPk*(
       nexusCRMDbContext: NexusCRMDbContext,
       accountUserId: int64,
       uniqueHash: string,
       name: string,
       created: DateTime,
       deleted: Option[DateTime] = none(DateTime),
       ignoreExistingPk: bool = false): int64 {.gcsafe.} =

  # Formulate insertStatement and insertValues
  var
    insertValues: seq[string]
    insertStatement = "insert into mailing_list ("
    valuesClause = ""

  # Field: Account User Id
  insertStatement &= "account_user_id, "
  valuesClause &= "?, "
  insertValues.add($accountUserId)

  # Field: Unique Hash
  insertStatement &= "unique_hash, "
  valuesClause &= "?" & ", "
  insertValues.add(uniqueHash)

  # Field: Name
  insertStatement &= "name, "
  valuesClause &= "?" & ", "
  insertValues.add(name)

  # Field: Created
  insertStatement &= "created, "
  valuesClause &= pgToDateTimeString(created) & ", "

  # Field: Deleted
  if deleted != none(DateTime):
    insertStatement &= "deleted, "
    valuesClause &= pgToDateTimeString(deleted.get) & ", "

  # Remove trailing commas and finalize insertStatement
  if insertStatement[len(insertStatement) - 2 .. len(insertStatement) - 1] == ", ":
    insertStatement = insertStatement[0 .. len(insertStatement) - 3]

  if valuesClause[len(valuesClause) - 2 .. len(valuesClause) - 1] == ", ":
    valuesClause = valuesClause[0 .. len(valuesClause) - 3]

  # Finalize insertStatement
  insertStatement &=
    ") values (" & valuesClause & ")"

  if ignoreExistingPk == true:
    insertStatement &= " on conflict (mailing_list_id) do nothing"

  # Execute the insert statement and return the sequence values
  return tryInsertNamedID(
    nexusCRMDbContext.dbConn,
    sql(insertStatement),
    "mailing_list_id",
    insertValues)


proc createMailingList*(
       nexusCRMDbContext: NexusCRMDbContext,
       accountUserId: int64,
       uniqueHash: string,
       name: string,
       created: DateTime,
       deleted: Option[DateTime] = none(DateTime),
       ignoreExistingPk: bool = false,
       copyAllStringFields: bool = true,
       convertToRawTypes: bool = true): MailingList {.gcsafe.} =

  var mailingList = MailingList()

  mailingList.mailingListId =
    createMailingListReturnsPk(
      nexusCRMDbContext,
      accountUserId,
      uniqueHash,
      name,
      created,
      deleted,
      ignoreExistingPk)

  # Copy all fields as strings
  mailingList.accountUserId = accountUserId
  mailingList.uniqueHash = uniqueHash
  mailingList.name = name
  mailingList.created = created
  mailingList.deleted = deleted

  return mailingList


proc deleteMailingListByPk*(
       nexusCRMDbContext: NexusCRMDbContext,
       mailingListId: int64): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from mailing_list" &
    " where mailing_list_id = ?"

  return execAffectedRows(
           nexusCRMDbContext.dbConn,
           sql(deleteStatement),
           mailingListId)


proc deleteMailingList*(
       nexusCRMDbContext: NexusCRMDbContext,
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from mailing_list" &
    " where " & whereClause

  return execAffectedRows(
           nexusCRMDbContext.dbConn,
           sql(deleteStatement),
           whereValues)


proc deleteMailingList*(
       nexusCRMDbContext: NexusCRMDbContext,
       whereFields: seq[string],
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from mailing_list"

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
           nexusCRMDbContext.dbConn,
           sql(deleteStatement),
           whereValues)


proc existsMailingListByPk*(
       nexusCRMDbContext: NexusCRMDbContext,
       mailingListId: int64): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from mailing_list" &
    " where mailing_list_id = ?"

  let row = getRow(
              nexusCRMDbContext.dbConn,
              sql(selectStatement),
              $mailingListId)

  if row[0] == "":
    return false
  else:
    return true


proc existsMailingListByUniqueHash*(
       nexusCRMDbContext: NexusCRMDbContext,
       uniqueHash: string): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from mailing_list" &
    " where unique_hash = ?"

  let row = getRow(
              nexusCRMDbContext.dbConn,
              sql(selectStatement),
              uniqueHash)

  if row[0] == "":
    return false
  else:
    return true


proc existsMailingListByAccountUserIdAndName*(
       nexusCRMDbContext: NexusCRMDbContext,
       accountUserId: int64,
       name: string): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from mailing_list" &
    " where account_user_id = ?" &
    "   and name = ?"

  let row = getRow(
              nexusCRMDbContext.dbConn,
              sql(selectStatement),
              $accountUserId,
              name)

  if row[0] == "":
    return false
  else:
    return true


proc filterMailingList*(
       nexusCRMDbContext: NexusCRMDbContext,
       whereClause: string = "",
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): MailingLists {.gcsafe.} =

  var selectStatement =
    "select mailing_list_id, account_user_id, unique_hash, name, created, deleted" & 
    "  from mailing_list"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  if len(orderByFields) > 0:
    selectStatement &= " order by " & orderByFields.join(", ")

  if limit != none(int):
    selectStatement &= " limit " & $limit.get

  var mailingLists: MailingLists

  for row in fastRows(nexusCRMDbContext.dbConn,
                      sql(selectStatement),
                      whereValues):

    mailingLists.add(rowToMailingList(row))

  return mailingLists


proc filterMailingList*(
       nexusCRMDbContext: NexusCRMDbContext,
       whereFields: seq[string],
       whereValues: seq[string],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): MailingLists {.gcsafe.} =

  var selectStatement =
    "select mailing_list_id, account_user_id, unique_hash, name, created, deleted" & 
    "  from mailing_list"

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

  var mailingLists: MailingLists

  for row in fastRows(nexusCRMDbContext.dbConn,
                      sql(selectStatement),
                      whereValues):

    mailingLists.add(rowToMailingList(row))

  return mailingLists


proc getMailingListByPk*(
       nexusCRMDbContext: NexusCRMDbContext,
       mailingListId: int64): Option[MailingList] {.gcsafe.} =

  var selectStatement =
    "select mailing_list_id, account_user_id, unique_hash, name, created, deleted" & 
    "  from mailing_list" &
    " where mailing_list_id = ?"

  let row = getRow(
              nexusCRMDbContext.dbConn,
              sql(selectStatement),
              mailingListId)

  if row[0] == "":
    return none(MailingList)

  return some(rowToMailingList(row))


proc getMailingListByPk*(
       nexusCRMDbContext: NexusCRMDbContext,
       mailingListId: string): Option[MailingList] {.gcsafe.} =

  var selectStatement =
    "select mailing_list_id, account_user_id, unique_hash, name, created, deleted" & 
    "  from mailing_list" &
    " where mailing_list_id = ?"

  let row = getRow(
              nexusCRMDbContext.dbConn,
              sql(selectStatement),
              mailingListId)

  if row[0] == "":
    return none(MailingList)

  return some(rowToMailingList(row))


proc getMailingListByUniqueHash*(
       nexusCRMDbContext: NexusCRMDbContext,
       uniqueHash: string): Option[MailingList] {.gcsafe.} =

  var selectStatement =
    "select mailing_list_id, account_user_id, unique_hash, name, created, deleted" & 
    "  from mailing_list" &
    " where unique_hash = ?"

  let row = getRow(
              nexusCRMDbContext.dbConn,
              sql(selectStatement),
              uniqueHash)

  if row[0] == "":
    return none(MailingList)

  return some(rowToMailingList(row))


proc getMailingListByAccountUserIdAndName*(
       nexusCRMDbContext: NexusCRMDbContext,
       accountUserId: int64,
       name: string): Option[MailingList] {.gcsafe.} =

  var selectStatement =
    "select mailing_list_id, account_user_id, unique_hash, name, created, deleted" & 
    "  from mailing_list" &
    " where account_user_id = ?" &
    "   and name = ?"

  let row = getRow(
              nexusCRMDbContext.dbConn,
              sql(selectStatement),
              accountUserId,
              name)

  if row[0] == "":
    return none(MailingList)

  return some(rowToMailingList(row))


proc getOrCreateMailingListByUniqueHash*(
       nexusCRMDbContext: NexusCRMDbContext,
       accountUserId: int64,
       uniqueHash: string,
       name: string,
       created: DateTime,
       deleted: Option[DateTime]): MailingList {.gcsafe.} =

  let mailingList =
        getMailingListByUniqueHash(
          nexusCRMDbContext,
          uniqueHash)

  if mailingList != none(MailingList):
    return mailingList.get

  return createMailingList(
           nexusCRMDbContext,
           accountUserId,
           uniqueHash,
           name,
           created,
           deleted)


proc getOrCreateMailingListByAccountUserIdAndName*(
       nexusCRMDbContext: NexusCRMDbContext,
       accountUserId: int64,
       uniqueHash: string,
       name: string,
       created: DateTime,
       deleted: Option[DateTime]): MailingList {.gcsafe.} =

  let mailingList =
        getMailingListByAccountUserIdAndName(
          nexusCRMDbContext,
          accountUserId,
          name)

  if mailingList != none(MailingList):
    return mailingList.get

  return createMailingList(
           nexusCRMDbContext,
           accountUserId,
           uniqueHash,
           name,
           created,
           deleted)


proc rowToMailingList*(row: seq[string]):
       MailingList {.gcsafe.} =

  var mailingList = MailingList()

  mailingList.mailingListId = parseBiggestInt(row[0])
  mailingList.accountUserId = parseBiggestInt(row[1])
  mailingList.uniqueHash = row[2]
  mailingList.name = row[3]
  mailingList.created = parsePgTimestamp(row[4])

  if row[5] != "":
    mailingList.deleted = some(parsePgTimestamp(row[5]))
  else:
    mailingList.deleted = none(DateTime)


  return mailingList


proc truncateMailingList*(
       nexusCRMDbContext: NexusCRMDbContext,
       cascade: bool = false) =

  if cascade == false:
    exec(nexusCRMDbContext.dbConn,
         sql("truncate table mailing_list restart identity;"))

  else:
    exec(nexusCRMDbContext.dbConn,
         sql("truncate table mailing_list restart identity cascade;"))


proc updateMailingListSetClause*(
       mailingList: MailingList,
       setFields: seq[string],
       updateStatement: var string,
       updateValues: var seq[string]) {.gcsafe.} =

  updateStatement =
    "update mailing_list" &
    "   set "

  for field in setFields:

    if field == "mailing_list_id":
      updateStatement &= "       mailing_list_id = ?,"
      updateValues.add($mailingList.mailingListId)

    elif field == "account_user_id":
      updateStatement &= "       account_user_id = ?,"
      updateValues.add($mailingList.accountUserId)

    elif field == "unique_hash":
      updateStatement &= "       unique_hash = ?,"
      updateValues.add(mailingList.uniqueHash)

    elif field == "name":
      updateStatement &= "       name = ?,"
      updateValues.add(mailingList.name)

    elif field == "created":
        updateStatement &= "       created = " & pgToDateTimeString(mailingList.created) & ","

    elif field == "deleted":
      if mailingList.deleted != none(DateTime):
        updateStatement &= "       deleted = " & pgToDateTimeString(mailingList.deleted.get) & ","
      else:
        updateStatement &= "       deleted = null,"

  updateStatement[len(updateStatement) - 1] = ' '



proc updateMailingListByPk*(
       nexusCRMDbContext: NexusCRMDbContext,
       mailingList: MailingList,
       setFields: seq[string],
       exceptionOnNRowsUpdated: bool = true): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateMailingListSetClause(
    mailing_list,
    setFields,
    updateStatement,
    updateValues)

  updateStatement &= " where mailing_list_id = ?"

  updateValues.add($mailingList.mailingListId)

  let rowsUpdated = 
        execAffectedRows(
          nexusCRMDbContext.dbConn,
          sql(updateStatement),
          updateValues)

  # Exception on no rows updated
  if rowsUpdated == 0 and
     exceptionOnNRowsUpdated == true:

    raise newException(ValueError,
                       "no rows updated")

  # Return rows updated
  return rowsUpdated


proc updateMailingListByWhereClause*(
       nexusCRMDbContext: NexusCRMDbContext,
       mailingList: MailingList,
       setFields: seq[string],
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateMailingListSetClause(
    mailing_list,
    setFields,
    updateStatement,
    updateValues)

  if whereClause != "":
    updateStatement &= " where " & whereClause

  return execAffectedRows(
           nexusCRMDbContext.dbConn,
           sql(updateStatement),
           concat(updateValues,
                  whereValues))


proc updateMailingListByWhereEqOnly*(
       nexusCRMDbContext: NexusCRMDbContext,
       mailingList: MailingList,
       setFields: seq[string],
       whereFields: seq[string],
       whereValues: seq[string]): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateMailingListSetClause(
    mailing_list,
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
           nexusCRMDbContext.dbConn,
           sql(updateStatement),
           concat(updateValues,
                  whereValues))


