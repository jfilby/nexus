# Nexus generated file
import options, sequtils, strutils, times
import db_connector/db_postgres
import nexus/core/data_access/data_utils
import nexus/core/data_access/pg_try_insert_id
import nexus/core/types/model_types


# Code
proc cachedCreateAccountUserRole*(
       dai: var DAI,
       accountUserId: int64,
       role: string,
       created: DateTime,
       copyAllStringFields: bool = true,
       convertToRawTypes: bool = true): AccountUserRole =

  # Call the create proc
  let accountUser_role = createAccountUserRole(dai.db,
                                                accountUserId,
                                                role,
                                                created)

  # Add to the model row cache
  dai.cached_accountUser_role[accountUser_roleId] = accountUser_role

  return accountUser_role


proc cachedDeleteAccountUserRole*(
       dai: var DAI,
       accountUser_roleId: int64): int64 =

  # Call the model's delete proc
  let rows_deleted = deleteAccountUserRoleByPk(dai.db,
                                               accountUser_roleId)

  # Remove from the model row cache
  dai.cached_accountUser_role.del(accountUser_roleId)

  return rows_deleted


proc cachedExistsAccountUserRoleByPk*(
       dai: var DAI,
       accountUser_roleId: int64): bool =

  # Check existence in the model row cache
  if dai.cached_accountUser_role.hasKey(accountUser_roleId):
    return true

  # Call the model's exists proc
  return existsAccountUserRoleByPk(dai.db,
                                   accountUser_roleId)


proc cachedExistsAccountUserRoleByAccountUserIdAndRole*(
       dai: var DAI,
       accountUserId: int64,
       role: string): bool =

  # Check existence in the model row cache
  if dai.cached_accountUser_role.hasKey(accountUser_roleId):
    return true

  # Call the model's exists proc
  return existsAccountUserRoleByAccountUserIdAndRole(dai.db,
                                                     accountUserId,
                                                     role)


proc cachedFilterAccountUserRole*(
       dai: var DAI,
       whereClause: string = "",
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[]): AccountUserRoles =

  # Get rows in the model row cache via the filter cache
  let filter_key = "0|" & whereClause &
                   "1|" & join(whereValues, "|") &
                   "2|" & join(orderByFields, "|")

  var cached_accountUser_roles: AccountUserRoles

  if dai.cachedFilter_accountUser_role.hasKey(filter_key):

    for pk in dai.cachedFilter_accountUser_role[filter_key]:

      cached_accountUser_roles.add(dai.cached_accountUser_role[pk])

    return cached_accountUser_roles

  # Call the model's filter proc
  let accountUser_roles = filterAccountUserRole(dai.db,
                                                 whereClause,
                                                 whereValues,
                                                 orderByFields)

  # Get PKs from the filter results
  var pks: seq[int64]

  for accountUser_role in accountUser_roles:
    pks.add(accountUser_role[0])

  # Set rows in filter cache
  let filter_key = "0|" & whereClause &
                   "1|" & join(whereValues, "|") &
                   "2|" & join(orderByFields, "|")

  dai.cachedFilter_accountUser_role[filter_key] = pks

  # Set rows in model row cache
  for accountUser_role in accountUser_roles:

    dai.cached_accountUser_roles[accountUser_role[0]] = accountUser_role

  return accountUser_roles


proc cachedFilterAccountUserRole*(
       dai: var DAI,
       whereFields: seq[string],
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[]): AccountUserRoles =

  # Get rows in the model row cache via the filter cache
  let filter_key = "0|" & join(whereFields, "|") &
                   "1|" & join(whereValues, "|") &
                   "2|" & join(orderByFields, "|")

  var cached_accountUser_roles: AccountUserRoles

  if dai.cachedFilter_accountUser_role.hasKey(filter_key):

    for pk in dai.cachedFilter_accountUser_role[filter_key]:

      cached_accountUser_roles.add(dai.cached_accountUser_role[pk])

    return cached_accountUser_roles

  # Call the model's filter proc
  let accountUser_roles = filterAccountUserRole(dai.db,
                                                 whereFields,
                                                 whereValues,
                                                 orderByFields)

  # Get PKs from the filter results
  var pks: seq[int64]

  for accountUser_role in accountUser_roles:
    pks.add(accountUser_role[0])

  # Set rows in filter cache
  let filter_key = "0|" & join(whereFields, "|") &
                   "1|" & join(whereValues, "|") &
                   "2|" & join(orderByFields, "|")

  dai.cachedFilter_accountUser_role[filter_key] = pks

  # Set rows in model row cache
  for accountUser_role in accountUser_roles:

    dai.cached_accountUser_roles[accountUser_role[0]] = accountUser_role

  return accountUser_roles


proc cachedGetAccountUserRoleByPk*(
       dai: var DAI,
       accountUser_roleId: int64): bool =

  # Get from the model row cache
  if dai.cached_accountUser_role.hasKey(accountUser_roleId):
    return dai.cached_accountUser_role[accountUser_roleId]

  # Call the model's get proc
  return getAccountUserRoleByPk(dai.db,
                                accountUser_roleId)


proc cachedGetAccountUserRoleByAccountUserIdAndRole*(
       dai: var DAI,
       accountUserId: int64,
       role: string): bool =

  # Get from the model row cache
  if dai.cached_accountUser_role.hasKey(accountUser_roleId):
    return dai.cached_accountUser_role[accountUser_roleId]

  # Call the model's get proc
  return getAccountUserRoleByAccountUserIdAndRole(dai.db,
                                                  accountUserId,
                                                  role)



proc cachedGetOrCreateAccountUserRoleByAccountUserIdAndRole*(
       dai: var DAI,
       accountUserId: int64,
       role: string,
       created: DateTime): bool =

  # Get from the model row cache
  if dai.cached_accountUser_role.hasKey(accountUser_roleId):
    return dai.cached_accountUser_role[accountUser_roleId]

  let accountUser_role = getOrCreateAccountUserRoleByAccountUserIdAndRole(
       accountUserId,
       role,
       created)

  # Add to the model row cache if it's not there
  if not dai.cached_accountUser_role.hasKey(accountUser_roleId):
    dai.cached_accountUser_role[accountUser_roleId] = accountUser_role

  return accountUser_role


proc cachedUpdateAccountUserRoleByPk*(
       dai: var DAI,
       accountUser_role: AccountUserRole,
       setFields: seq[string]): int64 =

  # Call the model's update proc
  let rowsUpdated = updateAccountUserRoleByPk(dai.db,
                                               accountUser_role,
                                               setFields)

  # Add to the model row cache
  dai.cached_accountUser_role[accountUser_roleId] = accountUser_role

  return rowsUpdated


