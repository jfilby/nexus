import chronicles, os, strformat, strutils
import nexus/core/service/format/filename_utils
import nexus/core/service/format/name_utils
import nexus/core/service/format/tokenize
import nexus/cmd/service/generate/main_config/gen_nexus_conf
import nexus/cmd/service/generate/main_config/write_file
import nexus/cmd/types/types
import console_app
import gen_env_scripts
import web_artifact


# Forward declarations
proc basicAppTemplate(
       appTemplate: AppTemplate,
       generatorInfo: GeneratorInfo)
proc notifyOfGenerateAppTemplate(appTemplate: AppTemplate)
proc promptForInfo(appTemplate: var AppTemplate)
proc validateAndTransformName*(name: var string): bool
proc verifyAppNamePathDoesntExist(appTemplate: AppTemplate)


# Code
proc generateAppTemplate*(
       artifact: string,
       generatorInfo: var GeneratorInfo) =

  var appTemplate =
        AppTemplate(
          artifact: artifact,
          docUi: false)

  if DirSep == '/':
    appTemplate.isUnix = true
    appTemplate.compileScript = "compile.sh"

  else:
    appTemplate.isUnix = false
    appTemplate.compileScript = "compile"

  appTemplate.cwd = getCurrentDir()

  # Notify of what will be created and where
  notifyOfGenerateAppTemplate(appTemplate)

  # Prompt for app info
  promptForInfo(appTemplate)

  # Populate some initial fields for GeneratorInfo
  generatorInfo.package = appTemplate.appNameSnakeCase

  # Setup for all types of basic
  basicAppTemplate(
    appTemplate,
    generatorInfo)

  # Generate env scripts
  genEnvScripts(appTemplate)

  # Console app specific
  if artifact == "console-app":
    generateConsoleAppTemplate(appTemplate)

  # Web app specific
  elif artifact == "web-app" or
       artifact == "web-service":

    generateWebArtifactTemplate(
      appTemplate,
      generatorInfo)


proc basicAppTemplate(
       appTemplate: AppTemplate,
       generatorInfo: GeneratorInfo) =

  debug "basicAppTemplate"

  # Write the conf/nexus.yaml file
  generateMainConfigFile(
    appTemplate,
    generatorInfo)

  # Create initial conf directories and files
  var
    confModels = &"{appTemplate.moduleConfPath}{DirSep}models"
    modelsYaml = &"{confModels}{DirSep}models.yaml"

  discard parseFilenameExpandEnvVars(confModels)
  discard parseFilenameExpandEnvVars(modelsYaml)

  let blankYaml = "%YAML 1.2\n" &
                  "---\n" &
                  "\n\n"

  echo ".. creating conf path: " & confModels
  createDir(confModels)

  # Check if models.yaml file already exists, prompt for overwrite
  promptToOverwriteFile(
     "A models definition file already exists:\n" &
    &"{modelsYaml}\n" &
     "Would you like to overwrite this file?",
    modelsYaml,
    blankYaml)

  # Create additional directories
  var
    tmpPath = &"{appTemplate.basePath}{DirSep}tmp"
    envScriptsPath = &"{appTemplate.basePath}{DirSep}env_scripts"
    binPath = &"{appTemplate.modulePath}{DirSep}bin"
    servicePath = &"{appTemplate.modulePath}{DirSep}service"

  discard parseFilenameExpandEnvVars(tmpPath)
  discard parseFilenameExpandEnvVars(envScriptsPath)
  discard parseFilenameExpandEnvVars(binPath)
  discard parseFilenameExpandEnvVars(servicePath)

  echo ".. creating tmp path: " & tmpPath
  createDir(tmpPath)

  echo ".. creating env_scripts path: " & envScriptsPath
  createDir(envScriptsPath)

  echo ".. creating bin path: " & binPath
  createDir(binPath)

  echo ".. creating service path: " & servicePath
  createDir(servicePath)


proc getDefaultModuleName(appTemplate: var AppTemplate) =

  case appTemplate.artifact:

    of "console":
      appTemplate.moduleName = "Console app"

    of "web-app":
      appTemplate.moduleName = "Web-app"

    of "web-service":
      appTemplate.moduleName = "Web-service"

    else:
      raise newException(
              ValueError,
              "Unhandled artifact as appType")


proc notifyOfGenerateAppTemplate(appTemplate: AppTemplate) =

  echo &"This will create a new {appTemplate.artifact}."
  echo  "The app will be created in the current directory."
  echo  "The new directory name will be based on the application name."
  echo  ""


proc promptForInfo(appTemplate: var AppTemplate) =

  # Prompt for app name
  echo ""
  echo "App name, e.g. My Application (use full capitalization with spaces)"

  while true:

    stdout.write("> ")
    appTemplate.appName = readLine(stdin)

    if validateAndTransformName(appTemplate.appName) == true:
      break

    else:
      echo "Invalid capitalized name, please try again."
      echo ""

  # Ensure appName-based path doesn't already exist
  verifyAppNamePathDoesntExist(appTemplate)

  # Formulate default module name
  getDefaultModuleName(appTemplate)

  # Prompt for initial module name
  echo ""
  echo  "Name of the initial module, e.g. Web-app (use full capitalization with spaces)"
  echo &"The default module name, based on your application type is: {appTemplate.moduleName}"
  echo ""
  echo  "Press enter (leaving out the name) to use the default"

  while true:

    stdout.write("> ")
    let userInput = readLine(stdin)

    if userInput == "":
      break

    # Set and validate moduleName
    appTemplate.moduleName = userInput

    if validateAndTransformName(appTemplate.moduleName) == true:
      break

    else:
      echo "Invalid capitalized name, please try again."
      echo ""

  # Set vars
  let p = getPlatformVars(appTemplate)

  # appName processing
  appTemplate.appNameSnakeCase =
    getSnakeCaseName(appTemplate.appName)

  appTemplate.appNameUpperSnakeCase =
    toUpperAscii(appTemplate.appnameSnakeCase)

  appTemplate.appNameLowerSnakeCase =
    toLowerAscii(appTemplate.appnameSnakeCase)

  # moduleName formulations
  appTemplate.moduleNameSnakeCase =
    getSnakeCaseName(appTemplate.moduleName)

  appTemplate.moduleNameUpperSnakeCase =
    toUpperAscii(appTemplate.modulenameSnakeCase)

  appTemplate.moduleNameLowerSnakeCase =
    toLowerAscii(appTemplate.modulenameSnakeCase)

  # Path formulations
  appTemplate.basePath =
    &"{appTemplate.cwd}{DirSep}{appTemplate.appNameSnakeCase}"

  appTemplate.basePathEnvVar = &"{appTemplate.appNameUpperSnakeCase}_BASE_PATH"
  appTemplate.nimSrcPathEnvVar =
    &"{appTemplate.appNameUpperSnakeCase}_BASE_SRC_PATH"

  appTemplate.confPath = &"{appTemplate.basePath}{DirSep}conf"

  appTemplate.moduleConfPath = &"{appTemplate.confPath}{DirSep}" &
    appTemplate.moduleNameLowerSnakeCase

  appTemplate.nimPath =
    &"{p.envStart}{appTemplate.basePathEnvVar}{p.envEnd}{DirSep}nim{DirSep}src"

  # The expanded path must be used right now because the environment var isn't
  # set yet (the env file itself must still be created)
  appTemplate.nimPathExpanded = &"{appTemplate.basePath}{DirSep}nim{DirSep}src"

  appTemplate.modulePath =
    &"{appTemplate.nimPathExpanded}{DirSep}" &
    &"{appTemplate.moduleNameLowerSnakeCase}"

  # Initial DB settings template
  appTemplate.dbServer = "localhost"
  appTemplate.dbPort = "5432"
  appTemplate.dbName = appTemplate.appNameLowerSnakeCase
  appTemplate.dbUsername = ""
  appTemplate.dbPassword = ""


proc validateAndTransformName*(name: var string): bool =

  # Verify not an empty string
  if name == "":
    return false

  if find(name, "_") >= 0:

    echo "The name may not contain underscores (use spaces or hyphens)"

    return false

  # Validate tokens
  var tokens = tokenize(name)

  for token in tokens.mitems:

    if isUpperAscii(token[0]) == false:
      token[0] = toUpperAscii(token[0])

  name = join(tokens, " ")

  # Validated OK
  return true


proc verifyAppNamePathDoesntExist(appTemplate: AppTemplate) =

  # Ensure appName-based path doesn't already exist
  let appNameLowerSnakeCase = getSnakeCaseName(appTemplate.appName)

  if dirExists(appNameLowerSnakeCase) == true:

    if promptForOverwrite(
         &"A directory called {appNameLowerSnakeCase} already exists.\n" &
          "Would you like to proceed and overwrite existing config files?") == false:

      quit(1)

