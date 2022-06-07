# Nexus generated file
import db_postgres, options, json, tables, times


type
  MailingList* = object
    mailingListId*: int64
    mailingListIdStr*: string
    accountUserId*: int64
    accountUserIdStr*: string
    uniqueHash*: string
    name*: string
    created*: DateTime
    createdStr*: string
    deleted*: Option[DateTime]
    deletedStr*: string

  MailingLists* = seq[MailingList]


  MailingListMessage* = object
    mailingListMessageId*: int64
    mailingListMessageIdStr*: string
    accountUserId*: int64
    accountUserIdStr*: string
    uniqueHash*: string
    subject*: string
    message*: string
    created*: DateTime
    createdStr*: string
    updated*: Option[DateTime]
    updatedStr*: string
    deleted*: Option[DateTime]
    deletedStr*: string

  MailingListMessages* = seq[MailingListMessage]


  MailingListSubscriber* = object
    mailingListSubscriberId*: int64
    mailingListSubscriberIdStr*: string
    accountUserId*: Option[int64]
    accountUserIdStr*: string
    mailingListId*: int64
    mailingListIdStr*: string
    uniqueHash*: string
    isActive*: bool
    isActiveStr*: string
    email*: string
    name*: Option[string]
    verificationCode*: Option[string]
    isVerified*: bool
    isVerifiedStr*: string
    created*: DateTime
    createdStr*: string
    deleted*: Option[DateTime]
    deletedStr*: string

  MailingListSubscribers* = seq[MailingListSubscriber]


  MailingListSubscriberMessage* = object
    mailingListSubscriberMessageId*: int64
    mailingListSubscriberMessageIdStr*: string
    accountUserId*: Option[int64]
    accountUserIdStr*: string
    mailingListId*: int64
    mailingListIdStr*: string
    mailingListSubscriberId*: int64
    mailingListSubscriberIdStr*: string
    mailingListMessageId*: int64
    mailingListMessageIdStr*: string
    created*: DateTime
    createdStr*: string

  MailingListSubscriberMessages* = seq[MailingListSubscriberMessage]


  NexusCRMModule* = object
    db*: DbConn
    modelToIntSeqTable*: Table[string, int]
    intSeqToModelTable*: Table[int, string]
    fieldToIntSeqTable*: Table[string, int]
    intSeqToFieldTable*: Table[int, string]


