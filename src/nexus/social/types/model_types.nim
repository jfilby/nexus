# Nexus generated file
import db_postgres, options, tables, times


type
  SMPost* = object
    smPostId*: int64
    smPostParentId*: Option[int64]
    accountUserId*: int64
    uniqueHash*: string
    postType*: char
    status*: char
    title*: Option[string]
    body*: string
    tagIds*: Option[int64]
    created*: DateTime
    published*: Option[DateTime]
    updateCount*: int
    updated*: Option[DateTime]
    deleted*: Option[DateTime]

  SMPosts* = seq[SMPost]


  SMPostVote* = object
    smPostId*: int64
    votesUpCount*: int
    votesDownCount*: int

  SMPostVotes* = seq[SMPostVote]


  SMPostVoteUser* = object
    smPostId*: int64
    accountUserId*: int64
    voteUp*: bool
    voteDown*: bool

  SMPostVoteUsers* = seq[SMPostVoteUser]


  NexusSocialDbContext* = object
    dbConn*: DbConn
    modelToIntSeqTable*: Table[string, int]
    intSeqToModelTable*: Table[int, string]
    fieldToIntSeqTable*: Table[string, int]
    intSeqToFieldTable*: Table[int, string]

    cachedSMPosts*: Table[int64, SMPost]
    cachedFilterSMPost*: Table[string, seq[int64]]


