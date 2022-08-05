import nexus/core/types/context_type as nexus_core_context_type
import model_types


type
  NexusSocialContext* = object
    db*: NexusSocialDbContext
    nexusCoreContext*: NexusCoreContext

    # Add your own context vars below this comment

