import nexus/core_extras/data_access/list_item_data
import nexus/core_extras/data_access/menu_item_data
import nexus/core_extras/types/model_types


proc truncateNexusCoreExtrasTables*(
       nexusCoreExtrasModule: NexusCoreExtrasModule,
       cascade: bool = false) =

  truncateListItem(nexusCoreExtrasModule,
                   cascade = cascade)

  truncateMenuItem(nexusCoreExtrasModule)

