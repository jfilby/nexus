import db_postgres, tables
import nexus/core/types/model_types


proc beginTransaction*(nexusCoreModule: NexusCoreModule) =

  nexusCoreModule.db.exec(sql"begin")


proc commitTransaction*(nexusCoreModule: NexusCoreModule) =

  nexusCoreModule.db.exec(sql"commit")


proc isInATransaction*(nexusCoreModule: NexusCoreModule): bool =

  let row = getRow(
              nexusCoreModule.db,
              sql"select pg_current_xact_id_if_assigned()")

  if row[0] == "":
    return false

  else:
    return true


proc rollbackTransaction*(nexusCoreModule: NexusCoreModule) =

  nexusCoreModule.db.exec(sql"rollback")


proc newNexusCoreModule*(): NexusCoreModule =

  var nexusCoreModule = NexusCoreModule()

  nexusCoreModule.modelToIntSeqTable["Account User"] = 0

  nexusCoreModule.intSeqToModelTable[0] = "Account User"

  nexusCoreModule.fieldToIntSeqTable["Account User.Account User Id"] = 0
  nexusCoreModule.fieldToIntSeqTable["Account User.Account Id"] = 1
  nexusCoreModule.fieldToIntSeqTable["Account User.Name"] = 2
  nexusCoreModule.fieldToIntSeqTable["Account User.Email"] = 3
  nexusCoreModule.fieldToIntSeqTable["Account User.Password Hash"] = 4
  nexusCoreModule.fieldToIntSeqTable["Account User.Password Salt"] = 5
  nexusCoreModule.fieldToIntSeqTable["Account User.API Key"] = 6
  nexusCoreModule.fieldToIntSeqTable["Account User.Last Token"] = 7
  nexusCoreModule.fieldToIntSeqTable["Account User.Sign up Code"] = 8
  nexusCoreModule.fieldToIntSeqTable["Account User.Sign up Date"] = 9
  nexusCoreModule.fieldToIntSeqTable["Account User.Password Reset Code"] = 10
  nexusCoreModule.fieldToIntSeqTable["Account User.Password Reset Date"] = 11
  nexusCoreModule.fieldToIntSeqTable["Account User.Is Active"] = 12
  nexusCoreModule.fieldToIntSeqTable["Account User.Is Admin"] = 13
  nexusCoreModule.fieldToIntSeqTable["Account User.Is Verified"] = 14
  nexusCoreModule.fieldToIntSeqTable["Account User.Subscription Status"] = 15
  nexusCoreModule.fieldToIntSeqTable["Account User.Last Login"] = 16
  nexusCoreModule.fieldToIntSeqTable["Account User.Last Update"] = 17
  nexusCoreModule.fieldToIntSeqTable["Account User.Created"] = 18

  nexusCoreModule.intSeqToFieldTable[0] = "Account User.Account User Id"
  nexusCoreModule.intSeqToFieldTable[1] = "Account User.Account Id"
  nexusCoreModule.intSeqToFieldTable[2] = "Account User.Name"
  nexusCoreModule.intSeqToFieldTable[3] = "Account User.Email"
  nexusCoreModule.intSeqToFieldTable[4] = "Account User.Password Hash"
  nexusCoreModule.intSeqToFieldTable[5] = "Account User.Password Salt"
  nexusCoreModule.intSeqToFieldTable[6] = "Account User.API Key"
  nexusCoreModule.intSeqToFieldTable[7] = "Account User.Last Token"
  nexusCoreModule.intSeqToFieldTable[8] = "Account User.Sign up Code"
  nexusCoreModule.intSeqToFieldTable[9] = "Account User.Sign up Date"
  nexusCoreModule.intSeqToFieldTable[10] = "Account User.Password Reset Code"
  nexusCoreModule.intSeqToFieldTable[11] = "Account User.Password Reset Date"
  nexusCoreModule.intSeqToFieldTable[12] = "Account User.Is Active"
  nexusCoreModule.intSeqToFieldTable[13] = "Account User.Is Admin"
  nexusCoreModule.intSeqToFieldTable[14] = "Account User.Is Verified"
  nexusCoreModule.intSeqToFieldTable[15] = "Account User.Subscription Status"
  nexusCoreModule.intSeqToFieldTable[16] = "Account User.Last Login"
  nexusCoreModule.intSeqToFieldTable[17] = "Account User.Last Update"
  nexusCoreModule.intSeqToFieldTable[18] = "Account User.Created"

  nexusCoreModule.modelToIntSeqTable["Account User Role"] = 1

  nexusCoreModule.intSeqToModelTable[1] = "Account User Role"

  nexusCoreModule.fieldToIntSeqTable["Account User Role.Account User Role Id"] = 19
  nexusCoreModule.fieldToIntSeqTable["Account User Role.Account User Id"] = 20
  nexusCoreModule.fieldToIntSeqTable["Account User Role.Role Id"] = 21
  nexusCoreModule.fieldToIntSeqTable["Account User Role.Created"] = 22

  nexusCoreModule.intSeqToFieldTable[19] = "Account User Role.Account User Role Id"
  nexusCoreModule.intSeqToFieldTable[20] = "Account User Role.Account User Id"
  nexusCoreModule.intSeqToFieldTable[21] = "Account User Role.Role Id"
  nexusCoreModule.intSeqToFieldTable[22] = "Account User Role.Created"

  nexusCoreModule.modelToIntSeqTable["Account User Token"] = 2

  nexusCoreModule.intSeqToModelTable[2] = "Account User Token"

  nexusCoreModule.fieldToIntSeqTable["Account User Token.Account User Id"] = 23
  nexusCoreModule.fieldToIntSeqTable["Account User Token.Unique Hash"] = 24
  nexusCoreModule.fieldToIntSeqTable["Account User Token.Token"] = 25
  nexusCoreModule.fieldToIntSeqTable["Account User Token.Created"] = 26
  nexusCoreModule.fieldToIntSeqTable["Account User Token.Deleted"] = 27

  nexusCoreModule.intSeqToFieldTable[23] = "Account User Token.Account User Id"
  nexusCoreModule.intSeqToFieldTable[24] = "Account User Token.Unique Hash"
  nexusCoreModule.intSeqToFieldTable[25] = "Account User Token.Token"
  nexusCoreModule.intSeqToFieldTable[26] = "Account User Token.Created"
  nexusCoreModule.intSeqToFieldTable[27] = "Account User Token.Deleted"

  nexusCoreModule.modelToIntSeqTable["Invite"] = 3

  nexusCoreModule.intSeqToModelTable[3] = "Invite"

  nexusCoreModule.fieldToIntSeqTable["Invite.Invite Id"] = 28
  nexusCoreModule.fieldToIntSeqTable["Invite.From Account User Id"] = 29
  nexusCoreModule.fieldToIntSeqTable["Invite.From Email"] = 30
  nexusCoreModule.fieldToIntSeqTable["Invite.From Name"] = 31
  nexusCoreModule.fieldToIntSeqTable["Invite.To Email"] = 32
  nexusCoreModule.fieldToIntSeqTable["Invite.To Name"] = 33
  nexusCoreModule.fieldToIntSeqTable["Invite.Sent"] = 34
  nexusCoreModule.fieldToIntSeqTable["Invite.Created"] = 35

  nexusCoreModule.intSeqToFieldTable[28] = "Invite.Invite Id"
  nexusCoreModule.intSeqToFieldTable[29] = "Invite.From Account User Id"
  nexusCoreModule.intSeqToFieldTable[30] = "Invite.From Email"
  nexusCoreModule.intSeqToFieldTable[31] = "Invite.From Name"
  nexusCoreModule.intSeqToFieldTable[32] = "Invite.To Email"
  nexusCoreModule.intSeqToFieldTable[33] = "Invite.To Name"
  nexusCoreModule.intSeqToFieldTable[34] = "Invite.Sent"
  nexusCoreModule.intSeqToFieldTable[35] = "Invite.Created"

  nexusCoreModule.modelToIntSeqTable["Nexus Setting"] = 4

  nexusCoreModule.intSeqToModelTable[4] = "Nexus Setting"

  nexusCoreModule.fieldToIntSeqTable["Nexus Setting.Nexus Setting Id"] = 36
  nexusCoreModule.fieldToIntSeqTable["Nexus Setting.Module"] = 37
  nexusCoreModule.fieldToIntSeqTable["Nexus Setting.Key"] = 38
  nexusCoreModule.fieldToIntSeqTable["Nexus Setting.Value"] = 39
  nexusCoreModule.fieldToIntSeqTable["Nexus Setting.Created"] = 40

  nexusCoreModule.intSeqToFieldTable[36] = "Nexus Setting.Nexus Setting Id"
  nexusCoreModule.intSeqToFieldTable[37] = "Nexus Setting.Module"
  nexusCoreModule.intSeqToFieldTable[38] = "Nexus Setting.Key"
  nexusCoreModule.intSeqToFieldTable[39] = "Nexus Setting.Value"
  nexusCoreModule.intSeqToFieldTable[40] = "Nexus Setting.Created"

  return nexusCoreModule

