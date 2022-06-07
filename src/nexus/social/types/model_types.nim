# Nexus generated file
import db_postgres, options, json, tables, times


type
  SMPost* = object
    smPostId*: int64
    smPostIdStr*: string
    smPostParentId*: Option[int64]
    smPostParentIdStr*: string
    accountUserId*: int64
    accountUserIdStr*: string
    uniqueHash*: string
    postType*: char
    postTypeStr*: string
    status*: char
    statusStr*: string
    title*: Option[string]
    body*: string
    tagIds*: Option[int64]
    tagIdsStr*: string
    created*: DateTime
    createdStr*: string
    published*: Option[DateTime]
    publishedStr*: string
    updateCount*: int
    updateCountStr*: string
    updated*: Option[DateTime]
    updatedStr*: string
    deleted*: Option[DateTime]
    deletedStr*: string

  SMPosts* = seq[SMPost]


  SMPostVote* = object
    smPostId*: int64
    smPostIdStr*: string
    votesUpCount*: int
    votesUpCountStr*: string
    votesDownCount*: int
    votesDownCountStr*: string

  SMPostVotes* = seq[SMPostVote]


  SMPostVoteUser* = object
    smPostId*: int64
    smPostIdStr*: string
    accountUserId*: int64
    accountUserIdStr*: string
    voteUp*: bool
    voteUpStr*: string
    voteDown*: bool
    voteDownStr*: string

  SMPostVoteUsers* = seq[SMPostVoteUser]


  NexusSocialModule* = object
    db*: DbConn
    modelToIntSeqTable*: Table[string, int]
    intSeqToModelTable*: Table[int, string]
    fieldToIntSeqTable*: Table[string, int]
    intSeqToFieldTable*: Table[int, string]

    cachedSMPosts*: Table[int64, SMPost]
    cachedFilterSMPost*: Table[string, seq[int64]]


