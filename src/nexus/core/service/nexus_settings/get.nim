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

  if nexusSetting.isNone:
    raise newException(
            ValueError,
            &"NexusSetting record not found for module: \"{module}\" and " &
            &"key: \"{key}\"")

  if nexusSetting.get.value.isNone:
    raise newException(
            ValueError,
            &"NexusSetting has none value for module: \"{module}\" and " &
            &"key: \"{key}\"")

  return nexusSetting.get.value

