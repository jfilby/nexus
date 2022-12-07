# Nexus generated file
import db_postgres, options, sequtils, strutils, times
import nexus/core/data_access/data_utils
import nexus/core/data_access/pg_try_insert_id
import nexus/crm/types/model_types


# Forward declarations
proc rowToMailingListMessage*(row: seq[string]):
       MailingListMessage {.gcsafe.}


# Code
proc countMailingListMessage*(
       dbContext: NexusCRMDbContext,
       whereFields: seq[string] = @[],
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from mailing_list_message"
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


proc countMailingListMessage*(
       dbContext: NexusCRMDbContext,
       whereClause: string,
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from mailing_list_message"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  let row = getRow(dbContext.dbConn,
                   sql(selectStatement),
                   whereValues)

  return parseBiggestInt(row[0])


proc createMailingListMessageReturnsPk*(
       dbContext: NexusCRMDbContext,
       accountUserId: int64,
       uniqueHash: string,
       subject: string,
       message: string,
       created: DateTime,
       updated: Option[DateTime] = none(DateTime),
       deleted: Option[DateTime] = none(DateTime),
       ignoreExistingPk: bool = false): int64 {.gcsafe.} =

  # Formulate insertStatement and insertValues
  var
    insertValues: seq[string]
    insertStatement = "insert into mailing_list_message ("
    valuesClause = ""

  # Field: Account User Id
  insertStatement &= "account_user_id, "
  valuesClause &= "?, "
  insertValues.add($accountUserId)

  # Field: Unique Hash
  insertStatement &= "unique_hash, "
  valuesClause &= "?" & ", "
  insertValues.add(uniqueHash)

  # Field: Subject
  insertStatement &= "subject, "
  valuesClause &= "?" & ", "
  insertValues.add(subject)

  # Field: Message
  insertStatement &= "message, "
  valuesClause &= "?" & ", "
  insertValues.add(message)

  # Field: Created
  insertStatement &= "created, "
  valuesClause &= pgToDateTimeString(created) & ", "

  # Field: Updated
  if updated != none(DateTime):
    insertStatement &= "updated, "
    valuesClause &= pgToDateTimeString(updated.get) & ", "

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
    insertStatement &= " on conflict (mailing_list_message_id) do nothing"

  # Execute the insert statement and return the sequence values
  return tryInsertNamedID(
    dbContext.dbConn,
    sql(insertStatement),
    "mailing_list_message_id",
    insertValues)


proc createMailingListMessage*(
       dbContext: NexusCRMDbContext,
       accountUserId: int64,
       uniqueHash: string,
       subject: string,
       message: string,
       created: DateTime,
       updated: Option[DateTime] = none(DateTime),
       deleted: Option[DateTime] = none(DateTime),
       ignoreExistingPk: bool = false,
       copyAllStringFields: bool = true,
       convertToRawTypes: bool = true): MailingListMessage {.gcsafe.} =

  var mailingListMessage = MailingListMessage()

  mailingListMessage.mailingListMessageId =
    createMailingListMessageReturnsPk(
      dbContext,
      accountUserId,
      uniqueHash,
      subject,
      message,
      created,
      updated,
      deleted,
      ignoreExistingPk)

  # Copy all fields as strings
  mailingListMessage.accountUserId = accountUserId
  mailingListMessage.uniqueHash = uniqueHash
  mailingListMessage.subject = subject
  mailingListMessage.message = message
  mailingListMessage.created = created
  mailingListMessage.updated = updated
  mailingListMessage.deleted = deleted

  return mailingListMessage


proc deleteMailingListMessageByPk*(
       dbContext: NexusCRMDbContext,
       mailingListMessageId: int64): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from mailing_list_message" &
    " where mailing_list_message_id = ?"

  return execAffectedRows(
           dbContext.dbConn,
           sql(deleteStatement),
           mailingListMessageId)


proc deleteMailingListMessage*(
       dbContext: NexusCRMDbContext,
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from mailing_list_message" &
    " where " & whereClause

  return execAffectedRows(
           dbContext.dbConn,
           sql(deleteStatement),
           whereValues)


proc deleteMailingListMessage*(
       dbContext: NexusCRMDbContext,
       whereFields: seq[string],
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from mailing_list_message"

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


proc existsMailingListMessageByPk*(
       dbContext: NexusCRMDbContext,
       mailingListMessageId: int64): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from mailing_list_message" &
    " where mailing_list_message_id = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              $mailingListMessageId)

  if row[0] == "":
    return false
  else:
    return true


proc existsMailingListMessageByUniqueHash*(
       dbContext: NexusCRMDbContext,
       uniqueHash: string): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from mailing_list_message" &
    " where unique_hash = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              uniqueHash)

  if row[0] == "":
    return false
  else:
    return true


proc filterMailingListMessage*(
       dbContext: NexusCRMDbContext,
       whereClause: string = "",
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): MailingListMessages {.gcsafe.} =

  var selectStatement =
    "select mailing_list_message_id, account_user_id, unique_hash, subject, message, created, updated," & 
    "       deleted" &
    "  from mailing_list_message"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  if len(orderByFields) > 0:
    selectStatement &= " order by " & orderByFields.join(", ")

  if limit != none(int):
    selectStatement &= " limit " & $limit.get

  var mailingListMessages: MailingListMessages

  for row in fastRows(dbContext.dbConn,
                      sql(selectStatement),
                      whereValues):

    mailingListMessages.add(rowToMailingListMessage(row))

  return mailingListMessages


proc filterMailingListMessage*(
       dbContext: NexusCRMDbContext,
       whereFields: seq[string],
       whereValues: seq[string],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): MailingListMessages {.gcsafe.} =

  var selectStatement =
    "select mailing_list_message_id, account_user_id, unique_hash, subject, message, created, updated," & 
    "       deleted" &
    "  from mailing_list_message"

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

  var mailingListMessages: MailingListMessages

  for row in fastRows(dbContext.dbConn,
                      sql(selectStatement),
                      whereValues):

    mailingListMessages.add(rowToMailingListMessage(row))

  return mailingListMessages


proc getMailingListMessageByPk*(
       dbContext: NexusCRMDbContext,
       mailingListMessageId: int64): Option[MailingListMessage] {.gcsafe.} =

  var selectStatement =
    "select mailing_list_message_id, account_user_id, unique_hash, subject, message, created, updated," & 
    "       deleted" &
    "  from mailing_list_message" &
    " where mailing_list_message_id = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              mailingListMessageId)

  if row[0] == "":
    return none(MailingListMessage)

  return some(rowToMailingListMessage(row))


proc getMailingListMessageByPk*(
       dbContext: NexusCRMDbContext,
       mailingListMessageId: string): Option[MailingListMessage] {.gcsafe.} =

  var selectStatement =
    "select mailing_list_message_id, account_user_id, unique_hash, subject, message, created, updated," & 
    "       deleted" &
    "  from mailing_list_message" &
    " where mailing_list_message_id = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              mailingListMessageId)

  if row[0] == "":
    return none(MailingListMessage)

  return some(rowToMailingListMessage(row))


proc getMailingListMessageByUniqueHash*(
       dbContext: NexusCRMDbContext,
       uniqueHash: string): Option[MailingListMessage] {.gcsafe.} =

  var selectStatement =
    "select mailing_list_message_id, account_user_id, unique_hash, subject, message, created, updated," & 
    "       deleted" &
    "  from mailing_list_message" &
    " where unique_hash = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              uniqueHash)

  if row[0] == "":
    return none(MailingListMessage)

  return some(rowToMailingListMessage(row))


proc getOrCreateMailingListMessageByUniqueHash*(
       dbContext: NexusCRMDbContext,
       accountUserId: int64,
       uniqueHash: string,
       subject: string,
       message: string,
       created: DateTime,
       updated: Option[DateTime],
       deleted: Option[DateTime]): MailingListMessage {.gcsafe.} =

  let mailingListMessage =
        getMailingListMessageByUniqueHash(
          dbContext,
          uniqueHash)

  if mailingListMessage != none(MailingListMessage):
    return mailingListMessage.get

  return createMailingListMessage(
           dbContext,
           accountUserId,
           uniqueHash,
           subject,
           message,
           created,
           updated,
           deleted)


proc rowToMailingListMessage*(row: seq[string]):
       MailingListMessage {.gcsafe.} =

  var mailingListMessage = MailingListMessage()

  mailingListMessage.mailingListMessageId = parseBiggestInt(row[0])
  mailingListMessage.accountUserId = parseBiggestInt(row[1])
  mailingListMessage.uniqueHash = row[2]
  mailingListMessage.subject = row[3]
  mailingListMessage.message = row[4]
  mailingListMessage.created = parsePgTimestamp(row[5])

  if row[6] != "":
    mailingListMessage.updated = some(parsePgTimestamp(row[6]))
  else:
    mailingListMessage.updated = none(DateTime)

  if row[7] != "":
    mailingListMessage.deleted = some(parsePgTimestamp(row[7]))
  else:
    mailingListMessage.deleted = none(DateTime)


  return mailingListMessage


proc truncateMailingListMessage*(
       dbContext: NexusCRMDbContext,
       cascade: bool = false) =

  if cascade == false:
    exec(dbContext.dbConn,
         sql("truncate table mailing_list_message restart identity;"))

  else:
    exec(dbContext.dbConn,
         sql("truncate table mailing_list_message restart identity cascade;"))


proc updateMailingListMessageSetClause*(
       mailingListMessage: MailingListMessage,
       setFields: seq[string],
       updateStatement: var string,
       updateValues: var seq[string]) {.gcsafe.} =

  updateStatement =
    "update mailing_list_message" &
    "   set "

  for field in setFields:

    if field == "mailing_list_message_id":
      updateStatement &= "       mailing_list_message_id = ?,"
      updateValues.add($mailingListMessage.mailingListMessageId)

    elif field == "account_user_id":
      updateStatement &= "       account_user_id = ?,"
      updateValues.add($mailingListMessage.accountUserId)

    elif field == "unique_hash":
      updateStatement &= "       unique_hash = ?,"
      updateValues.add(mailingListMessage.uniqueHash)

    elif field == "subject":
      updateStatement &= "       subject = ?,"
      updateValues.add(mailingListMessage.subject)

    elif field == "message":
      updateStatement &= "       message = ?,"
      updateValues.add(mailingListMessage.message)

    elif field == "created":
        updateStatement &= "       created = " & pgToDateTimeString(mailingListMessage.created) & ","

    elif field == "updated":
      if mailingListMessage.updated != none(DateTime):
        updateStatement &= "       updated = " & pgToDateTimeString(mailingListMessage.updated.get) & ","
      else:
        updateStatement &= "       updated = null,"

    elif field == "deleted":
      if mailingListMessage.deleted != none(DateTime):
        updateStatement &= "       deleted = " & pgToDateTimeString(mailingListMessage.deleted.get) & ","
      else:
        updateStatement &= "       deleted = null,"

  updateStatement[len(updateStatement) - 1] = ' '



proc updateMailingListMessageByPk*(
       dbContext: NexusCRMDbContext,
       mailingListMessage: MailingListMessage,
       setFields: seq[string],
       exceptionOnNRowsUpdated: bool = true): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateMailingListMessageSetClause(
    mailing_list_message,
    setFields,
    updateStatement,
    updateValues)

  updateStatement &= " where mailing_list_message_id = ?"

  updateValues.add($mailingListMessage.mailingListMessageId)

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


proc updateMailingListMessageByWhereClause*(
       dbContext: NexusCRMDbContext,
       mailingListMessage: MailingListMessage,
       setFields: seq[string],
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateMailingListMessageSetClause(
    mailing_list_message,
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


proc updateMailingListMessageByWhereEqOnly*(
       dbContext: NexusCRMDbContext,
       mailingListMessage: MailingListMessage,
       setFields: seq[string],
       whereFields: seq[string],
       whereValues: seq[string]): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateMailingListMessageSetClause(
    mailing_list_message,
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


