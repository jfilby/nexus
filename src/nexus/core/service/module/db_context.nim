import db_postgres, tables
import nexus/core/types/model_types


proc beginTransaction*(dbContext: NexusCoreDbContext) =

  dbContext.dbConn.exec(sql"begin")


proc commitTransaction*(dbContext: NexusCoreDbContext) =

  dbContext.dbConn.exec(sql"commit")


proc isInATransaction*(dbContext: NexusCoreDbContext): bool =

  let row = getRow(
              dbContext.dbConn,
              sql"select pg_current_xact_id_if_assigned()")

  if row[0] == "":
    return false

  else:
    return true


proc rollbackTransaction*(dbContext: NexusCoreDbContext) =

  dbContext.dbConn.exec(sql"rollback")


proc newNexusCoreDbContext*(): NexusCoreDbContext =

  var dbContext = NexusCoreDbContext()

  dbContext.modelToIntSeqTable["Account User"] = 0

  dbContext.intSeqToModelTable[0] = "Account User"

  dbContext.fieldToIntSeqTable["Account User.Id"] = 0
  dbContext.fieldToIntSeqTable["Account User.Account Id"] = 1
  dbContext.fieldToIntSeqTable["Account User.Name"] = 2
  dbContext.fieldToIntSeqTable["Account User.Email"] = 3
  dbContext.fieldToIntSeqTable["Account User.Password Hash"] = 4
  dbContext.fieldToIntSeqTable["Account User.Password Salt"] = 5
  dbContext.fieldToIntSeqTable["Account User.API Key"] = 6
  dbContext.fieldToIntSeqTable["Account User.Last Token"] = 7
  dbContext.fieldToIntSeqTable["Account User.Sign up Code"] = 8
  dbContext.fieldToIntSeqTable["Account User.Sign up Date"] = 9
  dbContext.fieldToIntSeqTable["Account User.Password Reset Code"] = 10
  dbContext.fieldToIntSeqTable["Account User.Password Reset Date"] = 11
  dbContext.fieldToIntSeqTable["Account User.Is Active"] = 12
  dbContext.fieldToIntSeqTable["Account User.Is Admin"] = 13
  dbContext.fieldToIntSeqTable["Account User.Is Verified"] = 14
  dbContext.fieldToIntSeqTable["Account User.Subscription Status"] = 15
  dbContext.fieldToIntSeqTable["Account User.Last Login"] = 16
  dbContext.fieldToIntSeqTable["Account User.Last Update"] = 17
  dbContext.fieldToIntSeqTable["Account User.Created"] = 18

  dbContext.intSeqToFieldTable[0] = "Account User.Id"
  dbContext.intSeqToFieldTable[1] = "Account User.Account Id"
  dbContext.intSeqToFieldTable[2] = "Account User.Name"
  dbContext.intSeqToFieldTable[3] = "Account User.Email"
  dbContext.intSeqToFieldTable[4] = "Account User.Password Hash"
  dbContext.intSeqToFieldTable[5] = "Account User.Password Salt"
  dbContext.intSeqToFieldTable[6] = "Account User.API Key"
  dbContext.intSeqToFieldTable[7] = "Account User.Last Token"
  dbContext.intSeqToFieldTable[8] = "Account User.Sign up Code"
  dbContext.intSeqToFieldTable[9] = "Account User.Sign up Date"
  dbContext.intSeqToFieldTable[10] = "Account User.Password Reset Code"
  dbContext.intSeqToFieldTable[11] = "Account User.Password Reset Date"
  dbContext.intSeqToFieldTable[12] = "Account User.Is Active"
  dbContext.intSeqToFieldTable[13] = "Account User.Is Admin"
  dbContext.intSeqToFieldTable[14] = "Account User.Is Verified"
  dbContext.intSeqToFieldTable[15] = "Account User.Subscription Status"
  dbContext.intSeqToFieldTable[16] = "Account User.Last Login"
  dbContext.intSeqToFieldTable[17] = "Account User.Last Update"
  dbContext.intSeqToFieldTable[18] = "Account User.Created"

  dbContext.modelToIntSeqTable["Account User Role"] = 1

  dbContext.intSeqToModelTable[1] = "Account User Role"

  dbContext.fieldToIntSeqTable["Account User Role.Id"] = 19
  dbContext.fieldToIntSeqTable["Account User Role.Account User Id"] = 20
  dbContext.fieldToIntSeqTable["Account User Role.Role Id"] = 21
  dbContext.fieldToIntSeqTable["Account User Role.Created"] = 22

  dbContext.intSeqToFieldTable[19] = "Account User Role.Id"
  dbContext.intSeqToFieldTable[20] = "Account User Role.Account User Id"
  dbContext.intSeqToFieldTable[21] = "Account User Role.Role Id"
  dbContext.intSeqToFieldTable[22] = "Account User Role.Created"

  dbContext.modelToIntSeqTable["Account User Token"] = 2

  dbContext.intSeqToModelTable[2] = "Account User Token"

  dbContext.fieldToIntSeqTable["Account User Token.Account User Id"] = 23
  dbContext.fieldToIntSeqTable["Account User Token.Unique Hash"] = 24
  dbContext.fieldToIntSeqTable["Account User Token.Token"] = 25
  dbContext.fieldToIntSeqTable["Account User Token.Created"] = 26
  dbContext.fieldToIntSeqTable["Account User Token.Deleted"] = 27

  dbContext.intSeqToFieldTable[23] = "Account User Token.Account User Id"
  dbContext.intSeqToFieldTable[24] = "Account User Token.Unique Hash"
  dbContext.intSeqToFieldTable[25] = "Account User Token.Token"
  dbContext.intSeqToFieldTable[26] = "Account User Token.Created"
  dbContext.intSeqToFieldTable[27] = "Account User Token.Deleted"

  dbContext.modelToIntSeqTable["Invite"] = 3

  dbContext.intSeqToModelTable[3] = "Invite"

  dbContext.fieldToIntSeqTable["Invite.Id"] = 28
  dbContext.fieldToIntSeqTable["Invite.From Account User Id"] = 29
  dbContext.fieldToIntSeqTable["Invite.From Email"] = 30
  dbContext.fieldToIntSeqTable["Invite.From Name"] = 31
  dbContext.fieldToIntSeqTable["Invite.To Email"] = 32
  dbContext.fieldToIntSeqTable["Invite.To Name"] = 33
  dbContext.fieldToIntSeqTable["Invite.Sent"] = 34
  dbContext.fieldToIntSeqTable["Invite.Created"] = 35

  dbContext.intSeqToFieldTable[28] = "Invite.Id"
  dbContext.intSeqToFieldTable[29] = "Invite.From Account User Id"
  dbContext.intSeqToFieldTable[30] = "Invite.From Email"
  dbContext.intSeqToFieldTable[31] = "Invite.From Name"
  dbContext.intSeqToFieldTable[32] = "Invite.To Email"
  dbContext.intSeqToFieldTable[33] = "Invite.To Name"
  dbContext.intSeqToFieldTable[34] = "Invite.Sent"
  dbContext.intSeqToFieldTable[35] = "Invite.Created"

  dbContext.modelToIntSeqTable["Nexus Setting"] = 4

  dbContext.intSeqToModelTable[4] = "Nexus Setting"

  dbContext.fieldToIntSeqTable["Nexus Setting.Id"] = 36
  dbContext.fieldToIntSeqTable["Nexus Setting.Module"] = 37
  dbContext.fieldToIntSeqTable["Nexus Setting.Key"] = 38
  dbContext.fieldToIntSeqTable["Nexus Setting.Value"] = 39
  dbContext.fieldToIntSeqTable["Nexus Setting.Created"] = 40

  dbContext.intSeqToFieldTable[36] = "Nexus Setting.Id"
  dbContext.intSeqToFieldTable[37] = "Nexus Setting.Module"
  dbContext.intSeqToFieldTable[38] = "Nexus Setting.Key"
  dbContext.intSeqToFieldTable[39] = "Nexus Setting.Value"
  dbContext.intSeqToFieldTable[40] = "Nexus Setting.Created"

  return dbContext

