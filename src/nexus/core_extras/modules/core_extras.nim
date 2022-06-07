import db_postgres, tables
import nexus/core_extras/types/model_types


proc beginTransaction*(coreExtrasModule: CoreExtrasModule) =

  coreExtrasModule.db.exec(sql"begin")


proc commitTransaction*(coreExtrasModule: CoreExtrasModule) =

  coreExtrasModule.db.exec(sql"commit")


proc isInATransaction*(coreExtrasModule: CoreExtrasModule): bool =

  let row = getRow(
              coreExtrasModule.db,
              sql"select pg_current_xact_id_if_assigned()")

  if row[0] == "":
    return false

  else:
    return true


proc rollbackTransaction*(coreExtrasModule: CoreExtrasModule) =

  coreExtrasModule.db.exec(sql"rollback")


proc newCoreExtrasModule*(): CoreExtrasModule =

  var coreExtrasModule = CoreExtrasModule()

  coreExtrasModule.modelToIntSeqTable["List Item"] = 0

  coreExtrasModule.intSeqToModelTable[0] = "List Item"

  coreExtrasModule.fieldToIntSeqTable["List Item.List Item Id"] = 0
  coreExtrasModule.fieldToIntSeqTable["List Item.Parent List Item Id"] = 1
  coreExtrasModule.fieldToIntSeqTable["List Item.Seq No"] = 2
  coreExtrasModule.fieldToIntSeqTable["List Item.Name"] = 3
  coreExtrasModule.fieldToIntSeqTable["List Item.Display Name"] = 4
  coreExtrasModule.fieldToIntSeqTable["List Item.Description"] = 5
  coreExtrasModule.fieldToIntSeqTable["List Item.Created"] = 6

  coreExtrasModule.intSeqToFieldTable[0] = "List Item.List Item Id"
  coreExtrasModule.intSeqToFieldTable[1] = "List Item.Parent List Item Id"
  coreExtrasModule.intSeqToFieldTable[2] = "List Item.Seq No"
  coreExtrasModule.intSeqToFieldTable[3] = "List Item.Name"
  coreExtrasModule.intSeqToFieldTable[4] = "List Item.Display Name"
  coreExtrasModule.intSeqToFieldTable[5] = "List Item.Description"
  coreExtrasModule.intSeqToFieldTable[6] = "List Item.Created"

  coreExtrasModule.modelToIntSeqTable["Menu Item"] = 1

  coreExtrasModule.intSeqToModelTable[1] = "Menu Item"

  coreExtrasModule.fieldToIntSeqTable["Menu Item.Menu Item Id"] = 7
  coreExtrasModule.fieldToIntSeqTable["Menu Item.Parent Menu Item Id"] = 8
  coreExtrasModule.fieldToIntSeqTable["Menu Item.Name"] = 9
  coreExtrasModule.fieldToIntSeqTable["Menu Item.URL"] = 10
  coreExtrasModule.fieldToIntSeqTable["Menu Item.Screen"] = 11
  coreExtrasModule.fieldToIntSeqTable["Menu Item.Level"] = 12
  coreExtrasModule.fieldToIntSeqTable["Menu Item.Position"] = 13
  coreExtrasModule.fieldToIntSeqTable["Menu Item.Role Ids"] = 14
  coreExtrasModule.fieldToIntSeqTable["Menu Item.Created"] = 15

  coreExtrasModule.intSeqToFieldTable[7] = "Menu Item.Menu Item Id"
  coreExtrasModule.intSeqToFieldTable[8] = "Menu Item.Parent Menu Item Id"
  coreExtrasModule.intSeqToFieldTable[9] = "Menu Item.Name"
  coreExtrasModule.intSeqToFieldTable[10] = "Menu Item.URL"
  coreExtrasModule.intSeqToFieldTable[11] = "Menu Item.Screen"
  coreExtrasModule.intSeqToFieldTable[12] = "Menu Item.Level"
  coreExtrasModule.intSeqToFieldTable[13] = "Menu Item.Position"
  coreExtrasModule.intSeqToFieldTable[14] = "Menu Item.Role Ids"
  coreExtrasModule.intSeqToFieldTable[15] = "Menu Item.Created"

  coreExtrasModule.modelToIntSeqTable["Temp Form Data"] = 2

  coreExtrasModule.intSeqToModelTable[2] = "Temp Form Data"

  coreExtrasModule.fieldToIntSeqTable["Temp Form Data.Token"] = 16
  coreExtrasModule.fieldToIntSeqTable["Temp Form Data.Format"] = 17
  coreExtrasModule.fieldToIntSeqTable["Temp Form Data.Data"] = 18
  coreExtrasModule.fieldToIntSeqTable["Temp Form Data.Created"] = 19

  coreExtrasModule.intSeqToFieldTable[16] = "Temp Form Data.Token"
  coreExtrasModule.intSeqToFieldTable[17] = "Temp Form Data.Format"
  coreExtrasModule.intSeqToFieldTable[18] = "Temp Form Data.Data"
  coreExtrasModule.intSeqToFieldTable[19] = "Temp Form Data.Created"

  coreExtrasModule.modelToIntSeqTable["Temp Queue Data"] = 3

  coreExtrasModule.intSeqToModelTable[3] = "Temp Queue Data"

  coreExtrasModule.fieldToIntSeqTable["Temp Queue Data.Temp Queue Data Id"] = 20
  coreExtrasModule.fieldToIntSeqTable["Temp Queue Data.Format"] = 21
  coreExtrasModule.fieldToIntSeqTable["Temp Queue Data.Data In"] = 22
  coreExtrasModule.fieldToIntSeqTable["Temp Queue Data.Data Out"] = 23
  coreExtrasModule.fieldToIntSeqTable["Temp Queue Data.Created"] = 24
  coreExtrasModule.fieldToIntSeqTable["Temp Queue Data.Fulfilled"] = 25

  coreExtrasModule.intSeqToFieldTable[20] = "Temp Queue Data.Temp Queue Data Id"
  coreExtrasModule.intSeqToFieldTable[21] = "Temp Queue Data.Format"
  coreExtrasModule.intSeqToFieldTable[22] = "Temp Queue Data.Data In"
  coreExtrasModule.intSeqToFieldTable[23] = "Temp Queue Data.Data Out"
  coreExtrasModule.intSeqToFieldTable[24] = "Temp Queue Data.Created"
  coreExtrasModule.intSeqToFieldTable[25] = "Temp Queue Data.Fulfilled"

  return coreExtrasModule

