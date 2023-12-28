# Nexus generated file
import db_connector/db_postgres, options, tables, times


type
  AccountUser* = object
    id*: string
    accountId*: Option[string]
    name*: string
    email*: string
    passwordHash*: string
    passwordSalt*: string
    apiKey*: string
    lastToken*: Option[string]
    signUpCode*: string
    signUpDate*: DateTime
    passwordResetCode*: Option[string]
    passwordResetDate*: Option[DateTime]
    isActive*: bool
    isAdmin*: bool
    isVerified*: bool
    subscriptionStatus*: Option[char]
    lastLogin*: Option[DateTime]
    lastUpdate*: Option[DateTime]
    created*: DateTime

  AccountUsers* = seq[AccountUser]


  AccountUserRole* = object
    id*: string
    accountUserId*: string
    roleId*: string
    created*: DateTime

  AccountUserRoles* = seq[AccountUserRole]


  AccountUserToken* = object
    accountUserId*: string
    uniqueHash*: string
    token*: string
    created*: DateTime
    deleted*: Option[DateTime]

  AccountUserTokens* = seq[AccountUserToken]


  Invite* = object
    id*: string
    fromAccountUserId*: string
    fromEmail*: string
    fromName*: string
    toEmail*: string
    toName*: string
    sent*: Option[DateTime]
    created*: DateTime

  Invites* = seq[Invite]


  NexusSetting* = object
    id*: string
    module*: string
    key*: string
    value*: Option[string]
    created*: DateTime

  NexusSettings* = seq[NexusSetting]


  NexusCoreDbContext* = object
    dbConn*: DbConn
    modelToIntSeqTable*: Table[string, int]
    intSeqToModelTable*: Table[int, string]
    fieldToIntSeqTable*: Table[string, int]
    intSeqToFieldTable*: Table[int, string]

    cachedAccountUsers*: Table[string, AccountUser]
    cachedFilterAccountUser*: Table[string, seq[string]]


