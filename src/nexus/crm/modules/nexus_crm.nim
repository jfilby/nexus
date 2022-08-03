import db_postgres, tables
import nexus/crm/types/model_types


proc beginTransaction*(nexusCRMDbContext: NexusCRMDbContext) =

  nexusCRMDbContext.dbConn.exec(sql"begin")


proc commitTransaction*(nexusCRMDbContext: NexusCRMDbContext) =

  nexusCRMDbContext.dbConn.exec(sql"commit")


proc isInATransaction*(nexusCRMDbContext: NexusCRMDbContext): bool =

  let row = getRow(
              nexusCRMDbContext.dbConn,
              sql"select pg_current_xact_id_if_assigned()")

  if row[0] == "":
    return false

  else:
    return true


proc rollbackTransaction*(nexusCRMDbContext: NexusCRMDbContext) =

  nexusCRMDbContext.dbConn.exec(sql"rollback")


proc newNexusCRMDbContext*(): NexusCRMDbContext =

  var nexusCRMDbContext = NexusCRMDbContext()

  nexusCRMDbContext.modelToIntSeqTable["Mailing List"] = 0

  nexusCRMDbContext.intSeqToModelTable[0] = "Mailing List"

  nexusCRMDbContext.fieldToIntSeqTable["Mailing List.Mailing List Id"] = 0
  nexusCRMDbContext.fieldToIntSeqTable["Mailing List.Account User Id"] = 1
  nexusCRMDbContext.fieldToIntSeqTable["Mailing List.Unique Hash"] = 2
  nexusCRMDbContext.fieldToIntSeqTable["Mailing List.Name"] = 3
  nexusCRMDbContext.fieldToIntSeqTable["Mailing List.Created"] = 4
  nexusCRMDbContext.fieldToIntSeqTable["Mailing List.Deleted"] = 5

  nexusCRMDbContext.intSeqToFieldTable[0] = "Mailing List.Mailing List Id"
  nexusCRMDbContext.intSeqToFieldTable[1] = "Mailing List.Account User Id"
  nexusCRMDbContext.intSeqToFieldTable[2] = "Mailing List.Unique Hash"
  nexusCRMDbContext.intSeqToFieldTable[3] = "Mailing List.Name"
  nexusCRMDbContext.intSeqToFieldTable[4] = "Mailing List.Created"
  nexusCRMDbContext.intSeqToFieldTable[5] = "Mailing List.Deleted"

  nexusCRMDbContext.modelToIntSeqTable["Mailing List Message"] = 1

  nexusCRMDbContext.intSeqToModelTable[1] = "Mailing List Message"

  nexusCRMDbContext.fieldToIntSeqTable["Mailing List Message.Mailing List Message Id"] = 6
  nexusCRMDbContext.fieldToIntSeqTable["Mailing List Message.Account User Id"] = 7
  nexusCRMDbContext.fieldToIntSeqTable["Mailing List Message.Unique Hash"] = 8
  nexusCRMDbContext.fieldToIntSeqTable["Mailing List Message.Subject"] = 9
  nexusCRMDbContext.fieldToIntSeqTable["Mailing List Message.Message"] = 10
  nexusCRMDbContext.fieldToIntSeqTable["Mailing List Message.Created"] = 11
  nexusCRMDbContext.fieldToIntSeqTable["Mailing List Message.Updated"] = 12
  nexusCRMDbContext.fieldToIntSeqTable["Mailing List Message.Deleted"] = 13

  nexusCRMDbContext.intSeqToFieldTable[6] = "Mailing List Message.Mailing List Message Id"
  nexusCRMDbContext.intSeqToFieldTable[7] = "Mailing List Message.Account User Id"
  nexusCRMDbContext.intSeqToFieldTable[8] = "Mailing List Message.Unique Hash"
  nexusCRMDbContext.intSeqToFieldTable[9] = "Mailing List Message.Subject"
  nexusCRMDbContext.intSeqToFieldTable[10] = "Mailing List Message.Message"
  nexusCRMDbContext.intSeqToFieldTable[11] = "Mailing List Message.Created"
  nexusCRMDbContext.intSeqToFieldTable[12] = "Mailing List Message.Updated"
  nexusCRMDbContext.intSeqToFieldTable[13] = "Mailing List Message.Deleted"

  nexusCRMDbContext.modelToIntSeqTable["Mailing List Subscriber"] = 2

  nexusCRMDbContext.intSeqToModelTable[2] = "Mailing List Subscriber"

  nexusCRMDbContext.fieldToIntSeqTable["Mailing List Subscriber.Mailing List Subscriber Id"] = 14
  nexusCRMDbContext.fieldToIntSeqTable["Mailing List Subscriber.Account User Id"] = 15
  nexusCRMDbContext.fieldToIntSeqTable["Mailing List Subscriber.Mailing List Id"] = 16
  nexusCRMDbContext.fieldToIntSeqTable["Mailing List Subscriber.Unique Hash"] = 17
  nexusCRMDbContext.fieldToIntSeqTable["Mailing List Subscriber.Is Active"] = 18
  nexusCRMDbContext.fieldToIntSeqTable["Mailing List Subscriber.Email"] = 19
  nexusCRMDbContext.fieldToIntSeqTable["Mailing List Subscriber.Name"] = 20
  nexusCRMDbContext.fieldToIntSeqTable["Mailing List Subscriber.Verification Code"] = 21
  nexusCRMDbContext.fieldToIntSeqTable["Mailing List Subscriber.Is Verified"] = 22
  nexusCRMDbContext.fieldToIntSeqTable["Mailing List Subscriber.Created"] = 23
  nexusCRMDbContext.fieldToIntSeqTable["Mailing List Subscriber.Deleted"] = 24

  nexusCRMDbContext.intSeqToFieldTable[14] = "Mailing List Subscriber.Mailing List Subscriber Id"
  nexusCRMDbContext.intSeqToFieldTable[15] = "Mailing List Subscriber.Account User Id"
  nexusCRMDbContext.intSeqToFieldTable[16] = "Mailing List Subscriber.Mailing List Id"
  nexusCRMDbContext.intSeqToFieldTable[17] = "Mailing List Subscriber.Unique Hash"
  nexusCRMDbContext.intSeqToFieldTable[18] = "Mailing List Subscriber.Is Active"
  nexusCRMDbContext.intSeqToFieldTable[19] = "Mailing List Subscriber.Email"
  nexusCRMDbContext.intSeqToFieldTable[20] = "Mailing List Subscriber.Name"
  nexusCRMDbContext.intSeqToFieldTable[21] = "Mailing List Subscriber.Verification Code"
  nexusCRMDbContext.intSeqToFieldTable[22] = "Mailing List Subscriber.Is Verified"
  nexusCRMDbContext.intSeqToFieldTable[23] = "Mailing List Subscriber.Created"
  nexusCRMDbContext.intSeqToFieldTable[24] = "Mailing List Subscriber.Deleted"

  nexusCRMDbContext.modelToIntSeqTable["Mailing List Subscriber Message"] = 3

  nexusCRMDbContext.intSeqToModelTable[3] = "Mailing List Subscriber Message"

  nexusCRMDbContext.fieldToIntSeqTable["Mailing List Subscriber Message.Mailing List Subscriber Message Id"] = 25
  nexusCRMDbContext.fieldToIntSeqTable["Mailing List Subscriber Message.Account User Id"] = 26
  nexusCRMDbContext.fieldToIntSeqTable["Mailing List Subscriber Message.Mailing List Id"] = 27
  nexusCRMDbContext.fieldToIntSeqTable["Mailing List Subscriber Message.Mailing List Subscriber Id"] = 28
  nexusCRMDbContext.fieldToIntSeqTable["Mailing List Subscriber Message.Mailing List Message Id"] = 29
  nexusCRMDbContext.fieldToIntSeqTable["Mailing List Subscriber Message.Created"] = 30

  nexusCRMDbContext.intSeqToFieldTable[25] = "Mailing List Subscriber Message.Mailing List Subscriber Message Id"
  nexusCRMDbContext.intSeqToFieldTable[26] = "Mailing List Subscriber Message.Account User Id"
  nexusCRMDbContext.intSeqToFieldTable[27] = "Mailing List Subscriber Message.Mailing List Id"
  nexusCRMDbContext.intSeqToFieldTable[28] = "Mailing List Subscriber Message.Mailing List Subscriber Id"
  nexusCRMDbContext.intSeqToFieldTable[29] = "Mailing List Subscriber Message.Mailing List Message Id"
  nexusCRMDbContext.intSeqToFieldTable[30] = "Mailing List Subscriber Message.Created"

  return nexusCRMDbContext

