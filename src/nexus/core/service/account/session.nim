# Sessions are deprecated, replaced by JWT.
import chronicles, db_postgres, jester, marshal, options, random_key, streams
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

  var session_context = SessionContext()
  session_context.sessionId = sessionId
  session_context.accountUserId = accountUserId

  # Save the session to the db
  session_data.create(db,
                      sessionId,
                      $$session_context)

  return session_context


proc createSessionId*(): string =

  return createRandomKey()


proc getSessionContext*(db: DbConn,
                        sessionId: string): SessionContext =

  debug "getSessionContext()",
    sessionId = sessionId

  let
    session = session_data.getBySessionId(db,
                                          sessionId)

    session_context = to[SessionContext](session.get.session_data)

  return session_context

