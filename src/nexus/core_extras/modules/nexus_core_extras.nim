import db_postgres, tables
import nexus/core_extras/types/model_types


proc beginTransaction*(nexusCoreExtrasDbContext: NexusCoreExtrasDbContext) =

  nexusCoreExtrasDbContext.dbConn.exec(sql"begin")


proc commitTransaction*(nexusCoreExtrasDbContext: NexusCoreExtrasDbContext) =

  nexusCoreExtrasDbContext.dbConn.exec(sql"commit")


proc isInATransaction*(nexusCoreExtrasDbContext: NexusCoreExtrasDbContext): bool =

  let row = getRow(
              nexusCoreExtrasDbContext.dbConn,
              sql"select pg_current_xact_id_if_assigned()")

  if row[0] == "":
    return false

  else:
    return true


proc rollbackTransaction*(nexusCoreExtrasDbContext: NexusCoreExtrasDbContext) =

  nexusCoreExtrasDbContext.dbConn.exec(sql"rollback")


proc newNexusCoreExtrasDbContext*(): NexusCoreExtrasDbContext =

  var nexusCoreExtrasDbContext = NexusCoreExtrasDbContext()

  nexusCoreExtrasDbContext.modelToIntSeqTable["List Item"] = 0

  nexusCoreExtrasDbContext.intSeqToModelTable[0] = "List Item"

  nexusCoreExtrasDbContext.fieldToIntSeqTable["List Item.List Item Id"] = 0
  nexusCoreExtrasDbContext.fieldToIntSeqTable["List Item.Parent List Item Id"] = 1
  nexusCoreExtrasDbContext.fieldToIntSeqTable["List Item.Seq No"] = 2
  nexusCoreExtrasDbContext.fieldToIntSeqTable["List Item.Name"] = 3
  nexusCoreExtrasDbContext.fieldToIntSeqTable["List Item.Display Name"] = 4
  nexusCoreExtrasDbContext.fieldToIntSeqTable["List Item.Description"] = 5
  nexusCoreExtrasDbContext.fieldToIntSeqTable["List Item.Created"] = 6

  nexusCoreExtrasDbContext.intSeqToFieldTable[0] = "List Item.List Item Id"
  nexusCoreExtrasDbContext.intSeqToFieldTable[1] = "List Item.Parent List Item Id"
  nexusCoreExtrasDbContext.intSeqToFieldTable[2] = "List Item.Seq No"
  nexusCoreExtrasDbContext.intSeqToFieldTable[3] = "List Item.Name"
  nexusCoreExtrasDbContext.intSeqToFieldTable[4] = "List Item.Display Name"
  nexusCoreExtrasDbContext.intSeqToFieldTable[5] = "List Item.Description"
  nexusCoreExtrasDbContext.intSeqToFieldTable[6] = "List Item.Created"

  nexusCoreExtrasDbContext.modelToIntSeqTable["Menu Item"] = 1

  nexusCoreExtrasDbContext.intSeqToModelTable[1] = "Menu Item"

  nexusCoreExtrasDbContext.fieldToIntSeqTable["Menu Item.Menu Item Id"] = 7
  nexusCoreExtrasDbContext.fieldToIntSeqTable["Menu Item.Parent Menu Item Id"] = 8
  nexusCoreExtrasDbContext.fieldToIntSeqTable["Menu Item.Name"] = 9
  nexusCoreExtrasDbContext.fieldToIntSeqTable["Menu Item.URL"] = 10
  nexusCoreExtrasDbContext.fieldToIntSeqTable["Menu Item.Screen"] = 11
  nexusCoreExtrasDbContext.fieldToIntSeqTable["Menu Item.Level"] = 12
  nexusCoreExtrasDbContext.fieldToIntSeqTable["Menu Item.Position"] = 13
  nexusCoreExtrasDbContext.fieldToIntSeqTable["Menu Item.Role Ids"] = 14
  nexusCoreExtrasDbContext.fieldToIntSeqTable["Menu Item.Created"] = 15

  nexusCoreExtrasDbContext.intSeqToFieldTable[7] = "Menu Item.Menu Item Id"
  nexusCoreExtrasDbContext.intSeqToFieldTable[8] = "Menu Item.Parent Menu Item Id"
  nexusCoreExtrasDbContext.intSeqToFieldTable[9] = "Menu Item.Name"
  nexusCoreExtrasDbContext.intSeqToFieldTable[10] = "Menu Item.URL"
  nexusCoreExtrasDbContext.intSeqToFieldTable[11] = "Menu Item.Screen"
  nexusCoreExtrasDbContext.intSeqToFieldTable[12] = "Menu Item.Level"
  nexusCoreExtrasDbContext.intSeqToFieldTable[13] = "Menu Item.Position"
  nexusCoreExtrasDbContext.intSeqToFieldTable[14] = "Menu Item.Role Ids"
  nexusCoreExtrasDbContext.intSeqToFieldTable[15] = "Menu Item.Created"

  nexusCoreExtrasDbContext.modelToIntSeqTable["Temp Form Data"] = 2

  nexusCoreExtrasDbContext.intSeqToModelTable[2] = "Temp Form Data"

  nexusCoreExtrasDbContext.fieldToIntSeqTable["Temp Form Data.Token"] = 16
  nexusCoreExtrasDbContext.fieldToIntSeqTable["Temp Form Data.Format"] = 17
  nexusCoreExtrasDbContext.fieldToIntSeqTable["Temp Form Data.Data"] = 18
  nexusCoreExtrasDbContext.fieldToIntSeqTable["Temp Form Data.Created"] = 19

  nexusCoreExtrasDbContext.intSeqToFieldTable[16] = "Temp Form Data.Token"
  nexusCoreExtrasDbContext.intSeqToFieldTable[17] = "Temp Form Data.Format"
  nexusCoreExtrasDbContext.intSeqToFieldTable[18] = "Temp Form Data.Data"
  nexusCoreExtrasDbContext.intSeqToFieldTable[19] = "Temp Form Data.Created"

  nexusCoreExtrasDbContext.modelToIntSeqTable["Temp Queue Data"] = 3

  nexusCoreExtrasDbContext.intSeqToModelTable[3] = "Temp Queue Data"

  nexusCoreExtrasDbContext.fieldToIntSeqTable["Temp Queue Data.Temp Queue Data Id"] = 20
  nexusCoreExtrasDbContext.fieldToIntSeqTable["Temp Queue Data.Format"] = 21
  nexusCoreExtrasDbContext.fieldToIntSeqTable["Temp Queue Data.Data In"] = 22
  nexusCoreExtrasDbContext.fieldToIntSeqTable["Temp Queue Data.Data Out"] = 23
  nexusCoreExtrasDbContext.fieldToIntSeqTable["Temp Queue Data.Created"] = 24
  nexusCoreExtrasDbContext.fieldToIntSeqTable["Temp Queue Data.Fulfilled"] = 25

  nexusCoreExtrasDbContext.intSeqToFieldTable[20] = "Temp Queue Data.Temp Queue Data Id"
  nexusCoreExtrasDbContext.intSeqToFieldTable[21] = "Temp Queue Data.Format"
  nexusCoreExtrasDbContext.intSeqToFieldTable[22] = "Temp Queue Data.Data In"
  nexusCoreExtrasDbContext.intSeqToFieldTable[23] = "Temp Queue Data.Data Out"
  nexusCoreExtrasDbContext.intSeqToFieldTable[24] = "Temp Queue Data.Created"
  nexusCoreExtrasDbContext.intSeqToFieldTable[25] = "Temp Queue Data.Fulfilled"

  return nexusCoreExtrasDbContext

