import chronicles, os, tables
import nexus/cmd/types/config_types
import generate_routes
import load_config


# Code
proc installModule*(module_path: string) =

  var settings = Settings()

  # Get env vars
  settings.envTable["NEXUS_BASE_PATH"] = getEnv("NEXUS_BASE_PATH")
  settings.envTable["NEXUS_SRC_PATH"] = getEnv("NEXUS_SRC_PATH")

  # Load the config files
  let moduleConfig = loadConfigFiles(&"{module_path}{DirSep}conf")

  settings.moduleConfigs.add(moduleConfig)

  # Generate routes file
  generateRoutes(settings)

