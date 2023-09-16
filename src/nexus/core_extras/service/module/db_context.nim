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

  dbContext.modelToIntSeqTable["Cached Key Value"] = 0

  dbContext.intSeqToModelTable[0] = "Cached Key Value"

  dbContext.fieldToIntSeqTable["Cached Key Value.Id"] = 0
  dbContext.fieldToIntSeqTable["Cached Key Value.Key"] = 1
  dbContext.fieldToIntSeqTable["Cached Key Value.Value"] = 2
  dbContext.fieldToIntSeqTable["Cached Key Value.Created"] = 3
  dbContext.fieldToIntSeqTable["Cached Key Value.Updated"] = 4
  dbContext.fieldToIntSeqTable["Cached Key Value.Expires"] = 5

  dbContext.intSeqToFieldTable[0] = "Cached Key Value.Id"
  dbContext.intSeqToFieldTable[1] = "Cached Key Value.Key"
  dbContext.intSeqToFieldTable[2] = "Cached Key Value.Value"
  dbContext.intSeqToFieldTable[3] = "Cached Key Value.Created"
  dbContext.intSeqToFieldTable[4] = "Cached Key Value.Updated"
  dbContext.intSeqToFieldTable[5] = "Cached Key Value.Expires"

  dbContext.modelToIntSeqTable["List Item"] = 1

  dbContext.intSeqToModelTable[1] = "List Item"

  dbContext.fieldToIntSeqTable["List Item.Id"] = 6
  dbContext.fieldToIntSeqTable["List Item.Parent Id"] = 7
  dbContext.fieldToIntSeqTable["List Item.Seq No"] = 8
  dbContext.fieldToIntSeqTable["List Item.Name"] = 9
  dbContext.fieldToIntSeqTable["List Item.Display Name"] = 10
  dbContext.fieldToIntSeqTable["List Item.Description"] = 11
  dbContext.fieldToIntSeqTable["List Item.Created"] = 12

  dbContext.intSeqToFieldTable[6] = "List Item.Id"
  dbContext.intSeqToFieldTable[7] = "List Item.Parent Id"
  dbContext.intSeqToFieldTable[8] = "List Item.Seq No"
  dbContext.intSeqToFieldTable[9] = "List Item.Name"
  dbContext.intSeqToFieldTable[10] = "List Item.Display Name"
  dbContext.intSeqToFieldTable[11] = "List Item.Description"
  dbContext.intSeqToFieldTable[12] = "List Item.Created"

  dbContext.modelToIntSeqTable["Menu Item"] = 2

  dbContext.intSeqToModelTable[2] = "Menu Item"

  dbContext.fieldToIntSeqTable["Menu Item.Id"] = 13
  dbContext.fieldToIntSeqTable["Menu Item.Parent Id"] = 14
  dbContext.fieldToIntSeqTable["Menu Item.Name"] = 15
  dbContext.fieldToIntSeqTable["Menu Item.URL"] = 16
  dbContext.fieldToIntSeqTable["Menu Item.Screen"] = 17
  dbContext.fieldToIntSeqTable["Menu Item.Level"] = 18
  dbContext.fieldToIntSeqTable["Menu Item.Position"] = 19
  dbContext.fieldToIntSeqTable["Menu Item.Role Ids"] = 20
  dbContext.fieldToIntSeqTable["Menu Item.Created"] = 21

  dbContext.intSeqToFieldTable[13] = "Menu Item.Id"
  dbContext.intSeqToFieldTable[14] = "Menu Item.Parent Id"
  dbContext.intSeqToFieldTable[15] = "Menu Item.Name"
  dbContext.intSeqToFieldTable[16] = "Menu Item.URL"
  dbContext.intSeqToFieldTable[17] = "Menu Item.Screen"
  dbContext.intSeqToFieldTable[18] = "Menu Item.Level"
  dbContext.intSeqToFieldTable[19] = "Menu Item.Position"
  dbContext.intSeqToFieldTable[20] = "Menu Item.Role Ids"
  dbContext.intSeqToFieldTable[21] = "Menu Item.Created"

  dbContext.modelToIntSeqTable["Temp Form Data"] = 3

  dbContext.intSeqToModelTable[3] = "Temp Form Data"

  dbContext.fieldToIntSeqTable["Temp Form Data.Token"] = 22
  dbContext.fieldToIntSeqTable["Temp Form Data.Format"] = 23
  dbContext.fieldToIntSeqTable["Temp Form Data.Data"] = 24
  dbContext.fieldToIntSeqTable["Temp Form Data.Created"] = 25

  dbContext.intSeqToFieldTable[22] = "Temp Form Data.Token"
  dbContext.intSeqToFieldTable[23] = "Temp Form Data.Format"
  dbContext.intSeqToFieldTable[24] = "Temp Form Data.Data"
  dbContext.intSeqToFieldTable[25] = "Temp Form Data.Created"

  dbContext.modelToIntSeqTable["Temp Queue Data"] = 4

  dbContext.intSeqToModelTable[4] = "Temp Queue Data"

  dbContext.fieldToIntSeqTable["Temp Queue Data.Temp Queue Data Id"] = 26
  dbContext.fieldToIntSeqTable["Temp Queue Data.Format"] = 27
  dbContext.fieldToIntSeqTable["Temp Queue Data.Data In"] = 28
  dbContext.fieldToIntSeqTable["Temp Queue Data.Data Out"] = 29
  dbContext.fieldToIntSeqTable["Temp Queue Data.Created"] = 30
  dbContext.fieldToIntSeqTable["Temp Queue Data.Fulfilled"] = 31

  dbContext.intSeqToFieldTable[26] = "Temp Queue Data.Temp Queue Data Id"
  dbContext.intSeqToFieldTable[27] = "Temp Queue Data.Format"
  dbContext.intSeqToFieldTable[28] = "Temp Queue Data.Data In"
  dbContext.intSeqToFieldTable[29] = "Temp Queue Data.Data Out"
  dbContext.intSeqToFieldTable[30] = "Temp Queue Data.Created"
  dbContext.intSeqToFieldTable[31] = "Temp Queue Data.Fulfilled"

  dbContext.modelToIntSeqTable["Country Timezone"] = 5

  dbContext.intSeqToModelTable[5] = "Country Timezone"

  dbContext.fieldToIntSeqTable["Country Timezone.Country Code"] = 32
  dbContext.fieldToIntSeqTable["Country Timezone.Timezone"] = 33
  dbContext.fieldToIntSeqTable["Country Timezone.Created"] = 34

  dbContext.intSeqToFieldTable[32] = "Country Timezone.Country Code"
  dbContext.intSeqToFieldTable[33] = "Country Timezone.Timezone"
  dbContext.intSeqToFieldTable[34] = "Country Timezone.Created"

  return dbContext

