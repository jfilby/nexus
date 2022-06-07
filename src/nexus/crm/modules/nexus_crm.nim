import db_postgres, tables
import nexus/crm/types/model_types


proc beginTransaction*(nexusCRMModule: NexusCRMModule) =

  nexusCRMModule.db.exec(sql"begin")


proc commitTransaction*(nexusCRMModule: NexusCRMModule) =

  nexusCRMModule.db.exec(sql"commit")


proc isInATransaction*(nexusCRMModule: NexusCRMModule): bool =

  let row = getRow(
              nexusCRMModule.db,
              sql"select pg_current_xact_id_if_assigned()")

  if row[0] == "":
    return false

  else:
    return true


proc rollbackTransaction*(nexusCRMModule: NexusCRMModule) =

  nexusCRMModule.db.exec(sql"rollback")


proc newNexusCRMModule*(): NexusCRMModule =

  var nexusCRMModule = NexusCRMModule()

  nexusCRMModule.modelToIntSeqTable["Mailing List"] = 0

  nexusCRMModule.intSeqToModelTable[0] = "Mailing List"

  nexusCRMModule.fieldToIntSeqTable["Mailing List.Mailing List Id"] = 0
  nexusCRMModule.fieldToIntSeqTable["Mailing List.Account User Id"] = 1
  nexusCRMModule.fieldToIntSeqTable["Mailing List.Unique Hash"] = 2
  nexusCRMModule.fieldToIntSeqTable["Mailing List.Name"] = 3
  nexusCRMModule.fieldToIntSeqTable["Mailing List.Created"] = 4
  nexusCRMModule.fieldToIntSeqTable["Mailing List.Deleted"] = 5

  nexusCRMModule.intSeqToFieldTable[0] = "Mailing List.Mailing List Id"
  nexusCRMModule.intSeqToFieldTable[1] = "Mailing List.Account User Id"
  nexusCRMModule.intSeqToFieldTable[2] = "Mailing List.Unique Hash"
  nexusCRMModule.intSeqToFieldTable[3] = "Mailing List.Name"
  nexusCRMModule.intSeqToFieldTable[4] = "Mailing List.Created"
  nexusCRMModule.intSeqToFieldTable[5] = "Mailing List.Deleted"

  nexusCRMModule.modelToIntSeqTable["Mailing List Message"] = 1

  nexusCRMModule.intSeqToModelTable[1] = "Mailing List Message"

  nexusCRMModule.fieldToIntSeqTable["Mailing List Message.Mailing List Message Id"] = 6
  nexusCRMModule.fieldToIntSeqTable["Mailing List Message.Account User Id"] = 7
  nexusCRMModule.fieldToIntSeqTable["Mailing List Message.Unique Hash"] = 8
  nexusCRMModule.fieldToIntSeqTable["Mailing List Message.Subject"] = 9
  nexusCRMModule.fieldToIntSeqTable["Mailing List Message.Message"] = 10
  nexusCRMModule.fieldToIntSeqTable["Mailing List Message.Created"] = 11
  nexusCRMModule.fieldToIntSeqTable["Mailing List Message.Updated"] = 12
  nexusCRMModule.fieldToIntSeqTable["Mailing List Message.Deleted"] = 13

  nexusCRMModule.intSeqToFieldTable[6] = "Mailing List Message.Mailing List Message Id"
  nexusCRMModule.intSeqToFieldTable[7] = "Mailing List Message.Account User Id"
  nexusCRMModule.intSeqToFieldTable[8] = "Mailing List Message.Unique Hash"
  nexusCRMModule.intSeqToFieldTable[9] = "Mailing List Message.Subject"
  nexusCRMModule.intSeqToFieldTable[10] = "Mailing List Message.Message"
  nexusCRMModule.intSeqToFieldTable[11] = "Mailing List Message.Created"
  nexusCRMModule.intSeqToFieldTable[12] = "Mailing List Message.Updated"
  nexusCRMModule.intSeqToFieldTable[13] = "Mailing List Message.Deleted"

  nexusCRMModule.modelToIntSeqTable["Mailing List Subscriber"] = 2

  nexusCRMModule.intSeqToModelTable[2] = "Mailing List Subscriber"

  nexusCRMModule.fieldToIntSeqTable["Mailing List Subscriber.Mailing List Subscriber Id"] = 14
  nexusCRMModule.fieldToIntSeqTable["Mailing List Subscriber.Account User Id"] = 15
  nexusCRMModule.fieldToIntSeqTable["Mailing List Subscriber.Mailing List Id"] = 16
  nexusCRMModule.fieldToIntSeqTable["Mailing List Subscriber.Unique Hash"] = 17
  nexusCRMModule.fieldToIntSeqTable["Mailing List Subscriber.Is Active"] = 18
  nexusCRMModule.fieldToIntSeqTable["Mailing List Subscriber.Email"] = 19
  nexusCRMModule.fieldToIntSeqTable["Mailing List Subscriber.Name"] = 20
  nexusCRMModule.fieldToIntSeqTable["Mailing List Subscriber.Verification Code"] = 21
  nexusCRMModule.fieldToIntSeqTable["Mailing List Subscriber.Is Verified"] = 22
  nexusCRMModule.fieldToIntSeqTable["Mailing List Subscriber.Created"] = 23
  nexusCRMModule.fieldToIntSeqTable["Mailing List Subscriber.Deleted"] = 24

  nexusCRMModule.intSeqToFieldTable[14] = "Mailing List Subscriber.Mailing List Subscriber Id"
  nexusCRMModule.intSeqToFieldTable[15] = "Mailing List Subscriber.Account User Id"
  nexusCRMModule.intSeqToFieldTable[16] = "Mailing List Subscriber.Mailing List Id"
  nexusCRMModule.intSeqToFieldTable[17] = "Mailing List Subscriber.Unique Hash"
  nexusCRMModule.intSeqToFieldTable[18] = "Mailing List Subscriber.Is Active"
  nexusCRMModule.intSeqToFieldTable[19] = "Mailing List Subscriber.Email"
  nexusCRMModule.intSeqToFieldTable[20] = "Mailing List Subscriber.Name"
  nexusCRMModule.intSeqToFieldTable[21] = "Mailing List Subscriber.Verification Code"
  nexusCRMModule.intSeqToFieldTable[22] = "Mailing List Subscriber.Is Verified"
  nexusCRMModule.intSeqToFieldTable[23] = "Mailing List Subscriber.Created"
  nexusCRMModule.intSeqToFieldTable[24] = "Mailing List Subscriber.Deleted"

  nexusCRMModule.modelToIntSeqTable["Mailing List Subscriber Message"] = 3

  nexusCRMModule.intSeqToModelTable[3] = "Mailing List Subscriber Message"

  nexusCRMModule.fieldToIntSeqTable["Mailing List Subscriber Message.Mailing List Subscriber Message Id"] = 25
  nexusCRMModule.fieldToIntSeqTable["Mailing List Subscriber Message.Account User Id"] = 26
  nexusCRMModule.fieldToIntSeqTable["Mailing List Subscriber Message.Mailing List Id"] = 27
  nexusCRMModule.fieldToIntSeqTable["Mailing List Subscriber Message.Mailing List Subscriber Id"] = 28
  nexusCRMModule.fieldToIntSeqTable["Mailing List Subscriber Message.Mailing List Message Id"] = 29
  nexusCRMModule.fieldToIntSeqTable["Mailing List Subscriber Message.Created"] = 30

  nexusCRMModule.intSeqToFieldTable[25] = "Mailing List Subscriber Message.Mailing List Subscriber Message Id"
  nexusCRMModule.intSeqToFieldTable[26] = "Mailing List Subscriber Message.Account User Id"
  nexusCRMModule.intSeqToFieldTable[27] = "Mailing List Subscriber Message.Mailing List Id"
  nexusCRMModule.intSeqToFieldTable[28] = "Mailing List Subscriber Message.Mailing List Subscriber Id"
  nexusCRMModule.intSeqToFieldTable[29] = "Mailing List Subscriber Message.Mailing List Message Id"
  nexusCRMModule.intSeqToFieldTable[30] = "Mailing List Subscriber Message.Created"

  return nexusCRMModule

