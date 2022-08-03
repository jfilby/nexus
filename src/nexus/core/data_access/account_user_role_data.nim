# Nexus generated file
import db_postgres, options, sequtils, strutils, times
import nexus/core/data_access/data_utils
import nexus/core/data_access/pg_try_insert_id
import nexus/core/types/model_types


# Forward declarations
proc rowToAccountUserRole*(row: seq[string]):
       AccountUserRole {.gcsafe.}


# Code
proc countAccountUserRole*(
       nexusCoreDbContext: NexusCoreDbContext,
       whereFields: seq[string] = @[],
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from account_user_role"
  var first = true

  for whereField in whereFields:

    var whereClause: string

    if first == false:
      whereClause = "   and " & whereField & " = ?"
    else:
      first = false
      whereClause = " where " & whereField & " = ?"

    selectStatement &= whereClause

  let row = getRow(nexusCoreDbContext.dbConn,
                   sql(selectStatement),
                   whereValues)

  return parseBiggestInt(row[0])


proc countAccountUserRole*(
       nexusCoreDbContext: NexusCoreDbContext,
       whereClause: string,
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from account_user_role"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  let row = getRow(nexusCoreDbContext.dbConn,
                   sql(selectStatement),
                   whereValues)

  return parseBiggestInt(row[0])


proc createAccountUserRoleReturnsPk*(
       nexusCoreDbContext: NexusCoreDbContext,
       accountUserId: int64,
       roleId: int64,
       created: DateTime,
       ignoreExistingPk: bool = false): int64 {.gcsafe.} =

  # Formulate insertStatement and insertValues
  var
    insertValues: seq[string]
    insertStatement = "insert into account_user_role ("
    valuesClause = ""

  # Field: Account User Id
  insertStatement &= "account_user_id, "
  valuesClause &= "?, "
  insertValues.add($accountUserId)

  # Field: Role Id
  insertStatement &= "role_id, "
  valuesClause &= "?, "
  insertValues.add($roleId)

  # Field: Created
  insertStatement &= "created, "
  valuesClause &= pgToDateTimeString(created) & ", "

  # Remove trailing commas and finalize insertStatement
  if insertStatement[len(insertStatement) - 2 .. len(insertStatement) - 1] == ", ":
    insertStatement = insertStatement[0 .. len(insertStatement) - 3]

  if valuesClause[len(valuesClause) - 2 .. len(valuesClause) - 1] == ", ":
    valuesClause = valuesClause[0 .. len(valuesClause) - 3]

  # Finalize insertStatement
  insertStatement &=
    ") values (" & valuesClause & ")"

  if ignoreExistingPk == true:
    insertStatement &= " on conflict (account_user_role_id) do nothing"

  # Execute the insert statement and return the sequence values
  return tryInsertNamedID(
    nexusCoreDbContext.dbConn,
    sql(insertStatement),
    "account_user_role_id",
    insertValues)


proc createAccountUserRole*(
       nexusCoreDbContext: NexusCoreDbContext,
       accountUserId: int64,
       roleId: int64,
       created: DateTime,
       ignoreExistingPk: bool = false,
       copyAllStringFields: bool = true,
       convertToRawTypes: bool = true): AccountUserRole {.gcsafe.} =

  var accountUserRole = AccountUserRole()

  accountUserRole.accountUserRoleId =
    createAccountUserRoleReturnsPk(
      nexusCoreDbContext,
      accountUserId,
      roleId,
      created,
      ignoreExistingPk)

  # Copy all fields as strings
  accountUserRole.accountUserId = accountUserId
  accountUserRole.roleId = roleId
  accountUserRole.created = created

  return accountUserRole


proc deleteAccountUserRoleByPk*(
       nexusCoreDbContext: NexusCoreDbContext,
       accountUserRoleId: int64): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from account_user_role" &
    " where account_user_role_id = ?"

  return execAffectedRows(
           nexusCoreDbContext.dbConn,
           sql(deleteStatement),
           accountUserRoleId)


proc deleteAccountUserRole*(
       nexusCoreDbContext: NexusCoreDbContext,
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from account_user_role" &
    " where " & whereClause

  return execAffectedRows(
           nexusCoreDbContext.dbConn,
           sql(deleteStatement),
           whereValues)


proc deleteAccountUserRole*(
       nexusCoreDbContext: NexusCoreDbContext,
       whereFields: seq[string],
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from account_user_role"

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
           nexusCoreDbContext.dbConn,
           sql(deleteStatement),
           whereValues)


proc existsAccountUserRoleByPk*(
       nexusCoreDbContext: NexusCoreDbContext,
       accountUserRoleId: int64): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from account_user_role" &
    " where account_user_role_id = ?"

  let row = getRow(
              nexusCoreDbContext.dbConn,
              sql(selectStatement),
              $accountUserRoleId)

  if row[0] == "":
    return false
  else:
    return true


proc existsAccountUserRoleByAccountUserIdAndRoleId*(
       nexusCoreDbContext: NexusCoreDbContext,
       accountUserId: int64,
       roleId: int64): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from account_user_role" &
    " where account_user_id = ?" &
    "   and role_id = ?"

  let row = getRow(
              nexusCoreDbContext.dbConn,
              sql(selectStatement),
              $accountUserId,
              $roleId)

  if row[0] == "":
    return false
  else:
    return true


proc filterAccountUserRole*(
       nexusCoreDbContext: NexusCoreDbContext,
       whereClause: string = "",
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): AccountUserRoles {.gcsafe.} =

  var selectStatement =
    "select account_user_role_id, account_user_id, role_id, created" & 
    "  from account_user_role"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  if len(orderByFields) > 0:
    selectStatement &= " order by " & orderByFields.join(", ")

  if limit != none(int):
    selectStatement &= " limit " & $limit.get

  var accountUserRoles: AccountUserRoles

  for row in fastRows(nexusCoreDbContext.dbConn,
                      sql(selectStatement),
                      whereValues):

    accountUserRoles.add(rowToAccountUserRole(row))

  return accountUserRoles


proc filterAccountUserRole*(
       nexusCoreDbContext: NexusCoreDbContext,
       whereFields: seq[string],
       whereValues: seq[string],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): AccountUserRoles {.gcsafe.} =

  var selectStatement =
    "select account_user_role_id, account_user_id, role_id, created" & 
    "  from account_user_role"

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

  var accountUserRoles: AccountUserRoles

  for row in fastRows(nexusCoreDbContext.dbConn,
                      sql(selectStatement),
                      whereValues):

    accountUserRoles.add(rowToAccountUserRole(row))

  return accountUserRoles


proc getAccountUserRoleByPk*(
       nexusCoreDbContext: NexusCoreDbContext,
       accountUserRoleId: int64): Option[AccountUserRole] {.gcsafe.} =

  var selectStatement =
    "select account_user_role_id, account_user_id, role_id, created" & 
    "  from account_user_role" &
    " where account_user_role_id = ?"

  let row = getRow(
              nexusCoreDbContext.dbConn,
              sql(selectStatement),
              accountUserRoleId)

  if row[0] == "":
    return none(AccountUserRole)

  return some(rowToAccountUserRole(row))


proc getAccountUserRoleByPk*(
       nexusCoreDbContext: NexusCoreDbContext,
       accountUserRoleId: string): Option[AccountUserRole] {.gcsafe.} =

  var selectStatement =
    "select account_user_role_id, account_user_id, role_id, created" & 
    "  from account_user_role" &
    " where account_user_role_id = ?"

  let row = getRow(
              nexusCoreDbContext.dbConn,
              sql(selectStatement),
              accountUserRoleId)

  if row[0] == "":
    return none(AccountUserRole)

  return some(rowToAccountUserRole(row))


proc getAccountUserRoleByAccountUserIdAndRoleId*(
       nexusCoreDbContext: NexusCoreDbContext,
       accountUserId: int64,
       roleId: int64): Option[AccountUserRole] {.gcsafe.} =

  var selectStatement =
    "select account_user_role_id, account_user_id, role_id, created" & 
    "  from account_user_role" &
    " where account_user_id = ?" &
    "   and role_id = ?"

  let row = getRow(
              nexusCoreDbContext.dbConn,
              sql(selectStatement),
              accountUserId,
              roleId)

  if row[0] == "":
    return none(AccountUserRole)

  return some(rowToAccountUserRole(row))


proc getOrCreateAccountUserRoleByAccountUserIdAndRoleId*(
       nexusCoreDbContext: NexusCoreDbContext,
       accountUserId: int64,
       roleId: int64,
       created: DateTime): AccountUserRole {.gcsafe.} =

  let accountUserRole =
        getAccountUserRoleByAccountUserIdAndRoleId(
          nexusCoreDbContext,
          accountUserId,
          roleId)

  if accountUserRole != none(AccountUserRole):
    return accountUserRole.get

  return createAccountUserRole(
           nexusCoreDbContext,
           accountUserId,
           roleId,
           created)


proc rowToAccountUserRole*(row: seq[string]):
       AccountUserRole {.gcsafe.} =

  var accountUserRole = AccountUserRole()

  accountUserRole.accountUserRoleId = parseBiggestInt(row[0])
  accountUserRole.accountUserId = parseBiggestInt(row[1])
  accountUserRole.roleId = parseBiggestInt(row[2])
  accountUserRole.created = parsePgTimestamp(row[3])

  return accountUserRole


proc truncateAccountUserRole*(
       nexusCoreDbContext: NexusCoreDbContext,
       cascade: bool = false) =

  if cascade == false:
    exec(nexusCoreDbContext.dbConn,
         sql("truncate table account_user_role restart identity;"))

  else:
    exec(nexusCoreDbContext.dbConn,
         sql("truncate table account_user_role restart identity cascade;"))


proc updateAccountUserRoleSetClause*(
       accountUserRole: AccountUserRole,
       setFields: seq[string],
       updateStatement: var string,
       updateValues: var seq[string]) {.gcsafe.} =

  updateStatement =
    "update account_user_role" &
    "   set "

  for field in setFields:

    if field == "account_user_role_id":
      updateStatement &= "       account_user_role_id = ?,"
      updateValues.add($accountUserRole.accountUserRoleId)

    elif field == "account_user_id":
      updateStatement &= "       account_user_id = ?,"
      updateValues.add($accountUserRole.accountUserId)

    elif field == "role_id":
      updateStatement &= "       role_id = ?,"
      updateValues.add($accountUserRole.roleId)

    elif field == "created":
        updateStatement &= "       created = " & pgToDateTimeString(accountUserRole.created) & ","

  updateStatement[len(updateStatement) - 1] = ' '



proc updateAccountUserRoleByPk*(
       nexusCoreDbContext: NexusCoreDbContext,
       accountUserRole: AccountUserRole,
       setFields: seq[string],
       exceptionOnNRowsUpdated: bool = true): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateAccountUserRoleSetClause(
    account_user_role,
    setFields,
    updateStatement,
    updateValues)

  updateStatement &= " where account_user_role_id = ?"

  updateValues.add($accountUserRole.accountUserRoleId)

  let rowsUpdated = 
        execAffectedRows(
          nexusCoreDbContext.dbConn,
          sql(updateStatement),
          updateValues)

  # Exception on no rows updated
  if rowsUpdated == 0 and
     exceptionOnNRowsUpdated == true:

    raise newException(ValueError,
                       "no rows updated")

  # Return rows updated
  return rowsUpdated


proc updateAccountUserRoleByWhereClause*(
       nexusCoreDbContext: NexusCoreDbContext,
       accountUserRole: AccountUserRole,
       setFields: seq[string],
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateAccountUserRoleSetClause(
    account_user_role,
    setFields,
    updateStatement,
    updateValues)

  if whereClause != "":
    updateStatement &= " where " & whereClause

  return execAffectedRows(
           nexusCoreDbContext.dbConn,
           sql(updateStatement),
           concat(updateValues,
                  whereValues))


proc updateAccountUserRoleByWhereEqOnly*(
       nexusCoreDbContext: NexusCoreDbContext,
       accountUserRole: AccountUserRole,
       setFields: seq[string],
       whereFields: seq[string],
       whereValues: seq[string]): int64 {.gcsafe.} =

  var
    updateStatement: string
    updateValues: seq[string]

  updateAccountUserRoleSetClause(
    account_user_role,
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
           nexusCoreDbContext.dbConn,
           sql(updateStatement),
           concat(updateValues,
                  whereValues))


