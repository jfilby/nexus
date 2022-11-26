# Nexus generated file
import db_postgres, options, tables, times


type
  ListItem* = object
    listItemId*: int64
    parentListItemId*: Option[int64]
    seqNo*: int
    name*: string
    displayName*: string
    description*: Option[string]
    created*: DateTime

  ListItems* = seq[ListItem]


  MenuItem* = object
    menuItemId*: int64
    parentMenuItemId*: Option[int64]
    name*: string
    url*: string
    screen*: string
    level*: int
    position*: int
    roleIds*: Option[seq[int64]]
    created*: DateTime

  MenuItems* = seq[MenuItem]


  TempFormData* = object
    token*: string
    format*: string
    data*: string
    created*: DateTime

  TempFormDatas* = seq[TempFormData]


  TempQueueData* = object
    tempQueueDataId*: int64
    format*: string
    dataIn*: string
    dataOut*: Option[string]
    created*: DateTime
    fulfilled*: DateTime

  TempQueueDatas* = seq[TempQueueData]


  NexusCoreExtrasDbContext* = object
    dbConn*: DbConn
    modelToIntSeqTable*: Table[string, int]
    intSeqToModelTable*: Table[int, string]
    fieldToIntSeqTable*: Table[string, int]
    intSeqToFieldTable*: Table[int, string]


