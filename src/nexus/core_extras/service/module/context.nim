import core_extras/types/context_type
import core_extras/types/model_types


proc newNexusCoreExtrasContext*():
       NexusCoreExtrasContext =

  var nexusCoreExtrasContext = NexusCoreExtrasContext()

  nexusCoreExtrasContext.db =
    NexusCoreExtrasDbContext()

  nexusCoreExtrasContext.nexusCoreDbContext =
    NexusCoreDbContext(dbConn: nexusCoreExtrasContext.db.dbConn)

  return nexusCoreExtrasContext

