import chronicles, os, strformat, strutils
import nexus/core/service/format/filename_utils
import nexus/cmd/service/generate/main_config/write_file
import nexus/cmd/service/generate/routes/route_utils
import nexus/cmd/service/generate/web_artifacts/gen_web_artifact
import nexus/cmd/types/types
import utils


# Forward declarations
proc writeConfWebAppYaml(
       pathName: string,
       projectTemplate: ProjectTemplate)
proc writeRoutesYamlFile(
       routesYamlFilename: string,
       routes: Routes,
       projectTemplate: ProjectTemplate)


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

  var routes = Routes(name: moduleSnakeCaseName)

  routes.routes.add(route)

  return routes


proc generateInitialWebArtifact*(
       pathName: string,
       routes: Routes,
       projectTemplate: var ProjectTemplate,
       generatorInfo: var GeneratorInfo) =

  # Defined a WebArtifact object
  var webArtifact =
        getWebArtifactFromProjectTemplate(
          pathName,
          routes,
          projectTemplate,
          generatorInfo)

  # Set GeneratorInfo fields
  # generatorInfo.confPath = projectTemplate.confPath

  # This will generate the initial web artifact, including the routes file and
  # any page files.
  generateWebArtifact(
    projectTemplate.basePath,
    webArtifact,
    generatorInfo)


proc generateWebArtifactTemplate*(
       projectTemplate: var ProjectTemplate,
       generatorInfo: var GeneratorInfo) =

  debug "generateWebArtifactTemplate()"

  # Get path name
  let pathName =
        replace(
          projectTemplate.artifact,
          '-',
          '_')

  # Get paths
  var srcPath = &"{projectTemplate.appPath}{DirSep}view{DirSep}{pathName}"

  discard parseFilenameExpandEnvVars(srcPath)

  projectTemplate.confWebApp =
    &"{projectTemplate.appConfPath}{DirSep}{pathName}s{DirSep}" &
    projectTemplate.projectNameInSnakeCase

  projectTemplate.confWebAppYaml =
    &"{projectTemplate.confWebApp}{DirSep}{pathName}.yaml"

  var
    confWebApp = projectTemplate.confWebApp
    confWebAppYaml = projectTemplate.confWebAppYaml

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
    projectTemplate)

  # An initial routes.yaml file
  debug "generateWebArtifactTemplate(): create initial routes.yaml file"

  let
    routesPath = &"{projectTemplate.confWebApp}{DirSep}routes"
    routesYamlFilename = &"{routesPath}{DirSep}routes.yaml"

  echo ".. creating initial routes.yaml file: " & routesYamlFilename

  createDir(routesPath)

  writeRoutesYamlFile(
    routesYamlFilename,
    routes,
    projectTemplate)

  # Source directory and generate routes file
  debug "generateWebArtifactTemplate(): generating initial web source files"

  echo &".. generating initial web artifact.."

  # Generate the initial WebArtifact
  createDir(srcPath)

  generateInitialWebArtifact(
    pathName,
    routes,
    projectTemplate,
    generatorInfo)

  # Done
  debug "generateWebArtifactTemplate(): done"


proc writeConfWebAppYaml(
       pathName: string,
       projectTemplate: ProjectTemplate) =

  # Check if projectTemplate.confWebAppYaml file already exists, prompt for
  # overwrite
  promptToOverwriteFile(
    &"A {pathName}.yaml file already exists:\n" &
    &"{projectTemplate.confWebAppYaml}\n" &
     "Would you like to overwrite this file?",
    projectTemplate.confWebAppYaml,
     "%YAML 1.2\n" &
     "---\n" &
     "\n" &
    &"shortName: {projectTemplate.appName}\n" &
    &"description: Web application.\n" &
    &"basePath: ${projectTemplate.basePathEnvVar}\n" &
    &"srcPath: ${projectTemplate.nimSrcPathEnvVar}/" &
      &"{projectTemplate.appNameInSnakeCase}\n" &
     "mediaList: []\n" &
     "\n")


proc writeRoutesYamlFile(
       routesYamlFilename: string,
       routes: Routes,
       projectTemplate: ProjectTemplate) =

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

