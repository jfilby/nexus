# Nexus generated file
import db_postgres, options, sequtils, strutils, times
import nexus/core/data_access/data_utils
import nexus/core/data_access/pg_try_insert_id
import nexus/crm/types/model_types


# Forward declarations
proc rowToMailingListSubscriber*(row: seq[string]):
       MailingListSubscriber {.gcsafe.}


# Code
proc countMailingListSubscriber*(
       nexusCRMModule: NexusCRMModule,
       whereFields: seq[string] = @[],
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from mailing_list_subscriber"
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


proc countMailingListSubscriber*(
       nexusCRMModule: NexusCRMModule,
       whereClause: string,
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from mailing_list_subscriber"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  let row = getRow(nexusCRMModule.db,
                   sql(selectStatement),
                   whereValues)

  return parseBiggestInt(row[0])


proc createMailingListSubscriberReturnsPK*(
       nexusCRMModule: NexusCRMModule,
       accountUserId: Option[int64] = none(int64),
       mailingListId: int64,
       uniqueHash: string,
       isActive: bool,
       email: string,
       name: Option[string] = none(string),
       verificationCode: Option[string] = none(string),
       isVerified: bool,
       created: DateTime,
       deleted: Option[DateTime] = none(DateTime)): int64 {.gcsafe.} =

  # Formulate insertStatement and insertValues
  var
    insertValues: seq[string]
    insertStatement = "insert into mailing_list_subscriber ("
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

  # Field: Unique Hash
  insertStatement &= "unique_hash, "
  valuesClause &= "?, "
  insertValues.add(unique_hash)

  # Field: Is Active
  insertStatement &= "is_active, "
  valuesClause &= pgToBool(is_active) & ", "

  # Field: Email
  insertStatement &= "email, "
  valuesClause &= "?, "
  insertValues.add(email)

  # Field: Name
  if name != none(string):
    insertStatement &= "name, "
    valuesClause &= "?, "
    insertValues.add(name.get)

  # Field: Verification Code
  if verification_code != none(string):
    insertStatement &= "verification_code, "
    valuesClause &= "?, "
    insertValues.add(verification_code.get)

  # Field: Is Verified
  insertStatement &= "is_verified, "
  valuesClause &= pgToBool(is_verified) & ", "

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
  insertStatement &= ") values (" & valuesClause & ")"

  # Execute the insert statement and return the sequence values
  return tryInsertNamedID(
    nexusCRMModule.db,
    sql(insertStatement),
    "mailing_list_subscriber_id",
    insertValues)


proc createMailingListSubscriber*(
       nexusCRMModule: NexusCRMModule,
       accountUserId: Option[int64] = none(int64),
       mailingListId: int64,
       uniqueHash: string,
       isActive: bool,
       email: string,
       name: Option[string] = none(string),
       verificationCode: Option[string] = none(string),
       isVerified: bool,
       created: DateTime,
       deleted: Option[DateTime] = none(DateTime),
       copyAllStringFields: bool = true,
       convertToRawTypes: bool = true): MailingListSubscriber {.gcsafe.} =

  var mailingListSubscriber = MailingListSubscriber()

  mailingListSubscriber.mailingListSubscriberId =
    createMailingListSubscriberReturnsPK(
      nexusCRMModule,
      accountUserId,
      mailingListId,
      uniqueHash,
      isActive,
      email,
      name,
      verificationCode,
      isVerified,
      created,
      deleted)

  # Copy all fields as strings
  mailingListSubscriber.accountUserId = accountUserId
  mailingListSubscriber.mailingListId = mailingListId
  mailingListSubscriber.uniqueHash = uniqueHash
  mailingListSubscriber.isActive = isActive
  mailingListSubscriber.email = email
  mailingListSubscriber.name = name
  mailingListSubscriber.verificationCode = verificationCode
  mailingListSubscriber.isVerified = isVerified
  mailingListSubscriber.created = created
  mailingListSubscriber.deleted = deleted

  return mailingListSubscriber


proc deleteMailingListSubscriberByPk*(
       nexusCRMModule: NexusCRMModule,
       mailingListSubscriberId: int64): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from mailing_list_subscriber" &
    " where mailing_list_subscriber_id = ?"

  return execAffectedRows(
           nexusCRMModule.db,
           sql(deleteStatement),
           mailingListSubscriberId)


proc deleteMailingListSubscriber*(
       nexusCRMModule: NexusCRMModule,
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from mailing_list_subscriber" &
    " where " & whereClause

  return execAffectedRows(
           nexusCRMModule.db,
           sql(deleteStatement),
           whereValues)


proc existsMailingListSubscriberByPk*(
       nexusCRMModule: NexusCRMModule,
       mailingListSubscriberId: int64): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from mailing_list_subscriber" &
    " where mailing_list_subscriber_id = ?"

  let row = getRow(
              nexusCRMModule.db,
              sql(selectStatement),
              mailingListSubscriberId)

  if row[0] == "":
    return false
  else:
    return true


proc existsMailingListSubscriberByUniqueHash*(
       nexusCRMModule: NexusCRMModule,
       uniqueHash: string): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from mailing_list_subscriber" &
    " where unique_hash = ?"

  let row = getRow(
              nexusCRMModule.db,
              sql(selectStatement),
              uniqueHash)

  if row[0] == "":
    return false
  else:
    return true


proc existsMailingListSubscriberByMailingListIdAndAccountUserId*(
       nexusCRMModule: NexusCRMModule,
       mailingListId: int64,
       accountUserId: Option[int64]): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from mailing_list_subscriber" &
    " where mailing_list_id = ?" &
    "   and account_user_id = ?"

  let row = getRow(
              nexusCRMModule.db,
              sql(selectStatement),
              mailingListId,
              accountUserId)

  if row[0] == "":
    return false
  else:
    return true


proc existsMailingListSubscriberByMailingListIdAndEmail*(
       nexusCRMModule: NexusCRMModule,
       mailingListId: int64,
       email: string): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from mailing_list_subscriber" &
    " where mailing_list_id = ?" &
    "   and email = ?"

  let row = getRow(
              nexusCRMModule.db,
              sql(selectStatement),
              mailingListId,
              email)

  if row[0] == "":
    return false
  else:
    return true


proc filterMailingListSubscriber*(
       nexusCRMModule: NexusCRMModule,
       whereClause: string = "",
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[]): MailingListSubscribers {.gcsafe.} =

  var selectStatement =
    "select mailing_list_subscriber_id, account_user_id, mailing_list_id, unique_hash, is_active," & 
    "       email, name, verification_code, is_verified, created, deleted" &
    "  from mailing_list_subscriber"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  if len(orderByFields) > 0:
    selectStatement &= " order by " & orderByFields.join(", ")

  var mailingListSubscribers: MailingListSubscribers

  for row in fastRows(nexusCRMModule.db,
                      sql(selectStatement),
                      whereValues):

    mailingListSubscribers.add(rowToMailingListSubscriber(row))

  return mailingListSubscribers


proc filterMailingListSubscriber*(
       nexusCRMModule: NexusCRMModule,
       whereFields: seq[string],
       whereValues: seq[string],
       orderByFields: seq[string] = @[]): MailingListSubscribers {.gcsafe.} =

  var selectStatement =
    "select mailing_list_subscriber_id, account_user_id, mailing_list_id, unique_hash, is_active," & 
    "       email, name, verification_code, is_verified, created, deleted" &
    "  from mailing_list_subscriber"

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

  var mailingListSubscribers: MailingListSubscribers

  for row in fastRows(nexusCRMModule.db,
                      sql(selectStatement),
                      whereValues):

    mailingListSubscribers.add(rowToMailingListSubscriber(row))

  return mailingListSubscribers


proc getMailingListSubscriberByPk*(
       nexusCRMModule: NexusCRMModule,
       mailingListSubscriberId: int64): Option[MailingListSubscriber] {.gcsafe.} =

  var selectStatement =
    "select mailing_list_subscriber_id, account_user_id, mailing_list_id, unique_hash, is_active," & 
    "       email, name, verification_code, is_verified, created, deleted" &
    "  from mailing_list_subscriber" &
    " where mailing_list_subscriber_id = ?"

  let row = getRow(
              nexusCRMModule.db,
              sql(selectStatement),
              mailingListSubscriberId)

  if row[0] == "":
    return none(MailingListSubscriber)

  return some(rowToMailingListSubscriber(row))


proc getMailingListSubscriberByPk*(
       nexusCRMModule: NexusCRMModule,
       mailingListSubscriberId: string): Option[MailingListSubscriber] {.gcsafe.} =

  var selectStatement =
    "select mailing_list_subscriber_id, account_user_id, mailing_list_id, unique_hash, is_active," & 
    "       email, name, verification_code, is_verified, created, deleted" &
    "  from mailing_list_subscriber" &
    " where mailing_list_subscriber_id = ?"

  let row = getRow(
              nexusCRMModule.db,
              sql(selectStatement),
              mailingListSubscriberId)

  if row[0] == "":
    return none(MailingListSubscriber)

  return some(rowToMailingListSubscriber(row))


proc getMailingListSubscriberByUniqueHash*(
       nexusCRMModule: NexusCRMModule,
       uniqueHash: string): Option[MailingListSubscriber] {.gcsafe.} =

  var selectStatement =
    "select mailing_list_subscriber_id, account_user_id, mailing_list_id, unique_hash, is_active," & 
    "       email, name, verification_code, is_verified, created, deleted" &
    "  from mailing_list_subscriber" &
    " where unique_hash = ?"

  let row = getRow(
              nexusCRMModule.db,
              sql(selectStatement),
              uniqueHash)

  if row[0] == "":
    return none(MailingListSubscriber)

  return some(rowToMailingListSubscriber(row))


proc getMailingListSubscriberByMailingListIdAndAccountUserId*(
       nexusCRMModule: NexusCRMModule,
       mailingListId: int64,
       accountUserId: int64): Option[MailingListSubscriber] {.gcsafe.} =

  var selectStatement =
    "select mailing_list_subscriber_id, account_user_id, mailing_list_id, unique_hash, is_active," & 
    "       email, name, verification_code, is_verified, created, deleted" &
    "  from mailing_list_subscriber" &
    " where mailing_list_id = ?" &
    "   and account_user_id = ?"

  let row = getRow(
              nexusCRMModule.db,
              sql(selectStatement),
              mailingListId,
              accountUserId)

  if row[0] == "":
    return none(MailingListSubscriber)

  return some(rowToMailingListSubscriber(row))


proc getMailingListSubscriberByMailingListIdAndEmail*(
       nexusCRMModule: NexusCRMModule,
       mailingListId: int64,
       email: string): Option[MailingListSubscriber] {.gcsafe.} =

  var selectStatement =
    "select mailing_list_subscriber_id, account_user_id, mailing_list_id, unique_hash, is_active," & 
    "       email, name, verification_code, is_verified, created, deleted" &
    "  from mailing_list_subscriber" &
    " where mailing_list_id = ?" &
    "   and email = ?"

  let row = getRow(
              nexusCRMModule.db,
              sql(selectStatement),
              mailingListId,
              email)

  if row[0] == "":
    return none(MailingListSubscriber)

  return some(rowToMailingListSubscriber(row))


proc getOrCreateMailingListSubscriberByUniqueHash*(
       nexusCRMModule: NexusCRMModule,
       accountUserId: Option[int64],
       mailingListId: int64,
       uniqueHash: string,
       isActive: bool,
       email: string,
       name: Option[string],
       verificationCode: Option[string],
       isVerified: bool,
       created: DateTime,
       deleted: Option[DateTime]): MailingListSubscriber {.gcsafe.} =

  let mailingListSubscriber =
        getMailingListSubscriberByUniqueHash(
          nexusCRMModule,
          uniqueHash)

  if mailingListSubscriber != none(MailingListSubscriber):
    return mailingListSubscriber.get

  return createMailingListSubscriber(
           nexusCRMModule,
           accountUserId,
           mailingListId,
           uniqueHash,
           isActive,
           email,
           name,
           verificationCode,
           isVerified,
           created,
           deleted)


proc getOrCreateMailingListSubscriberByMailingListIdAndAccountUserId*(
       nexusCRMModule: NexusCRMModule,
       accountUserId: int64,
       mailingListId: int64,
       uniqueHash: string,
       isActive: bool,
       email: string,
       name: Option[string],
       verificationCode: Option[string],
       isVerified: bool,
       created: DateTime,
       deleted: Option[DateTime]): MailingListSubscriber {.gcsafe.} =

  let mailingListSubscriber =
        getMailingListSubscriberByMailingListIdAndAccountUserId(
          nexusCRMModule,
          mailingListId,
          accountUserId)

  if mailingListSubscriber != none(MailingListSubscriber):
    return mailingListSubscriber.get

  return createMailingListSubscriber(
           nexusCRMModule,
           some(accountUserId),
           mailingListId,
           uniqueHash,
           isActive,
           email,
           name,
           verificationCode,
           isVerified,
           created,
           deleted)


proc getOrCreateMailingListSubscriberByMailingListIdAndEmail*(
       nexusCRMModule: NexusCRMModule,
       accountUserId: Option[int64],
       mailingListId: int64,
       uniqueHash: string,
       isActive: bool,
       email: string,
       name: Option[string],
       verificationCode: Option[string],
       isVerified: bool,
       created: DateTime,
       deleted: Option[DateTime]): MailingListSubscriber {.gcsafe.} =

  let mailingListSubscriber =
        getMailingListSubscriberByMailingListIdAndEmail(
          nexusCRMModule,
          mailingListId,
          email)

  if mailingListSubscriber != none(MailingListSubscriber):
    return mailingListSubscriber.get

  return createMailingListSubscriber(
           nexusCRMModule,
           accountUserId,
           mailingListId,
           uniqueHash,
           isActive,
           email,
           name,
           verificationCode,
           isVerified,
           created,
           deleted)


proc rowToMailingListSubscriber*(row: seq[string]):
       MailingListSubscriber {.gcsafe.} =

  var mailingListSubscriber = MailingListSubscriber()

  mailingListSubscriber.mailingListSubscriberId = parseBiggestInt(row[0])

  if row[1] != "":
    mailingListSubscriber.accountUserId = some(parseBiggestInt(row[1]))
  else:
    mailingListSubscriber.accountUserId = none(int64)

  mailingListSubscriber.mailingListId = parseBiggestInt(row[2])
  mailingListSubscriber.uniqueHash = row[3]
  mailingListSubscriber.isActive = parsePgBool(row[4])
  mailingListSubscriber.email = row[5]

  if row[6] != "":
    mailingListSubscriber.name = some(row[6])
  else:
    mailingListSubscriber.name = none(string)

  if row[7] != "":
    mailingListSubscriber.verificationCode = some(row[7])
  else:
    mailingListSubscriber.verificationCode = none(string)

  mailingListSubscriber.isVerified = parsePgBool(row[8])
  mailingListSubscriber.created = parsePgTimestamp(row[9])

  if row[10] != "":
    mailingListSubscriber.deleted = some(parsePgTimestamp(row[10]))
  else:
    mailingListSubscriber.deleted = none(DateTime)


  return mailingListSubscriber


proc truncateMailingListSubscriber*(
       nexusCRMModule: NexusCRMModule,
       cascade: bool = false) =

  if cascade == false:
    exec(nexusCRMModule.db,
         sql("truncate table mailing_list_subscriber restart identity;"))

  else:
    exec(nexusCRMModule.db,
         sql("truncate table mailing_list_subscriber restart identity cascade;"))


proc updateMailingListSubscriberSetClause*(
       mailingListSubscriber: MailingListSubscriber,
       setFields: seq[string],
       updateStatement: var string,
       updateValues: var seq[string]) {.gcsafe.} =

  updateStatement =
    "update mailing_list_subscriber" &
    "   set "

  for field in setFields:

    if field == "mailing_list_subscriber_id":
      updateStatement &= "       mailing_list_subscriber_id = ?,"
      updateValues.add($mailingListSubscriber.mailingListSubscriberId)

    elif field == "account_user_id":
      if mailingListSubscriber.accountUserId != none(int64):
        updateStatement &= "       account_user_id = ?,"
        updateValues.add($mailingListSubscriber.accountUserId.get)
      else:
        updateStatement &= "       account_user_id = null,"

    elif field == "mailing_list_id":
      updateStatement &= "       mailing_list_id = ?,"
      updateValues.add($mailingListSubscriber.mailingListId)

    elif field == "unique_hash":
      updateStatement &= "       unique_hash = ?,"
      updateValues.add($mailingListSubscriber.uniqueHash)

    elif field == "is_active":
      updateStatement &= "       is_active = ?,"
      updateValues.add($mailingListSubscriber.isActive)

    elif field == "email":
      updateStatement &= "       email = ?,"
      updateValues.add($mailingListSubscriber.email)

    elif field == "name":
      if mailingListSubscriber.name != none(string):
        updateStatement &= "       name = ?,"
        updateValues.add($mailingListSubscriber.name.get)
      else:
        updateStatement &= "       name = null,"

    elif field == "verification_code":
      if mailingListSubscriber.verificationCode != none(string):
        updateStatement &= "       verification_code = ?,"
        updateValues.add($mailingListSubscriber.verificationCode.get)
      else:
        updateStatement &= "       verification_code = null,"

    elif field == "is_verified":
      updateStatement &= "       is_verified = ?,"
      updateValues.add($mailingListSubscriber.isVerified)

    elif field == "created":
      updateStatement &= "       created = ?,"
      updateValues.add($mailingListSubscriber.created)

    elif field == "deleted":
      if mailingListSubscriber.deleted != none(DateTime):
        updateStatement &= "       deleted = ?,"
        updateValues.add($mailingListSubscriber.deleted.get)
      else:
        updateStatement &= "       deleted = null,"

  updateStatement[len(updateStatement) - 1] = ' '



proc updateMailingListSubscriberByPk*(
       nexusCRMModule: NexusCRMModule,
       mailingListSubscriber: MailingListSubscriber,
       setFields: seq[string],
       exceptionOnNRowsUpdated: bool = true): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateMailingListSubscriberSetClause(
    mailing_list_subscriber,
    setFields,
    updateStatement,
    updateValues)

  updateStatement &= " where mailing_list_subscriber_id = ?"

  updateValues.add($mailingListSubscriber.mailingListSubscriberId)

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


proc updateMailingListSubscriberByWhereClause*(
       nexusCRMModule: NexusCRMModule,
       mailingListSubscriber: MailingListSubscriber,
       setFields: seq[string],
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateMailingListSubscriberSetClause(
    mailing_list_subscriber,
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


proc updateMailingListSubscriberByWhereEqOnly*(
       nexusCRMModule: NexusCRMModule,
       mailingListSubscriber: MailingListSubscriber,
       setFields: seq[string],
       whereFields: seq[string],
       whereValues: seq[string]): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateMailingListSubscriberSetClause(
    mailing_list_subscriber,
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


