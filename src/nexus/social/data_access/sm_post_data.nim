# Nexus generated file
import db_postgres, options, sequtils, strutils, times
import nexus/core/data_access/data_utils
import nexus/core/data_access/pg_try_insert_id
import nexus/social/types/model_types


# Forward declarations
proc rowToSMPost*(row: seq[string]):
       SMPost {.gcsafe.}


# Code
proc countSMPost*(
       nexusSocialModule: NexusSocialModule,
       whereFields: seq[string] = @[],
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from sm_post"
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


proc countSMPost*(
       nexusSocialModule: NexusSocialModule,
       whereClause: string,
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from sm_post"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  let row = getRow(nexusSocialModule.db,
                   sql(selectStatement),
                   whereValues)

  return parseBiggestInt(row[0])


proc createSMPostReturnsPK*(
       nexusSocialModule: NexusSocialModule,
       smPostParentId: Option[int64] = none(int64),
       accountUserId: int64,
       uniqueHash: string,
       postType: char,
       status: char = 'A',
       title: Option[string] = none(string),
       body: string,
       tagIds: Option[int64] = none(int64),
       created: DateTime = now(),
       published: Option[DateTime] = none(DateTime),
       updateCount: int = 0,
       updated: Option[DateTime] = none(DateTime),
       deleted: Option[DateTime] = none(DateTime)): int64 {.gcsafe.} =

  # Formulate insertStatement and insertValues
  var
    insertValues: seq[string]
    insertStatement = "insert into sm_post ("
    valuesClause = ""

  # Field: SM Post Parent Id
  if sm_post_parent_id != none(int64):
    insertStatement &= "sm_post_parent_id, "
    valuesClause &= "?, "
    insertValues.add($sm_post_parent_id.get)

  # Field: Account User Id
  insertStatement &= "account_user_id, "
  valuesClause &= "?, "
  insertValues.add($account_user_id)

  # Field: Unique Hash
  insertStatement &= "unique_hash, "
  valuesClause &= "?, "
  insertValues.add(unique_hash)

  # Field: Post Type
  insertStatement &= "post_type, "
  valuesClause &= "?, "
  insertValues.add($post_type)

  # Field: Status
  insertStatement &= "status, "
  valuesClause &= "?, "
  insertValues.add($status)

  # Field: Title
  if title != none(string):
    insertStatement &= "title, "
    valuesClause &= "?, "
    insertValues.add(title.get)

  # Field: Body
  insertStatement &= "body, "
  valuesClause &= "?, "
  insertValues.add(body)

  # Field: Tag Ids
  if tag_ids != none(int64):
    insertStatement &= "tag_ids, "
    valuesClause &= "?, "
    insertValues.add($tag_ids.get)

  # Field: Created
  insertStatement &= "created, "
  valuesClause &= pgToDateTimeString(created) & ", "

  # Field: Published
  if published != none(DateTime):
    insertStatement &= "published, "
    valuesClause &= pgToDateTimeString(published.get) & ", "

  # Field: Update Count
  insertStatement &= "update_count, "
  valuesClause &= "?, "
  insertValues.add($update_count)

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
  insertStatement &= ") values (" & valuesClause & ")"

  # Execute the insert statement and return the sequence values
  return tryInsertNamedID(
    nexusSocialModule.db,
    sql(insertStatement),
    "sm_post_id",
    insertValues)


proc createSMPost*(
       nexusSocialModule: NexusSocialModule,
       smPostParentId: Option[int64] = none(int64),
       accountUserId: int64,
       uniqueHash: string,
       postType: char,
       status: char = 'A',
       title: Option[string] = none(string),
       body: string,
       tagIds: Option[int64] = none(int64),
       created: DateTime = now(),
       published: Option[DateTime] = none(DateTime),
       updateCount: int = 0,
       updated: Option[DateTime] = none(DateTime),
       deleted: Option[DateTime] = none(DateTime),
       copyAllStringFields: bool = true,
       convertToRawTypes: bool = true): SMPost {.gcsafe.} =

  var smPost = SMPost()

  smPost.smPostId =
    createSMPostReturnsPK(
      nexusSocialModule,
      smPostParentId,
      accountUserId,
      uniqueHash,
      postType,
      status,
      title,
      body,
      tagIds,
      created,
      published,
      updateCount,
      updated,
      deleted)

  # Copy all fields as strings
  smPost.smPostParentId = smPostParentId
  smPost.accountUserId = accountUserId
  smPost.uniqueHash = uniqueHash
  smPost.postType = postType
  smPost.status = status
  smPost.title = title
  smPost.body = body
  smPost.tagIds = tagIds
  smPost.created = created
  smPost.published = published
  smPost.updateCount = updateCount
  smPost.updated = updated
  smPost.deleted = deleted

  return smPost


proc deleteSMPostByPK*(
       nexusSocialModule: NexusSocialModule,
       smPostId: int64): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from sm_post" &
    " where sm_post_id = ?"

  return execAffectedRows(
           nexusSocialModule.db,
           sql(deleteStatement),
           smPostId)


proc deleteSMPost*(
       nexusSocialModule: NexusSocialModule,
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from sm_post" &
    " where " & whereClause

  return execAffectedRows(
           nexusSocialModule.db,
           sql(deleteStatement),
           whereValues)


proc existsSMPostByPK*(
       nexusSocialModule: NexusSocialModule,
       smPostId: int64): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from sm_post" &
    " where sm_post_id = ?"

  let row = getRow(
              nexusSocialModule.db,
              sql(selectStatement),
              smPostId)

  if row[0] == "":
    return false
  else:
    return true


proc existsSMPostByUniqueHash*(
       nexusSocialModule: NexusSocialModule,
       uniqueHash: string): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from sm_post" &
    " where unique_hash = ?"

  let row = getRow(
              nexusSocialModule.db,
              sql(selectStatement),
              uniqueHash)

  if row[0] == "":
    return false
  else:
    return true


proc filterSMPost*(
       nexusSocialModule: NexusSocialModule,
       whereClause: string = "",
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[]): SMPosts {.gcsafe.} =

  var selectStatement =
    "select sm_post_id, sm_post_parent_id, account_user_id, unique_hash, post_type, status, title," & 
    "       body, tag_ids, created, published, update_count, updated, deleted" &
    "  from sm_post"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  if len(orderByFields) > 0:
    selectStatement &= " order by " & orderByFields.join(", ")

  var smPosts: SMPosts

  for row in fastRows(nexusSocialModule.db,
                      sql(selectStatement),
                      whereValues):

    smPosts.add(rowToSMPost(row))

  return smPosts


proc filterSMPost*(
       nexusSocialModule: NexusSocialModule,
       whereFields: seq[string],
       whereValues: seq[string],
       orderByFields: seq[string] = @[]): SMPosts {.gcsafe.} =

  var selectStatement =
    "select sm_post_id, sm_post_parent_id, account_user_id, unique_hash, post_type, status, title," & 
    "       body, tag_ids, created, published, update_count, updated, deleted" &
    "  from sm_post"

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

  var smPosts: SMPosts

  for row in fastRows(nexusSocialModule.db,
                      sql(selectStatement),
                      whereValues):

    smPosts.add(rowToSMPost(row))

  return smPosts


proc getSMPostByPK*(
       nexusSocialModule: NexusSocialModule,
       smPostId: int64): Option[SMPost] {.gcsafe.} =

  var selectStatement =
    "select sm_post_id, sm_post_parent_id, account_user_id, unique_hash, post_type, status, title," & 
    "       body, tag_ids, created, published, update_count, updated, deleted" &
    "  from sm_post" &
    " where sm_post_id = ?"

  let row = getRow(
              nexusSocialModule.db,
              sql(selectStatement),
              smPostId)

  if row[0] == "":
    return none(SMPost)

  return some(rowToSMPost(row))


proc getSMPostByPK*(
       nexusSocialModule: NexusSocialModule,
       smPostId: string): Option[SMPost] {.gcsafe.} =

  var selectStatement =
    "select sm_post_id, sm_post_parent_id, account_user_id, unique_hash, post_type, status, title," & 
    "       body, tag_ids, created, published, update_count, updated, deleted" &
    "  from sm_post" &
    " where sm_post_id = ?"

  let row = getRow(
              nexusSocialModule.db,
              sql(selectStatement),
              smPostId)

  if row[0] == "":
    return none(SMPost)

  return some(rowToSMPost(row))


proc getSMPostByUniqueHash*(
       nexusSocialModule: NexusSocialModule,
       uniqueHash: string): Option[SMPost] {.gcsafe.} =

  var selectStatement =
    "select sm_post_id, sm_post_parent_id, account_user_id, unique_hash, post_type, status, title," & 
    "       body, tag_ids, created, published, update_count, updated, deleted" &
    "  from sm_post" &
    " where unique_hash = ?"

  let row = getRow(
              nexusSocialModule.db,
              sql(selectStatement),
              uniqueHash)

  if row[0] == "":
    return none(SMPost)

  return some(rowToSMPost(row))


proc getOrCreateSMPostByUniqueHash*(
       nexusSocialModule: NexusSocialModule,
       smPostParentId: Option[int64],
       accountUserId: int64,
       uniqueHash: string,
       postType: char,
       status: char,
       title: Option[string],
       body: string,
       tagIds: Option[int64],
       created: DateTime,
       published: Option[DateTime],
       updateCount: int,
       updated: Option[DateTime],
       deleted: Option[DateTime]): SMPost {.gcsafe.} =

  let smPost =
        getSMPostByUniqueHash(
          nexusSocialModule,
          uniqueHash)

  if smPost != none(SMPost):
    return smPost.get

  return createSMPost(
           nexusSocialModule,
           smPostParentId,
           accountUserId,
           uniqueHash,
           postType,
           status,
           title,
           body,
           tagIds,
           created,
           published,
           updateCount,
           updated,
           deleted)


proc rowToSMPost*(row: seq[string]):
       SMPost {.gcsafe.} =

  var smPost = SMPost()

  smPost.smPostId = parseBiggestInt(row[0])

  if row[1] != "":
    smPost.smPostParentId = some(parseBiggestInt(row[1]))
  else:
    smPost.smPostParentId = none(int64)

  smPost.accountUserId = parseBiggestInt(row[2])
  smPost.uniqueHash = row[3]
  smPost.postType = row[4][0]
  smPost.status = row[5][0]

  if row[6] != "":
    smPost.title = some(row[6])
  else:
    smPost.title = none(string)

  smPost.body = row[7]

  if row[8] != "":
    smPost.tagIds = some(parseBiggestInt(row[8]))
  else:
    smPost.tagIds = none(int64)

  smPost.created = parsePgTimestamp(row[9])

  if row[10] != "":
    smPost.published = some(parsePgTimestamp(row[10]))
  else:
    smPost.published = none(DateTime)

  smPost.updateCount = parseInt(row[11])

  if row[12] != "":
    smPost.updated = some(parsePgTimestamp(row[12]))
  else:
    smPost.updated = none(DateTime)

  if row[13] != "":
    smPost.deleted = some(parsePgTimestamp(row[13]))
  else:
    smPost.deleted = none(DateTime)


  return smPost


proc truncateSMPost*(
       nexusSocialModule: NexusSocialModule,
       cascade: bool = false) =

  if cascade == false:
    exec(nexusSocialModule.db,
         sql("truncate table sm_post restart identity;"))

  else:
    exec(nexusSocialModule.db,
         sql("truncate table sm_post restart identity cascade;"))


proc updateSMPostSetClause*(
       smPost: SMPost,
       setFields: seq[string],
       updateStatement: var string,
       updateValues: var seq[string]) {.gcsafe.} =

  updateStatement =
    "update sm_post" &
    "   set "

  for field in setFields:

    if field == "sm_post_id":
      updateStatement &= "       sm_post_id = ?,"
      updateValues.add($smPost.smPostId)

    elif field == "sm_post_parent_id":
      if smPost.smPostParentId != none(int64):
        updateStatement &= "       sm_post_parent_id = ?,"
        updateValues.add($smPost.smPostParentId.get)
      else:
        updateStatement &= "       sm_post_parent_id = null,"

    elif field == "account_user_id":
      updateStatement &= "       account_user_id = ?,"
      updateValues.add($smPost.accountUserId)

    elif field == "unique_hash":
      updateStatement &= "       unique_hash = ?,"
      updateValues.add($smPost.uniqueHash)

    elif field == "post_type":
      updateStatement &= "       post_type = ?,"
      updateValues.add($smPost.postType)

    elif field == "status":
      updateStatement &= "       status = ?,"
      updateValues.add($smPost.status)

    elif field == "title":
      if smPost.title != none(string):
        updateStatement &= "       title = ?,"
        updateValues.add($smPost.title.get)
      else:
        updateStatement &= "       title = null,"

    elif field == "body":
      updateStatement &= "       body = ?,"
      updateValues.add($smPost.body)

    elif field == "tag_ids":
      if smPost.tagIds != none(int64):
        updateStatement &= "       tag_ids = ?,"
        updateValues.add($smPost.tagIds.get)
      else:
        updateStatement &= "       tag_ids = null,"

    elif field == "created":
      updateStatement &= "       created = ?,"
      updateValues.add($smPost.created)

    elif field == "published":
      if smPost.published != none(DateTime):
        updateStatement &= "       published = ?,"
        updateValues.add($smPost.published.get)
      else:
        updateStatement &= "       published = null,"

    elif field == "update_count":
      updateStatement &= "       update_count = ?,"
      updateValues.add($smPost.updateCount)

    elif field == "updated":
      if smPost.updated != none(DateTime):
        updateStatement &= "       updated = ?,"
        updateValues.add($smPost.updated.get)
      else:
        updateStatement &= "       updated = null,"

    elif field == "deleted":
      if smPost.deleted != none(DateTime):
        updateStatement &= "       deleted = ?,"
        updateValues.add($smPost.deleted.get)
      else:
        updateStatement &= "       deleted = null,"

  updateStatement[len(updateStatement) - 1] = ' '



proc updateSMPostByPK*(
       nexusSocialModule: NexusSocialModule,
       smPost: SMPost,
       setFields: seq[string],
       exceptionOnNRowsUpdated: bool = true): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateSMPostSetClause(
    sm_post,
    setFields,
    updateStatement,
    updateValues)

  updateStatement &= " where sm_post_id = ?"

  updateValues.add($smPost.smPostId)

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


proc updateSMPostByWhereClause*(
       nexusSocialModule: NexusSocialModule,
       smPost: SMPost,
       setFields: seq[string],
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateSMPostSetClause(
    sm_post,
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


proc updateSMPostByWhereEqOnly*(
       nexusSocialModule: NexusSocialModule,
       smPost: SMPost,
       setFields: seq[string],
       whereFields: seq[string],
       whereValues: seq[string]): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateSMPostSetClause(
    sm_post,
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


