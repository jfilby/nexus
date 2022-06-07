import chronicles, streams, yaml
import nexus/cmd/types/config_types


# Forward declarations
proc loadRoutesYAMLFile(filename: string,
                        moduleConfig: var ModuleConfig)
proc loadModelsYAMLFile(filename: string,
                        moduleConfig: var ModuleConfig)


# Code
proc loadConfigFiles*(configPath: string): ModuleConfig =

  debug "loadConfigFiles",
    configPath = configPath

  var moduleConfig = ModuleConfig()

  # Load the routes file
  loadRoutesYAMLFile(configPath & &"{DirSep}routes.yaml",
                     moduleConfig)

  # Load the models file
  loadModelsYAMLFile(configPath & &"{DirSep}models.yaml",
                     moduleConfig)

  return moduleConfig


proc loadRoutesYAMLFile(filename: string,
                        moduleConfig: var ModuleConfig) =

  debug "loadRoutesYAMLFile()",
    filename = filename

  var
    routesYamlCollection: seq[RouteYAML]
    s = newFileStream(filename)

  load(s,
       routesYamlCollection)

  s.close()

  for routeYaml in routesYamlCollection:

    debug "loadRoutesYAMLFile()",
      route = routeYaml.route

    moduleConfig.routes.add(routeYaml)


proc loadModelsYAMLFile(filename: string,
                        moduleConfig: var ModuleConfig) =

  debug "loadModelsYAMLFile()",
    filename = filename

  var
    modelsYamlCollection: seq[ModelYAML]
    s = newFileStream(filename)

  load(s,
       modelsYamlCollection)

  s.close()

  for modelYaml in modelsYamlCollection:

    debug "loadModelsYAMLFile()",
      name = modelYaml.name

    moduleConfig.models.add(modelYaml)

