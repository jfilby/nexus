import db_postgres, tables
import nexus/core/types/model_types


proc beginTransaction*(nexusCoreDbContext: NexusCoreDbContext) =

  nexusCoreDbContext.dbConn.exec(sql"begin")


proc commitTransaction*(nexusCoreDbContext: NexusCoreDbContext) =

  nexusCoreDbContext.dbConn.exec(sql"commit")


proc isInATransaction*(nexusCoreDbContext: NexusCoreDbContext): bool =

  let row = getRow(
              nexusCoreDbContext.dbConn,
              sql"select pg_current_xact_id_if_assigned()")

  if row[0] == "":
    return false

  else:
    return true


proc rollbackTransaction*(nexusCoreDbContext: NexusCoreDbContext) =

  nexusCoreDbContext.dbConn.exec(sql"rollback")


proc newNexusCoreDbContext*(): NexusCoreDbContext =

  var nexusCoreDbContext = NexusCoreDbContext()

  nexusCoreDbContext.modelToIntSeqTable["Account User"] = 0

  nexusCoreDbContext.intSeqToModelTable[0] = "Account User"

  nexusCoreDbContext.fieldToIntSeqTable["Account User.Account User Id"] = 0
  nexusCoreDbContext.fieldToIntSeqTable["Account User.Account Id"] = 1
  nexusCoreDbContext.fieldToIntSeqTable["Account User.Name"] = 2
  nexusCoreDbContext.fieldToIntSeqTable["Account User.Email"] = 3
  nexusCoreDbContext.fieldToIntSeqTable["Account User.Password Hash"] = 4
  nexusCoreDbContext.fieldToIntSeqTable["Account User.Password Salt"] = 5
  nexusCoreDbContext.fieldToIntSeqTable["Account User.API Key"] = 6
  nexusCoreDbContext.fieldToIntSeqTable["Account User.Last Token"] = 7
  nexusCoreDbContext.fieldToIntSeqTable["Account User.Sign up Code"] = 8
  nexusCoreDbContext.fieldToIntSeqTable["Account User.Sign up Date"] = 9
  nexusCoreDbContext.fieldToIntSeqTable["Account User.Password Reset Code"] = 10
  nexusCoreDbContext.fieldToIntSeqTable["Account User.Password Reset Date"] = 11
  nexusCoreDbContext.fieldToIntSeqTable["Account User.Is Active"] = 12
  nexusCoreDbContext.fieldToIntSeqTable["Account User.Is Admin"] = 13
  nexusCoreDbContext.fieldToIntSeqTable["Account User.Is Verified"] = 14
  nexusCoreDbContext.fieldToIntSeqTable["Account User.Subscription Status"] = 15
  nexusCoreDbContext.fieldToIntSeqTable["Account User.Last Login"] = 16
  nexusCoreDbContext.fieldToIntSeqTable["Account User.Last Update"] = 17
  nexusCoreDbContext.fieldToIntSeqTable["Account User.Created"] = 18

  nexusCoreDbContext.intSeqToFieldTable[0] = "Account User.Account User Id"
  nexusCoreDbContext.intSeqToFieldTable[1] = "Account User.Account Id"
  nexusCoreDbContext.intSeqToFieldTable[2] = "Account User.Name"
  nexusCoreDbContext.intSeqToFieldTable[3] = "Account User.Email"
  nexusCoreDbContext.intSeqToFieldTable[4] = "Account User.Password Hash"
  nexusCoreDbContext.intSeqToFieldTable[5] = "Account User.Password Salt"
  nexusCoreDbContext.intSeqToFieldTable[6] = "Account User.API Key"
  nexusCoreDbContext.intSeqToFieldTable[7] = "Account User.Last Token"
  nexusCoreDbContext.intSeqToFieldTable[8] = "Account User.Sign up Code"
  nexusCoreDbContext.intSeqToFieldTable[9] = "Account User.Sign up Date"
  nexusCoreDbContext.intSeqToFieldTable[10] = "Account User.Password Reset Code"
  nexusCoreDbContext.intSeqToFieldTable[11] = "Account User.Password Reset Date"
  nexusCoreDbContext.intSeqToFieldTable[12] = "Account User.Is Active"
  nexusCoreDbContext.intSeqToFieldTable[13] = "Account User.Is Admin"
  nexusCoreDbContext.intSeqToFieldTable[14] = "Account User.Is Verified"
  nexusCoreDbContext.intSeqToFieldTable[15] = "Account User.Subscription Status"
  nexusCoreDbContext.intSeqToFieldTable[16] = "Account User.Last Login"
  nexusCoreDbContext.intSeqToFieldTable[17] = "Account User.Last Update"
  nexusCoreDbContext.intSeqToFieldTable[18] = "Account User.Created"

  nexusCoreDbContext.modelToIntSeqTable["Account User Role"] = 1

  nexusCoreDbContext.intSeqToModelTable[1] = "Account User Role"

  nexusCoreDbContext.fieldToIntSeqTable["Account User Role.Account User Role Id"] = 19
  nexusCoreDbContext.fieldToIntSeqTable["Account User Role.Account User Id"] = 20
  nexusCoreDbContext.fieldToIntSeqTable["Account User Role.Role Id"] = 21
  nexusCoreDbContext.fieldToIntSeqTable["Account User Role.Created"] = 22

  nexusCoreDbContext.intSeqToFieldTable[19] = "Account User Role.Account User Role Id"
  nexusCoreDbContext.intSeqToFieldTable[20] = "Account User Role.Account User Id"
  nexusCoreDbContext.intSeqToFieldTable[21] = "Account User Role.Role Id"
  nexusCoreDbContext.intSeqToFieldTable[22] = "Account User Role.Created"

  nexusCoreDbContext.modelToIntSeqTable["Account User Token"] = 2

  nexusCoreDbContext.intSeqToModelTable[2] = "Account User Token"

  nexusCoreDbContext.fieldToIntSeqTable["Account User Token.Account User Id"] = 23
  nexusCoreDbContext.fieldToIntSeqTable["Account User Token.Unique Hash"] = 24
  nexusCoreDbContext.fieldToIntSeqTable["Account User Token.Token"] = 25
  nexusCoreDbContext.fieldToIntSeqTable["Account User Token.Created"] = 26
  nexusCoreDbContext.fieldToIntSeqTable["Account User Token.Deleted"] = 27

  nexusCoreDbContext.intSeqToFieldTable[23] = "Account User Token.Account User Id"
  nexusCoreDbContext.intSeqToFieldTable[24] = "Account User Token.Unique Hash"
  nexusCoreDbContext.intSeqToFieldTable[25] = "Account User Token.Token"
  nexusCoreDbContext.intSeqToFieldTable[26] = "Account User Token.Created"
  nexusCoreDbContext.intSeqToFieldTable[27] = "Account User Token.Deleted"

  nexusCoreDbContext.modelToIntSeqTable["Invite"] = 3

  nexusCoreDbContext.intSeqToModelTable[3] = "Invite"

  nexusCoreDbContext.fieldToIntSeqTable["Invite.Invite Id"] = 28
  nexusCoreDbContext.fieldToIntSeqTable["Invite.From Account User Id"] = 29
  nexusCoreDbContext.fieldToIntSeqTable["Invite.From Email"] = 30
  nexusCoreDbContext.fieldToIntSeqTable["Invite.From Name"] = 31
  nexusCoreDbContext.fieldToIntSeqTable["Invite.To Email"] = 32
  nexusCoreDbContext.fieldToIntSeqTable["Invite.To Name"] = 33
  nexusCoreDbContext.fieldToIntSeqTable["Invite.Sent"] = 34
  nexusCoreDbContext.fieldToIntSeqTable["Invite.Created"] = 35

  nexusCoreDbContext.intSeqToFieldTable[28] = "Invite.Invite Id"
  nexusCoreDbContext.intSeqToFieldTable[29] = "Invite.From Account User Id"
  nexusCoreDbContext.intSeqToFieldTable[30] = "Invite.From Email"
  nexusCoreDbContext.intSeqToFieldTable[31] = "Invite.From Name"
  nexusCoreDbContext.intSeqToFieldTable[32] = "Invite.To Email"
  nexusCoreDbContext.intSeqToFieldTable[33] = "Invite.To Name"
  nexusCoreDbContext.intSeqToFieldTable[34] = "Invite.Sent"
  nexusCoreDbContext.intSeqToFieldTable[35] = "Invite.Created"

  nexusCoreDbContext.modelToIntSeqTable["Nexus Setting"] = 4

  nexusCoreDbContext.intSeqToModelTable[4] = "Nexus Setting"

  nexusCoreDbContext.fieldToIntSeqTable["Nexus Setting.Nexus Setting Id"] = 36
  nexusCoreDbContext.fieldToIntSeqTable["Nexus Setting.Module"] = 37
  nexusCoreDbContext.fieldToIntSeqTable["Nexus Setting.Key"] = 38
  nexusCoreDbContext.fieldToIntSeqTable["Nexus Setting.Value"] = 39
  nexusCoreDbContext.fieldToIntSeqTable["Nexus Setting.Created"] = 40

  nexusCoreDbContext.intSeqToFieldTable[36] = "Nexus Setting.Nexus Setting Id"
  nexusCoreDbContext.intSeqToFieldTable[37] = "Nexus Setting.Module"
  nexusCoreDbContext.intSeqToFieldTable[38] = "Nexus Setting.Key"
  nexusCoreDbContext.intSeqToFieldTable[39] = "Nexus Setting.Value"
  nexusCoreDbContext.intSeqToFieldTable[40] = "Nexus Setting.Created"

  return nexusCoreDbContext

