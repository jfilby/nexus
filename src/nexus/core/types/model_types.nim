# Nexus generated file
import db_postgres, tables, times, options


type
  AccountUser* = object
    accountUserId*: int64
    accountUserIdStr*: string
    accountId*: Option[int64]
    accountIdStr*: string
    name*: string
    email*: string
    passwordHash*: string
    passwordSalt*: string
    apiKey*: string
    lastToken*: Option[string]
    signUpCode*: string
    signUpDate*: DateTime
    signUpDateStr*: string
    passwordResetCode*: Option[string]
    passwordResetDate*: Option[DateTime]
    passwordResetDateStr*: string
    isActive*: bool
    isActiveStr*: string
    isAdmin*: bool
    isAdminStr*: string
    isVerified*: bool
    isVerifiedStr*: string
    subscriptionStatus*: Option[char]
    subscriptionStatusStr*: string
    lastLogin*: Option[DateTime]
    lastLoginStr*: string
    lastUpdate*: Option[DateTime]
    lastUpdateStr*: string
    created*: DateTime
    createdStr*: string

  AccountUsers* = seq[AccountUser]


  AccountUserRole* = object
    accountUserRoleId*: int64
    accountUserRoleIdStr*: string
    accountUserId*: int64
    accountUserIdStr*: string
    roleId*: int64
    roleIdStr*: string
    created*: DateTime
    createdStr*: string

  AccountUserRoles* = seq[AccountUserRole]


  AccountUserToken* = object
    accountUserId*: int64
    accountUserIdStr*: string
    uniqueHash*: string
    token*: string
    created*: DateTime
    createdStr*: string
    deleted*: Option[DateTime]
    deletedStr*: string

  AccountUserTokens* = seq[AccountUserToken]


  Invite* = object
    inviteId*: int64
    inviteIdStr*: string
    fromAccountUserId*: int64
    fromAccountUserIdStr*: string
    fromEmail*: string
    fromName*: string
    toEmail*: string
    toName*: string
    sent*: Option[DateTime]
    sentStr*: string
    created*: DateTime
    createdStr*: string

  Invites* = seq[Invite]


  NexusSetting* = object
    nexusSettingId*: int64
    nexusSettingIdStr*: string
    module*: string
    key*: string
    value*: Option[string]
    created*: DateTime
    createdStr*: string

  NexusSettings* = seq[NexusSetting]


  NexusCoreDbContext* = object
    dbConn*: DbConn
    modelToIntSeqTable*: Table[string, int]
    intSeqToModelTable*: Table[int, string]
    fieldToIntSeqTable*: Table[string, int]
    intSeqToFieldTable*: Table[int, string]

    cachedAccountUsers*: Table[int64, AccountUser]
    cachedFilterAccountUser*: Table[string, seq[int64]]


