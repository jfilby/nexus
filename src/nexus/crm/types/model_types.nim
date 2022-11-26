# Nexus generated file
import db_postgres, options, tables, times


type
  MailingList* = object
    mailingListId*: int64
    accountUserId*: int64
    uniqueHash*: string
    name*: string
    created*: DateTime
    deleted*: Option[DateTime]

  MailingLists* = seq[MailingList]


  MailingListMessage* = object
    mailingListMessageId*: int64
    accountUserId*: int64
    uniqueHash*: string
    subject*: string
    message*: string
    created*: DateTime
    updated*: Option[DateTime]
    deleted*: Option[DateTime]

  MailingListMessages* = seq[MailingListMessage]


  MailingListSubscriber* = object
    mailingListSubscriberId*: int64
    accountUserId*: Option[int64]
    mailingListId*: int64
    uniqueHash*: string
    isActive*: bool
    email*: string
    name*: Option[string]
    verificationCode*: Option[string]
    isVerified*: bool
    created*: DateTime
    deleted*: Option[DateTime]

  MailingListSubscribers* = seq[MailingListSubscriber]


  MailingListSubscriberMessage* = object
    mailingListSubscriberMessageId*: int64
    accountUserId*: Option[int64]
    mailingListId*: int64
    mailingListSubscriberId*: int64
    mailingListMessageId*: int64
    created*: DateTime

  MailingListSubscriberMessages* = seq[MailingListSubscriberMessage]


  NexusCRMDbContext* = object
    dbConn*: DbConn
    modelToIntSeqTable*: Table[string, int]
    intSeqToModelTable*: Table[int, string]
    fieldToIntSeqTable*: Table[string, int]
    intSeqToFieldTable*: Table[int, string]


