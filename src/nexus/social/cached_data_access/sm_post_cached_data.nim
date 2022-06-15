# Nexus generated file
import db_postgres, options, sequtils, strutils, tables, times
import nexus/core/data_access/data_utils
import nexus/core/data_access/pg_try_insert_id
import nexus_social/data_access/sm_post_data
import nexus_social/types/model_types


# Code
proc cachedCreateSMPost*(
       nexusSocialModule: var NexusSocialModule,
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

  # Call the create proc
  let smPost = createSMPost(nexusSocialModule,
                            smPostParentId = none(int64),
                            accountUserId,
                            uniqueHash,
                            postType,
                            status = 'A',
                            title = none(string),
                            body,
                            tagIds = none(int64),
                            created = now(),
                            published = none(DateTime),
                            updateCount = 0,
                            updated = none(DateTime),
                            deleted = none(DateTime))

  # Add to the model row cache
  nexusSocialModule.cachedSMPosts[smPost.smPostId] = smPost

  # Clear filter cache
  nexusSocialModule.cachedFilterSMPost.clear()

  return smPost


proc cachedDeleteSMPostByPk*(
       nexusSocialModule: var NexusSocialModule,
       smPostId: int64): int64 {.gcsafe.} =

  # Call the model's delete proc
  let rows_deleted = deleteSMPostByPk(nexusSocialModule,
                                      smPostId)

  # Remove from the model row cache
  nexusSocialModule.cachedSMPosts.del(smPostId)

  # Clear the filter cache
  nexusSocialModule.cachedFilterSMPost.clear()

  # Clear filter cache
  nexusSocialModule.cachedFilterSMPost.clear()

  return rowsDeleted


proc cachedExistsSMPostByPk*(
       nexusSocialModule: var NexusSocialModule,
       smPostId: int64): bool {.gcsafe.} =

  # Check existence in the model row cache
  if nexusSocialModule.cachedSMPosts.hasKey(smPostId):
    return true

  # Call the model's exists proc
  return existsSMPostByPk(nexusSocialModule,
                          smPostId)


proc cachedExistsSMPostByUniqueHash*(
       nexusSocialModule: var NexusSocialModule,
       uniqueHash: string): bool {.gcsafe.} =

  # Define the filter key
  let filterKey = "0|Unique Hash" & 
                  "1|" & uniqueHash

  # Check existence in the model row cache
  if nexusSocialModule.cachedFilterSMPost.hasKey(filterKey):
    return true

  # Call the model's exists proc
  return existsSMPostByUniqueHash(nexusSocialModule,
                                  uniqueHash)


proc cachedFilterSMPost*(
       nexusSocialModule: var NexusSocialModule,
       whereClause: string = "",
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[]): SMPosts {.gcsafe.} =

  # Get rows in the model row cache via the filter cache
  let filterKey = "0|" & whereClause &
                  "1|" & join(whereValues, "|") &
                  "2|" & join(orderByFields, "|")

  var cachedSMPosts: SMPosts

  if nexusSocialModule.cachedFilterSMPost.hasKey(filterKey):

    for pk in nexusSocialModule.cachedFilterSMPost[filterKey]:

      cachedSMPosts.add(nexusSocialModule.cachedSMPosts[pk])

    return cachedSMPosts

  # Call the model's filter proc
  let smPosts = filterSMPost(nexusSocialModule,
                             whereClause,
                             whereValues,
                             orderByFields)

  # Get PKs from the filter results
  var pks: seq[int64]

  for smPost in smPosts:
    pks.add(smPost.smPostId)

  # Set rows in filter cache
  nexusSocialModule.cachedFilterSMPost[filterKey] = pks

  # Set rows in model row cache
  for smPost in smPosts:

    nexusSocialModule.cachedSMPosts[smPost.smPostId] = smPost

  return smPosts


proc cachedFilterSMPost*(
       nexusSocialModule: var NexusSocialModule,
       whereFields: seq[string],
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[]): SMPosts {.gcsafe.} =

  # Get rows in the model row cache via the filter cache
  let filterKey = "0|" & join(whereFields, "|") &
                  "1|" & join(whereValues, "|") &
                  "2|" & join(orderByFields, "|")

  var cachedSMPosts: SMPosts

  if nexusSocialModule.cachedFilterSMPost.hasKey(filterKey):

    for pk in nexusSocialModule.cachedFilterSMPost[filterKey]:

      cachedSMPosts.add(nexusSocialModule.cachedSMPosts[pk])

    return cachedSMPosts

  # Call the model's filter proc
  let sm_posts = filterSMPost(nexus_socialModule,
                              whereFields,
                              whereValues,
                              orderByFields)

  # Get PKs from the filter results
  var pks: seq[int64]

  for smPost in smPosts:
    pks.add(smPost.smPostId)

  # Set rows in filter cache
  nexusSocialModule.cachedFilterSMPost[filterKey] = pks

  # Set rows in model row cache
  for smPost in smPosts:

    nexusSocialModule.cachedSMPosts[smPost.smPostId] = smPost

  return smPosts


proc cachedGetSMPostByPk*(
       nexusSocialModule: var NexusSocialModule,
       smPostId: int64): Option[SMPost] {.gcsafe.} =

  # Get from the model row cache
  if nexusSocialModule.cachedSMPosts.hasKey(smPostId):
    return some(nexusSocialModule.cachedSMPosts[smPostId])

  # Call the model's get proc
  let smPost = getSMPostByPk(nexusSocialModule,
                             smPostId)

  if smPost != none(SMPost):

    # Add to the model row cache
    nexusSocialModule.cachedSMPosts[smPost.get.smPostId] = smPost.get

  return smPost


proc cachedGetSMPostByUniqueHash*(
       nexusSocialModule: var NexusSocialModule,
       uniqueHash: string): Option[SMPost] {.gcsafe.} =

  # Define the filter key
  let filterKey = "0|Unique Hash" & 
                  "1|" & uniqueHash

  # Get from the model row cache
  if nexusSocialModule.cachedFilterSMPost.hasKey(filterKey):
    return some(nexusSocialModule.cachedSMPosts[nexusSocialModule.cachedFilterSMPost[filterKey][0]])

  # Call the model's get proc
  let smPost = getSMPostByUniqueHash(nexusSocialModule,
                                     uniqueHash)

  if smPost != none(SMPost):

    # Add to the model row cache
    nexusSocialModule.cachedSMPosts[smPost.get.smPostId] = smPost.get

  return smPost


proc cachedGetOrCreateSMPostByUniqueHash*(
       nexusSocialModule: var NexusSocialModule,
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

  # Define the filter key
  let filterKey = "0|Unique Hash" & 
                  "1|" & uniqueHash

  # Get from the model row cache
  if nexusSocialModule.cachedFilterSMPost.hasKey(filterKey):
    return nexusSocialModule.cachedSMPosts[nexusSocialModule.cachedFilterSMPost[filterKey][0]]

  let smPost = getOrCreateSMPostByUniqueHash(nexusSocialModule,
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

  # Add to the model row cache if it's not there
  if not nexusSocialModule.cachedSMPosts.hasKey(smPost.smPostId):
    nexusSocialModule.cachedSMPosts[smPost.smPostId] = smPost

  return smPost


proc cachedUpdateSMPostByPk*(
       nexusSocialModule: var NexusSocialModule,
       smPost: SMPost,
       setFields: seq[string]): int64 {.gcsafe.} =

  # Call the model's update proc
  let rowsUpdated = updateSMPostByPk(nexusSocialModule,
                                     smPost,
                                     setFields)

  # Add to the model row cache
  nexusSocialModule.cachedSMPosts[smPost.smPostId] = smPost

  # Clear filter cache
  nexusSocialModule.cachedFilterSMPost.clear()

  return rowsUpdated


