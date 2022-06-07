import db_postgres, tables
import nexus/crm/types/model_types


proc beginTransaction*(crmModule: CRMModule) =

  crmModule.db.exec(sql"begin")


proc commitTransaction*(crmModule: CRMModule) =

  crmModule.db.exec(sql"commit")


proc isInATransaction*(crmModule: CRMModule): bool =

  let row = getRow(
              crmModule.db,
              sql"select pg_current_xact_id_if_assigned()")

  if row[0] == "":
    return false

  else:
    return true


proc rollbackTransaction*(crmModule: CRMModule) =

  crmModule.db.exec(sql"rollback")


proc newCRMModule*(): CRMModule =

  var crmModule = CRMModule()

  crmModule.modelToIntSeqTable["Mailing List"] = 0

  crmModule.intSeqToModelTable[0] = "Mailing List"

  crmModule.fieldToIntSeqTable["Mailing List.Mailing List Id"] = 0
  crmModule.fieldToIntSeqTable["Mailing List.Account User Id"] = 1
  crmModule.fieldToIntSeqTable["Mailing List.Unique Hash"] = 2
  crmModule.fieldToIntSeqTable["Mailing List.Name"] = 3
  crmModule.fieldToIntSeqTable["Mailing List.Created"] = 4
  crmModule.fieldToIntSeqTable["Mailing List.Deleted"] = 5

  crmModule.intSeqToFieldTable[0] = "Mailing List.Mailing List Id"
  crmModule.intSeqToFieldTable[1] = "Mailing List.Account User Id"
  crmModule.intSeqToFieldTable[2] = "Mailing List.Unique Hash"
  crmModule.intSeqToFieldTable[3] = "Mailing List.Name"
  crmModule.intSeqToFieldTable[4] = "Mailing List.Created"
  crmModule.intSeqToFieldTable[5] = "Mailing List.Deleted"

  crmModule.modelToIntSeqTable["Mailing List Message"] = 1

  crmModule.intSeqToModelTable[1] = "Mailing List Message"

  crmModule.fieldToIntSeqTable["Mailing List Message.Mailing List Message Id"] = 6
  crmModule.fieldToIntSeqTable["Mailing List Message.Account User Id"] = 7
  crmModule.fieldToIntSeqTable["Mailing List Message.Unique Hash"] = 8
  crmModule.fieldToIntSeqTable["Mailing List Message.Subject"] = 9
  crmModule.fieldToIntSeqTable["Mailing List Message.Message"] = 10
  crmModule.fieldToIntSeqTable["Mailing List Message.Created"] = 11
  crmModule.fieldToIntSeqTable["Mailing List Message.Updated"] = 12
  crmModule.fieldToIntSeqTable["Mailing List Message.Deleted"] = 13

  crmModule.intSeqToFieldTable[6] = "Mailing List Message.Mailing List Message Id"
  crmModule.intSeqToFieldTable[7] = "Mailing List Message.Account User Id"
  crmModule.intSeqToFieldTable[8] = "Mailing List Message.Unique Hash"
  crmModule.intSeqToFieldTable[9] = "Mailing List Message.Subject"
  crmModule.intSeqToFieldTable[10] = "Mailing List Message.Message"
  crmModule.intSeqToFieldTable[11] = "Mailing List Message.Created"
  crmModule.intSeqToFieldTable[12] = "Mailing List Message.Updated"
  crmModule.intSeqToFieldTable[13] = "Mailing List Message.Deleted"

  crmModule.modelToIntSeqTable["Mailing List Subscriber"] = 2

  crmModule.intSeqToModelTable[2] = "Mailing List Subscriber"

  crmModule.fieldToIntSeqTable["Mailing List Subscriber.Mailing List Subscriber Id"] = 14
  crmModule.fieldToIntSeqTable["Mailing List Subscriber.Account User Id"] = 15
  crmModule.fieldToIntSeqTable["Mailing List Subscriber.Mailing List Id"] = 16
  crmModule.fieldToIntSeqTable["Mailing List Subscriber.Unique Hash"] = 17
  crmModule.fieldToIntSeqTable["Mailing List Subscriber.Is Active"] = 18
  crmModule.fieldToIntSeqTable["Mailing List Subscriber.Email"] = 19
  crmModule.fieldToIntSeqTable["Mailing List Subscriber.Name"] = 20
  crmModule.fieldToIntSeqTable["Mailing List Subscriber.Verification Code"] = 21
  crmModule.fieldToIntSeqTable["Mailing List Subscriber.Is Verified"] = 22
  crmModule.fieldToIntSeqTable["Mailing List Subscriber.Created"] = 23
  crmModule.fieldToIntSeqTable["Mailing List Subscriber.Deleted"] = 24

  crmModule.intSeqToFieldTable[14] = "Mailing List Subscriber.Mailing List Subscriber Id"
  crmModule.intSeqToFieldTable[15] = "Mailing List Subscriber.Account User Id"
  crmModule.intSeqToFieldTable[16] = "Mailing List Subscriber.Mailing List Id"
  crmModule.intSeqToFieldTable[17] = "Mailing List Subscriber.Unique Hash"
  crmModule.intSeqToFieldTable[18] = "Mailing List Subscriber.Is Active"
  crmModule.intSeqToFieldTable[19] = "Mailing List Subscriber.Email"
  crmModule.intSeqToFieldTable[20] = "Mailing List Subscriber.Name"
  crmModule.intSeqToFieldTable[21] = "Mailing List Subscriber.Verification Code"
  crmModule.intSeqToFieldTable[22] = "Mailing List Subscriber.Is Verified"
  crmModule.intSeqToFieldTable[23] = "Mailing List Subscriber.Created"
  crmModule.intSeqToFieldTable[24] = "Mailing List Subscriber.Deleted"

  crmModule.modelToIntSeqTable["Mailing List Subscriber Message"] = 3

  crmModule.intSeqToModelTable[3] = "Mailing List Subscriber Message"

  crmModule.fieldToIntSeqTable["Mailing List Subscriber Message.Mailing List Subscriber Message Id"] = 25
  crmModule.fieldToIntSeqTable["Mailing List Subscriber Message.Account User Id"] = 26
  crmModule.fieldToIntSeqTable["Mailing List Subscriber Message.Mailing List Id"] = 27
  crmModule.fieldToIntSeqTable["Mailing List Subscriber Message.Mailing List Subscriber Id"] = 28
  crmModule.fieldToIntSeqTable["Mailing List Subscriber Message.Mailing List Message Id"] = 29
  crmModule.fieldToIntSeqTable["Mailing List Subscriber Message.Created"] = 30

  crmModule.intSeqToFieldTable[25] = "Mailing List Subscriber Message.Mailing List Subscriber Message Id"
  crmModule.intSeqToFieldTable[26] = "Mailing List Subscriber Message.Account User Id"
  crmModule.intSeqToFieldTable[27] = "Mailing List Subscriber Message.Mailing List Id"
  crmModule.intSeqToFieldTable[28] = "Mailing List Subscriber Message.Mailing List Subscriber Id"
  crmModule.intSeqToFieldTable[29] = "Mailing List Subscriber Message.Mailing List Message Id"
  crmModule.intSeqToFieldTable[30] = "Mailing List Subscriber Message.Created"

  return crmModule

