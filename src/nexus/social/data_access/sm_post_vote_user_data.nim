# Nexus generated file
import db_postgres, options, sequtils, strutils, times
import nexus/core/data_access/data_utils
import nexus/social/types/model_types


# Forward declarations
proc rowToSMPostVoteUser*(row: seq[string]):
       SMPostVoteUser {.gcsafe.}


# Code
proc countSMPostVoteUser*(
       nexusSocialModule: NexusSocialModule,
       whereFields: seq[string] = @[],
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from sm_post_vote_user"
  var first = true

  for whereField in whereFields:

    var whereClause: string

    if first == false:
      whereClause = "   and " & whereField & " = ?"
    else:
      first = false
      whereClause = " where " & whereField & " = ?"

    selectStatement &= whereClause

  let row = getRow(nexusSocialModule.db,
                   sql(selectStatement),
                   whereValues)

  return parseBiggestInt(row[0])


proc countSMPostVoteUser*(
       nexusSocialModule: NexusSocialModule,
       whereClause: string,
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from sm_post_vote_user"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  let row = getRow(nexusSocialModule.db,
                   sql(selectStatement),
                   whereValues)

  return parseBiggestInt(row[0])


proc createSMPostVoteUserReturnsPK*(
       nexusSocialModule: NexusSocialModule,
       smPostId: int64,
       accountUserId: int64,
       voteUp: bool,
       voteDown: bool): (int64, int64) {.gcsafe.} =

  # Formulate insertStatement and insertValues
  var
    insertValues: seq[string]
    insertStatement = "insert into sm_post_vote_user ("
    valuesClause = ""

  # Field: SM Post Id
  insertStatement &= "sm_post_id, "
  valuesClause &= "?, "
  insertValues.add($sm_post_id)

  # Field: Account User Id
  insertStatement &= "account_user_id, "
  valuesClause &= "?, "
  insertValues.add($account_user_id)

  # Field: Vote Up
  insertStatement &= "vote_up, "
  valuesClause &= pgToBool(vote_up) & ", "

  # Field: Vote Down
  insertStatement &= "vote_down, "
  valuesClause &= pgToBool(vote_down) & ", "

  # Remove trailing commas and finalize insertStatement
  if insertStatement[len(insertStatement) - 2 .. len(insertStatement) - 1] == ", ":
    insertStatement = insertStatement[0 .. len(insertStatement) - 3]

  if valuesClause[len(valuesClause) - 2 .. len(valuesClause) - 1] == ", ":
    valuesClause = valuesClause[0 .. len(valuesClause) - 3]

  # Finalize insertStatement
  insertStatement &= ") values (" & valuesClause & ")"

  # Execute the insert statement and return the sequence values
  exec(
    nexusSocialModule.db,
    sql(insertStatement),
    insertValues)

  return (smPostId, accountUserId)


proc createSMPostVoteUser*(
       nexusSocialModule: NexusSocialModule,
       smPostId: int64,
       accountUserId: int64,
       voteUp: bool,
       voteDown: bool,
       copyAllStringFields: bool = true,
       convertToRawTypes: bool = true): SMPostVoteUser {.gcsafe.} =

  var smPostVoteUser = SMPostVoteUser()

  (smPostVoteUser.smPostId, smPostVoteUser.accountUserId) =
    createSMPostVoteUserReturnsPK(
      nexusSocialModule,
      smPostId,
      accountUserId,
      voteUp,
      voteDown)

  # Copy all fields as strings
  smPostVoteUser.voteUp = voteUp
  smPostVoteUser.voteDown = voteDown

  return smPostVoteUser


proc deleteSMPostVoteUserByPK*(
       nexusSocialModule: NexusSocialModule,
       smPostId: int64,
       accountUserId: int64): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from sm_post_vote_user" &
    " where sm_post_id = ?"&
    "   and account_user_id = ?"

  return execAffectedRows(
           nexusSocialModule.db,
           sql(deleteStatement),
           smPostId,
           accountUserId)


proc deleteSMPostVoteUser*(
       nexusSocialModule: NexusSocialModule,
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from sm_post_vote_user" &
    " where " & whereClause

  return execAffectedRows(
           nexusSocialModule.db,
           sql(deleteStatement),
           whereValues)


proc existsSMPostVoteUserByPK*(
       nexusSocialModule: NexusSocialModule,
       smPostId: int64,
       accountUserId: int64): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from sm_post_vote_user" &
    " where sm_post_id = ?" &
    "   and account_user_id = ?"

  let row = getRow(
              nexusSocialModule.db,
              sql(selectStatement),
              smPostId,
              accountUserId)

  if row[0] == "":
    return false
  else:
    return true


proc filterSMPostVoteUser*(
       nexusSocialModule: NexusSocialModule,
       whereClause: string = "",
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[]): SMPostVoteUsers {.gcsafe.} =

  var selectStatement =
    "select sm_post_id, account_user_id, vote_up, vote_down" & 
    "  from sm_post_vote_user"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  if len(orderByFields) > 0:
    selectStatement &= " order by " & orderByFields.join(", ")

  var smPostVoteUsers: SMPostVoteUsers

  for row in fastRows(nexusSocialModule.db,
                      sql(selectStatement),
                      whereValues):

    smPostVoteUsers.add(rowToSMPostVoteUser(row))

  return smPostVoteUsers


proc filterSMPostVoteUser*(
       nexusSocialModule: NexusSocialModule,
       whereFields: seq[string],
       whereValues: seq[string],
       orderByFields: seq[string] = @[]): SMPostVoteUsers {.gcsafe.} =

  var selectStatement =
    "select sm_post_id, account_user_id, vote_up, vote_down" & 
    "  from sm_post_vote_user"

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

  var smPostVoteUsers: SMPostVoteUsers

  for row in fastRows(nexusSocialModule.db,
                      sql(selectStatement),
                      whereValues):

    smPostVoteUsers.add(rowToSMPostVoteUser(row))

  return smPostVoteUsers


proc getSMPostVoteUserByPK*(
       nexusSocialModule: NexusSocialModule,
       smPostId: int64,
       accountUserId: int64): Option[SMPostVoteUser] {.gcsafe.} =

  var selectStatement =
    "select sm_post_id, account_user_id, vote_up, vote_down" & 
    "  from sm_post_vote_user" &
    " where sm_post_id = ?" &
    "   and account_user_id = ?"

  let row = getRow(
              nexusSocialModule.db,
              sql(selectStatement),
              smPostId,
              accountUserId)

  if row[0] == "":
    return none(SMPostVoteUser)

  return some(rowToSMPostVoteUser(row))


proc getSMPostVoteUserByPK*(
       nexusSocialModule: NexusSocialModule,
       smPostId: string,
       accountUserId: string): Option[SMPostVoteUser] {.gcsafe.} =

  var selectStatement =
    "select sm_post_id, account_user_id, vote_up, vote_down" & 
    "  from sm_post_vote_user" &
    " where sm_post_id = ?" &
    "   and account_user_id = ?"

  let row = getRow(
              nexusSocialModule.db,
              sql(selectStatement),
              smPostId,
              accountUserId)

  if row[0] == "":
    return none(SMPostVoteUser)

  return some(rowToSMPostVoteUser(row))


proc getOrCreateSMPostVoteUserByPK*(
       nexusSocialModule: NexusSocialModule,
       smPostId: int64,
       accountUserId: int64,
       voteUp: bool,
       voteDown: bool): SMPostVoteUser {.gcsafe.} =

  let smPostVoteUser =
        getSMPostVoteUserByPK(
          nexusSocialModule,
          smPostId,
          accountUserId)

  if smPostVoteUser != none(SMPostVoteUser):
    return smPostVoteUser.get

  return createSMPostVoteUser(
           nexusSocialModule,
           smPostId,
           accountUserId,
           voteUp,
           voteDown)


proc rowToSMPostVoteUser*(row: seq[string]):
       SMPostVoteUser {.gcsafe.} =

  var smPostVoteUser = SMPostVoteUser()

  smPostVoteUser.smPostId = parseBiggestInt(row[0])
  smPostVoteUser.accountUserId = parseBiggestInt(row[1])
  smPostVoteUser.voteUp = parsePgBool(row[2])
  smPostVoteUser.voteDown = parsePgBool(row[3])

  return smPostVoteUser


proc truncateSMPostVoteUser*(
       nexusSocialModule: NexusSocialModule,
       cascade: bool = false) =

  if cascade == false:
    exec(nexusSocialModule.db,
         sql("truncate table sm_post_vote_user restart identity;"))

  else:
    exec(nexusSocialModule.db,
         sql("truncate table sm_post_vote_user restart identity cascade;"))


proc updateSMPostVoteUserSetClause*(
       smPostVoteUser: SMPostVoteUser,
       setFields: seq[string],
       updateStatement: var string,
       updateValues: var seq[string]) {.gcsafe.} =

  updateStatement =
    "update sm_post_vote_user" &
    "   set "

  for field in setFields:

    if field == "sm_post_id":
      updateStatement &= "       sm_post_id = ?,"
      updateValues.add($smPostVoteUser.smPostId)

    elif field == "account_user_id":
      updateStatement &= "       account_user_id = ?,"
      updateValues.add($smPostVoteUser.accountUserId)

    elif field == "vote_up":
      updateStatement &= "       vote_up = ?,"
      updateValues.add($smPostVoteUser.voteUp)

    elif field == "vote_down":
      updateStatement &= "       vote_down = ?,"
      updateValues.add($smPostVoteUser.voteDown)

  updateStatement[len(updateStatement) - 1] = ' '



proc updateSMPostVoteUserByPK*(
       nexusSocialModule: NexusSocialModule,
       smPostVoteUser: SMPostVoteUser,
       setFields: seq[string],
       exceptionOnNRowsUpdated: bool = true): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateSMPostVoteUserSetClause(
    sm_post_vote_user,
    setFields,
    updateStatement,
    updateValues)

  updateStatement &= " where sm_post_id = ?"
  updateStatement &= "   and account_user_id = ?"

  updateValues.add($smPostVoteUser.smPostId)
  updateValues.add($smPostVoteUser.accountUserId)

  let rowsUpdated = 
        execAffectedRows(
          nexusSocialModule.db,
          sql(updateStatement),
          updateValues)

  # Exception on no rows updated
  if rowsUpdated == 0 and
     exceptionOnNRowsUpdated == true:

    raise newException(ValueError,
                       "no rows updated")

  # Return rows updated
  return rowsUpdated


proc updateSMPostVoteUserByWhereClause*(
       nexusSocialModule: NexusSocialModule,
       smPostVoteUser: SMPostVoteUser,
       setFields: seq[string],
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateSMPostVoteUserSetClause(
    sm_post_vote_user,
    setFields,
    updateStatement,
    updateValues)

  if whereClause != "":
    updateStatement &= " where " & whereClause

  return execAffectedRows(
           nexusSocialModule.db,
           sql(updateStatement),
           concat(updateValues,
                  whereValues))


proc updateSMPostVoteUserByWhereEqOnly*(
       nexusSocialModule: NexusSocialModule,
       smPostVoteUser: SMPostVoteUser,
       setFields: seq[string],
       whereFields: seq[string],
       whereValues: seq[string]): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateSMPostVoteUserSetClause(
    sm_post_vote_user,
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
           nexusSocialModule.db,
           sql(updateStatement),
           concat(updateValues,
                  whereValues))


