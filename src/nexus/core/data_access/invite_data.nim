# Nexus generated file
import db_connector/db_postgres, options, sequtils, strutils, times, uuids
import nexus/core/data_access/data_utils
import nexus/core/types/model_types


# Forward declarations
proc rowToInvite*(row: seq[string]):
       Invite {.gcsafe.}


# Code
proc countInvite*(
       dbContext: NexusCoreDbContext,
       whereFields: seq[string] = @[],
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from invite"
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


proc countInvite*(
       dbContext: NexusCoreDbContext,
       whereClause: string,
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from invite"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  let row = getRow(dbContext.dbConn,
                   sql(selectStatement),
                   whereValues)

  return parseBiggestInt(row[0])


proc createInviteReturnsPk*(
       dbContext: NexusCoreDbContext,
       fromAccountUserId: string,
       fromEmail: string,
       fromName: string,
       toEmail: string,
       toName: string,
       sent: Option[DateTime] = none(DateTime),
       created: DateTime,
       ignoreExistingPk: bool = false): string {.gcsafe.} =

  # Formulate insertStatement and insertValues
  var
    insertValues: seq[string]
    insertStatement = "insert into invite ("
    valuesClause = ""

  # Field: Id
  insertStatement &= "id, "
  valuesClause &= "?, "

  let id = $genUUID()
  insertValues.add(id)

  # Field: From Account User Id
  insertStatement &= "from_account_user_id, "
  valuesClause &= "?, "
  insertValues.add(fromAccountUserId)

  # Field: From Email
  insertStatement &= "from_email, "
  valuesClause &= "?, "
  insertValues.add(fromEmail)

  # Field: From Name
  insertStatement &= "from_name, "
  valuesClause &= "?, "
  insertValues.add(fromName)

  # Field: To Email
  insertStatement &= "to_email, "
  valuesClause &= "?, "
  insertValues.add(toEmail)

  # Field: To Name
  insertStatement &= "to_name, "
  valuesClause &= "?, "
  insertValues.add(toName)

  # Field: Sent
  if sent != none(DateTime):
    insertStatement &= "sent, "
    valuesClause &= pgToDateTimeString(sent.get) & ", "

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
  exec(
    dbContext.dbConn,
    sql(insertStatement),
    insertValues)

  return id


proc createInvite*(
       dbContext: NexusCoreDbContext,
       fromAccountUserId: string,
       fromEmail: string,
       fromName: string,
       toEmail: string,
       toName: string,
       sent: Option[DateTime] = none(DateTime),
       created: DateTime,
       ignoreExistingPk: bool = false,
       copyAllStringFields: bool = true,
       convertToRawTypes: bool = true): Invite {.gcsafe.} =

  var invite = Invite()

  invite.id =
    createInviteReturnsPk(
      dbContext,
      fromAccountUserId,
      fromEmail,
      fromName,
      toEmail,
      toName,
      sent,
      created,
      ignoreExistingPk)

  # Copy all fields as strings
  invite.fromAccountUserId = fromAccountUserId
  invite.fromEmail = fromEmail
  invite.fromName = fromName
  invite.toEmail = toEmail
  invite.toName = toName
  invite.sent = sent
  invite.created = created

  return invite


proc deleteInviteByPk*(
       dbContext: NexusCoreDbContext,
       id: string): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from invite" &
    " where id = ?"

  return execAffectedRows(
           dbContext.dbConn,
           sql(deleteStatement),
           id)


proc deleteInvite*(
       dbContext: NexusCoreDbContext,
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from invite" &
    " where " & whereClause

  return execAffectedRows(
           dbContext.dbConn,
           sql(deleteStatement),
           whereValues)


proc deleteInvite*(
       dbContext: NexusCoreDbContext,
       whereFields: seq[string],
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from invite"

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


proc existsInviteByPk*(
       dbContext: NexusCoreDbContext,
       id: string): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from invite" &
    " where id = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              id)

  if row[0] == "":
    return false
  else:
    return true


proc existsInviteByToEmail*(
       dbContext: NexusCoreDbContext,
       toEmail: string): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from invite" &
    " where to_email = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              toEmail)

  if row[0] == "":
    return false
  else:
    return true


proc filterInvite*(
       dbContext: NexusCoreDbContext,
       whereClause: string = "",
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): Invites {.gcsafe.} =

  var selectStatement =
    "select id, from_account_user_id, from_email, from_name, to_email, to_name, sent, created" & 
    "  from invite"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  if len(orderByFields) > 0:
    selectStatement &= " order by " & orderByFields.join(", ")

  if limit != none(int):
    selectStatement &= " limit " & $limit.get

  var invites: Invites

  for row in fastRows(dbContext.dbConn,
                      sql(selectStatement),
                      whereValues):

    invites.add(rowToInvite(row))

  return invites


proc filterInvite*(
       dbContext: NexusCoreDbContext,
       whereFields: seq[string],
       whereValues: seq[string],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): Invites {.gcsafe.} =

  var selectStatement =
    "select id, from_account_user_id, from_email, from_name, to_email, to_name, sent, created" & 
    "  from invite"

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

  var invites: Invites

  for row in fastRows(dbContext.dbConn,
                      sql(selectStatement),
                      whereValues):

    invites.add(rowToInvite(row))

  return invites


proc getInviteByPk*(
       dbContext: NexusCoreDbContext,
       id: string): Option[Invite] {.gcsafe.} =

  var selectStatement =
    "select id, from_account_user_id, from_email, from_name, to_email, to_name, sent, created" & 
    "  from invite" &
    " where id = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              id)

  if row[0] == "":
    return none(Invite)

  return some(rowToInvite(row))


proc getInviteByToEmail*(
       dbContext: NexusCoreDbContext,
       toEmail: string): Option[Invite] {.gcsafe.} =

  var selectStatement =
    "select id, from_account_user_id, from_email, from_name, to_email, to_name, sent, created" & 
    "  from invite" &
    " where to_email = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              toEmail)

  if row[0] == "":
    return none(Invite)

  return some(rowToInvite(row))


proc getOrCreateInviteByToEmail*(
       dbContext: NexusCoreDbContext,
       fromAccountUserId: string,
       fromEmail: string,
       fromName: string,
       toEmail: string,
       toName: string,
       sent: Option[DateTime],
       created: DateTime): Invite {.gcsafe.} =

  let invite =
        getInviteByToEmail(
          dbContext,
          toEmail)

  if invite != none(Invite):
    return invite.get

  return createInvite(
           dbContext,
           fromAccountUserId,
           fromEmail,
           fromName,
           toEmail,
           toName,
           sent,
           created)


proc rowToInvite*(row: seq[string]):
       Invite {.gcsafe.} =

  var invite = Invite()

  invite.id = row[0]
  invite.fromAccountUserId = row[1]
  invite.fromEmail = row[2]
  invite.fromName = row[3]
  invite.toEmail = row[4]
  invite.toName = row[5]

  if row[6] != "":
    invite.sent = some(parsePgTimestamp(row[6]))
  else:
    invite.sent = none(DateTime)

  invite.created = parsePgTimestamp(row[7])

  return invite


proc truncateInvite*(
       dbContext: NexusCoreDbContext,
       cascade: bool = false) =

  if cascade == false:
    exec(dbContext.dbConn,
         sql("truncate table invite restart identity;"))

  else:
    exec(dbContext.dbConn,
         sql("truncate table invite restart identity cascade;"))


proc updateInviteSetClause*(
       invite: Invite,
       setFields: seq[string],
       updateStatement: var string,
       updateValues: var seq[string]) {.gcsafe.} =

  updateStatement =
    "update invite" &
    "   set "

  for field in setFields:

    if field == "id":
      updateStatement &= "       id = ?,"
      updateValues.add(invite.id)

    elif field == "from_account_user_id":
      updateStatement &= "       from_account_user_id = ?,"
      updateValues.add(invite.fromAccountUserId)

    elif field == "from_email":
      updateStatement &= "       from_email = ?,"
      updateValues.add(invite.fromEmail)

    elif field == "from_name":
      updateStatement &= "       from_name = ?,"
      updateValues.add(invite.fromName)

    elif field == "to_email":
      updateStatement &= "       to_email = ?,"
      updateValues.add(invite.toEmail)

    elif field == "to_name":
      updateStatement &= "       to_name = ?,"
      updateValues.add(invite.toName)

    elif field == "sent":
      if invite.sent != none(DateTime):
        updateStatement &= "       sent = " & pgToDateTimeString(invite.sent.get) & ","
      else:
        updateStatement &= "       sent = null,"

    elif field == "created":
        updateStatement &= "       created = " & pgToDateTimeString(invite.created) & ","

  updateStatement[len(updateStatement) - 1] = ' '



proc updateInviteByPk*(
       dbContext: NexusCoreDbContext,
       invite: Invite,
       setFields: seq[string],
       exceptionOnNRowsUpdated: bool = true): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateInviteSetClause(
    invite,
    setFields,
    updateStatement,
    updateValues)

  updateStatement &= " where id = ?"

  updateValues.add($invite.id)

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


proc updateInviteByWhereClause*(
       dbContext: NexusCoreDbContext,
       invite: Invite,
       setFields: seq[string],
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateInviteSetClause(
    invite,
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


proc updateInviteByWhereEqOnly*(
       dbContext: NexusCoreDbContext,
       invite: Invite,
       setFields: seq[string],
       whereFields: seq[string],
       whereValues: seq[string]): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateInviteSetClause(
    invite,
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


