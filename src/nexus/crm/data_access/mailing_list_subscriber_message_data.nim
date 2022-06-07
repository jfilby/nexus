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
       nexusCRMModule: NexusCRMModule,
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

  let row = getRow(nexusCRMModule.db,
                   sql(selectStatement),
                   whereValues)

  return parseBiggestInt(row[0])


proc countMailingListSubscriberMessage*(
       nexusCRMModule: NexusCRMModule,
       whereClause: string,
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from mailing_list_subscriber_message"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  let row = getRow(nexusCRMModule.db,
                   sql(selectStatement),
                   whereValues)

  return parseBiggestInt(row[0])


proc createMailingListSubscriberMessageReturnsPK*(
       nexusCRMModule: NexusCRMModule,
       accountUserId: Option[int64] = none(int64),
       mailingListId: int64,
       mailingListSubscriberId: int64,
       mailingListMessageId: int64,
       created: DateTime): int64 {.gcsafe.} =

  # Formulate insertStatement and insertValues
  var
    insertValues: seq[string]
    insertStatement = "insert into mailing_list_subscriber_message ("
    valuesClause = ""

  # Field: Account User Id
  if account_user_id != none(int64):
    insertStatement &= "account_user_id, "
    valuesClause &= "?, "
    insertValues.add($account_user_id.get)

  # Field: Mailing List Id
  insertStatement &= "mailing_list_id, "
  valuesClause &= "?, "
  insertValues.add($mailing_list_id)

  # Field: Mailing List Subscriber Id
  insertStatement &= "mailing_list_subscriber_id, "
  valuesClause &= "?, "
  insertValues.add($mailing_list_subscriber_id)

  # Field: Mailing List Message Id
  insertStatement &= "mailing_list_message_id, "
  valuesClause &= "?, "
  insertValues.add($mailing_list_message_id)

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
    nexusCRMModule.db,
    sql(insertStatement),
    "mailing_list_subscriber_message_id",
    insertValues)


proc createMailingListSubscriberMessage*(
       nexusCRMModule: NexusCRMModule,
       accountUserId: Option[int64] = none(int64),
       mailingListId: int64,
       mailingListSubscriberId: int64,
       mailingListMessageId: int64,
       created: DateTime,
       copyAllStringFields: bool = true,
       convertToRawTypes: bool = true): MailingListSubscriberMessage {.gcsafe.} =

  var mailingListSubscriberMessage = MailingListSubscriberMessage()

  mailingListSubscriberMessage.mailingListSubscriberMessageId =
    createMailingListSubscriberMessageReturnsPK(
      nexusCRMModule,
      accountUserId,
      mailingListId,
      mailingListSubscriberId,
      mailingListMessageId,
      created)

  # Copy all fields as strings
  mailingListSubscriberMessage.accountUserId = accountUserId
  mailingListSubscriberMessage.mailingListId = mailingListId
  mailingListSubscriberMessage.mailingListSubscriberId = mailingListSubscriberId
  mailingListSubscriberMessage.mailingListMessageId = mailingListMessageId
  mailingListSubscriberMessage.created = created

  return mailingListSubscriberMessage


proc deleteMailingListSubscriberMessageByPK*(
       nexusCRMModule: NexusCRMModule,
       mailingListSubscriberMessageId: int64): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from mailing_list_subscriber_message" &
    " where mailing_list_subscriber_message_id = ?"

  return execAffectedRows(
           nexusCRMModule.db,
           sql(deleteStatement),
           mailingListSubscriberMessageId)


proc deleteMailingListSubscriberMessage*(
       nexusCRMModule: NexusCRMModule,
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from mailing_list_subscriber_message" &
    " where " & whereClause

  return execAffectedRows(
           nexusCRMModule.db,
           sql(deleteStatement),
           whereValues)


proc existsMailingListSubscriberMessageByPK*(
       nexusCRMModule: NexusCRMModule,
       mailingListSubscriberMessageId: int64): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from mailing_list_subscriber_message" &
    " where mailing_list_subscriber_message_id = ?"

  let row = getRow(
              nexusCRMModule.db,
              sql(selectStatement),
              mailingListSubscriberMessageId)

  if row[0] == "":
    return false
  else:
    return true


proc existsMailingListSubscriberMessageByMailingListSubscriberIdAndMailingListMessageId*(
       nexusCRMModule: NexusCRMModule,
       mailingListSubscriberId: int64,
       mailingListMessageId: int64): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from mailing_list_subscriber_message" &
    " where mailing_list_subscriber_id = ?" &
    "   and mailing_list_message_id = ?"

  let row = getRow(
              nexusCRMModule.db,
              sql(selectStatement),
              mailingListSubscriberId,
              mailingListMessageId)

  if row[0] == "":
    return false
  else:
    return true


proc filterMailingListSubscriberMessage*(
       nexusCRMModule: NexusCRMModule,
       whereClause: string = "",
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[]): MailingListSubscriberMessages {.gcsafe.} =

  var selectStatement =
    "select mailing_list_subscriber_message_id, account_user_id, mailing_list_id, mailing_list_subscriber_id," & 
    "       mailing_list_message_id, created" &
    "  from mailing_list_subscriber_message"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  if len(orderByFields) > 0:
    selectStatement &= " order by " & orderByFields.join(", ")

  var mailingListSubscriberMessages: MailingListSubscriberMessages

  for row in fastRows(nexusCRMModule.db,
                      sql(selectStatement),
                      whereValues):

    mailingListSubscriberMessages.add(rowToMailingListSubscriberMessage(row))

  return mailingListSubscriberMessages


proc filterMailingListSubscriberMessage*(
       nexusCRMModule: NexusCRMModule,
       whereFields: seq[string],
       whereValues: seq[string],
       orderByFields: seq[string] = @[]): MailingListSubscriberMessages {.gcsafe.} =

  var selectStatement =
    "select mailing_list_subscriber_message_id, account_user_id, mailing_list_id, mailing_list_subscriber_id," & 
    "       mailing_list_message_id, created" &
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

  var mailingListSubscriberMessages: MailingListSubscriberMessages

  for row in fastRows(nexusCRMModule.db,
                      sql(selectStatement),
                      whereValues):

    mailingListSubscriberMessages.add(rowToMailingListSubscriberMessage(row))

  return mailingListSubscriberMessages


proc getMailingListSubscriberMessageByPK*(
       nexusCRMModule: NexusCRMModule,
       mailingListSubscriberMessageId: int64): Option[MailingListSubscriberMessage] {.gcsafe.} =

  var selectStatement =
    "select mailing_list_subscriber_message_id, account_user_id, mailing_list_id, mailing_list_subscriber_id," & 
    "       mailing_list_message_id, created" &
    "  from mailing_list_subscriber_message" &
    " where mailing_list_subscriber_message_id = ?"

  let row = getRow(
              nexusCRMModule.db,
              sql(selectStatement),
              mailingListSubscriberMessageId)

  if row[0] == "":
    return none(MailingListSubscriberMessage)

  return some(rowToMailingListSubscriberMessage(row))


proc getMailingListSubscriberMessageByPK*(
       nexusCRMModule: NexusCRMModule,
       mailingListSubscriberMessageId: string): Option[MailingListSubscriberMessage] {.gcsafe.} =

  var selectStatement =
    "select mailing_list_subscriber_message_id, account_user_id, mailing_list_id, mailing_list_subscriber_id," & 
    "       mailing_list_message_id, created" &
    "  from mailing_list_subscriber_message" &
    " where mailing_list_subscriber_message_id = ?"

  let row = getRow(
              nexusCRMModule.db,
              sql(selectStatement),
              mailingListSubscriberMessageId)

  if row[0] == "":
    return none(MailingListSubscriberMessage)

  return some(rowToMailingListSubscriberMessage(row))


proc getMailingListSubscriberMessageByMailingListSubscriberIdAndMailingListMessageId*(
       nexusCRMModule: NexusCRMModule,
       mailingListSubscriberId: int64,
       mailingListMessageId: int64): Option[MailingListSubscriberMessage] {.gcsafe.} =

  var selectStatement =
    "select mailing_list_subscriber_message_id, account_user_id, mailing_list_id, mailing_list_subscriber_id," & 
    "       mailing_list_message_id, created" &
    "  from mailing_list_subscriber_message" &
    " where mailing_list_subscriber_id = ?" &
    "   and mailing_list_message_id = ?"

  let row = getRow(
              nexusCRMModule.db,
              sql(selectStatement),
              mailingListSubscriberId,
              mailingListMessageId)

  if row[0] == "":
    return none(MailingListSubscriberMessage)

  return some(rowToMailingListSubscriberMessage(row))


proc getOrCreateMailingListSubscriberMessageByMailingListSubscriberIdAndMailingListMessageId*(
       nexusCRMModule: NexusCRMModule,
       accountUserId: Option[int64],
       mailingListId: int64,
       mailingListSubscriberId: int64,
       mailingListMessageId: int64,
       created: DateTime): MailingListSubscriberMessage {.gcsafe.} =

  let mailingListSubscriberMessage =
        getMailingListSubscriberMessageByMailingListSubscriberIdAndMailingListMessageId(
          nexusCRMModule,
          mailingListSubscriberId,
          mailingListMessageId)

  if mailingListSubscriberMessage != none(MailingListSubscriberMessage):
    return mailingListSubscriberMessage.get

  return createMailingListSubscriberMessage(
           nexusCRMModule,
           accountUserId,
           mailingListId,
           mailingListSubscriberId,
           mailingListMessageId,
           created)


proc rowToMailingListSubscriberMessage*(row: seq[string]):
       MailingListSubscriberMessage {.gcsafe.} =

  var mailingListSubscriberMessage = MailingListSubscriberMessage()

  mailingListSubscriberMessage.mailingListSubscriberMessageId = parseBiggestInt(row[0])

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
       nexusCRMModule: NexusCRMModule,
       cascade: bool = false) =

  if cascade == false:
    exec(nexusCRMModule.db,
         sql("truncate table mailing_list_subscriber_message restart identity;"))

  else:
    exec(nexusCRMModule.db,
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

    if field == "mailing_list_subscriber_message_id":
      updateStatement &= "       mailing_list_subscriber_message_id = ?,"
      updateValues.add($mailingListSubscriberMessage.mailingListSubscriberMessageId)

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
      updateStatement &= "       created = ?,"
      updateValues.add($mailingListSubscriberMessage.created)

  updateStatement[len(updateStatement) - 1] = ' '



proc updateMailingListSubscriberMessageByPK*(
       nexusCRMModule: NexusCRMModule,
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

  updateStatement &= " where mailing_list_subscriber_message_id = ?"

  updateValues.add($mailingListSubscriberMessage.mailingListSubscriberMessageId)

  let rowsUpdated = 
        execAffectedRows(
          nexusCRMModule.db,
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
       nexusCRMModule: NexusCRMModule,
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
           nexusCRMModule.db,
           sql(updateStatement),
           concat(updateValues,
                  whereValues))


proc updateMailingListSubscriberMessageByWhereEqOnly*(
       nexusCRMModule: NexusCRMModule,
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
           nexusCRMModule.db,
           sql(updateStatement),
           concat(updateValues,
                  whereValues))


