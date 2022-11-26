# Nexus generated file
import db_postgres, options, tables, times


type
  AccountUser* = object
    accountUserId*: int64
    accountId*: Option[int64]
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
    accountUserRoleId*: int64
    accountUserId*: int64
    roleId*: int64
    created*: DateTime

  AccountUserRoles* = seq[AccountUserRole]


  AccountUserToken* = object
    accountUserId*: int64
    uniqueHash*: string
    token*: string
    created*: DateTime
    deleted*: Option[DateTime]

  AccountUserTokens* = seq[AccountUserToken]


  Invite* = object
    inviteId*: int64
    fromAccountUserId*: int64
    fromEmail*: string
    fromName*: string
    toEmail*: string
    toName*: string
    sent*: Option[DateTime]
    created*: DateTime

  Invites* = seq[Invite]


  NexusSetting* = object
    nexusSettingId*: int64
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

    cachedAccountUsers*: Table[int64, AccountUser]
    cachedFilterAccountUser*: Table[string, seq[int64]]


