# Nexus generated file
import db_connector/db_postgres, options, tables, times


type
  CachedKeyValue* = object
    id*: string
    key*: string
    value*: string
    created*: DateTime
    updated*: Option[DateTime]
    expires*: Option[DateTime]

  CachedKeyValues* = seq[CachedKeyValue]


  ListItem* = object
    id*: string
    parentId*: Option[string]
    seqNo*: int
    name*: string
    displayName*: string
    description*: Option[string]
    created*: DateTime

  ListItems* = seq[ListItem]


  MenuItem* = object
    id*: string
    parentId*: Option[string]
    name*: string
    url*: string
    screen*: string
    level*: int
    position*: int
    roleIds*: Option[seq[string]]
    created*: DateTime

  MenuItems* = seq[MenuItem]


  TempFormData* = object
    token*: string
    format*: string
    data*: string
    created*: DateTime

  TempFormDatas* = seq[TempFormData]


  TempQueueData* = object
    tempQueueDataId*: string
    format*: string
    dataIn*: string
    dataOut*: Option[string]
    created*: DateTime
    fulfilled*: DateTime

  TempQueueDatas* = seq[TempQueueData]


  CountryTimezone* = object
    countryCode*: string
    timezone*: string
    created*: DateTime

  CountryTimezones* = seq[CountryTimezone]


  NexusCoreExtrasDbContext* = object
    dbConn*: DbConn
    modelToIntSeqTable*: Table[string, int]
    intSeqToModelTable*: Table[int, string]
    fieldToIntSeqTable*: Table[string, int]
    intSeqToFieldTable*: Table[int, string]


