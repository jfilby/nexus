# Nexus generated file
import db_postgres, options, sequtils, strutils, times
import nexus/core/data_access/data_utils
import nexus/core/data_access/pg_try_insert_id
import nexus/social/types/model_types


# Code
proc cachedCreateSmPostVoteUser*(
       dai: var DAI,
       sm_postId: int64,
       accountUserId: int64,
       vote_up: bool,
       vote_down: bool,
       copyAllStringFields: bool = true,
       convertToRawTypes: bool = true): SmPostVoteUser =

  # Call the create proc
  let sm_post_vote_user = createSmPostVoteUser(dai.db,
                                               sm_postId,
                                               accountUserId,
                                               vote_up,
                                               vote_down)

  # Add to the model row cache
  dai.cached_sm_post_vote_user[sm_postId, accountUserId] = sm_post_vote_user

  return sm_post_vote_user


proc cachedDeleteSmPostVoteUser*(
       dai: var DAI,
       sm_postId: int64,
       accountUserId: int64): int64 =

  # Call the model's delete proc
  let rows_deleted = deleteSmPostVoteUserByPK(dai.db,
                                              sm_postId,
                                              accountUserId)

  # Remove from the model row cache
  dai.cached_sm_post_vote_user.del(sm_postId, accountUserId)

  return rows_deleted


proc cachedExistsSmPostVoteUserByPK*(
       dai: var DAI,
       sm_postId: int64,
       accountUserId: int64): bool =

  # Check existence in the model row cache
  if dai.cached_sm_post_vote_user.hasKey(sm_postId, accountUserId):
    return true

  # Call the model's exists proc
  return existsSmPostVoteUserByPK(dai.db,
                                  sm_postId,
                                  accountUserId)


proc cachedFilterSmPostVoteUser*(
       dai: var DAI,
       whereClause: string = "",
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[]): SmPostVoteUsers =

  # Get rows in the model row cache via the filter cache
  let filter_key = "0|" & whereClause &
                   "1|" & join(whereValues, "|") &
                   "2|" & join(orderByFields, "|")

  var cached_sm_post_vote_users: SmPostVoteUsers

  if dai.cachedFilter_sm_post_vote_user.hasKey(filter_key):

    for pk in dai.cachedFilter_sm_post_vote_user[filter_key]:

      cached_sm_post_vote_users.add(dai.cached_sm_post_vote_user[pk])

    return cached_sm_post_vote_users

  # Call the model's filter proc
  let sm_post_vote_users = filterSmPostVoteUser(dai.db,
                                                whereClause,
                                                whereValues,
                                                orderByFields)

  # Get PKs from the filter results
  var pks: seq[(int64, int64)]

  for sm_post_vote_user in sm_post_vote_users:
    pks.add(sm_post_vote_user[0])

  # Set rows in filter cache
  let filter_key = "0|" & whereClause &
                   "1|" & join(whereValues, "|") &
                   "2|" & join(orderByFields, "|")

  dai.cachedFilter_sm_post_vote_user[filter_key] = pks

  # Set rows in model row cache
  for sm_post_vote_user in sm_post_vote_users:

    dai.cached_sm_post_vote_users[sm_post_vote_user[0]] = sm_post_vote_user

  return sm_post_vote_users


proc cachedFilterSmPostVoteUser*(
       dai: var DAI,
       whereFields: seq[string],
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[]): SmPostVoteUsers =

  # Get rows in the model row cache via the filter cache
  let filter_key = "0|" & join(whereFields, "|") &
                   "1|" & join(whereValues, "|") &
                   "2|" & join(orderByFields, "|")

  var cached_sm_post_vote_users: SmPostVoteUsers

  if dai.cachedFilter_sm_post_vote_user.hasKey(filter_key):

    for pk in dai.cachedFilter_sm_post_vote_user[filter_key]:

      cached_sm_post_vote_users.add(dai.cached_sm_post_vote_user[pk])

    return cached_sm_post_vote_users

  # Call the model's filter proc
  let sm_post_vote_users = filterSmPostVoteUser(dai.db,
                                                whereFields,
                                                whereValues,
                                                orderByFields)

  # Get PKs from the filter results
  var pks: seq[(int64, int64)]

  for sm_post_vote_user in sm_post_vote_users:
    pks.add(sm_post_vote_user[0])

  # Set rows in filter cache
  let filter_key = "0|" & join(whereFields, "|") &
                   "1|" & join(whereValues, "|") &
                   "2|" & join(orderByFields, "|")

  dai.cachedFilter_sm_post_vote_user[filter_key] = pks

  # Set rows in model row cache
  for sm_post_vote_user in sm_post_vote_users:

    dai.cached_sm_post_vote_users[sm_post_vote_user[0]] = sm_post_vote_user

  return sm_post_vote_users


proc cachedGetSmPostVoteUserByPK*(
       dai: var DAI,
       sm_postId: int64,
       accountUserId: int64): bool =

  # Get from the model row cache
  if dai.cached_sm_post_vote_user.hasKey(sm_postId, accountUserId):
    return dai.cached_sm_post_vote_user[sm_postId, accountUserId]

  # Call the model's get proc
  return getSmPostVoteUserByPK(dai.db,
                               sm_postId,
                               accountUserId)


proc cachedGetOrCreateSmPostVoteUserByPK*(
       dai: var DAI,
       sm_postId: int64,
       accountUserId: int64,
       vote_up: bool,
       vote_down: bool): bool =

  # Get from the model row cache
  if dai.cached_sm_post_vote_user.hasKey(sm_postId, accountUserId):
    return dai.cached_sm_post_vote_user[sm_postId, accountUserId]

  let sm_post_vote_user = getOrCreateSmPostVoteUserByPK(
       sm_postId,
       accountUserId,
       vote_up,
       vote_down)

  # Add to the model row cache if it's not there
  if not dai.cached_sm_post_vote_user.hasKey(sm_postId, accountUserId):
    dai.cached_sm_post_vote_user[sm_postId, accountUserId] = sm_post_vote_user

  return sm_post_vote_user


proc cachedUpdateSmPostVoteUserByPK*(
       dai: var DAI,
       sm_post_vote_user: SmPostVoteUser,
       setFields: seq[string]): int64 =

  # Call the model's update proc
  let rowsUpdated = updateSmPostVoteUserByPK(dai.db,
                                              sm_post_vote_user,
                                              setFields)

  # Add to the model row cache
  dai.cached_sm_post_vote_user[sm_postId, accountUserId] = sm_post_vote_user

  return rowsUpdated


