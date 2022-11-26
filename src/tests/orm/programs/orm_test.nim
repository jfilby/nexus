# This is a long-running test to check for memory leaks in the ORM.
# It uses the CRM module's data model.
import chronicles, locks, options, strformat, times
import nexus/core/data_access/account_user_data
import nexus/core/data_access/db_conn
import nexus/core/types/model_types
import nexus/crm/data_access/mailing_list_data
import nexus/crm/data_access/mailing_list_subscriber_data
import nexus/crm/service/module/context
import nexus/crm/types/context_type
import nexus/crm/types/model_types


# Consts
let
  mailingListName = "Mailing list"
  mailingListUniqueHash = "test-mailing-list-uq"


# Code
proc getOrCreateTestAccountUser(nexusCRMContext: NexusCRMContext): int64 =

  let accountUser =
        getOrCreateAccountUserByEmail(
          nexusCRMContext.nexusCoreContext.db,
          accountId = none(int64),
          name = "Test account",
          email = "test@mydomain.com",
          passwordHash = "-",
          passwordSalt = "-",
          apiKey = "5293059030455",
          lastToken = none(string),
          signUpCode = "abc",
          signUpDate = now(),
          passwordResetCode = none(string),
          passwordResetDate = none(DateTime),
          isActive = false,
          isAdmin = false,
          isVerified = false,
          subscriptionStatus = none(char),
          lastLogin = none(DateTime),
          lastUpdate = none(DateTime),
          created = now())

  return accountUser.accountUserId


proc createTestMailingList(
       nexusCRMDbContext: var NexusCRMDbContext,
       accountUserId: int64): int64 =

  # Create MailingList record
  let mailingList =
        getOrCreateMailingListByAccountUserIdAndName(
          nexusCRMDbContext,
          accountUserId,
          mailingListuniqueHash,
          mailingListName,
          created = now(),
          deleted = none(DateTime))

  return mailingList.mailingListId


proc createMailingListSubscribers(
       nexusCRMDbContext: var NexusCRMDbContext,
       mailingListId: int64) =

  for i in 0 .. 999:

    let
      email = &"me{i}@mydomain.com"
      uniqueHash = &"{email}-uq"

    discard createMailingListSubscriber(
              nexusCRMDbContext,
              mailingListId = mailingListId,
              uniqueHash = uniqueHash,
              isActive = false,
              email = email,
              isVerified = false,
              created = now())


proc deleteMailingList(
       nexusCRMDbContext: var NexusCRMDbContext,
       mailingListId: int64) =

  discard deleteMailingListByPk(
            nexusCRMDbContext,
            mailingListId)


proc deleteMailingListSubscribers(
       nexusCRMDbContext: var NexusCRMDbContext,
       mailingListId: int64,
       checkCount: bool = true) =

  let deleteCount =
        deleteMailingListSubscriber(
          nexusCRMDbContext,
          whereFields = @[ "mailing_list_id" ],
          whereValues = @[ $mailingListId ])

  if checkCount == true and
     deleteCount != 1000:

    raise newException(
            ValueError,
            "1000 mailing list subscribers should have been deleted, " &
            &"instead {deleteCount} were deleted")


proc filterMailingListSubscribers(
       nexusCRMDbContext: var NexusCRMDbContext,
       mailingListId: int64):
         MailingListSubscribers =

  # Filter MailingList
  let mailingLists =
        filterMailingList(
          nexusCRMDbContext,
          whereFields = @[ "name" ],
          whereValues = @[ mailingListName ])

  if len(mailingLists) != 1:

    raise newException(
            ValueError,
            "Only 1 mailing list result expected")

  # Filter MailingListSubscriber
  let mailingListSubscribers =
        filterMailingListSubscriber(
          nexusCRMDbContext,
          whereFields = @[ "mailing_list_id" ],
          whereValues = @[ $mailingListId ])

  if len(mailingListSubscribers) != 1000:

    raise newException(
            ValueError,
            "1000 mailing list subscribers expected, found: " &
            $len(mailingListSubscribers))

  return mailingListSubscribers


proc updateMailingListSubscribers(
       nexusCRMDbContext: var NexusCRMDbContext,
       mailingListSubscribers: var MailingListSubscribers) =

  for i in 0 .. len(mailingListSubscribers) - 1:

    mailingListSubscribers[i].isActive = true

    discard updateMailingListSubscriberByWhereEqOnly(
              nexusCRMDbContext,
              mailingListSubscribers[i],
              setFields = @[ "is_active" ],
              whereFields = @[],
              whereValues = @[])


proc longRunningTest() =

  # Run for an hour
  let endTime = now() + 1.hours

  # Program-level initLock
  initLock(dbConnLock)

  dbConnLockInited = true

  # Get context
  var nexusCRMContext = newNexusCRMContext()

  # Test accountUserId
  let accountUserId = getOrCreateTestAccountUser(nexusCRMContext)

  # Create
  let mailingListId =
        createTestMailingList(
          nexusCRMContext.db,
          accountUserId)

  echo &"mailingListId: {mailingListId}"

  # Delete any old test subscribers
  deleteMailingListSubscribers(
    nexusCRMContext.db,
    mailingListId,
    checkCount = false)

  # Run test loop
  var i = 1
  let maxIters = 20

  while i < maxIters + 1:

    echo &"Iteration: {i}"

    # Create
    createMailingListSubscribers(
      nexusCRMContext.db,
      mailingListId)

    # Filter
    var mailingListSubscribers =
          filterMailingListSubscribers(
            nexusCRMContext.db,
            mailingListId)

    # Update
    updateMailingListSubscribers(
      nexusCRMContext.db,
      mailingListSubscribers)

    # Delete
    deleteMailingListSubscribers(
      nexusCRMContext.db,
      mailingListId)

    # Inc i
    i += 1

  # Delete mailing list
  deleteMailingList(
    nexusCRMContext.db,
    mailingListId)

  # Delete context
  deleteNexusCRMContext(nexusCrmContext)

  # Program-level deinitLock
  deinitLock(dbConnLock)


# Main
longRunningTest()

