# Sessions are deprecated, replaced by JWT.
import chronicles, jester, marshal, options, random_key, streams
import db_connector/db_postgres
import nexus/core/data_access/session_data


# Forward declarations
proc createSessionId*(): string


# Code
proc createSession*(db: DbConn,
                    accountUserId: string): SessionContext =

  debug "createSession()",
    accountUserId = accountUserId

  # Verify accountUserId
  if accountUserId == "":
    raise newException(ValueError,
                       "accountUserId is blank")

  # Create a session id (random key)
  let sessionId = createSessionId()

  var sessionContext = SessionContext()
  sessionContext.sessionId = sessionId
  sessionContext.accountUserId = accountUserId

  # Save the session to the db
  session_data.create(db,
                      sessionId,
                      $$sessionContext)

  return sessionContext


proc createSessionId*(): string =

  return createRandomKey()


proc getSessionContext*(db: DbConn,
                        sessionId: string): SessionContext =

  debug "getSessionContext()",
    sessionId = sessionId

  let
    session = session_data.getBySessionId(db,
                                          sessionId)

    sessionContext = to[SessionContext](session.get.session_data)

  return sessionContext

