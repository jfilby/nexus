import db_postgres, tables
import nexus/social/types/model_types


proc beginTransaction*(nexusSocialModule: NexusSocialModule) =

  nexusSocialModule.db.exec(sql"begin")


proc commitTransaction*(nexusSocialModule: NexusSocialModule) =

  nexusSocialModule.db.exec(sql"commit")


proc isInATransaction*(nexusSocialModule: NexusSocialModule): bool =

  let row = getRow(
              nexusSocialModule.db,
              sql"select pg_current_xact_id_if_assigned()")

  if row[0] == "":
    return false

  else:
    return true


proc rollbackTransaction*(nexusSocialModule: NexusSocialModule) =

  nexusSocialModule.db.exec(sql"rollback")


proc newNexusSocialModule*(): NexusSocialModule =

  var nexusSocialModule = NexusSocialModule()

  nexusSocialModule.modelToIntSeqTable["SM Post"] = 0

  nexusSocialModule.intSeqToModelTable[0] = "SM Post"

  nexusSocialModule.fieldToIntSeqTable["SM Post.SM Post Id"] = 0
  nexusSocialModule.fieldToIntSeqTable["SM Post.SM Post Parent Id"] = 1
  nexusSocialModule.fieldToIntSeqTable["SM Post.Account User Id"] = 2
  nexusSocialModule.fieldToIntSeqTable["SM Post.Unique Hash"] = 3
  nexusSocialModule.fieldToIntSeqTable["SM Post.Post Type"] = 4
  nexusSocialModule.fieldToIntSeqTable["SM Post.Status"] = 5
  nexusSocialModule.fieldToIntSeqTable["SM Post.Title"] = 6
  nexusSocialModule.fieldToIntSeqTable["SM Post.Body"] = 7
  nexusSocialModule.fieldToIntSeqTable["SM Post.Tag Ids"] = 8
  nexusSocialModule.fieldToIntSeqTable["SM Post.Created"] = 9
  nexusSocialModule.fieldToIntSeqTable["SM Post.Published"] = 10
  nexusSocialModule.fieldToIntSeqTable["SM Post.Update Count"] = 11
  nexusSocialModule.fieldToIntSeqTable["SM Post.Updated"] = 12
  nexusSocialModule.fieldToIntSeqTable["SM Post.Deleted"] = 13

  nexusSocialModule.intSeqToFieldTable[0] = "SM Post.SM Post Id"
  nexusSocialModule.intSeqToFieldTable[1] = "SM Post.SM Post Parent Id"
  nexusSocialModule.intSeqToFieldTable[2] = "SM Post.Account User Id"
  nexusSocialModule.intSeqToFieldTable[3] = "SM Post.Unique Hash"
  nexusSocialModule.intSeqToFieldTable[4] = "SM Post.Post Type"
  nexusSocialModule.intSeqToFieldTable[5] = "SM Post.Status"
  nexusSocialModule.intSeqToFieldTable[6] = "SM Post.Title"
  nexusSocialModule.intSeqToFieldTable[7] = "SM Post.Body"
  nexusSocialModule.intSeqToFieldTable[8] = "SM Post.Tag Ids"
  nexusSocialModule.intSeqToFieldTable[9] = "SM Post.Created"
  nexusSocialModule.intSeqToFieldTable[10] = "SM Post.Published"
  nexusSocialModule.intSeqToFieldTable[11] = "SM Post.Update Count"
  nexusSocialModule.intSeqToFieldTable[12] = "SM Post.Updated"
  nexusSocialModule.intSeqToFieldTable[13] = "SM Post.Deleted"

  nexusSocialModule.modelToIntSeqTable["SM Post Vote"] = 1

  nexusSocialModule.intSeqToModelTable[1] = "SM Post Vote"

  nexusSocialModule.fieldToIntSeqTable["SM Post Vote.SM Post Id"] = 14
  nexusSocialModule.fieldToIntSeqTable["SM Post Vote.Votes Up Count"] = 15
  nexusSocialModule.fieldToIntSeqTable["SM Post Vote.Votes Down Count"] = 16

  nexusSocialModule.intSeqToFieldTable[14] = "SM Post Vote.SM Post Id"
  nexusSocialModule.intSeqToFieldTable[15] = "SM Post Vote.Votes Up Count"
  nexusSocialModule.intSeqToFieldTable[16] = "SM Post Vote.Votes Down Count"

  nexusSocialModule.modelToIntSeqTable["SM Post Vote User"] = 2

  nexusSocialModule.intSeqToModelTable[2] = "SM Post Vote User"

  nexusSocialModule.fieldToIntSeqTable["SM Post Vote User.SM Post Id"] = 17
  nexusSocialModule.fieldToIntSeqTable["SM Post Vote User.Account User Id"] = 18
  nexusSocialModule.fieldToIntSeqTable["SM Post Vote User.Vote Up"] = 19
  nexusSocialModule.fieldToIntSeqTable["SM Post Vote User.Vote Down"] = 20

  nexusSocialModule.intSeqToFieldTable[17] = "SM Post Vote User.SM Post Id"
  nexusSocialModule.intSeqToFieldTable[18] = "SM Post Vote User.Account User Id"
  nexusSocialModule.intSeqToFieldTable[19] = "SM Post Vote User.Vote Up"
  nexusSocialModule.intSeqToFieldTable[20] = "SM Post Vote User.Vote Down"

  return nexusSocialModule

