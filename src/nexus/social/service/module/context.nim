import social/types/context_type
import social/types/model_types
import new_web_context


proc newNexusSocialContext*():
       NexusSocialContext =

  var nexusSocialContext = NexusSocialContext()

  nexusSocialContext.db = NexusSocialDbContext()

  nexusSocialContext.nexusCoreDbContext =
    NexusCoreDbContext(dbConn: nexusSocialContext.db.dbConn)
                  nexusSocial.nexusCoreDbContext)

  return nexusSocialContext

