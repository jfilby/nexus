import chronicles, options, os, streams, strformat, strutils, yaml
import nexus/cmd/types/types
import nexus/core/service/format/filename_utils
import nexus/core/service/format/case_utils
import route_utils


# Forward declaration
proc readRoutesFiles*(
       basePath: string,
       routesPath: string,
       srcPath: string,
       webArtifact: var WebArtifact,
       generatorInfo: GeneratorInfo)


# Code
proc readExternalRoutesFile(
       externalRoutesFilename: string,
       webArtifact: var WebArtifact,
       generatorInfo: GeneratorInfo) =

  debug "readExternalRoutesFile()",
    lenModules = $len(generatorInfo.modules),
    lenPackages = $len(generatorInfo.packages)

  # Read external routes YAML file
  var
    externalRoute: ExternalRouteYAML
    s = newFileStream(externalRoutesFilename)

  load(s, externalRoute)
  s.close()

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
          &"{routesModule.get.nameInSnakeCase}{DirSep}routes{DirSep}external"

    if not dirExists(routesPath):

      raise newException(
              ValueError,
              &"Route's path for {webArtifact.shortName} doesn't exist: " &
              &"{routesPath}")

    # Unimplemented
    raise newException(
            ValueError,
            "unimplemented")

#[
    # Read all routes YAML files
    for kind, filename in walkDir(path,
                                  relative = true):

      if kind == pcFile and
         filename[0] != '.':
    
        # Read routes file
        readRoutesFiles(
          webArtifact.basePath,
          routesPath,
          webArtifact.srcPath,
          webArtifact,
          generatorInfo)
]#


proc readExternalRoutes(
       externalRoutesPath: string,
       webArtifact: var WebArtifact,
       generatorInfo: GeneratorInfo) =

  # Read all routes YAML files
  for kind, filename in walkDir(externalRoutesPath,
                                relative = false):

    if kind == pcFile and
       filename[0] != '.':
    
      # Read routes file
      readExternalRoutesFile(
        filename,
        webArtifact,
        generatorInfo)


proc readRoutesFile(
       routesFilename: string,
       webArtifact: var WebArtifact,
       generatorInfo: GeneratorInfo) =

  # Parse env vars
  debug "readRoutesFile()",
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
  var filename = routesFilename

  filename = getRelativePath(filename)

  let dotPos = find(filename,
                    ".y")

  if dotPos < 0:
    raise newException(
            ValueError,
            "Non .yaml file found: " & filename)

  webArtifact.routes.name =
    inNaturalCase(filename[0 .. dotPos])

  echo &"Routes: {webArtifact.routes.name} ({len(routeFilesCollection)})"

  # Read in the routes
  for routeYaml in routeFilesCollection:

    debug "readRoutesFile(): url line"

    # Convert RouteYAML to Route
    webArtifact.routes.routes.add(
      routeYAMLtoRoute(
        webArtifact,
        routeYaml))


proc readRoutesFiles*(
       basePath: string,
       routesPath: string,
       srcPath: string,
       webArtifact: var WebArtifact,
       generatorInfo: GeneratorInfo) =

  debug "readRoutesFiles()",
    basePath = basePath,
    routesPath = routesPath,
    srcPath = srcPath

  # Read all routes YAML files
  for kind, filename in walkDir(routesPath,
                                relative = false):

    if kind == pcFile and
       filename[0] != '.':
    
      # Read routes file
      readRoutesFile(
        filename,
        webArtifact,
        generatorInfo)

#[
proc readRoutesFile(
       inRoutesFilename: string,
       webArtifact: var WebArtifact,
       generatorInfo: GeneratorInfo)
]#

  # Read external routes
  let externalRoutesPath = &"{routesPath}{DirSep}external"

  if dirExists(externalRoutesPath):

    readExternalRoutes(
      externalRoutesPath,
      webArtifact,
      generatorInfo)

