# Nexus generated file
import db_postgres, options, sequtils, strutils
import nexus/social/types/model_types


# Forward declarations
proc rowToSMPostVote*(row: seq[string]):
       SMPostVote {.gcsafe.}


# Code
proc countSMPostVote*(
       dbContext: NexusSocialDbContext,
       whereFields: seq[string] = @[],
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from sm_post_vote"
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


proc countSMPostVote*(
       dbContext: NexusSocialDbContext,
       whereClause: string,
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from sm_post_vote"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  let row = getRow(dbContext.dbConn,
                   sql(selectStatement),
                   whereValues)

  return parseBiggestInt(row[0])


proc createSMPostVoteReturnsPk*(
       dbContext: NexusSocialDbContext,
       smPostId: int64,
       votesUpCount: int,
       votesDownCount: int,
       ignoreExistingPk: bool = false): int64 {.gcsafe.} =

  # Formulate insertStatement and insertValues
  var
    insertValues: seq[string]
    insertStatement = "insert into sm_post_vote ("
    valuesClause = ""

  # Field: SM Post Id
  insertStatement &= "sm_post_id, "
  valuesClause &= "?, "
  insertValues.add($smPostId)

  # Field: Votes Up Count
  insertStatement &= "votes_up_count, "
  valuesClause &= "?, "
  insertValues.add($votesUpCount)

  # Field: Votes Down Count
  insertStatement &= "votes_down_count, "
  valuesClause &= "?, "
  insertValues.add($votesDownCount)

  # Remove trailing commas and finalize insertStatement
  if insertStatement[len(insertStatement) - 2 .. len(insertStatement) - 1] == ", ":
    insertStatement = insertStatement[0 .. len(insertStatement) - 3]

  if valuesClause[len(valuesClause) - 2 .. len(valuesClause) - 1] == ", ":
    valuesClause = valuesClause[0 .. len(valuesClause) - 3]

  # Finalize insertStatement
  insertStatement &=
    ") values (" & valuesClause & ")"

  if ignoreExistingPk == true:
    insertStatement &= " on conflict (sm_post_id) do nothing"

  # Execute the insert statement and return the sequence values
  exec(
    dbContext.dbConn,
    sql(insertStatement),
    insertValues)

  return smPostId


proc createSMPostVote*(
       dbContext: NexusSocialDbContext,
       smPostId: int64,
       votesUpCount: int,
       votesDownCount: int,
       ignoreExistingPk: bool = false,
       copyAllStringFields: bool = true,
       convertToRawTypes: bool = true): SMPostVote {.gcsafe.} =

  var smPostVote = SMPostVote()

  smPostVote.smPostId =
    createSMPostVoteReturnsPk(
      dbContext,
      smPostId,
      votesUpCount,
      votesDownCount,
      ignoreExistingPk)

  # Copy all fields as strings
  smPostVote.votesUpCount = votesUpCount
  smPostVote.votesDownCount = votesDownCount

  return smPostVote


proc deleteSMPostVoteByPk*(
       dbContext: NexusSocialDbContext,
       smPostId: int64): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from sm_post_vote" &
    " where sm_post_id = ?"

  return execAffectedRows(
           dbContext.dbConn,
           sql(deleteStatement),
           smPostId)


proc deleteSMPostVote*(
       dbContext: NexusSocialDbContext,
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from sm_post_vote" &
    " where " & whereClause

  return execAffectedRows(
           dbContext.dbConn,
           sql(deleteStatement),
           whereValues)


proc deleteSMPostVote*(
       dbContext: NexusSocialDbContext,
       whereFields: seq[string],
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from sm_post_vote"

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


proc existsSMPostVoteByPk*(
       dbContext: NexusSocialDbContext,
       smPostId: int64): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from sm_post_vote" &
    " where sm_post_id = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              $smPostId)

  if row[0] == "":
    return false
  else:
    return true


proc filterSMPostVote*(
       dbContext: NexusSocialDbContext,
       whereClause: string = "",
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): SMPostVotes {.gcsafe.} =

  var selectStatement =
    "select sm_post_id, votes_up_count, votes_down_count" & 
    "  from sm_post_vote"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  if len(orderByFields) > 0:
    selectStatement &= " order by " & orderByFields.join(", ")

  if limit != none(int):
    selectStatement &= " limit " & $limit.get

  var smPostVotes: SMPostVotes

  for row in fastRows(dbContext.dbConn,
                      sql(selectStatement),
                      whereValues):

    smPostVotes.add(rowToSMPostVote(row))

  return smPostVotes


proc filterSMPostVote*(
       dbContext: NexusSocialDbContext,
       whereFields: seq[string],
       whereValues: seq[string],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): SMPostVotes {.gcsafe.} =

  var selectStatement =
    "select sm_post_id, votes_up_count, votes_down_count" & 
    "  from sm_post_vote"

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

  var smPostVotes: SMPostVotes

  for row in fastRows(dbContext.dbConn,
                      sql(selectStatement),
                      whereValues):

    smPostVotes.add(rowToSMPostVote(row))

  return smPostVotes


proc getSMPostVoteByPk*(
       dbContext: NexusSocialDbContext,
       smPostId: int64): Option[SMPostVote] {.gcsafe.} =

  var selectStatement =
    "select sm_post_id, votes_up_count, votes_down_count" & 
    "  from sm_post_vote" &
    " where sm_post_id = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              smPostId)

  if row[0] == "":
    return none(SMPostVote)

  return some(rowToSMPostVote(row))


proc getSMPostVoteByPk*(
       dbContext: NexusSocialDbContext,
       smPostId: string): Option[SMPostVote] {.gcsafe.} =

  var selectStatement =
    "select sm_post_id, votes_up_count, votes_down_count" & 
    "  from sm_post_vote" &
    " where sm_post_id = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              smPostId)

  if row[0] == "":
    return none(SMPostVote)

  return some(rowToSMPostVote(row))


proc getOrCreateSMPostVoteByPk*(
       dbContext: NexusSocialDbContext,
       smPostId: int64,
       votesUpCount: int,
       votesDownCount: int): SMPostVote {.gcsafe.} =

  let smPostVote =
        getSMPostVoteByPK(
          dbContext,
          smPostId)

  if smPostVote != none(SMPostVote):
    return smPostVote.get

  return createSMPostVote(
           dbContext,
           smPostId,
           votesUpCount,
           votesDownCount)


proc rowToSMPostVote*(row: seq[string]):
       SMPostVote {.gcsafe.} =

  var smPostVote = SMPostVote()

  smPostVote.smPostId = parseBiggestInt(row[0])
  smPostVote.votesUpCount = parseInt(row[1])
  smPostVote.votesDownCount = parseInt(row[2])

  return smPostVote


proc truncateSMPostVote*(
       dbContext: NexusSocialDbContext,
       cascade: bool = false) =

  if cascade == false:
    exec(dbContext.dbConn,
         sql("truncate table sm_post_vote restart identity;"))

  else:
    exec(dbContext.dbConn,
         sql("truncate table sm_post_vote restart identity cascade;"))


proc updateSMPostVoteSetClause*(
       smPostVote: SMPostVote,
       setFields: seq[string],
       updateStatement: var string,
       updateValues: var seq[string]) {.gcsafe.} =

  updateStatement =
    "update sm_post_vote" &
    "   set "

  for field in setFields:

    if field == "sm_post_id":
      updateStatement &= "       sm_post_id = ?,"
      updateValues.add($smPostVote.smPostId)

    elif field == "votes_up_count":
      updateStatement &= "       votes_up_count = ?,"
      updateValues.add($smPostVote.votesUpCount)

    elif field == "votes_down_count":
      updateStatement &= "       votes_down_count = ?,"
      updateValues.add($smPostVote.votesDownCount)

  updateStatement[len(updateStatement) - 1] = ' '



proc updateSMPostVoteByPk*(
       dbContext: NexusSocialDbContext,
       smPostVote: SMPostVote,
       setFields: seq[string],
       exceptionOnNRowsUpdated: bool = true): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateSMPostVoteSetClause(
    sm_post_vote,
    setFields,
    updateStatement,
    updateValues)

  updateStatement &= " where sm_post_id = ?"

  updateValues.add($smPostVote.smPostId)

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


proc updateSMPostVoteByWhereClause*(
       dbContext: NexusSocialDbContext,
       smPostVote: SMPostVote,
       setFields: seq[string],
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateSMPostVoteSetClause(
    sm_post_vote,
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


proc updateSMPostVoteByWhereEqOnly*(
       dbContext: NexusSocialDbContext,
       smPostVote: SMPostVote,
       setFields: seq[string],
       whereFields: seq[string],
       whereValues: seq[string]): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateSMPostVoteSetClause(
    sm_post_vote,
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


