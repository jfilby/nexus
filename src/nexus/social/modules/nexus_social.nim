import db_postgres, tables
import nexus/social/types/model_types


proc beginTransaction*(nexusSocialDbContext: NexusSocialDbContext) =

  nexusSocialDbContext.dbConn.exec(sql"begin")


proc commitTransaction*(nexusSocialDbContext: NexusSocialDbContext) =

  nexusSocialDbContext.dbConn.exec(sql"commit")


proc isInATransaction*(nexusSocialDbContext: NexusSocialDbContext): bool =

  let row = getRow(
              nexusSocialDbContext.dbConn,
              sql"select pg_current_xact_id_if_assigned()")

  if row[0] == "":
    return false

  else:
    return true


proc rollbackTransaction*(nexusSocialDbContext: NexusSocialDbContext) =

  nexusSocialDbContext.dbConn.exec(sql"rollback")


proc newNexusSocialDbContext*(): NexusSocialDbContext =

  var nexusSocialDbContext = NexusSocialDbContext()

  nexusSocialDbContext.modelToIntSeqTable["SM Post"] = 0

  nexusSocialDbContext.intSeqToModelTable[0] = "SM Post"

  nexusSocialDbContext.fieldToIntSeqTable["SM Post.SM Post Id"] = 0
  nexusSocialDbContext.fieldToIntSeqTable["SM Post.SM Post Parent Id"] = 1
  nexusSocialDbContext.fieldToIntSeqTable["SM Post.Account User Id"] = 2
  nexusSocialDbContext.fieldToIntSeqTable["SM Post.Unique Hash"] = 3
  nexusSocialDbContext.fieldToIntSeqTable["SM Post.Post Type"] = 4
  nexusSocialDbContext.fieldToIntSeqTable["SM Post.Status"] = 5
  nexusSocialDbContext.fieldToIntSeqTable["SM Post.Title"] = 6
  nexusSocialDbContext.fieldToIntSeqTable["SM Post.Body"] = 7
  nexusSocialDbContext.fieldToIntSeqTable["SM Post.Tag Ids"] = 8
  nexusSocialDbContext.fieldToIntSeqTable["SM Post.Created"] = 9
  nexusSocialDbContext.fieldToIntSeqTable["SM Post.Published"] = 10
  nexusSocialDbContext.fieldToIntSeqTable["SM Post.Update Count"] = 11
  nexusSocialDbContext.fieldToIntSeqTable["SM Post.Updated"] = 12
  nexusSocialDbContext.fieldToIntSeqTable["SM Post.Deleted"] = 13

  nexusSocialDbContext.intSeqToFieldTable[0] = "SM Post.SM Post Id"
  nexusSocialDbContext.intSeqToFieldTable[1] = "SM Post.SM Post Parent Id"
  nexusSocialDbContext.intSeqToFieldTable[2] = "SM Post.Account User Id"
  nexusSocialDbContext.intSeqToFieldTable[3] = "SM Post.Unique Hash"
  nexusSocialDbContext.intSeqToFieldTable[4] = "SM Post.Post Type"
  nexusSocialDbContext.intSeqToFieldTable[5] = "SM Post.Status"
  nexusSocialDbContext.intSeqToFieldTable[6] = "SM Post.Title"
  nexusSocialDbContext.intSeqToFieldTable[7] = "SM Post.Body"
  nexusSocialDbContext.intSeqToFieldTable[8] = "SM Post.Tag Ids"
  nexusSocialDbContext.intSeqToFieldTable[9] = "SM Post.Created"
  nexusSocialDbContext.intSeqToFieldTable[10] = "SM Post.Published"
  nexusSocialDbContext.intSeqToFieldTable[11] = "SM Post.Update Count"
  nexusSocialDbContext.intSeqToFieldTable[12] = "SM Post.Updated"
  nexusSocialDbContext.intSeqToFieldTable[13] = "SM Post.Deleted"

  nexusSocialDbContext.modelToIntSeqTable["SM Post Vote"] = 1

  nexusSocialDbContext.intSeqToModelTable[1] = "SM Post Vote"

  nexusSocialDbContext.fieldToIntSeqTable["SM Post Vote.SM Post Id"] = 14
  nexusSocialDbContext.fieldToIntSeqTable["SM Post Vote.Votes Up Count"] = 15
  nexusSocialDbContext.fieldToIntSeqTable["SM Post Vote.Votes Down Count"] = 16

  nexusSocialDbContext.intSeqToFieldTable[14] = "SM Post Vote.SM Post Id"
  nexusSocialDbContext.intSeqToFieldTable[15] = "SM Post Vote.Votes Up Count"
  nexusSocialDbContext.intSeqToFieldTable[16] = "SM Post Vote.Votes Down Count"

  nexusSocialDbContext.modelToIntSeqTable["SM Post Vote User"] = 2

  nexusSocialDbContext.intSeqToModelTable[2] = "SM Post Vote User"

  nexusSocialDbContext.fieldToIntSeqTable["SM Post Vote User.SM Post Id"] = 17
  nexusSocialDbContext.fieldToIntSeqTable["SM Post Vote User.Account User Id"] = 18
  nexusSocialDbContext.fieldToIntSeqTable["SM Post Vote User.Vote Up"] = 19
  nexusSocialDbContext.fieldToIntSeqTable["SM Post Vote User.Vote Down"] = 20

  nexusSocialDbContext.intSeqToFieldTable[17] = "SM Post Vote User.SM Post Id"
  nexusSocialDbContext.intSeqToFieldTable[18] = "SM Post Vote User.Account User Id"
  nexusSocialDbContext.intSeqToFieldTable[19] = "SM Post Vote User.Vote Up"
  nexusSocialDbContext.intSeqToFieldTable[20] = "SM Post Vote User.Vote Down"

  return nexusSocialDbContext

