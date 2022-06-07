# Nexus generated file
import db_postgres, options, sequtils, strutils, times
import nexus/core/data_access/data_utils
import nexus/core/data_access/pg_try_insert_id
import nexus/social/types/model_types


# Code
proc cachedCreateSmPostVote*(
       dai: var DAI,
       sm_postId: int64,
       votes_up_count: int,
       votes_down_count: int,
       copyAllStringFields: bool = true,
       convertToRawTypes: bool = true): SmPostVote =

  # Call the create proc
  let sm_post_vote = createSmPostVote(dai.db,
                                      sm_postId,
                                      votes_up_count,
                                      votes_down_count)

  # Add to the model row cache
  dai.cached_sm_post_vote[sm_postId] = sm_post_vote

  return sm_post_vote


proc cachedDeleteSmPostVote*(
       dai: var DAI,
       sm_postId: int64): int64 =

  # Call the model's delete proc
  let rows_deleted = deleteSmPostVoteByPK(dai.db,
                                          sm_postId)

  # Remove from the model row cache
  dai.cached_sm_post_vote.del(sm_postId)

  return rows_deleted


proc cachedExistsSmPostVoteByPK*(
       dai: var DAI,
       sm_postId: int64): bool =

  # Check existence in the model row cache
  if dai.cached_sm_post_vote.hasKey(sm_postId):
    return true

  # Call the model's exists proc
  return existsSmPostVoteByPK(dai.db,
                              sm_postId)


proc cachedFilterSmPostVote*(
       dai: var DAI,
       whereClause: string = "",
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[]): SmPostVotes =

  # Get rows in the model row cache via the filter cache
  let filter_key = "0|" & whereClause &
                   "1|" & join(whereValues, "|") &
                   "2|" & join(orderByFields, "|")

  var cached_sm_post_votes: SmPostVotes

  if dai.cachedFilter_sm_post_vote.hasKey(filter_key):

    for pk in dai.cachedFilter_sm_post_vote[filter_key]:

      cached_sm_post_votes.add(dai.cached_sm_post_vote[pk])

    return cached_sm_post_votes

  # Call the model's filter proc
  let sm_post_votes = filterSmPostVote(dai.db,
                                       whereClause,
                                       whereValues,
                                       orderByFields)

  # Get PKs from the filter results
  var pks: seq[int64]

  for sm_post_vote in sm_post_votes:
    pks.add(sm_post_vote[0])

  # Set rows in filter cache
  let filter_key = "0|" & whereClause &
                   "1|" & join(whereValues, "|") &
                   "2|" & join(orderByFields, "|")

  dai.cachedFilter_sm_post_vote[filter_key] = pks

  # Set rows in model row cache
  for sm_post_vote in sm_post_votes:

    dai.cached_sm_post_votes[sm_post_vote[0]] = sm_post_vote

  return sm_post_votes


proc cachedFilterSmPostVote*(
       dai: var DAI,
       whereFields: seq[string],
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[]): SmPostVotes =

  # Get rows in the model row cache via the filter cache
  let filter_key = "0|" & join(whereFields, "|") &
                   "1|" & join(whereValues, "|") &
                   "2|" & join(orderByFields, "|")

  var cached_sm_post_votes: SmPostVotes

  if dai.cachedFilter_sm_post_vote.hasKey(filter_key):

    for pk in dai.cachedFilter_sm_post_vote[filter_key]:

      cached_sm_post_votes.add(dai.cached_sm_post_vote[pk])

    return cached_sm_post_votes

  # Call the model's filter proc
  let sm_post_votes = filterSmPostVote(dai.db,
                                       whereFields,
                                       whereValues,
                                       orderByFields)

  # Get PKs from the filter results
  var pks: seq[int64]

  for sm_post_vote in sm_post_votes:
    pks.add(sm_post_vote[0])

  # Set rows in filter cache
  let filter_key = "0|" & join(whereFields, "|") &
                   "1|" & join(whereValues, "|") &
                   "2|" & join(orderByFields, "|")

  dai.cachedFilter_sm_post_vote[filter_key] = pks

  # Set rows in model row cache
  for sm_post_vote in sm_post_votes:

    dai.cached_sm_post_votes[sm_post_vote[0]] = sm_post_vote

  return sm_post_votes


proc cachedGetSmPostVoteByPK*(
       dai: var DAI,
       sm_postId: int64): bool =

  # Get from the model row cache
  if dai.cached_sm_post_vote.hasKey(sm_postId):
    return dai.cached_sm_post_vote[sm_postId]

  # Call the model's get proc
  return getSmPostVoteByPK(dai.db,
                           sm_postId)


proc cachedGetOrCreateSmPostVoteByPK*(
       dai: var DAI,
       sm_postId: int64,
       votes_up_count: int,
       votes_down_count: int): bool =

  # Get from the model row cache
  if dai.cached_sm_post_vote.hasKey(sm_postId):
    return dai.cached_sm_post_vote[sm_postId]

  let sm_post_vote = getOrCreateSmPostVoteByPK(
       sm_postId,
       votes_up_count,
       votes_down_count)

  # Add to the model row cache if it's not there
  if not dai.cached_sm_post_vote.hasKey(sm_postId):
    dai.cached_sm_post_vote[sm_postId] = sm_post_vote

  return sm_post_vote


proc cachedUpdateSmPostVoteByPK*(
       dai: var DAI,
       sm_post_vote: SmPostVote,
       setFields: seq[string]): int64 =

  # Call the model's update proc
  let rowsUpdated = updateSmPostVoteByPK(dai.db,
                                          sm_post_vote,
                                          setFields)

  # Add to the model row cache
  dai.cached_sm_post_vote[sm_postId] = sm_post_vote

  return rowsUpdated


