# Nexus generated file
import options, strutils, tables, times
import nexus/social/data_access/sm_post_data
import nexus/social/types/model_types


# Code
proc cachedCreateSMPost*(
       nexusSocialDbContext: var NexusSocialDbContext,
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
  let smPost =
        createSMPost(
           nexusSocialDbContext,
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

  # Add to the model row cache
  nexusSocialDbContext.cachedSMPosts[smPost.smPostId] = smPost

  # Clear filter cache
  nexusSocialDbContext.cachedFilterSMPost.clear()

  return smPost


proc cachedDeleteSMPostByPk*(
       nexusSocialDbContext: var NexusSocialDbContext,
       smPostId: int64): int64 {.gcsafe.} =

  # Call the model's delete proc
  let rowsDeleted = 
        deleteSMPostByPk(
          nexusSocialDbContext,
          smPostId)

  # Remove from the model row cache
  nexusSocialDbContext.cachedSMPosts.del(smPostId)

  # Clear the filter cache
  nexusSocialDbContext.cachedFilterSMPost.clear()

  # Clear filter cache
  nexusSocialDbContext.cachedFilterSMPost.clear()

  return rowsDeleted


proc cachedExistsSMPostByPk*(
       nexusSocialDbContext: var NexusSocialDbContext,
       smPostId: int64): bool {.gcsafe.} =

  # Check existence in the model row cache
  if nexusSocialDbContext.cachedSMPosts.hasKey(smPostId):
    return true

  # Call the model's exists proc
  return existsSMPostByPk(
           nexusSocialDbContext,
           smPostId)


proc cachedExistsSMPostByUniqueHash*(
       nexusSocialDbContext: var NexusSocialDbContext,
       uniqueHash: string): bool {.gcsafe.} =

  # Define the filter key
  let filterKey = "0|Unique Hash" & 
                  "1|" & uniqueHash

  # Check existence in the model row cache
  if nexusSocialDbContext.cachedFilterSMPost.hasKey(filterKey):
    return true

  # Call the model's exists proc
  return existsSMPostByUniqueHash(
           nexusSocialDbContext,
           uniqueHash)


proc cachedFilterSMPost*(
       nexusSocialDbContext: var NexusSocialDbContext,
       whereClause: string = "",
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): SMPosts {.gcsafe.} =

  # Get rows in the model row cache via the filter cache
  let filterKey = "0|" & whereClause &
                  "1|" & join(whereValues, "|") &
                  "2|" & join(orderByFields, "|")

  var cachedSMPosts: SMPosts

  if nexusSocialDbContext.cachedFilterSMPost.hasKey(filterKey):

    for pk in nexusSocialDbContext.cachedFilterSMPost[filterKey]:

      cachedSMPosts.add(nexusSocialDbContext.cachedSMPosts[pk])

    return cachedSMPosts

  # Call the model's filter proc
  let smPosts =
        filterSMPost(
          nexusSocialDbContext,
          whereClause,
          whereValues,
          orderByFields,
          limit)

  # Get PKs from the filter results
  var pks: seq[int64]

  for smPost in smPosts:
    pks.add(smPost.smPostId)

  # Set rows in filter cache
  nexusSocialDbContext.cachedFilterSMPost[filterKey] = pks

  # Set rows in model row cache
  for smPost in smPosts:

    nexusSocialDbContext.cachedSMPosts[smPost.smPostId] = smPost

  return smPosts


proc cachedFilterSMPost*(
       nexusSocialDbContext: var NexusSocialDbContext,
       whereFields: seq[string],
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): SMPosts {.gcsafe.} =

  # Get rows in the model row cache via the filter cache
  let filterKey = "0|" & join(whereFields, "|") &
                  "1|" & join(whereValues, "|") &
                  "2|" & join(orderByFields, "|")

  var cachedSMPosts: SMPosts

  if nexusSocialDbContext.cachedFilterSMPost.hasKey(filterKey):

    for pk in nexusSocialDbContext.cachedFilterSMPost[filterKey]:

      cachedSMPosts.add(nexusSocialDbContext.cachedSMPosts[pk])

    return cachedSMPosts

  # Call the model's filter proc
  let sm_posts =
        filterSMPost(
          nexus_socialDbContext,
          whereFields,
          whereValues,
          orderByFields,
          limit)

  # Get PKs from the filter results
  var pks: seq[int64]

  for smPost in smPosts:
    pks.add(smPost.smPostId)

  # Set rows in filter cache
  nexusSocialDbContext.cachedFilterSMPost[filterKey] = pks

  # Set rows in model row cache
  for smPost in smPosts:

    nexusSocialDbContext.cachedSMPosts[smPost.smPostId] = smPost

  return smPosts


proc cachedGetSMPostByPk*(
       nexusSocialDbContext: var NexusSocialDbContext,
       smPostId: int64): Option[SMPost] {.gcsafe.} =

  # Get from the model row cache
  if nexusSocialDbContext.cachedSMPosts.hasKey(smPostId):
    return some(nexusSocialDbContext.cachedSMPosts[smPostId])

  # Call the model's get proc
  let smPost =
        getSMPostByPk(
          nexusSocialDbContext,
          smPostId)

  if smPost != none(SMPost):

    # Add to the model row cache
    nexusSocialDbContext.cachedSMPosts[smPost.get.smPostId] = smPost.get

  return smPost


proc cachedGetSMPostByUniqueHash*(
       nexusSocialDbContext: var NexusSocialDbContext,
       uniqueHash: string): Option[SMPost] {.gcsafe.} =

  # Define the filter key
  let filterKey = "0|Unique Hash" & 
                  "1|" & uniqueHash

  # Get from the model row cache
  if nexusSocialDbContext.cachedFilterSMPost.hasKey(filterKey):
    return some(nexusSocialDbContext.cachedSMPosts[nexusSocialDbContext.cachedFilterSMPost[filterKey][0]])

  # Call the model's get proc
  let smPost =
        getSMPostByUniqueHash(
          nexusSocialDbContext,
          uniqueHash)

  if smPost != none(SMPost):

    # Add to the model row cache
    nexusSocialDbContext.cachedSMPosts[smPost.get.smPostId] = smPost.get

  return smPost


proc cachedGetOrCreateSMPostByUniqueHash*(
       nexusSocialDbContext: var NexusSocialDbContext,
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
  if nexusSocialDbContext.cachedFilterSMPost.hasKey(filterKey):
    return nexusSocialDbContext.cachedSMPosts[nexusSocialDbContext.cachedFilterSMPost[filterKey][0]]

  let smPost =
        getOrCreateSMPostByUniqueHash(
          nexusSocialDbContext,
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
  if not nexusSocialDbContext.cachedSMPosts.hasKey(smPost.smPostId):
    nexusSocialDbContext.cachedSMPosts[smPost.smPostId] = smPost

  return smPost


proc cachedUpdateSMPostByPk*(
       nexusSocialDbContext: var NexusSocialDbContext,
       smPost: SMPost,
       setFields: seq[string]): int64 {.gcsafe.} =

  # Call the model's update proc
  let rowsUpdated =
        updateSMPostByPk(
          nexusSocialDbContext,
          smPost,
          setFields)

  # Add to the model row cache
  nexusSocialDbContext.cachedSMPosts[smPost.smPostId] = smPost

  # Clear filter cache
  nexusSocialDbContext.cachedFilterSMPost.clear()

  return rowsUpdated


