import db_postgres, tables
import nexus/core/types/model_types


proc beginTransaction*(coreModule: CoreModule) =

  coreModule.dbConn.exec(sql"begin")


proc commitTransaction*(coreModule: CoreModule) =

  coreModule.dbConn.exec(sql"commit")


proc isInATransaction*(coreModule: CoreModule): bool =

  let row = getRow(
              coreModule.db,
              sql"select pg_current_xact_id_if_assigned()")

  if row[0] == "":
    return false

  else:
    return true


proc rollbackTransaction*(coreModule: CoreModule) =

  coreModule.dbConn.exec(sql"rollback")


proc newCoreModule*(): CoreModule =

  var coreModule = CoreModule()

  coreModule.modelToIntSeqTable["Account User"] = 0

  coreModule.intSeqToModelTable[0] = "Account User"

  coreModule.fieldToIntSeqTable["Account User.Account User Id"] = 0
  coreModule.fieldToIntSeqTable["Account User.Account Id"] = 1
  coreModule.fieldToIntSeqTable["Account User.Name"] = 2
  coreModule.fieldToIntSeqTable["Account User.Email"] = 3
  coreModule.fieldToIntSeqTable["Account User.Password Hash"] = 4
  coreModule.fieldToIntSeqTable["Account User.Password Salt"] = 5
  coreModule.fieldToIntSeqTable["Account User.API Key"] = 6
  coreModule.fieldToIntSeqTable["Account User.Last Token"] = 7
  coreModule.fieldToIntSeqTable["Account User.Sign up Code"] = 8
  coreModule.fieldToIntSeqTable["Account User.Sign up Date"] = 9
  coreModule.fieldToIntSeqTable["Account User.Password Reset Code"] = 10
  coreModule.fieldToIntSeqTable["Account User.Password Reset Date"] = 11
  coreModule.fieldToIntSeqTable["Account User.Is Active"] = 12
  coreModule.fieldToIntSeqTable["Account User.Is Admin"] = 13
  coreModule.fieldToIntSeqTable["Account User.Is Verified"] = 14
  coreModule.fieldToIntSeqTable["Account User.Subscription Status"] = 15
  coreModule.fieldToIntSeqTable["Account User.Last Login"] = 16
  coreModule.fieldToIntSeqTable["Account User.Last Update"] = 17
  coreModule.fieldToIntSeqTable["Account User.Created"] = 18

  coreModule.intSeqToFieldTable[0] = "Account User.Account User Id"
  coreModule.intSeqToFieldTable[1] = "Account User.Account Id"
  coreModule.intSeqToFieldTable[2] = "Account User.Name"
  coreModule.intSeqToFieldTable[3] = "Account User.Email"
  coreModule.intSeqToFieldTable[4] = "Account User.Password Hash"
  coreModule.intSeqToFieldTable[5] = "Account User.Password Salt"
  coreModule.intSeqToFieldTable[6] = "Account User.API Key"
  coreModule.intSeqToFieldTable[7] = "Account User.Last Token"
  coreModule.intSeqToFieldTable[8] = "Account User.Sign up Code"
  coreModule.intSeqToFieldTable[9] = "Account User.Sign up Date"
  coreModule.intSeqToFieldTable[10] = "Account User.Password Reset Code"
  coreModule.intSeqToFieldTable[11] = "Account User.Password Reset Date"
  coreModule.intSeqToFieldTable[12] = "Account User.Is Active"
  coreModule.intSeqToFieldTable[13] = "Account User.Is Admin"
  coreModule.intSeqToFieldTable[14] = "Account User.Is Verified"
  coreModule.intSeqToFieldTable[15] = "Account User.Subscription Status"
  coreModule.intSeqToFieldTable[16] = "Account User.Last Login"
  coreModule.intSeqToFieldTable[17] = "Account User.Last Update"
  coreModule.intSeqToFieldTable[18] = "Account User.Created"

  coreModule.modelToIntSeqTable["Account User Role"] = 1

  coreModule.intSeqToModelTable[1] = "Account User Role"

  coreModule.fieldToIntSeqTable["Account User Role.Account User Role Id"] = 19
  coreModule.fieldToIntSeqTable["Account User Role.Account User Id"] = 20
  coreModule.fieldToIntSeqTable["Account User Role.Role Id"] = 21
  coreModule.fieldToIntSeqTable["Account User Role.Created"] = 22

  coreModule.intSeqToFieldTable[19] = "Account User Role.Account User Role Id"
  coreModule.intSeqToFieldTable[20] = "Account User Role.Account User Id"
  coreModule.intSeqToFieldTable[21] = "Account User Role.Role Id"
  coreModule.intSeqToFieldTable[22] = "Account User Role.Created"

  coreModule.modelToIntSeqTable["Account User Token"] = 2

  coreModule.intSeqToModelTable[2] = "Account User Token"

  coreModule.fieldToIntSeqTable["Account User Token.Account User Id"] = 23
  coreModule.fieldToIntSeqTable["Account User Token.Unique Hash"] = 24
  coreModule.fieldToIntSeqTable["Account User Token.Token"] = 25
  coreModule.fieldToIntSeqTable["Account User Token.Created"] = 26
  coreModule.fieldToIntSeqTable["Account User Token.Deleted"] = 27

  coreModule.intSeqToFieldTable[23] = "Account User Token.Account User Id"
  coreModule.intSeqToFieldTable[24] = "Account User Token.Unique Hash"
  coreModule.intSeqToFieldTable[25] = "Account User Token.Token"
  coreModule.intSeqToFieldTable[26] = "Account User Token.Created"
  coreModule.intSeqToFieldTable[27] = "Account User Token.Deleted"

  coreModule.modelToIntSeqTable["Invite"] = 3

  coreModule.intSeqToModelTable[3] = "Invite"

  coreModule.fieldToIntSeqTable["Invite.Invite Id"] = 28
  coreModule.fieldToIntSeqTable["Invite.From Account User Id"] = 29
  coreModule.fieldToIntSeqTable["Invite.From Email"] = 30
  coreModule.fieldToIntSeqTable["Invite.From Name"] = 31
  coreModule.fieldToIntSeqTable["Invite.To Email"] = 32
  coreModule.fieldToIntSeqTable["Invite.To Name"] = 33
  coreModule.fieldToIntSeqTable["Invite.Sent"] = 34
  coreModule.fieldToIntSeqTable["Invite.Created"] = 35

  coreModule.intSeqToFieldTable[28] = "Invite.Invite Id"
  coreModule.intSeqToFieldTable[29] = "Invite.From Account User Id"
  coreModule.intSeqToFieldTable[30] = "Invite.From Email"
  coreModule.intSeqToFieldTable[31] = "Invite.From Name"
  coreModule.intSeqToFieldTable[32] = "Invite.To Email"
  coreModule.intSeqToFieldTable[33] = "Invite.To Name"
  coreModule.intSeqToFieldTable[34] = "Invite.Sent"
  coreModule.intSeqToFieldTable[35] = "Invite.Created"

  coreModule.modelToIntSeqTable["Nexus Setting"] = 4

  coreModule.intSeqToModelTable[4] = "Nexus Setting"

  coreModule.fieldToIntSeqTable["Nexus Setting.Nexus Setting Id"] = 36
  coreModule.fieldToIntSeqTable["Nexus Setting.Module"] = 37
  coreModule.fieldToIntSeqTable["Nexus Setting.Key"] = 38
  coreModule.fieldToIntSeqTable["Nexus Setting.Value"] = 39
  coreModule.fieldToIntSeqTable["Nexus Setting.Created"] = 40

  coreModule.intSeqToFieldTable[36] = "Nexus Setting.Nexus Setting Id"
  coreModule.intSeqToFieldTable[37] = "Nexus Setting.Module"
  coreModule.intSeqToFieldTable[38] = "Nexus Setting.Key"
  coreModule.intSeqToFieldTable[39] = "Nexus Setting.Value"
  coreModule.intSeqToFieldTable[40] = "Nexus Setting.Created"

  return coreModule

