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
       dbContext: NexusCoreDbContext,
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

  let row = getRow(dbContext.dbConn,
                   sql(selectStatement),
                   whereValues)

  return parseBiggestInt(row[0])


proc countAccountUserRole*(
       dbContext: NexusCoreDbContext,
       whereClause: string,
       whereValues: seq[string] = @[]): int64 {.gcsafe.} =

  var selectStatement =
    "select count(1)" & 
    "  from account_user_role"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  let row = getRow(dbContext.dbConn,
                   sql(selectStatement),
                   whereValues)

  return parseBiggestInt(row[0])


proc createAccountUserRoleReturnsPk*(
       dbContext: NexusCoreDbContext,
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
    insertStatement &= " on conflict (id) do nothing"

  # Execute the insert statement and return the sequence values
  return tryInsertNamedID(
    dbContext.dbConn,
    sql(insertStatement),
    "id",
    insertValues)


proc createAccountUserRole*(
       dbContext: NexusCoreDbContext,
       accountUserId: int64,
       roleId: int64,
       created: DateTime,
       ignoreExistingPk: bool = false,
       copyAllStringFields: bool = true,
       convertToRawTypes: bool = true): AccountUserRole {.gcsafe.} =

  var accountUserRole = AccountUserRole()

  accountUserRole.id =
    createAccountUserRoleReturnsPk(
      dbContext,
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
       dbContext: NexusCoreDbContext,
       id: int64): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from account_user_role" &
    " where id = ?"

  return execAffectedRows(
           dbContext.dbConn,
           sql(deleteStatement),
           id)


proc deleteAccountUserRole*(
       dbContext: NexusCoreDbContext,
       whereClause: string,
       whereValues: seq[string]): int64 {.gcsafe.} =

  var deleteStatement =
    "delete" & 
    "  from account_user_role" &
    " where " & whereClause

  return execAffectedRows(
           dbContext.dbConn,
           sql(deleteStatement),
           whereValues)


proc deleteAccountUserRole*(
       dbContext: NexusCoreDbContext,
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
           dbContext.dbConn,
           sql(deleteStatement),
           whereValues)


proc existsAccountUserRoleByPk*(
       dbContext: NexusCoreDbContext,
       id: int64): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from account_user_role" &
    " where id = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              $id)

  if row[0] == "":
    return false
  else:
    return true


proc existsAccountUserRoleByAccountUserIdAndRoleId*(
       dbContext: NexusCoreDbContext,
       accountUserId: int64,
       roleId: int64): bool {.gcsafe.} =

  var selectStatement =
    "select 1" & 
    "  from account_user_role" &
    " where account_user_id = ?" &
    "   and role_id = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              $accountUserId,
              $roleId)

  if row[0] == "":
    return false
  else:
    return true


proc filterAccountUserRole*(
       dbContext: NexusCoreDbContext,
       whereClause: string = "",
       whereValues: seq[string] = @[],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): AccountUserRoles {.gcsafe.} =

  var selectStatement =
    "select id, account_user_id, role_id, created" & 
    "  from account_user_role"

  if whereClause != "":
    selectStatement &= " where " & whereClause

  if len(orderByFields) > 0:
    selectStatement &= " order by " & orderByFields.join(", ")

  if limit != none(int):
    selectStatement &= " limit " & $limit.get

  var accountUserRoles: AccountUserRoles

  for row in fastRows(dbContext.dbConn,
                      sql(selectStatement),
                      whereValues):

    accountUserRoles.add(rowToAccountUserRole(row))

  return accountUserRoles


proc filterAccountUserRole*(
       dbContext: NexusCoreDbContext,
       whereFields: seq[string],
       whereValues: seq[string],
       orderByFields: seq[string] = @[],
       limit: Option[int] = none(int)): AccountUserRoles {.gcsafe.} =

  var selectStatement =
    "select id, account_user_id, role_id, created" & 
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

  for row in fastRows(dbContext.dbConn,
                      sql(selectStatement),
                      whereValues):

    accountUserRoles.add(rowToAccountUserRole(row))

  return accountUserRoles


proc getAccountUserRoleByPk*(
       dbContext: NexusCoreDbContext,
       id: int64): Option[AccountUserRole] {.gcsafe.} =

  var selectStatement =
    "select id, account_user_id, role_id, created" & 
    "  from account_user_role" &
    " where id = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              id)

  if row[0] == "":
    return none(AccountUserRole)

  return some(rowToAccountUserRole(row))


proc getAccountUserRoleByPk*(
       dbContext: NexusCoreDbContext,
       id: string): Option[AccountUserRole] {.gcsafe.} =

  var selectStatement =
    "select id, account_user_id, role_id, created" & 
    "  from account_user_role" &
    " where id = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              id)

  if row[0] == "":
    return none(AccountUserRole)

  return some(rowToAccountUserRole(row))


proc getAccountUserRoleByAccountUserIdAndRoleId*(
       dbContext: NexusCoreDbContext,
       accountUserId: int64,
       roleId: int64): Option[AccountUserRole] {.gcsafe.} =

  var selectStatement =
    "select id, account_user_id, role_id, created" & 
    "  from account_user_role" &
    " where account_user_id = ?" &
    "   and role_id = ?"

  let row = getRow(
              dbContext.dbConn,
              sql(selectStatement),
              accountUserId,
              roleId)

  if row[0] == "":
    return none(AccountUserRole)

  return some(rowToAccountUserRole(row))


proc getOrCreateAccountUserRoleByAccountUserIdAndRoleId*(
       dbContext: NexusCoreDbContext,
       accountUserId: int64,
       roleId: int64,
       created: DateTime): AccountUserRole {.gcsafe.} =

  let accountUserRole =
        getAccountUserRoleByAccountUserIdAndRoleId(
          dbContext,
          accountUserId,
          roleId)

  if accountUserRole != none(AccountUserRole):
    return accountUserRole.get

  return createAccountUserRole(
           dbContext,
           accountUserId,
           roleId,
           created)


proc rowToAccountUserRole*(row: seq[string]):
       AccountUserRole {.gcsafe.} =

  var accountUserRole = AccountUserRole()

  accountUserRole.id = parseBiggestInt(row[0])
  accountUserRole.accountUserId = parseBiggestInt(row[1])
  accountUserRole.roleId = parseBiggestInt(row[2])
  accountUserRole.created = parsePgTimestamp(row[3])

  return accountUserRole


proc truncateAccountUserRole*(
       dbContext: NexusCoreDbContext,
       cascade: bool = false) =

  if cascade == false:
    exec(dbContext.dbConn,
         sql("truncate table account_user_role restart identity;"))

  else:
    exec(dbContext.dbConn,
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

    if field == "id":
      updateStatement &= "       id = ?,"
      updateValues.add($accountUserRole.id)

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
       dbContext: NexusCoreDbContext,
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

  updateStatement &= " where id = ?"

  updateValues.add($accountUserRole.id)

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


proc updateAccountUserRoleByWhereClause*(
       dbContext: NexusCoreDbContext,
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
           dbContext.dbConn,
           sql(updateStatement),
           concat(updateValues,
                  whereValues))


proc updateAccountUserRoleByWhereEqOnly*(
       dbContext: NexusCoreDbContext,
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
           dbContext.dbConn,
           sql(updateStatement),
           concat(updateValues,
                  whereValues))


