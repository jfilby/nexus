# Nexus generated file
import db_postgres, options, json, tables, times


type
  ListItem* = object
    listItemId*: int64
    listItemIdStr*: string
    parentListItemId*: Option[int64]
    parentListItemIdStr*: string
    seqNo*: int
    seqNoStr*: string
    name*: string
    displayName*: string
    description*: Option[string]
    created*: DateTime
    createdStr*: string

  ListItems* = seq[ListItem]


  MenuItem* = object
    menuItemId*: int64
    menuItemIdStr*: string
    parentMenuItemId*: Option[int64]
    parentMenuItemIdStr*: string
    name*: string
    url*: string
    screen*: string
    level*: int
    levelStr*: string
    position*: int
    positionStr*: string
    roleIds*: Option[seq[int64]]
    roleIdsStr*: string
    created*: DateTime
    createdStr*: string

  MenuItems* = seq[MenuItem]


  TempFormData* = object
    token*: string
    format*: string
    data*: string
    created*: DateTime
    createdStr*: string

  TempFormDatas* = seq[TempFormData]


  TempQueueData* = object
    tempQueueDataId*: int64
    tempQueueDataIdStr*: string
    format*: string
    dataIn*: string
    dataOut*: Option[string]
    created*: DateTime
    createdStr*: string
    fulfilled*: DateTime
    fulfilledStr*: string

  TempQueueDatas* = seq[TempQueueData]


  NexusCoreExtrasModule* = object
    db*: DbConn
    modelToIntSeqTable*: Table[string, int]
    intSeqToModelTable*: Table[int, string]
    fieldToIntSeqTable*: Table[string, int]
    intSeqToFieldTable*: Table[int, string]


