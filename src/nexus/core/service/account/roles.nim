import db_connector/db_postgres
import nexus/core/data_access/account_user_role_data
import nexus/core/types/model_types


proc checkModifyDataRole*(dbContext: NexusCoreDbContext,
                          accountUserId: int64,
                          modifyDataRole: string):
                            (bool, string) =

#[
  let modifyDataRoleId =
        getRoleByName(context,
                      modifyDataRole)

  # Check Modify data role
  var roleExists =
      existsAccountUserRoleByAccountUserIdAndRoleId(
        dbContext,
        accountUserId,
        modifyDataRoleId)

  if roleExists == false:

    roleExists =
      existsAccountUserRoleByAccountUserIDAndRoleId(
        dbContext,
        accountUserId,
        role = "Demo user")

    if roleExists == true:
      return (false,
              "The demo user can't create/modify data. " &
              "Please <a href=\"/account/logout?redirect=/account/sign-up\">sign up</a> for your own account.")

    else:
      return (false,
              "You don't have access to modify data.")
]#

  # Return OK
  return (true,
          "")

