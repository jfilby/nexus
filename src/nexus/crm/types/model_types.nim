# Nexus generated file
import db_connector/db_postgres, options, tables, times


type
  MailingList* = object
    id*: string
    accountUserId*: string
    uniqueHash*: string
    name*: string
    created*: DateTime
    deleted*: Option[DateTime]

  MailingLists* = seq[MailingList]


  MailingListMessage* = object
    id*: string
    accountUserId*: string
    uniqueHash*: string
    subject*: string
    message*: string
    created*: DateTime
    updated*: Option[DateTime]
    deleted*: Option[DateTime]

  MailingListMessages* = seq[MailingListMessage]


  MailingListSubscriber* = object
    id*: string
    accountUserId*: Option[string]
    mailingListId*: string
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
    id*: string
    accountUserId*: Option[string]
    mailingListId*: string
    mailingListSubscriberId*: string
    mailingListMessageId*: string
    created*: DateTime

  MailingListSubscriberMessages* = seq[MailingListSubscriberMessage]


  NexusCRMDbContext* = object
    dbConn*: DbConn
    modelToIntSeqTable*: Table[string, int]
    intSeqToModelTable*: Table[int, string]
    fieldToIntSeqTable*: Table[string, int]
    intSeqToFieldTable*: Table[int, string]


