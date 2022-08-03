import nexus/core/types/model_types as nexus_core_model_types
import model_types


type
  NexusSocialContext* = object
    db*: NexusSocialDbContext
    nexusCoreDbContext*: NexusCoreDbContext

    # Add your own context vars below this comment

