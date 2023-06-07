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
       dbContext: NexusCRMDbContext,
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

  let row = getRow(dbContext.dbConn,
                   sql(selectStatement),
                   whereValues)

  return parseBiggestInt(row[0])


proc countMailingListSubscriber*(
       dbContext: NexusCRMDbContext,
       whereClause: string,
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from mailing_list_subscriber"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  let row = getRow(dbContext.dbConn,
                   sql(selectStatement),
                   whereValues)

  return parseBiggestInt(row[0])


proc createMailingListSubscriberReturnsPk*(
       dbContext: NexusCRMDbContext,
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
       ignoreExistingPk: bool = false): int64 {.gcsafe.} =

  # Formulate insertStatement and insertValues
  var
    insertValues: seq[string]
    insertStatement = "insert into mailing_list_subscriber ("
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

  # Field: Unique Hash
  insertStatement &= "unique_hash, "
  valuesClause &= "?" & ", "
  insertValues.add(uniqueHash)

  # Field: Is Active
  insertStatement &= "is_active, "
  valuesClause &= "?, "
  insertValues.add($isActive)

  # Field: Email
  insertStatement &= "email, "
  valuesClause &= "?" & ", "
  insertValues.add(email)

  # Field: Name
  if name != none(string):
    insertStatement &= "name, "
    valuesClause &= "?" & ", "
    insertValues.add(name.get)

  # Field: Verification Code
  if verificationCode != none(string):
    insertStatement &= "verification_code, "
    valuesClause &= "?" & ", "
    insertValues.add(verificationCode.get)

  # Field: Is Verified
  insertStatement &= "is_verified, "
  valuesClause &= "?, "
  insertValues.add($isVerified)

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
    insertStatement &= " on conflict (id) do nothing"

  # Execute the insert statement and return the sequence values
  return tryInsertNamedID(
    dbContext.dbConn,
    sql(insertStatement),
    "id",
    insertValues)


proc createMailingListSubscriber*(
       dbContext: NexusCRMDbContext,
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
       ignoreExistingPk: bool = false,
       copyAllStringFields: bool = true,
       convertToRawTypes: bool = true): MailingListSubscriber {.gcsafe.} =

  var mailingListSubscriber = MailingListSubscriber()

  mailingListSubscriber.id =
    createMailingListSubscriberReturnsPk(
      dbContext,
      accountUserId,
      mailingListId,
      uniqueHash,
      isActive,
      email,
      name,
      verificationCode,
      isVerified,
      created,
      deleted,
      ignoreExistingPk)

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
       dbContext: NexusCRMDbContext,
       id: int64): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from mailing_list_subscriber" &
    " where id = ?"

  return execAffectedRows(
           dbContext.dbConn,
           sql(deleteStatement),
           id)


proc deleteMailingListSubscriber*(
       dbContext: NexusCRMDbContext,
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from mailing_list_subscriber" &
    " where " & whereClause

  return execAffectedRows(
           dbContext.dbConn,
           sql(deleteStatement),
           whereValues)


proc deleteMailingListSubscriber*(
       dbContext: NexusCRMDbContext,
       whereFields: seq[string],
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from mailing_list_subscriber"

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


proc existsMailingListSubscriberByPk*(
       dbContext: NexusCRMDbContext,
       id: int64): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from mailing_list_subscriber" &
    " where id = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              $id)

  if row[0] == "":
    return false
  else:
    return true


proc existsMailingListSubscriberByUniqueHash*(
       dbContext: NexusCRMDbContext,
       uniqueHash: string): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from mailing_list_subscriber" &
    " where unique_hash = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              uniqueHash)

  if row[0] == "":
    return false
  else:
    return true


proc existsMailingListSubscriberByMailingListIdAndAccountUserId*(
       dbContext: NexusCRMDbContext,
       mailingListId: int64,
       accountUserId: Option[int64]): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from mailing_list_subscriber" &
    " where mailing_list_id = ?" &
    "   and account_user_id = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              $mailingListId,
              $accountUserId)

  if row[0] == "":
    return false
  else:
    return true


proc existsMailingListSubscriberByMailingListIdAndEmail*(
       dbContext: NexusCRMDbContext,
       mailingListId: int64,
       email: string): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from mailing_list_subscriber" &
    " where mailing_list_id = ?" &
    "   and email = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              $mailingListId,
              email)

  if row[0] == "":
    return false
  else:
    return true


proc filterMailingListSubscriber*(
       dbContext: NexusCRMDbContext,
       whereClause: string = "",
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): MailingListSubscribers {.gcsafe.} =

  var selectStatement =
    "select id, account_user_id, mailing_list_id, unique_hash, is_active, email, name, verification_code," & 
    "       is_verified, created, deleted" &
    "  from mailing_list_subscriber"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  if len(orderByFields) > 0:
    selectStatement &= " order by " & orderByFields.join(", ")

  if limit != none(int):
    selectStatement &= " limit " & $limit.get

  var mailingListSubscribers: MailingListSubscribers

  for row in fastRows(dbContext.dbConn,
                      sql(selectStatement),
                      whereValues):

    mailingListSubscribers.add(rowToMailingListSubscriber(row))

  return mailingListSubscribers


proc filterMailingListSubscriber*(
       dbContext: NexusCRMDbContext,
       whereFields: seq[string],
       whereValues: seq[string],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): MailingListSubscribers {.gcsafe.} =

  var selectStatement =
    "select id, account_user_id, mailing_list_id, unique_hash, is_active, email, name, verification_code," & 
    "       is_verified, created, deleted" &
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

  if limit != none(int):
    selectStatement &= " limit " & $limit.get

  var mailingListSubscribers: MailingListSubscribers

  for row in fastRows(dbContext.dbConn,
                      sql(selectStatement),
                      whereValues):

    mailingListSubscribers.add(rowToMailingListSubscriber(row))

  return mailingListSubscribers


proc getMailingListSubscriberByPk*(
       dbContext: NexusCRMDbContext,
       id: int64): Option[MailingListSubscriber] {.gcsafe.} =

  var selectStatement =
    "select id, account_user_id, mailing_list_id, unique_hash, is_active, email, name, verification_code," & 
    "       is_verified, created, deleted" &
    "  from mailing_list_subscriber" &
    " where id = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              id)

  if row[0] == "":
    return none(MailingListSubscriber)

  return some(rowToMailingListSubscriber(row))


proc getMailingListSubscriberByPk*(
       dbContext: NexusCRMDbContext,
       id: string): Option[MailingListSubscriber] {.gcsafe.} =

  var selectStatement =
    "select id, account_user_id, mailing_list_id, unique_hash, is_active, email, name, verification_code," & 
    "       is_verified, created, deleted" &
    "  from mailing_list_subscriber" &
    " where id = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              id)

  if row[0] == "":
    return none(MailingListSubscriber)

  return some(rowToMailingListSubscriber(row))


proc getMailingListSubscriberByUniqueHash*(
       dbContext: NexusCRMDbContext,
       uniqueHash: string): Option[MailingListSubscriber] {.gcsafe.} =

  var selectStatement =
    "select id, account_user_id, mailing_list_id, unique_hash, is_active, email, name, verification_code," & 
    "       is_verified, created, deleted" &
    "  from mailing_list_subscriber" &
    " where unique_hash = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              uniqueHash)

  if row[0] == "":
    return none(MailingListSubscriber)

  return some(rowToMailingListSubscriber(row))


proc getMailingListSubscriberByMailingListIdAndAccountUserId*(
       dbContext: NexusCRMDbContext,
       mailingListId: int64,
       accountUserId: int64): Option[MailingListSubscriber] {.gcsafe.} =

  var selectStatement =
    "select id, account_user_id, mailing_list_id, unique_hash, is_active, email, name, verification_code," & 
    "       is_verified, created, deleted" &
    "  from mailing_list_subscriber" &
    " where mailing_list_id = ?" &
    "   and account_user_id = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              mailingListId,
              accountUserId)

  if row[0] == "":
    return none(MailingListSubscriber)

  return some(rowToMailingListSubscriber(row))


proc getMailingListSubscriberByMailingListIdAndEmail*(
       dbContext: NexusCRMDbContext,
       mailingListId: int64,
       email: string): Option[MailingListSubscriber] {.gcsafe.} =

  var selectStatement =
    "select id, account_user_id, mailing_list_id, unique_hash, is_active, email, name, verification_code," & 
    "       is_verified, created, deleted" &
    "  from mailing_list_subscriber" &
    " where mailing_list_id = ?" &
    "   and email = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              mailingListId,
              email)

  if row[0] == "":
    return none(MailingListSubscriber)

  return some(rowToMailingListSubscriber(row))


proc getOrCreateMailingListSubscriberByUniqueHash*(
       dbContext: NexusCRMDbContext,
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
          dbContext,
          uniqueHash)

  if mailingListSubscriber != none(MailingListSubscriber):
    return mailingListSubscriber.get

  return createMailingListSubscriber(
           dbContext,
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
       dbContext: NexusCRMDbContext,
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
          dbContext,
          mailingListId,
          accountUserId)

  if mailingListSubscriber != none(MailingListSubscriber):
    return mailingListSubscriber.get

  return createMailingListSubscriber(
           dbContext,
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
       dbContext: NexusCRMDbContext,
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
          dbContext,
          mailingListId,
          email)

  if mailingListSubscriber != none(MailingListSubscriber):
    return mailingListSubscriber.get

  return createMailingListSubscriber(
           dbContext,
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

  mailingListSubscriber.id = parseBiggestInt(row[0])

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
       dbContext: NexusCRMDbContext,
       cascade: bool = false) =

  if cascade == false:
    exec(dbContext.dbConn,
         sql("truncate table mailing_list_subscriber restart identity;"))

  else:
    exec(dbContext.dbConn,
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

    if field == "id":
      updateStatement &= "       id = ?,"
      updateValues.add($mailingListSubscriber.id)

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
      updateValues.add(mailingListSubscriber.uniqueHash)

    elif field == "is_active":
        updateStatement &= "       is_active = " & pgToBool(mailingListSubscriber.isActive) & ","

    elif field == "email":
      updateStatement &= "       email = ?,"
      updateValues.add(mailingListSubscriber.email)

    elif field == "name":
      if mailingListSubscriber.name != none(string):
        updateStatement &= "       name = ?,"
        updateValues.add(mailingListSubscriber.name.get)
      else:
        updateStatement &= "       name = null,"

    elif field == "verification_code":
      if mailingListSubscriber.verificationCode != none(string):
        updateStatement &= "       verification_code = ?,"
        updateValues.add(mailingListSubscriber.verificationCode.get)
      else:
        updateStatement &= "       verification_code = null,"

    elif field == "is_verified":
        updateStatement &= "       is_verified = " & pgToBool(mailingListSubscriber.isVerified) & ","

    elif field == "created":
        updateStatement &= "       created = " & pgToDateTimeString(mailingListSubscriber.created) & ","

    elif field == "deleted":
      if mailingListSubscriber.deleted != none(DateTime):
        updateStatement &= "       deleted = " & pgToDateTimeString(mailingListSubscriber.deleted.get) & ","
      else:
        updateStatement &= "       deleted = null,"

  updateStatement[len(updateStatement) - 1] = ' '



proc updateMailingListSubscriberByPk*(
       dbContext: NexusCRMDbContext,
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

  updateStatement &= " where id = ?"

  updateValues.add($mailingListSubscriber.id)

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


proc updateMailingListSubscriberByWhereClause*(
       dbContext: NexusCRMDbContext,
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
           dbContext.dbConn,
           sql(updateStatement),
           concat(updateValues,
                  whereValues))


proc updateMailingListSubscriberByWhereEqOnly*(
       dbContext: NexusCRMDbContext,
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
           dbContext.dbConn,
           sql(updateStatement),
           concat(updateValues,
                  whereValues))


