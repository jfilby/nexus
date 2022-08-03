import core/types/context_type
import core/types/model_types
import new_web_context


proc newNexusCoreContext*():
       NexusCoreContext =

  var nexusCoreContext = NexusCoreContext()

  nexusCoreContext.db = NexusCoreDbContext()
                  nexusCoreDbContext)

  return nexusCoreContext

