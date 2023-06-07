import db_postgres, tables
import nexus/core_extras/types/model_types


proc beginTransaction*(dbContext: NexusCoreExtrasDbContext) =

  dbContext.dbConn.exec(sql"begin")


proc commitTransaction*(dbContext: NexusCoreExtrasDbContext) =

  dbContext.dbConn.exec(sql"commit")


proc isInATransaction*(dbContext: NexusCoreExtrasDbContext): bool =

  let row = getRow(
              dbContext.dbConn,
              sql"select pg_current_xact_id_if_assigned()")

  if row[0] == "":
    return false

  else:
    return true


proc rollbackTransaction*(dbContext: NexusCoreExtrasDbContext) =

  dbContext.dbConn.exec(sql"rollback")


proc newNexusCoreExtrasDbContext*(): NexusCoreExtrasDbContext =

  var dbContext = NexusCoreExtrasDbContext()

  dbContext.modelToIntSeqTable["List Item"] = 0

  dbContext.intSeqToModelTable[0] = "List Item"

  dbContext.fieldToIntSeqTable["List Item.Id"] = 0
  dbContext.fieldToIntSeqTable["List Item.Parent Id"] = 1
  dbContext.fieldToIntSeqTable["List Item.Seq No"] = 2
  dbContext.fieldToIntSeqTable["List Item.Name"] = 3
  dbContext.fieldToIntSeqTable["List Item.Display Name"] = 4
  dbContext.fieldToIntSeqTable["List Item.Description"] = 5
  dbContext.fieldToIntSeqTable["List Item.Created"] = 6

  dbContext.intSeqToFieldTable[0] = "List Item.Id"
  dbContext.intSeqToFieldTable[1] = "List Item.Parent Id"
  dbContext.intSeqToFieldTable[2] = "List Item.Seq No"
  dbContext.intSeqToFieldTable[3] = "List Item.Name"
  dbContext.intSeqToFieldTable[4] = "List Item.Display Name"
  dbContext.intSeqToFieldTable[5] = "List Item.Description"
  dbContext.intSeqToFieldTable[6] = "List Item.Created"

  dbContext.modelToIntSeqTable["Menu Item"] = 1

  dbContext.intSeqToModelTable[1] = "Menu Item"

  dbContext.fieldToIntSeqTable["Menu Item.Id"] = 7
  dbContext.fieldToIntSeqTable["Menu Item.Parent Id"] = 8
  dbContext.fieldToIntSeqTable["Menu Item.Name"] = 9
  dbContext.fieldToIntSeqTable["Menu Item.URL"] = 10
  dbContext.fieldToIntSeqTable["Menu Item.Screen"] = 11
  dbContext.fieldToIntSeqTable["Menu Item.Level"] = 12
  dbContext.fieldToIntSeqTable["Menu Item.Position"] = 13
  dbContext.fieldToIntSeqTable["Menu Item.Role Ids"] = 14
  dbContext.fieldToIntSeqTable["Menu Item.Created"] = 15

  dbContext.intSeqToFieldTable[7] = "Menu Item.Id"
  dbContext.intSeqToFieldTable[8] = "Menu Item.Parent Id"
  dbContext.intSeqToFieldTable[9] = "Menu Item.Name"
  dbContext.intSeqToFieldTable[10] = "Menu Item.URL"
  dbContext.intSeqToFieldTable[11] = "Menu Item.Screen"
  dbContext.intSeqToFieldTable[12] = "Menu Item.Level"
  dbContext.intSeqToFieldTable[13] = "Menu Item.Position"
  dbContext.intSeqToFieldTable[14] = "Menu Item.Role Ids"
  dbContext.intSeqToFieldTable[15] = "Menu Item.Created"

  dbContext.modelToIntSeqTable["Temp Form Data"] = 2

  dbContext.intSeqToModelTable[2] = "Temp Form Data"

  dbContext.fieldToIntSeqTable["Temp Form Data.Token"] = 16
  dbContext.fieldToIntSeqTable["Temp Form Data.Format"] = 17
  dbContext.fieldToIntSeqTable["Temp Form Data.Data"] = 18
  dbContext.fieldToIntSeqTable["Temp Form Data.Created"] = 19

  dbContext.intSeqToFieldTable[16] = "Temp Form Data.Token"
  dbContext.intSeqToFieldTable[17] = "Temp Form Data.Format"
  dbContext.intSeqToFieldTable[18] = "Temp Form Data.Data"
  dbContext.intSeqToFieldTable[19] = "Temp Form Data.Created"

  dbContext.modelToIntSeqTable["Temp Queue Data"] = 3

  dbContext.intSeqToModelTable[3] = "Temp Queue Data"

  dbContext.fieldToIntSeqTable["Temp Queue Data.Temp Queue Data Id"] = 20
  dbContext.fieldToIntSeqTable["Temp Queue Data.Format"] = 21
  dbContext.fieldToIntSeqTable["Temp Queue Data.Data In"] = 22
  dbContext.fieldToIntSeqTable["Temp Queue Data.Data Out"] = 23
  dbContext.fieldToIntSeqTable["Temp Queue Data.Created"] = 24
  dbContext.fieldToIntSeqTable["Temp Queue Data.Fulfilled"] = 25

  dbContext.intSeqToFieldTable[20] = "Temp Queue Data.Temp Queue Data Id"
  dbContext.intSeqToFieldTable[21] = "Temp Queue Data.Format"
  dbContext.intSeqToFieldTable[22] = "Temp Queue Data.Data In"
  dbContext.intSeqToFieldTable[23] = "Temp Queue Data.Data Out"
  dbContext.intSeqToFieldTable[24] = "Temp Queue Data.Created"
  dbContext.intSeqToFieldTable[25] = "Temp Queue Data.Fulfilled"

  return dbContext

