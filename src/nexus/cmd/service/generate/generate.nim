import os, strformat
import nexus/cmd/service/generate/libraries/read_libraries
import nexus/cmd/service/generate/main_config/gen_nexus_conf
import nexus/cmd/service/generate/models/process_all_models
import nexus/cmd/service/generate/modules/gen_context_procs
import nexus/cmd/service/generate/modules/gen_context_type
import nexus/cmd/service/generate/modules/gen_db_context_procs
import nexus/cmd/service/generate/packages/import_packages
import nexus/cmd/service/generate/templates/gen_project_template
import nexus/cmd/service/generate/tmp_dict/tmp_dict_utils
import nexus/cmd/service/generate/web_artifacts/gen_web_artifact
import nexus/cmd/service/generate/web_artifacts/read_web_artifacts
import nexus/cmd/service/results/results_utils
import nexus/cmd/types/types


# Forward declarations
proc generateModulesConfig(
       generatorInfo: var GeneratorInfo,
       artifact: string,
       basePath: string,
       refresh: string)


# Code
proc generate*(artifact: string,
               basePath: string,
               refresh: string,
               overwrite: bool) =

  # Try to read conf/nexus.yaml (might not exist yet)
  var (nexusYamlExists,
       generatorInfo) =
        readNexusYaml(&"{basePath}{DirSep}conf")

  # Settings
  generatorInfo.overwrite = overwrite

  # Generate an app (only)
  if @[ "console-app",
        "web-app",
        "web-service",
        "library" ].contains(artifact):

    # If nexus.conf already exists
    if nexusYamlExists == true:
      echo "Can't proceed with generating a new application, " &
           "conf/nexus.yaml already exists"

    # Generate app template (if specified)
    generateProjectTemplate(
      artifact,
      generatorInfo)

    printGeneratorInfoResults(generatorInfo)

  else:
    # If nexus.yaml doesn't exist then exit
    if nexusYamlExists == false:
      echo "Can't proceed, conf/nexus.yaml doesn't exist"
      quit(1)

    # Process config for all modules under the conf directory
    generateModulesConfig(
      generatorInfo,
      artifact,
      basePath,
      refresh)


proc generateModuleConfig(
       generatorInfo: var GeneratorInfo,
       artifact: string,
       basePath: string,
       refresh: string,
       confPath: string) =

  # Set refresh
  if refresh != "":
    generatorInfo.refresh = true

  else:
    generatorInfo.refresh = false

  # Get or create tmp dict (cache file)
  generatorInfo.tmpDict = getOrCreateTmpDict("tmp/tmp_dict.yaml")

  # Process Nimble packages
  importPackages(
    confPath,
    generatorInfo)

  # Read library
  readLibraryDefinitionsPass1(
    confPath,
    generatorInfo)

  # Read web artifact definitions
  # Read these even if not generating web-apps/services as they could be
  # referenced elsewhere (they are registered as modules)
  readWebArtifactDefinitionsPass1(
    confPath,
    generatorInfo)

  # Process project models
  if @[ "console-app",
        "models",
        "library",
        "web-app",
        "web-service" ].contains(artifact):

    processAllModels(
      confPath,
      generatorInfo)

    # Generate Program and Context code
    # generateProgramProcs(generatorInfo)
    generateDbContextProcs(generatorInfo)

  # Generate context code
  generateContextProcs(generatorInfo)
  generateContextTypes(generatorInfo)

  # Read library and web app definitions
  readLibraryDefinitionsPass2(
    confPath,
    generatorInfo)

  # Process web apps
  if @[ "web-app",
        "web-service",
        "web-routes" ].contains(artifact):

    generateWebArtifacts(
      confPath,
      generatorInfo)

  # Write tmpDict
  writeTmpDict(generatorInfo.tmpDict,
               "tmp/tmp_dict.yaml")

  printGeneratorInfoResults(generatorInfo)


proc generateModulesConfig(
       generatorInfo: var GeneratorInfo,
       artifact: string,
       basePath: string,
       refresh: string) =

  # Check for tmp path
  tmpDictChecks()

  # Generate module config per conf/module path
  for pathType, confPath in walkDir("conf"):

    if @[ pcDir,
          pcLinkToDir ].contains(pathType):

      generateModuleConfig(
        generatorInfo,
        artifact,
        basePath,
        refresh,
        confPath)

