# Nexus generated file
import db_postgres, options, sequtils, strutils, times
import nexus/core/data_access/data_utils
import nexus/core/data_access/pg_try_insert_id
import nexus/crm/types/model_types


# Forward declarations
proc rowToMailingListSubscriberMessage*(row: seq[string]):
       MailingListSubscriberMessage {.gcsafe.}


# Code
proc countMailingListSubscriberMessage*(
       dbContext: NexusCRMDbContext,
       whereFields: seq[string] = @[],
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from mailing_list_subscriber_message"
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


proc countMailingListSubscriberMessage*(
       dbContext: NexusCRMDbContext,
       whereClause: string,
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from mailing_list_subscriber_message"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  let row = getRow(dbContext.dbConn,
                   sql(selectStatement),
                   whereValues)

  return parseBiggestInt(row[0])


proc createMailingListSubscriberMessageReturnsPk*(
       dbContext: NexusCRMDbContext,
       accountUserId: Option[int64] = none(int64),
       mailingListId: int64,
       mailingListSubscriberId: int64,
       mailingListMessageId: int64,
       created: DateTime,
       ignoreExistingPk: bool = false): int64 {.gcsafe.} =

  # Formulate insertStatement and insertValues
  var
    insertValues: seq[string]
    insertStatement = "insert into mailing_list_subscriber_message ("
    valuesClause = ""

  # Field: Account User Id
  if accountUserId != none(int64):
    insertStatement &= "account_user_id, "
    valuesClause &= "?, "
    insertValues.add($accountUserId.get)

  # Field: Mailing List Id
  insertStatement &= "mailing_list_id, "
  valuesClause &= "?, "
  insertValues.add($mailingListId)

  # Field: Mailing List Subscriber Id
  insertStatement &= "mailing_list_subscriber_id, "
  valuesClause &= "?, "
  insertValues.add($mailingListSubscriberId)

  # Field: Mailing List Message Id
  insertStatement &= "mailing_list_message_id, "
  valuesClause &= "?, "
  insertValues.add($mailingListMessageId)

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
  return tryInsertNamedID(
    dbContext.dbConn,
    sql(insertStatement),
    "id",
    insertValues)


proc createMailingListSubscriberMessage*(
       dbContext: NexusCRMDbContext,
       accountUserId: Option[int64] = none(int64),
       mailingListId: int64,
       mailingListSubscriberId: int64,
       mailingListMessageId: int64,
       created: DateTime,
       ignoreExistingPk: bool = false,
       copyAllStringFields: bool = true,
       convertToRawTypes: bool = true): MailingListSubscriberMessage {.gcsafe.} =

  var mailingListSubscriberMessage = MailingListSubscriberMessage()

  mailingListSubscriberMessage.id =
    createMailingListSubscriberMessageReturnsPk(
      dbContext,
      accountUserId,
      mailingListId,
      mailingListSubscriberId,
      mailingListMessageId,
      created,
      ignoreExistingPk)

  # Copy all fields as strings
  mailingListSubscriberMessage.accountUserId = accountUserId
  mailingListSubscriberMessage.mailingListId = mailingListId
  mailingListSubscriberMessage.mailingListSubscriberId = mailingListSubscriberId
  mailingListSubscriberMessage.mailingListMessageId = mailingListMessageId
  mailingListSubscriberMessage.created = created

  return mailingListSubscriberMessage


proc deleteMailingListSubscriberMessageByPk*(
       dbContext: NexusCRMDbContext,
       id: int64): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from mailing_list_subscriber_message" &
    " where id = ?"

  return execAffectedRows(
           dbContext.dbConn,
           sql(deleteStatement),
           id)


proc deleteMailingListSubscriberMessage*(
       dbContext: NexusCRMDbContext,
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from mailing_list_subscriber_message" &
    " where " & whereClause

  return execAffectedRows(
           dbContext.dbConn,
           sql(deleteStatement),
           whereValues)


proc deleteMailingListSubscriberMessage*(
       dbContext: NexusCRMDbContext,
       whereFields: seq[string],
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from mailing_list_subscriber_message"

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


proc existsMailingListSubscriberMessageByPk*(
       dbContext: NexusCRMDbContext,
       id: int64): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from mailing_list_subscriber_message" &
    " where id = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              $id)

  if row[0] == "":
    return false
  else:
    return true


proc existsMailingListSubscriberMessageByMailingListSubscriberIdAndMailingListMessageId*(
       dbContext: NexusCRMDbContext,
       mailingListSubscriberId: int64,
       mailingListMessageId: int64): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from mailing_list_subscriber_message" &
    " where mailing_list_subscriber_id = ?" &
    "   and mailing_list_message_id = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              $mailingListSubscriberId,
              $mailingListMessageId)

  if row[0] == "":
    return false
  else:
    return true


proc filterMailingListSubscriberMessage*(
       dbContext: NexusCRMDbContext,
       whereClause: string = "",
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): MailingListSubscriberMessages {.gcsafe.} =

  var selectStatement =
    "select id, account_user_id, mailing_list_id, mailing_list_subscriber_id, mailing_list_message_id," & 
    "       created" &
    "  from mailing_list_subscriber_message"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  if len(orderByFields) > 0:
    selectStatement &= " order by " & orderByFields.join(", ")

  if limit != none(int):
    selectStatement &= " limit " & $limit.get

  var mailingListSubscriberMessages: MailingListSubscriberMessages

  for row in fastRows(dbContext.dbConn,
                      sql(selectStatement),
                      whereValues):

    mailingListSubscriberMessages.add(rowToMailingListSubscriberMessage(row))

  return mailingListSubscriberMessages


proc filterMailingListSubscriberMessage*(
       dbContext: NexusCRMDbContext,
       whereFields: seq[string],
       whereValues: seq[string],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): MailingListSubscriberMessages {.gcsafe.} =

  var selectStatement =
    "select id, account_user_id, mailing_list_id, mailing_list_subscriber_id, mailing_list_message_id," & 
    "       created" &
    "  from mailing_list_subscriber_message"

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

  var mailingListSubscriberMessages: MailingListSubscriberMessages

  for row in fastRows(dbContext.dbConn,
                      sql(selectStatement),
                      whereValues):

    mailingListSubscriberMessages.add(rowToMailingListSubscriberMessage(row))

  return mailingListSubscriberMessages


proc getMailingListSubscriberMessageByPk*(
       dbContext: NexusCRMDbContext,
       id: int64): Option[MailingListSubscriberMessage] {.gcsafe.} =

  var selectStatement =
    "select id, account_user_id, mailing_list_id, mailing_list_subscriber_id, mailing_list_message_id," & 
    "       created" &
    "  from mailing_list_subscriber_message" &
    " where id = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              id)

  if row[0] == "":
    return none(MailingListSubscriberMessage)

  return some(rowToMailingListSubscriberMessage(row))


proc getMailingListSubscriberMessageByPk*(
       dbContext: NexusCRMDbContext,
       id: string): Option[MailingListSubscriberMessage] {.gcsafe.} =

  var selectStatement =
    "select id, account_user_id, mailing_list_id, mailing_list_subscriber_id, mailing_list_message_id," & 
    "       created" &
    "  from mailing_list_subscriber_message" &
    " where id = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              id)

  if row[0] == "":
    return none(MailingListSubscriberMessage)

  return some(rowToMailingListSubscriberMessage(row))


proc getMailingListSubscriberMessageByMailingListSubscriberIdAndMailingListMessageId*(
       dbContext: NexusCRMDbContext,
       mailingListSubscriberId: int64,
       mailingListMessageId: int64): Option[MailingListSubscriberMessage] {.gcsafe.} =

  var selectStatement =
    "select id, account_user_id, mailing_list_id, mailing_list_subscriber_id, mailing_list_message_id," & 
    "       created" &
    "  from mailing_list_subscriber_message" &
    " where mailing_list_subscriber_id = ?" &
    "   and mailing_list_message_id = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              mailingListSubscriberId,
              mailingListMessageId)

  if row[0] == "":
    return none(MailingListSubscriberMessage)

  return some(rowToMailingListSubscriberMessage(row))


proc getOrCreateMailingListSubscriberMessageByMailingListSubscriberIdAndMailingListMessageId*(
       dbContext: NexusCRMDbContext,
       accountUserId: Option[int64],
       mailingListId: int64,
       mailingListSubscriberId: int64,
       mailingListMessageId: int64,
       created: DateTime): MailingListSubscriberMessage {.gcsafe.} =

  let mailingListSubscriberMessage =
        getMailingListSubscriberMessageByMailingListSubscriberIdAndMailingListMessageId(
          dbContext,
          mailingListSubscriberId,
          mailingListMessageId)

  if mailingListSubscriberMessage != none(MailingListSubscriberMessage):
    return mailingListSubscriberMessage.get

  return createMailingListSubscriberMessage(
           dbContext,
           accountUserId,
           mailingListId,
           mailingListSubscriberId,
           mailingListMessageId,
           created)


proc rowToMailingListSubscriberMessage*(row: seq[string]):
       MailingListSubscriberMessage {.gcsafe.} =

  var mailingListSubscriberMessage = MailingListSubscriberMessage()

  mailingListSubscriberMessage.id = parseBiggestInt(row[0])

  if row[1] != "":
    mailingListSubscriberMessage.accountUserId = some(parseBiggestInt(row[1]))
  else:
    mailingListSubscriberMessage.accountUserId = none(int64)

  mailingListSubscriberMessage.mailingListId = parseBiggestInt(row[2])
  mailingListSubscriberMessage.mailingListSubscriberId = parseBiggestInt(row[3])
  mailingListSubscriberMessage.mailingListMessageId = parseBiggestInt(row[4])
  mailingListSubscriberMessage.created = parsePgTimestamp(row[5])

  return mailingListSubscriberMessage


proc truncateMailingListSubscriberMessage*(
       dbContext: NexusCRMDbContext,
       cascade: bool = false) =

  if cascade == false:
    exec(dbContext.dbConn,
         sql("truncate table mailing_list_subscriber_message restart identity;"))

  else:
    exec(dbContext.dbConn,
         sql("truncate table mailing_list_subscriber_message restart identity cascade;"))


proc updateMailingListSubscriberMessageSetClause*(
       mailingListSubscriberMessage: MailingListSubscriberMessage,
       setFields: seq[string],
       updateStatement: var string,
       updateValues: var seq[string]) {.gcsafe.} =

  updateStatement =
    "update mailing_list_subscriber_message" &
    "   set "

  for field in setFields:

    if field == "id":
      updateStatement &= "       id = ?,"
      updateValues.add($mailingListSubscriberMessage.id)

    elif field == "account_user_id":
      if mailingListSubscriberMessage.accountUserId != none(int64):
        updateStatement &= "       account_user_id = ?,"
        updateValues.add($mailingListSubscriberMessage.accountUserId.get)
      else:
        updateStatement &= "       account_user_id = null,"

    elif field == "mailing_list_id":
      updateStatement &= "       mailing_list_id = ?,"
      updateValues.add($mailingListSubscriberMessage.mailingListId)

    elif field == "mailing_list_subscriber_id":
      updateStatement &= "       mailing_list_subscriber_id = ?,"
      updateValues.add($mailingListSubscriberMessage.mailingListSubscriberId)

    elif field == "mailing_list_message_id":
      updateStatement &= "       mailing_list_message_id = ?,"
      updateValues.add($mailingListSubscriberMessage.mailingListMessageId)

    elif field == "created":
        updateStatement &= "       created = " & pgToDateTimeString(mailingListSubscriberMessage.created) & ","

  updateStatement[len(updateStatement) - 1] = ' '



proc updateMailingListSubscriberMessageByPk*(
       dbContext: NexusCRMDbContext,
       mailingListSubscriberMessage: MailingListSubscriberMessage,
       setFields: seq[string],
       exceptionOnNRowsUpdated: bool = true): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateMailingListSubscriberMessageSetClause(
    mailing_list_subscriber_message,
    setFields,
    updateStatement,
    updateValues)

  updateStatement &= " where id = ?"

  updateValues.add($mailingListSubscriberMessage.id)

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


proc updateMailingListSubscriberMessageByWhereClause*(
       dbContext: NexusCRMDbContext,
       mailingListSubscriberMessage: MailingListSubscriberMessage,
       setFields: seq[string],
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateMailingListSubscriberMessageSetClause(
    mailing_list_subscriber_message,
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


proc updateMailingListSubscriberMessageByWhereEqOnly*(
       dbContext: NexusCRMDbContext,
       mailingListSubscriberMessage: MailingListSubscriberMessage,
       setFields: seq[string],
       whereFields: seq[string],
       whereValues: seq[string]): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateMailingListSubscriberMessageSetClause(
    mailing_list_subscriber_message,
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


