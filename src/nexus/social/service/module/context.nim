import social/types/context_type
import social/types/model_types


proc newNexusSocialContext*():
       NexusSocialContext =

  var nexusSocialContext = NexusSocialContext()

  nexusSocialContext.db =
    NexusSocialDbContext()

  nexusSocialContext.nexusCoreDbContext =
    NexusCoreDbContext(dbConn: nexusSocialContext.db.dbConn)

  return nexusSocialContext

