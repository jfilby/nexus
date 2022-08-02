import chronicles, os, strformat, strutils
import nexus/core/service/format/filename_utils
import nexus/core/service/format/case_utils
import nexus/core/service/format/tokenize
import nexus/cmd/service/generate/main_config/gen_nexus_conf
import nexus/cmd/service/generate/main_config/write_file
import nexus/cmd/types/types
import console_app
import gen_env_scripts
import web_artifact


# Forward declarations
proc basicProjectTemplate(
       projectTemplate: ProjectTemplate,
       generatorInfo: GeneratorInfo)
proc notifyOfGenerateProjectTemplate(projectTemplate: ProjectTemplate)
proc promptForInfo(projectTemplate: var ProjectTemplate)
proc validateAndTransformName*(name: var string): bool
proc verifyProjectNamePathDoesntExist(projectTemplate: ProjectTemplate)


# Code
proc generateProjectTemplate*(
       artifact: string,
       generatorInfo: var GeneratorInfo) =

  var projectTemplate =
        ProjectTemplate(
          artifact: artifact,
          docUi: false)

  if DirSep == '/':
    projectTemplate.isUnix = true
    projectTemplate.compileScript = "compile.sh"

  else:
    projectTemplate.isUnix = false
    projectTemplate.compileScript = "compile"

  projectTemplate.cwd = getCurrentDir()

  # Notify of what will be created and where
  notifyOfGenerateProjectTemplate(projectTemplate)

  # Prompt for app info
  promptForInfo(projectTemplate)

  # Populate some initial fields for GeneratorInfo
  generatorInfo.package = projectTemplate.projectNameInSnakeCase

  # Setup for all types of basic
  basicProjectTemplate(
    projectTemplate,
    generatorInfo)

  # Generate env scripts
  genEnvScripts(projectTemplate)

  # Console app specific
  if artifact == "console-app":
    generateConsoleProjectTemplate(projectTemplate)

  # Web app specific
  elif artifact == "web-app" or
       artifact == "web-service":

    generateWebArtifactTemplate(
      projectTemplate,
      generatorInfo)


proc basicProjectTemplate(
       projectTemplate: ProjectTemplate,
       generatorInfo: GeneratorInfo) =

  debug "basicProjectTemplate"

  # Write the conf/nexus.yaml file
  generateMainConfigFile(
    projectTemplate,
    generatorInfo)

  # Create initial conf directories and files
  var
    confModels = &"{projectTemplate.applConfPath}{DirSep}models"
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
    tmpPath = &"{projectTemplate.basePath}{DirSep}tmp"
    envScriptsPath = &"{projectTemplate.basePath}{DirSep}env"
    binPath = &"{projectTemplate.applPath}{DirSep}bin"
    servicePath = &"{projectTemplate.applPath}{DirSep}service"

  discard parseFilenameExpandEnvVars(tmpPath)
  discard parseFilenameExpandEnvVars(envScriptsPath)
  discard parseFilenameExpandEnvVars(binPath)
  discard parseFilenameExpandEnvVars(servicePath)

  echo ".. creating tmp path: " & tmpPath
  createDir(tmpPath)

  echo ".. creating env path: " & envScriptsPath
  createDir(envScriptsPath)

  echo ".. creating bin path: " & binPath
  createDir(binPath)

  echo ".. creating service path: " & servicePath
  createDir(servicePath)


proc getDefaultAppName(projectTemplate: var ProjectTemplate) =

  case projectTemplate.artifact:

    of "console":
      projectTemplate.appName = "Console app"

    of "web-app":
      projectTemplate.appName = "Web-app"

    of "web-service":
      projectTemplate.appName = "Web-service"

    else:
      raise newException(
              ValueError,
              "Unhandled artifact as appType")


proc notifyOfGenerateProjectTemplate(projectTemplate: ProjectTemplate) =

  echo &"This will create a new {projectTemplate.artifact}."
  echo  "The project will be created in the current directory."
  echo  "The new directory name will be based on the application name."
  echo  ""


proc promptForInfo(projectTemplate: var ProjectTemplate) =

  # Prompt for project name
  echo ""
  echo "Project name, e.g. My Project (use full capitalization with spaces)."

  while true:

    stdout.write("> ")
    projectTemplate.projectName = readLine(stdin)

    if validateAndTransformName(projectTemplate.projectName) == true:
      break

    else:
      echo "Invalid capitalized name, please try again."
      echo ""

  # Ensure projectName-based path doesn't already exist
  verifyProjectNamePathDoesntExist(projectTemplate)

  # Formulate default app name
  getDefaultAppName(projectTemplate)

  # Prompt for initial app name
  echo ""
  echo ""
  echo  "Name of the initial app, e.g. Web-app (use full capitalization with spaces)."
  echo &"The default app name, based on your project type is: {projectTemplate.appName}"
  echo ""
  echo  "Press enter (leaving out the name) to use the default."

  while true:

    stdout.write("> ")
    let userInput = readLine(stdin)

    if userInput == "":
      break

    # Set and validate appName
    projectTemplate.appName = userInput

    if validateAndTransformName(projectTemplate.appName) == true:
      break

    else:
      echo "Invalid capitalized name, please try again."
      echo ""

  # Set vars
  let p = getPlatformVars(projectTemplate)

  # projectName processing
  projectTemplate.projectNameInSnakeCase =
    inSnakeCase(projectTemplate.projectName)

  projectTemplate.projectNameInUpperSnakeCase =
    toUpperAscii(projectTemplate.projectNameInSnakeCase)

  projectTemplate.projectNameInLowerSnakeCase =
    toLowerAscii(projectTemplate.projectNameInSnakeCase)

  # appName formulations
  projectTemplate.appNameInSnakeCase =
    inSnakeCase(projectTemplate.appName)

  projectTemplate.appNameUpperInSnakeCase =
    toUpperAscii(projectTemplate.appNameInSnakeCase)

  projectTemplate.appNameLowerInSnakeCase =
    toLowerAscii(projectTemplate.appNameInSnakeCase)

  # Path formulations
  projectTemplate.basePath =
    &"{projectTemplate.cwd}{DirSep}{projectTemplate.projectNameInSnakeCase}"

  projectTemplate.basePathEnvVar = &"{projectTemplate.projectNameInUpperSnakeCase}_BASE_PATH"
  projectTemplate.nimSrcPathEnvVar =
    &"{projectTemplate.projectNameInUpperSnakeCase}_BASE_SRC_PATH"

  projectTemplate.confPath = &"{projectTemplate.basePath}{DirSep}conf"

  projectTemplate.applConfPath = &"{projectTemplate.confPath}{DirSep}" &
    projectTemplate.appNameLowerInSnakeCase

  projectTemplate.nimPath =
    &"{p.envStart}{projectTemplate.basePathEnvVar}{p.envEnd}{DirSep}nim{DirSep}src"

  # The expanded path must be used right now because the environment var isn't
  # set yet (the env file itself must still be created)
  projectTemplate.nimPathExpanded =
    &"{projectTemplate.basePath}{DirSep}nim{DirSep}src"

  projectTemplate.applPath =
    &"{projectTemplate.nimPathExpanded}{DirSep}" &
    &"{projectTemplate.appNameLowerInSnakeCase}"

  # Initial DB settings template
  projectTemplate.dbServer = "localhost"
  projectTemplate.dbPort = "5432"
  projectTemplate.dbName = projectTemplate.projectNameInLowerSnakeCase
  projectTemplate.dbUsername = ""
  projectTemplate.dbPassword = ""


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


proc verifyProjectNamePathDoesntExist(projectTemplate: ProjectTemplate) =

  # Ensure projectName-based path doesn't already exist
  let projectNameInLowerSnakeCase = inSnakeCase(projectTemplate.projectName)

  if dirExists(projectNameInLowerSnakeCase) == true:

    if promptForOverwrite(
         &"A directory called {projectNameInLowerSnakeCase} already exists.\n" &
          "Would you like to proceed and overwrite existing config files?") == false:

      quit(1)

