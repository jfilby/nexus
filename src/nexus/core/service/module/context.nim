import jester, options
import nexus/core/data_access/db_conn
import nexus/core/types/context_type
import nexus/core/types/model_types
import new_web_context


proc deleteTraderEngineContext*(
       nexusCoreContext: var NexusCoreContext) =

  closeDbConn(nexusCoreContext.db.dbConn)


proc newNexusCoreContext*(request: Option[Request] = none(Request)):
       NexusCoreContext =

  var nexusCoreContext =
        NexusCoreContext(db: NexusCoreDbContext())

  nexusCoreContext.db.dbConn = getDbConn()

  nexusCoreContext.web =
    some(
      newWebContext(request.get,
                    nexusCoreContext.db))

  return nexusCoreContext

