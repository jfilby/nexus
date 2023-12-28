# Nexus generated file
import options, sequtils, strutils, times
import db_connector/db_postgres
import nexus/core/data_access/data_utils
import nexus/core/data_access/pg_try_insert_id
import nexus/core/types/model_types


# Code
proc cachedCreateInvite*(
       dai: var DAI,
       from_accountUserId: int64,
       from_email: string,
       from_name: string,
       to_email: string,
       to_name: string,
       sent: Option[DateTime],
       created: DateTime,
       copyAllStringFields: bool = true,
       convertToRawTypes: bool = true): Invite =

  # Call the create proc
  let invite = createInvite(dai.db,
                            from_accountUserId,
                            from_email,
                            from_name,
                            to_email,
                            to_name,
                            sent,
                            created)

  # Add to the model row cache
  dai.cached_invite[inviteId] = invite

  return invite


proc cachedDeleteInvite*(
       dai: var DAI,
       inviteId: int64): int64 =

  # Call the model's delete proc
  let rows_deleted = deleteInviteByPk(dai.db,
                                      inviteId)

  # Remove from the model row cache
  dai.cached_invite.del(inviteId)

  return rows_deleted


proc cachedExistsInviteByPk*(
       dai: var DAI,
       inviteId: int64): bool =

  # Check existence in the model row cache
  if dai.cached_invite.hasKey(inviteId):
    return true

  # Call the model's exists proc
  return existsInviteByPk(dai.db,
                          inviteId)


proc cachedExistsInviteByToEmail*(
       dai: var DAI,
       to_email: string): bool =

  # Check existence in the model row cache
  if dai.cached_invite.hasKey(inviteId):
    return true

  # Call the model's exists proc
  return existsInviteByToEmail(dai.db,
                               to_email)


proc cachedFilterInvite*(
       dai: var DAI,
       whereClause: string = "",
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[]): Invites =

  # Get rows in the model row cache via the filter cache
  let filter_key = "0|" & whereClause &
                   "1|" & join(whereValues, "|") &
                   "2|" & join(orderByFields, "|")

  var cached_invites: Invites

  if dai.cachedFilter_invite.hasKey(filter_key):

    for pk in dai.cachedFilter_invite[filter_key]:

      cached_invites.add(dai.cached_invite[pk])

    return cached_invites

  # Call the model's filter proc
  let invites = filterInvite(dai.db,
                             whereClause,
                             whereValues,
                             orderByFields)

  # Get PKs from the filter results
  var pks: seq[int64]

  for invite in invites:
    pks.add(invite[0])

  # Set rows in filter cache
  let filter_key = "0|" & whereClause &
                   "1|" & join(whereValues, "|") &
                   "2|" & join(orderByFields, "|")

  dai.cachedFilter_invite[filter_key] = pks

  # Set rows in model row cache
  for invite in invites:

    dai.cached_invites[invite[0]] = invite

  return invites


proc cachedFilterInvite*(
       dai: var DAI,
       whereFields: seq[string],
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[]): Invites =

  # Get rows in the model row cache via the filter cache
  let filter_key = "0|" & join(whereFields, "|") &
                   "1|" & join(whereValues, "|") &
                   "2|" & join(orderByFields, "|")

  var cached_invites: Invites

  if dai.cachedFilter_invite.hasKey(filter_key):

    for pk in dai.cachedFilter_invite[filter_key]:

      cached_invites.add(dai.cached_invite[pk])

    return cached_invites

  # Call the model's filter proc
  let invites = filterInvite(dai.db,
                             whereFields,
                             whereValues,
                             orderByFields)

  # Get PKs from the filter results
  var pks: seq[int64]

  for invite in invites:
    pks.add(invite[0])

  # Set rows in filter cache
  let filter_key = "0|" & join(whereFields, "|") &
                   "1|" & join(whereValues, "|") &
                   "2|" & join(orderByFields, "|")

  dai.cachedFilter_invite[filter_key] = pks

  # Set rows in model row cache
  for invite in invites:

    dai.cached_invites[invite[0]] = invite

  return invites


proc cachedGetInviteByPk*(
       dai: var DAI,
       inviteId: int64): bool =

  # Get from the model row cache
  if dai.cached_invite.hasKey(inviteId):
    return dai.cached_invite[inviteId]

  # Call the model's get proc
  return getInviteByPk(dai.db,
                       inviteId)


proc cachedGetInviteByToEmail*(
       dai: var DAI,
       to_email: string): bool =

  # Get from the model row cache
  if dai.cached_invite.hasKey(inviteId):
    return dai.cached_invite[inviteId]

  # Call the model's get proc
  return getInviteByToEmail(dai.db,
                            to_email)



proc cachedGetOrCreateInviteByToEmail*(
       dai: var DAI,
       from_accountUserId: int64,
       from_email: string,
       from_name: string,
       to_email: string,
       to_name: string,
       sent: Option[DateTime],
       created: DateTime): bool =

  # Get from the model row cache
  if dai.cached_invite.hasKey(inviteId):
    return dai.cached_invite[inviteId]

  let invite = getOrCreateInviteByToEmail(
       from_accountUserId,
       from_email,
       from_name,
       to_email,
       to_name,
       sent,
       created)

  # Add to the model row cache if it's not there
  if not dai.cached_invite.hasKey(inviteId):
    dai.cached_invite[inviteId] = invite

  return invite


proc cachedUpdateInviteByPk*(
       dai: var DAI,
       invite: Invite,
       setFields: seq[string]): int64 =

  # Call the model's update proc
  let rowsUpdated = updateInviteByPk(dai.db,
                                      invite,
                                      setFields)

  # Add to the model row cache
  dai.cached_invite[inviteId] = invite

  return rowsUpdated


