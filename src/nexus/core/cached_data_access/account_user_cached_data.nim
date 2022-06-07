,
       accountUserId: int64): int64 =

  var updateStatement =
    "update account_user" &
    "   set last_login = ?" &
    " where account_user_id = ?"

  return execAffectedRows(
           nexusCoreModule.db,
           sql(updateStatement),
           lastLogin.get,
           accountUserId)
