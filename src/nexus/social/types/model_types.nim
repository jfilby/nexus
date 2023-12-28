# Nexus generated file
import db_connector/db_postgres, options, tables, times


type
  SMPost* = object
    id*: string
    parentId*: Option[string]
    accountUserId*: string
    uniqueHash*: string
    postType*: char
    status*: char
    title*: Option[string]
    body*: string
    tagIds*: Option[string]
    created*: DateTime
    published*: Option[DateTime]
    updateCount*: int
    updated*: Option[DateTime]
    deleted*: Option[DateTime]

  SMPosts* = seq[SMPost]


  SMPostVote* = object
    smPostId*: string
    votesUpCount*: int
    votesDownCount*: int

  SMPostVotes* = seq[SMPostVote]


  SMPostVoteUser* = object
    smPostId*: string
    accountUserId*: string
    voteUp*: bool
    voteDown*: bool

  SMPostVoteUsers* = seq[SMPostVoteUser]


  NexusSocialDbContext* = object
    dbConn*: DbConn
    modelToIntSeqTable*: Table[string, int]
    intSeqToModelTable*: Table[int, string]
    fieldToIntSeqTable*: Table[string, int]
    intSeqToFieldTable*: Table[int, string]

    cachedSMPosts*: Table[string, SMPost]
    cachedFilterSMPost*: Table[string, seq[string]]


