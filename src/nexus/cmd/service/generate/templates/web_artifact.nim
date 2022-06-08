import chronicles, os, strformat, strutils
import nexus/core/service/format/filename_utils
import nexus/core/service/format/name_utils
import nexus/cmd/service/generate/main_config/write_file
import nexus/cmd/service/generate/routes/route_utils
import nexus/cmd/service/generate/web_artifacts/gen_web_artifact
import nexus/cmd/types/types
import utils


# Forward declarations
proc writeConfWebAppYaml(
       pathName: string,
       appTemplate: AppTemplate)
proc writeRoutesYamlFile(
       routesYamlFilename: string,
       routes: Routes,
       appTemplate: AppTemplate)


# Code
proc createInitialRoutes(moduleSnakeCaseName: string): Routes =

  var route =
        Route(
          name: "Frontpage",
          description: "The frontpage",
          group: "Home",
          methods: @[ "get" ],
          route: "/")

  enrichRouteNamesAndPaths(
    route,
    moduleSnakeCaseName)

  var routes = Routes(name: "Frontpage")

  routes.routes.add(route)

  return routes


proc generateInitialWebArtifact*(
       pathName: string,
       routes: Routes,
       appTemplate: var AppTemplate,
       generatorInfo: var GeneratorInfo) =

  # Defined a WebArtifact object
  var webArtifact =
        getWebArtifactFromAppTemplate(
          pathName,
          routes,
          appTemplate,
          generatorInfo)

  # Set GeneratorInfo fields
  # generatorInfo.confPath = appTemplate.confPath

  # This will generate the initial web artifact, including the routes file and
  # any page files.
  generateWebArtifact(
    appTemplate.basePath,
    webArtifact,
    generatorInfo)


proc generateWebArtifactTemplate*(
       appTemplate: var AppTemplate,
       generatorInfo: var GeneratorInfo) =

  debug "generateWebArtifactTemplate()"

  # Get path name
  let pathName =
        replace(
          appTemplate.artifact,
          '-',
          '_')

  # Get paths
  var srcPath = &"{appTemplate.modulePath}{DirSep}view{DirSep}{pathName}"

  discard parseFilenameExpandEnvVars(srcPath)

  appTemplate.confWebApp =
    &"{appTemplate.moduleConfPath}{DirSep}{pathName}s{DirSep}" &
    appTemplate.appNameSnakeCase

  appTemplate.confWebAppYaml =
    &"{appTemplate.confWebApp}{DirSep}{pathName}.yaml"

  var
    confWebApp = appTemplate.confWebApp
    confWebAppYaml = appTemplate.confWebAppYaml

  discard parseFilenameExpandEnvVars(confWebApp)
  discard parseFilenameExpandEnvVars(confWebAppYaml)

  # Create initial routes object
  let routes = createInitialRoutes(pathName)

  # Web app conf YAML file
  debug "generateWebArtifactTemplate(): create web-app YAML file"

  echo ".. creating conf path for web-app: " & confWebApp

  createDir(confWebApp)

  writeConfWebAppYaml(
    confWebAppYaml,
    appTemplate)

  # An initial routes.yaml file
  debug "generateWebArtifactTemplate(): create initial routes.yaml file"

  let routesYamlFilename = &"{appTemplate.confWebApp}{DirSep}routes.yaml"

  echo ".. creating initial routes.yaml file: " & routesYamlFilename

  createDir(srcPath)

  writeRoutesYamlFile(
    routesYamlFilename,
    routes,
    appTemplate)

  # Source directory and generate routes file
  debug "generateWebArtifactTemplate(): generating initial web source files"

  echo &".. generating initial web artifact.."

  # Generate the initial WebArtifact
  generateInitialWebArtifact(
    pathName,
    routes,
    appTemplate,
    generatorInfo)

  # Done
  debug "generateWebArtifactTemplate(): done"


proc writeConfWebAppYaml(
       pathName: string,
       appTemplate: AppTemplate) =

  # Check if appTemplate.confWebAppYaml file already exists, prompt for
  # overwrite
  promptToOverwriteFile(
    &"A {pathName}.yaml file already exists:\n" &
    &"{appTemplate.confWebAppYaml}\n" &
     "Would you like to overwrite this file?",
    appTemplate.confWebAppYaml,
     "%YAML 1.2\n" &
     "---\n" &
     "\n" &
    &"shortName: {appTemplate.appName} Web App\n" &
    &"description: Web application.\n" &
    &"basePath: ${appTemplate.basePathEnvVar}\n" &
    &"srcPath: ${appTemplate.nimSrcPathEnvVar}/" &
      &"{appTemplate.moduleNameSnakeCase}\n" &
     "mediaList: []\n" &
     "\n")


proc writeRoutesYamlFile(
       routesYamlFilename: string,
       routes: Routes,
       appTemplate: AppTemplate) =

  # Get the frontpage route
  let
    route = routes.routes[0]
    methods = join(route.methods, ", ")

  # Check if srcFilePath file already exists, prompt for overwrite
  promptToOverwriteFile(
     "A routes.yaml file already exists:\n" &
    &"{routesYamlFilename}\n" &
     "Would you like to overwrite this file?",
    routesYamlFilename,
     "%YAML 1.2\n" &
     "---\n" &
     "\n" &
    &"- name: {route.name}\n" &
    &"  description: {route.description}\n" &
    &"  group: {route.group}\n" &
    &"  methods: [ {methods} ]\n" &
    &"  options: {route.options}\n" &
    &"  route: {route.route}\n" &
     "  parameters: []\n" &
     "  defaults: []\n" &
     "  modelFields: []\n" &
     "\n")

