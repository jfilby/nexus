import db_postgres, tables
import nexus/core_extras/types/model_types


proc beginTransaction*(nexusCoreExtrasModule: NexusCoreExtrasModule) =

  nexusCoreExtrasModule.db.exec(sql"begin")


proc commitTransaction*(nexusCoreExtrasModule: NexusCoreExtrasModule) =

  nexusCoreExtrasModule.db.exec(sql"commit")


proc isInATransaction*(nexusCoreExtrasModule: NexusCoreExtrasModule): bool =

  let row = getRow(
              nexusCoreExtrasModule.db,
              sql"select pg_current_xact_id_if_assigned()")

  if row[0] == "":
    return false

  else:
    return true


proc rollbackTransaction*(nexusCoreExtrasModule: NexusCoreExtrasModule) =

  nexusCoreExtrasModule.db.exec(sql"rollback")


proc newNexusCoreExtrasModule*(): NexusCoreExtrasModule =

  var nexusCoreExtrasModule = NexusCoreExtrasModule()

  nexusCoreExtrasModule.modelToIntSeqTable["List Item"] = 0

  nexusCoreExtrasModule.intSeqToModelTable[0] = "List Item"

  nexusCoreExtrasModule.fieldToIntSeqTable["List Item.List Item Id"] = 0
  nexusCoreExtrasModule.fieldToIntSeqTable["List Item.Parent List Item Id"] = 1
  nexusCoreExtrasModule.fieldToIntSeqTable["List Item.Seq No"] = 2
  nexusCoreExtrasModule.fieldToIntSeqTable["List Item.Name"] = 3
  nexusCoreExtrasModule.fieldToIntSeqTable["List Item.Display Name"] = 4
  nexusCoreExtrasModule.fieldToIntSeqTable["List Item.Description"] = 5
  nexusCoreExtrasModule.fieldToIntSeqTable["List Item.Created"] = 6

  nexusCoreExtrasModule.intSeqToFieldTable[0] = "List Item.List Item Id"
  nexusCoreExtrasModule.intSeqToFieldTable[1] = "List Item.Parent List Item Id"
  nexusCoreExtrasModule.intSeqToFieldTable[2] = "List Item.Seq No"
  nexusCoreExtrasModule.intSeqToFieldTable[3] = "List Item.Name"
  nexusCoreExtrasModule.intSeqToFieldTable[4] = "List Item.Display Name"
  nexusCoreExtrasModule.intSeqToFieldTable[5] = "List Item.Description"
  nexusCoreExtrasModule.intSeqToFieldTable[6] = "List Item.Created"

  nexusCoreExtrasModule.modelToIntSeqTable["Menu Item"] = 1

  nexusCoreExtrasModule.intSeqToModelTable[1] = "Menu Item"

  nexusCoreExtrasModule.fieldToIntSeqTable["Menu Item.Menu Item Id"] = 7
  nexusCoreExtrasModule.fieldToIntSeqTable["Menu Item.Parent Menu Item Id"] = 8
  nexusCoreExtrasModule.fieldToIntSeqTable["Menu Item.Name"] = 9
  nexusCoreExtrasModule.fieldToIntSeqTable["Menu Item.URL"] = 10
  nexusCoreExtrasModule.fieldToIntSeqTable["Menu Item.Screen"] = 11
  nexusCoreExtrasModule.fieldToIntSeqTable["Menu Item.Level"] = 12
  nexusCoreExtrasModule.fieldToIntSeqTable["Menu Item.Position"] = 13
  nexusCoreExtrasModule.fieldToIntSeqTable["Menu Item.Role Ids"] = 14
  nexusCoreExtrasModule.fieldToIntSeqTable["Menu Item.Created"] = 15

  nexusCoreExtrasModule.intSeqToFieldTable[7] = "Menu Item.Menu Item Id"
  nexusCoreExtrasModule.intSeqToFieldTable[8] = "Menu Item.Parent Menu Item Id"
  nexusCoreExtrasModule.intSeqToFieldTable[9] = "Menu Item.Name"
  nexusCoreExtrasModule.intSeqToFieldTable[10] = "Menu Item.URL"
  nexusCoreExtrasModule.intSeqToFieldTable[11] = "Menu Item.Screen"
  nexusCoreExtrasModule.intSeqToFieldTable[12] = "Menu Item.Level"
  nexusCoreExtrasModule.intSeqToFieldTable[13] = "Menu Item.Position"
  nexusCoreExtrasModule.intSeqToFieldTable[14] = "Menu Item.Role Ids"
  nexusCoreExtrasModule.intSeqToFieldTable[15] = "Menu Item.Created"

  nexusCoreExtrasModule.modelToIntSeqTable["Temp Form Data"] = 2

  nexusCoreExtrasModule.intSeqToModelTable[2] = "Temp Form Data"

  nexusCoreExtrasModule.fieldToIntSeqTable["Temp Form Data.Token"] = 16
  nexusCoreExtrasModule.fieldToIntSeqTable["Temp Form Data.Format"] = 17
  nexusCoreExtrasModule.fieldToIntSeqTable["Temp Form Data.Data"] = 18
  nexusCoreExtrasModule.fieldToIntSeqTable["Temp Form Data.Created"] = 19

  nexusCoreExtrasModule.intSeqToFieldTable[16] = "Temp Form Data.Token"
  nexusCoreExtrasModule.intSeqToFieldTable[17] = "Temp Form Data.Format"
  nexusCoreExtrasModule.intSeqToFieldTable[18] = "Temp Form Data.Data"
  nexusCoreExtrasModule.intSeqToFieldTable[19] = "Temp Form Data.Created"

  nexusCoreExtrasModule.modelToIntSeqTable["Temp Queue Data"] = 3

  nexusCoreExtrasModule.intSeqToModelTable[3] = "Temp Queue Data"

  nexusCoreExtrasModule.fieldToIntSeqTable["Temp Queue Data.Temp Queue Data Id"] = 20
  nexusCoreExtrasModule.fieldToIntSeqTable["Temp Queue Data.Format"] = 21
  nexusCoreExtrasModule.fieldToIntSeqTable["Temp Queue Data.Data In"] = 22
  nexusCoreExtrasModule.fieldToIntSeqTable["Temp Queue Data.Data Out"] = 23
  nexusCoreExtrasModule.fieldToIntSeqTable["Temp Queue Data.Created"] = 24
  nexusCoreExtrasModule.fieldToIntSeqTable["Temp Queue Data.Fulfilled"] = 25

  nexusCoreExtrasModule.intSeqToFieldTable[20] = "Temp Queue Data.Temp Queue Data Id"
  nexusCoreExtrasModule.intSeqToFieldTable[21] = "Temp Queue Data.Format"
  nexusCoreExtrasModule.intSeqToFieldTable[22] = "Temp Queue Data.Data In"
  nexusCoreExtrasModule.intSeqToFieldTable[23] = "Temp Queue Data.Data Out"
  nexusCoreExtrasModule.intSeqToFieldTable[24] = "Temp Queue Data.Created"
  nexusCoreExtrasModule.intSeqToFieldTable[25] = "Temp Queue Data.Fulfilled"

  return nexusCoreExtrasModule

