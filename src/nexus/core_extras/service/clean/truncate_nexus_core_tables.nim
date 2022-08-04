import nexus/core_extras/data_access/list_item_data
import nexus/core_extras/data_access/menu_item_data
import nexus/core_extras/types/model_types


proc truncateNexusCoreExtrasTables*(
       nexusCoreExtrasDbContext: NexusCoreExtrasDbContext,
       cascade: bool = false) =

  truncateListItem(nexusCoreExtrasDbContext,
                   cascade = cascade)

  truncateMenuItem(nexusCoreExtrasDbContext)

