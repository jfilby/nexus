# Nexus generated file
import options, strutils, tables, times
import nexus/social/data_access/sm_post_data
import nexus/social/types/model_types


# Code
proc cachedCreateSMPost*(
       dbContext: var NexusSocialDbContext,
       parentId: Option[int64] = none(int64),
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
           dbContext,
           parentId,
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
  dbContext.cachedSMPosts[smPost.id] = smPost

  # Clear filter cache
  dbContext.cachedFilterSMPost.clear()

  return smPost


proc cachedDeleteSMPostByPk*(
       dbContext: var NexusSocialDbContext,
       id: int64): int64 {.gcsafe.} =

  # Call the model's delete proc
  let rowsDeleted = 
        deleteSMPostByPk(
          dbContext,
          id)

  # Remove from the model row cache
  dbContext.cachedSMPosts.del(id)

  # Clear the filter cache
  dbContext.cachedFilterSMPost.clear()

  # Clear filter cache
  dbContext.cachedFilterSMPost.clear()

  return rowsDeleted


proc cachedExistsSMPostByPk*(
       dbContext: var NexusSocialDbContext,
       id: int64): bool {.gcsafe.} =

  # Check existence in the model row cache
  if dbContext.cachedSMPosts.hasKey(id):
    return true

  # Call the model's exists proc
  return existsSMPostByPk(
           dbContext,
           id)


proc cachedExistsSMPostByUniqueHash*(
       dbContext: var NexusSocialDbContext,
       uniqueHash: string): bool {.gcsafe.} =

  # Define the filter key
  let filterKey = "0|Unique Hash" & 
                  "1|" & uniqueHash

  # Check existence in the model row cache
  if dbContext.cachedFilterSMPost.hasKey(filterKey):
    return true

  # Call the model's exists proc
  return existsSMPostByUniqueHash(
           dbContext,
           uniqueHash)


proc cachedFilterSMPost*(
       dbContext: var NexusSocialDbContext,
       whereClause: string = "",
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): SMPosts {.gcsafe.} =

  # Get rows in the model row cache via the filter cache
  let filterKey = "0|" & whereClause &
                  "1|" & join(whereValues, "|") &
                  "2|" & join(orderByFields, "|")

  var cachedSMPosts: SMPosts

  if dbContext.cachedFilterSMPost.hasKey(filterKey):

    for pk in dbContext.cachedFilterSMPost[filterKey]:

      cachedSMPosts.add(dbContext.cachedSMPosts[pk])

    return cachedSMPosts

  # Call the model's filter proc
  let smPosts =
        filterSMPost(
          dbContext,
          whereClause,
          whereValues,
          orderByFields,
          limit)

  # Get PKs from the filter results
  var pks: seq[int64]

  for smPost in smPosts:
    pks.add(smPost.id)

  # Set rows in filter cache
  dbContext.cachedFilterSMPost[filterKey] = pks

  # Set rows in model row cache
  for smPost in smPosts:

    dbContext.cachedSMPosts[smPost.id] = smPost

  return smPosts


proc cachedFilterSMPost*(
       dbContext: var NexusSocialDbContext,
       whereFields: seq[string],
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): SMPosts {.gcsafe.} =

  # Get rows in the model row cache via the filter cache
  let filterKey = "0|" & join(whereFields, "|") &
                  "1|" & join(whereValues, "|") &
                  "2|" & join(orderByFields, "|")

  var cachedSMPosts: SMPosts

  if dbContext.cachedFilterSMPost.hasKey(filterKey):

    for pk in dbContext.cachedFilterSMPost[filterKey]:

      cachedSMPosts.add(dbContext.cachedSMPosts[pk])

    return cachedSMPosts

  # Call the model's filter proc
  let sm_posts =
        filterSMPost(
          dbContext,
          whereFields,
          whereValues,
          orderByFields,
          limit)

  # Get PKs from the filter results
  var pks: seq[int64]

  for smPost in smPosts:
    pks.add(smPost.id)

  # Set rows in filter cache
  dbContext.cachedFilterSMPost[filterKey] = pks

  # Set rows in model row cache
  for smPost in smPosts:

    dbContext.cachedSMPosts[smPost.id] = smPost

  return smPosts


proc cachedGetSMPostByPk*(
       dbContext: var NexusSocialDbContext,
       id: int64): Option[SMPost] {.gcsafe.} =

  # Get from the model row cache
  if dbContext.cachedSMPosts.hasKey(id):
    return some(dbContext.cachedSMPosts[id])

  # Call the model's get proc
  let smPost =
        getSMPostByPk(
          dbContext,
          id)

  if smPost != none(SMPost):

    # Add to the model row cache
    dbContext.cachedSMPosts[smPost.get.id] = smPost.get

  return smPost


proc cachedGetSMPostByUniqueHash*(
       dbContext: var NexusSocialDbContext,
       uniqueHash: string): Option[SMPost] {.gcsafe.} =

  # Define the filter key
  let filterKey = "0|Unique Hash" & 
                  "1|" & uniqueHash

  # Get from the model row cache
  if dbContext.cachedFilterSMPost.hasKey(filterKey):
    return some(dbContext.cachedSMPosts[dbContext.cachedFilterSMPost[filterKey][0]])

  # Call the model's get proc
  let smPost =
        getSMPostByUniqueHash(
          dbContext,
          uniqueHash)

  if smPost != none(SMPost):

    # Add to the model row cache
    dbContext.cachedSMPosts[smPost.get.id] = smPost.get

  return smPost


proc cachedGetOrCreateSMPostByUniqueHash*(
       dbContext: var NexusSocialDbContext,
       parentId: Option[int64],
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
  if dbContext.cachedFilterSMPost.hasKey(filterKey):
    return dbContext.cachedSMPosts[dbContext.cachedFilterSMPost[filterKey][0]]

  let smPost =
        getOrCreateSMPostByUniqueHash(
          dbContext,
          parentId,
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
  if not dbContext.cachedSMPosts.hasKey(smPost.id):
    dbContext.cachedSMPosts[smPost.id] = smPost

  return smPost


proc cachedUpdateSMPostByPk*(
       dbContext: var NexusSocialDbContext,
       smPost: SMPost,
       setFields: seq[string]): int64 {.gcsafe.} =

  # Call the model's update proc
  let rowsUpdated =
        updateSMPostByPk(
          dbContext,
          smPost,
          setFields)

  # Add to the model row cache
  dbContext.cachedSMPosts[smPost.id] = smPost

  # Clear filter cache
  dbContext.cachedFilterSMPost.clear()

  return rowsUpdated


