import tables
import db_connector/db_postgres
import nexus/social/types/model_types


proc beginTransaction*(dbContext: NexusSocialDbContext) =

  dbContext.dbConn.exec(sql"begin")


proc commitTransaction*(dbContext: NexusSocialDbContext) =

  dbContext.dbConn.exec(sql"commit")


proc isInATransaction*(dbContext: NexusSocialDbContext): bool =

  let row = getRow(
              dbContext.dbConn,
              sql"select pg_current_xact_id_if_assigned()")

  if row[0] == "":
    return false

  else:
    return true


proc rollbackTransaction*(dbContext: NexusSocialDbContext) =

  dbContext.dbConn.exec(sql"rollback")


proc newNexusSocialDbContext*(): NexusSocialDbContext =

  var dbContext = NexusSocialDbContext()

  dbContext.modelToIntSeqTable["SM Post"] = 0

  dbContext.intSeqToModelTable[0] = "SM Post"

  dbContext.fieldToIntSeqTable["SM Post.Id"] = 0
  dbContext.fieldToIntSeqTable["SM Post.Parent Id"] = 1
  dbContext.fieldToIntSeqTable["SM Post.Account User Id"] = 2
  dbContext.fieldToIntSeqTable["SM Post.Unique Hash"] = 3
  dbContext.fieldToIntSeqTable["SM Post.Post Type"] = 4
  dbContext.fieldToIntSeqTable["SM Post.Status"] = 5
  dbContext.fieldToIntSeqTable["SM Post.Title"] = 6
  dbContext.fieldToIntSeqTable["SM Post.Body"] = 7
  dbContext.fieldToIntSeqTable["SM Post.Tag Ids"] = 8
  dbContext.fieldToIntSeqTable["SM Post.Created"] = 9
  dbContext.fieldToIntSeqTable["SM Post.Published"] = 10
  dbContext.fieldToIntSeqTable["SM Post.Update Count"] = 11
  dbContext.fieldToIntSeqTable["SM Post.Updated"] = 12
  dbContext.fieldToIntSeqTable["SM Post.Deleted"] = 13

  dbContext.intSeqToFieldTable[0] = "SM Post.Id"
  dbContext.intSeqToFieldTable[1] = "SM Post.Parent Id"
  dbContext.intSeqToFieldTable[2] = "SM Post.Account User Id"
  dbContext.intSeqToFieldTable[3] = "SM Post.Unique Hash"
  dbContext.intSeqToFieldTable[4] = "SM Post.Post Type"
  dbContext.intSeqToFieldTable[5] = "SM Post.Status"
  dbContext.intSeqToFieldTable[6] = "SM Post.Title"
  dbContext.intSeqToFieldTable[7] = "SM Post.Body"
  dbContext.intSeqToFieldTable[8] = "SM Post.Tag Ids"
  dbContext.intSeqToFieldTable[9] = "SM Post.Created"
  dbContext.intSeqToFieldTable[10] = "SM Post.Published"
  dbContext.intSeqToFieldTable[11] = "SM Post.Update Count"
  dbContext.intSeqToFieldTable[12] = "SM Post.Updated"
  dbContext.intSeqToFieldTable[13] = "SM Post.Deleted"

  dbContext.modelToIntSeqTable["SM Post Vote"] = 1

  dbContext.intSeqToModelTable[1] = "SM Post Vote"

  dbContext.fieldToIntSeqTable["SM Post Vote.SM Post Id"] = 14
  dbContext.fieldToIntSeqTable["SM Post Vote.Votes Up Count"] = 15
  dbContext.fieldToIntSeqTable["SM Post Vote.Votes Down Count"] = 16

  dbContext.intSeqToFieldTable[14] = "SM Post Vote.SM Post Id"
  dbContext.intSeqToFieldTable[15] = "SM Post Vote.Votes Up Count"
  dbContext.intSeqToFieldTable[16] = "SM Post Vote.Votes Down Count"

  dbContext.modelToIntSeqTable["SM Post Vote User"] = 2

  dbContext.intSeqToModelTable[2] = "SM Post Vote User"

  dbContext.fieldToIntSeqTable["SM Post Vote User.SM Post Id"] = 17
  dbContext.fieldToIntSeqTable["SM Post Vote User.Account User Id"] = 18
  dbContext.fieldToIntSeqTable["SM Post Vote User.Vote Up"] = 19
  dbContext.fieldToIntSeqTable["SM Post Vote User.Vote Down"] = 20

  dbContext.intSeqToFieldTable[17] = "SM Post Vote User.SM Post Id"
  dbContext.intSeqToFieldTable[18] = "SM Post Vote User.Account User Id"
  dbContext.intSeqToFieldTable[19] = "SM Post Vote User.Vote Up"
  dbContext.intSeqToFieldTable[20] = "SM Post Vote User.Vote Down"

  return dbContext

