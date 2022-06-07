import chronicles, options, os, streams, strformat, yaml
import nexus/cmd/types/types
import route_utils


# Forward declaration
proc readRoutesFile(
       routeName: string,
       inRoutesFilename: string,
       webApp: var WebApp,
       generatorInfo: GeneratorInfo)
proc readRoutesFilesFile*(
       basePath: string,
       routesPath: string,
       srcPath: string,
       filename: string,
       webApp: var WebApp,
       generatorInfo: GeneratorInfo)


# Code
proc readExternalRoutes*(
       externalRoute: ExternalRouteYAML,
       webApp: var WebApp,
       generatorInfo: GeneratorInfo) =

  debug "readExternalRoutes()",
    lenModules = $len(generatorInfo.modules),
    lenPackages = $len(generatorInfo.packages)

  # Debug
  for module in generatorInfo.modules:

    debug "readExternalRoutes()",
      moduleName = module.name

  var
    routesPath = ""
    routesModule: Option[Module]

  # Check modules (local) for the externalRoute module
  for module in generatorInfo.modules:

    if externalRoute.module == module.name:
      routesModule = some(module)
      routesPath = module.basePath
      break

  if routesModule == none(Module):

    raise newException(ValueError,
                       &"Module not found: {externalRoute.module}")

  # Check imported packages for the externalRoute module
  debug "readExternalRoutes(): looking for routesPath for module",
    moduleName = routesModule.get.name

  for route in externalRoute.routes:

    # Formulate and verify routes path
    let routesPath =
          &"{routesModule.get.confPath}{DirSep}web_apps{DirSep}" &
          &"{routesModule.get.snakeCaseName}{DirSep}routes"

    if not dirExists(routesPath):

      raise newException(
              ValueError,
              &"Route's path for {webApp.shortName} doesn't exist: " &
              &"{routesPath}")

    # Read routes file
    readRoutesFilesFile(
      webApp.basePath,
      routesPath,
      webApp.srcPath,
      &"{routesPath}{DirSep}all_routes.yaml",
      webApp,
      generatorInfo)


proc readRoutesFile(
       routeName: string,
       inRoutesFilename: string,
       webApp: var WebApp,
       generatorInfo: GeneratorInfo) =

  # Parse env vars
  var routesFilename = inRoutesFilename

  debug "readRoutesFile()",
    inRoutesFilename = inRoutesFilename,
    routesFilename = routesFilename

  # Verify file exists
  if not fileExists(routesFilename):

    raise newException(ValueError,
                       &"routes file not found: {routesFilename}")

  # Import route files YAML
  var
    routeFilesCollection: RoutesYAML
    s = newFileStream(routesFilename)

  load(s, routeFilesCollection)
  s.close()

  # Comment
  webApp.routes.name = routeName

  # Read in the routes
  for routeYaml in routeFilesCollection:

    debug "readRoutesFile(): url line"

    # Convert RouteYAML to Route
    webApp.routes.routes.add(
      routeYAMLtoRoute(
        webApp,
        routeYaml))


proc readRoutesFilesFile*(
       basePath: string,
       routesPath: string,
       srcPath: string,
       filename: string,
       webApp: var WebApp,
       generatorInfo: GeneratorInfo) =

  debug "readRoutesFilesFile()",
    basePath = basePath,
    routesPath = routesPath,
    srcPath = srcPath,
    filename = filename

  # Skip if the routes file doesn't exist
  if fileExists(filename) == false:
    return

  # Import route files YAML
  var
    routeFile: RouteFileYAML
    s = newFileStream(filename)

  load(s, routeFile)
  s.close()

  # Debug
  let
    routeFileLocal = routeFile.local
    routeFileExternal = routeFile.external

  debug "readRoutesFilesFile()",
    local = routeFileLocal,
    external = routeFileExternal

  discard routeFileLocal
  discard routeFileExternal

  # Process local routes
  for localRoute in routeFile.local:

    # Read local routes file
    readRoutesFile(
      localRoute,
      inRoutesFilename = &"{routesPath}{DirSep}{localRoute}.yaml",
      webApp,
      generatorInfo)

  # Process external routes
  for externalRoute in routeFile.external:

    # Read external routes file
    readExternalRoutes(
      externalRoute,
      webApp,
      generatorInfo)

