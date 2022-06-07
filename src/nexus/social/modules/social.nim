import db_postgres, tables
import nexus/social/types/model_types


proc beginTransaction*(socialModule: SocialModule) =

  socialModule.db.exec(sql"begin")


proc commitTransaction*(socialModule: SocialModule) =

  socialModule.db.exec(sql"commit")


proc isInATransaction*(socialModule: SocialModule): bool =

  let row = getRow(
              socialModule.db,
              sql"select pg_current_xact_id_if_assigned()")

  if row[0] == "":
    return false

  else:
    return true


proc rollbackTransaction*(socialModule: SocialModule) =

  socialModule.db.exec(sql"rollback")


proc newSocialModule*(): SocialModule =

  var socialModule = SocialModule()

  socialModule.modelToIntSeqTable["SM Post"] = 0

  socialModule.intSeqToModelTable[0] = "SM Post"

  socialModule.fieldToIntSeqTable["SM Post.SM Post Id"] = 0
  socialModule.fieldToIntSeqTable["SM Post.SM Post Parent Id"] = 1
  socialModule.fieldToIntSeqTable["SM Post.Account User Id"] = 2
  socialModule.fieldToIntSeqTable["SM Post.Unique Hash"] = 3
  socialModule.fieldToIntSeqTable["SM Post.Post Type"] = 4
  socialModule.fieldToIntSeqTable["SM Post.Status"] = 5
  socialModule.fieldToIntSeqTable["SM Post.Title"] = 6
  socialModule.fieldToIntSeqTable["SM Post.Body"] = 7
  socialModule.fieldToIntSeqTable["SM Post.Tag Ids"] = 8
  socialModule.fieldToIntSeqTable["SM Post.Created"] = 9
  socialModule.fieldToIntSeqTable["SM Post.Published"] = 10
  socialModule.fieldToIntSeqTable["SM Post.Update Count"] = 11
  socialModule.fieldToIntSeqTable["SM Post.Updated"] = 12
  socialModule.fieldToIntSeqTable["SM Post.Deleted"] = 13

  socialModule.intSeqToFieldTable[0] = "SM Post.SM Post Id"
  socialModule.intSeqToFieldTable[1] = "SM Post.SM Post Parent Id"
  socialModule.intSeqToFieldTable[2] = "SM Post.Account User Id"
  socialModule.intSeqToFieldTable[3] = "SM Post.Unique Hash"
  socialModule.intSeqToFieldTable[4] = "SM Post.Post Type"
  socialModule.intSeqToFieldTable[5] = "SM Post.Status"
  socialModule.intSeqToFieldTable[6] = "SM Post.Title"
  socialModule.intSeqToFieldTable[7] = "SM Post.Body"
  socialModule.intSeqToFieldTable[8] = "SM Post.Tag Ids"
  socialModule.intSeqToFieldTable[9] = "SM Post.Created"
  socialModule.intSeqToFieldTable[10] = "SM Post.Published"
  socialModule.intSeqToFieldTable[11] = "SM Post.Update Count"
  socialModule.intSeqToFieldTable[12] = "SM Post.Updated"
  socialModule.intSeqToFieldTable[13] = "SM Post.Deleted"

  socialModule.modelToIntSeqTable["SM Post Vote"] = 1

  socialModule.intSeqToModelTable[1] = "SM Post Vote"

  socialModule.fieldToIntSeqTable["SM Post Vote.SM Post Id"] = 14
  socialModule.fieldToIntSeqTable["SM Post Vote.Votes Up Count"] = 15
  socialModule.fieldToIntSeqTable["SM Post Vote.Votes Down Count"] = 16

  socialModule.intSeqToFieldTable[14] = "SM Post Vote.SM Post Id"
  socialModule.intSeqToFieldTable[15] = "SM Post Vote.Votes Up Count"
  socialModule.intSeqToFieldTable[16] = "SM Post Vote.Votes Down Count"

  socialModule.modelToIntSeqTable["SM Post Vote User"] = 2

  socialModule.intSeqToModelTable[2] = "SM Post Vote User"

  socialModule.fieldToIntSeqTable["SM Post Vote User.SM Post Id"] = 17
  socialModule.fieldToIntSeqTable["SM Post Vote User.Account User Id"] = 18
  socialModule.fieldToIntSeqTable["SM Post Vote User.Vote Up"] = 19
  socialModule.fieldToIntSeqTable["SM Post Vote User.Vote Down"] = 20

  socialModule.intSeqToFieldTable[17] = "SM Post Vote User.SM Post Id"
  socialModule.intSeqToFieldTable[18] = "SM Post Vote User.Account User Id"
  socialModule.intSeqToFieldTable[19] = "SM Post Vote User.Vote Up"
  socialModule.intSeqToFieldTable[20] = "SM Post Vote User.Vote Down"

  return socialModule

