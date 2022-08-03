import core_extras/types/context_type
import core_extras/types/model_types
import new_web_context


proc newNexusCoreExtrasContext*():
       NexusCoreExtrasContext =

  var nexusCoreExtrasContext = NexusCoreExtrasContext()

  nexusCoreExtrasContext.db = NexusCoreExtrasDbContext()

  nexusCoreExtrasContext.nexusCoreDbContext =
    NexusCoreDbContext(dbConn: nexusCoreExtrasContext.db.dbConn)
                  nexusCoreExtras.nexusCoreDbContext)

  return nexusCoreExtrasContext

