import tables
import db_connector/db_postgres
import nexus/crm/types/model_types


proc beginTransaction*(dbContext: NexusCRMDbContext) =

  dbContext.dbConn.exec(sql"begin")


proc commitTransaction*(dbContext: NexusCRMDbContext) =

  dbContext.dbConn.exec(sql"commit")


proc isInATransaction*(dbContext: NexusCRMDbContext): bool =

  let row = getRow(
              dbContext.dbConn,
              sql"select pg_current_xact_id_if_assigned()")

  if row[0] == "":
    return false

  else:
    return true


proc rollbackTransaction*(dbContext: NexusCRMDbContext) =

  dbContext.dbConn.exec(sql"rollback")


proc newNexusCRMDbContext*(): NexusCRMDbContext =

  var dbContext = NexusCRMDbContext()

  dbContext.modelToIntSeqTable["Mailing List"] = 0

  dbContext.intSeqToModelTable[0] = "Mailing List"

  dbContext.fieldToIntSeqTable["Mailing List.Id"] = 0
  dbContext.fieldToIntSeqTable["Mailing List.Account User Id"] = 1
  dbContext.fieldToIntSeqTable["Mailing List.Unique Hash"] = 2
  dbContext.fieldToIntSeqTable["Mailing List.Name"] = 3
  dbContext.fieldToIntSeqTable["Mailing List.Created"] = 4
  dbContext.fieldToIntSeqTable["Mailing List.Deleted"] = 5

  dbContext.intSeqToFieldTable[0] = "Mailing List.Id"
  dbContext.intSeqToFieldTable[1] = "Mailing List.Account User Id"
  dbContext.intSeqToFieldTable[2] = "Mailing List.Unique Hash"
  dbContext.intSeqToFieldTable[3] = "Mailing List.Name"
  dbContext.intSeqToFieldTable[4] = "Mailing List.Created"
  dbContext.intSeqToFieldTable[5] = "Mailing List.Deleted"

  dbContext.modelToIntSeqTable["Mailing List Message"] = 1

  dbContext.intSeqToModelTable[1] = "Mailing List Message"

  dbContext.fieldToIntSeqTable["Mailing List Message.Id"] = 6
  dbContext.fieldToIntSeqTable["Mailing List Message.Account User Id"] = 7
  dbContext.fieldToIntSeqTable["Mailing List Message.Unique Hash"] = 8
  dbContext.fieldToIntSeqTable["Mailing List Message.Subject"] = 9
  dbContext.fieldToIntSeqTable["Mailing List Message.Message"] = 10
  dbContext.fieldToIntSeqTable["Mailing List Message.Created"] = 11
  dbContext.fieldToIntSeqTable["Mailing List Message.Updated"] = 12
  dbContext.fieldToIntSeqTable["Mailing List Message.Deleted"] = 13

  dbContext.intSeqToFieldTable[6] = "Mailing List Message.Id"
  dbContext.intSeqToFieldTable[7] = "Mailing List Message.Account User Id"
  dbContext.intSeqToFieldTable[8] = "Mailing List Message.Unique Hash"
  dbContext.intSeqToFieldTable[9] = "Mailing List Message.Subject"
  dbContext.intSeqToFieldTable[10] = "Mailing List Message.Message"
  dbContext.intSeqToFieldTable[11] = "Mailing List Message.Created"
  dbContext.intSeqToFieldTable[12] = "Mailing List Message.Updated"
  dbContext.intSeqToFieldTable[13] = "Mailing List Message.Deleted"

  dbContext.modelToIntSeqTable["Mailing List Subscriber"] = 2

  dbContext.intSeqToModelTable[2] = "Mailing List Subscriber"

  dbContext.fieldToIntSeqTable["Mailing List Subscriber.Id"] = 14
  dbContext.fieldToIntSeqTable["Mailing List Subscriber.Account User Id"] = 15
  dbContext.fieldToIntSeqTable["Mailing List Subscriber.Mailing List Id"] = 16
  dbContext.fieldToIntSeqTable["Mailing List Subscriber.Unique Hash"] = 17
  dbContext.fieldToIntSeqTable["Mailing List Subscriber.Is Active"] = 18
  dbContext.fieldToIntSeqTable["Mailing List Subscriber.Email"] = 19
  dbContext.fieldToIntSeqTable["Mailing List Subscriber.Name"] = 20
  dbContext.fieldToIntSeqTable["Mailing List Subscriber.Verification Code"] = 21
  dbContext.fieldToIntSeqTable["Mailing List Subscriber.Is Verified"] = 22
  dbContext.fieldToIntSeqTable["Mailing List Subscriber.Created"] = 23
  dbContext.fieldToIntSeqTable["Mailing List Subscriber.Deleted"] = 24

  dbContext.intSeqToFieldTable[14] = "Mailing List Subscriber.Id"
  dbContext.intSeqToFieldTable[15] = "Mailing List Subscriber.Account User Id"
  dbContext.intSeqToFieldTable[16] = "Mailing List Subscriber.Mailing List Id"
  dbContext.intSeqToFieldTable[17] = "Mailing List Subscriber.Unique Hash"
  dbContext.intSeqToFieldTable[18] = "Mailing List Subscriber.Is Active"
  dbContext.intSeqToFieldTable[19] = "Mailing List Subscriber.Email"
  dbContext.intSeqToFieldTable[20] = "Mailing List Subscriber.Name"
  dbContext.intSeqToFieldTable[21] = "Mailing List Subscriber.Verification Code"
  dbContext.intSeqToFieldTable[22] = "Mailing List Subscriber.Is Verified"
  dbContext.intSeqToFieldTable[23] = "Mailing List Subscriber.Created"
  dbContext.intSeqToFieldTable[24] = "Mailing List Subscriber.Deleted"

  dbContext.modelToIntSeqTable["Mailing List Subscriber Message"] = 3

  dbContext.intSeqToModelTable[3] = "Mailing List Subscriber Message"

  dbContext.fieldToIntSeqTable["Mailing List Subscriber Message.Id"] = 25
  dbContext.fieldToIntSeqTable["Mailing List Subscriber Message.Account User Id"] = 26
  dbContext.fieldToIntSeqTable["Mailing List Subscriber Message.Mailing List Id"] = 27
  dbContext.fieldToIntSeqTable["Mailing List Subscriber Message.Mailing List Subscriber Id"] = 28
  dbContext.fieldToIntSeqTable["Mailing List Subscriber Message.Mailing List Message Id"] = 29
  dbContext.fieldToIntSeqTable["Mailing List Subscriber Message.Created"] = 30

  dbContext.intSeqToFieldTable[25] = "Mailing List Subscriber Message.Id"
  dbContext.intSeqToFieldTable[26] = "Mailing List Subscriber Message.Account User Id"
  dbContext.intSeqToFieldTable[27] = "Mailing List Subscriber Message.Mailing List Id"
  dbContext.intSeqToFieldTable[28] = "Mailing List Subscriber Message.Mailing List Subscriber Id"
  dbContext.intSeqToFieldTable[29] = "Mailing List Subscriber Message.Mailing List Message Id"
  dbContext.intSeqToFieldTable[30] = "Mailing List Subscriber Message.Created"

  return dbContext

