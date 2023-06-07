,
       id: int64): int64 =

  var updateStatement =
    "update account_user" &
    "   set last_login = ?" &
    " where id = ?"

  return execAffectedRows(
           dbContext.dbConn,
           sql(updateStatement),
           lastLogin.get,
           id)
