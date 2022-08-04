import jester, options
import nexus/core/data_access/db_conn
import nexus/core/types/model_types as nexus_core_model_types
import core/types/context_type
import core/types/model_types
import new_web_context


proc newNexusCoreContext*(request: Option[Request] = none(Request)):
       NexusCoreContext =

  var nexusCoreContext = NexusCoreContext()

  nexusCoreContext.db =
    NexusCoreDbContext(dbConn: getDbConn())

  nexusCoreContext.web =
    some(
      newWebContext(request.get,
                    nexusCoreDbContext))

  return nexusCoreContext

