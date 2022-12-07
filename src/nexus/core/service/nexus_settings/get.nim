import options, strformat
import nexus/core/data_access/nexus_setting_data
import nexus/core/types/model_types


proc getNexusSettingValue*(
       dbContext: NexusCoreDbContext,
       module: string,
       key: string,
       failOnNotExists: bool = true): Option[string] =

  let nexusSetting =
        getNexusSettingByModuleAndKey(
          dbContext,
          module,
          key)

  if nexusSetting == none(NexusSetting):
    raise newException(
            ValueError,
            &"NexusSetting record not found for module: \"{module}\" and " &
            &"key: \"{key}\"")

  if nexusSetting.get.value == none(string):
    raise newException(
            ValueError,
            &"NexusSetting has none value for module: \"{module}\" and " &
            &"key: \"{key}\"")

  return nexusSetting.get.value

