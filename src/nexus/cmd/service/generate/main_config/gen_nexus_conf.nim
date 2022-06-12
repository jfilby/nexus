import os, streams, strformat, yaml
import nexus/cmd/types/types
import nexus/core/service/format/type_utils


type
  NexusYAML* = object
    app_name*: string
    package*: string


proc generateMainConfigFile*(
       appTemplate: AppTemplate,
       generatorInfo: GeneratorInfo) =

  let
    nexusYamlFilename = &"{appTemplate.confPath}{DirSep}nexus.yaml"
    nexusYamlStr =
       "%YAML 1.2\n" &
       "---\n" &
       "\n" &
      &"app_name: {appTemplate.appName}\n" &
      &"package: {generatorInfo.package}\n" &
       "\n"

  # Create conf directory if it doesn't exist
  if not dirExists(appTemplate.confPath):
    createDir(appTemplate.confPath)

  # Write nexus.yaml file
  writeFile(nexusYamlFilename,
            nexusYamlStr)


proc readNexusYaml*(confPath: string):
       (bool,
        GeneratorInfo) =

  var generatorInfo = GeneratorInfo()

  # Read conf/nexus.yaml file if present
  let nexusYamlFilename = &"{confPath}{DirSep}nexus.yaml"

  if not fileExists(nexusYamlFilename):

    return (false,
            generatorInfo)

  # Read YAML
  var
    nexusYAML: NexusYAML
    s = newFileStream(nexusYamlFilename)

  load(s, nexusYAML)
  s.close()

  # Validate
  if isLowerAscii(nexusYAML.package) == false:

    echo &"Error: package in conf{DirSep}nexus.yaml isn't all lowercase: " &
         nexusYAML.package

    quit(1)

  # Assign to generatorInfo properties
  generatorInfo.appName = nexusYAML.appName
  generatorInfo.package = nexusYAML.package

  return (true,
          generatorInfo)

