import chronicles, os, streams, strformat, strutils, tables, yaml
import nexus/core/service/format/filename_utils
import nexus/core/service/format/name_utils
import nexus/cmd/service/generate/modules/module_utils
import nexus/cmd/types/types
import utils


proc readWebArtifactDefinitionFilePass1(
       artifact: string,
       pathName: string,
       webAppConfPath: string,
       generatorInfo: var GeneratorInfo) =

  debug "readWebArtifactDefinitionFilePass1()",
    webAppConfPath = webAppConfPath

  # Create WebArtifact object
  var
    basePath: string
    srcPath: string

    webArtifact =
      WebArtifact(
        artifact: artifact,
        package: generatorInfo.package)

  # Read web-app YAML
  if artifact == WebAppArtifact:

    var
      webAppYAML: WebAppYAML
      s = newFileStream(&"{webAppConfPath}/{pathName}.yaml")

    load(s, webAppYAML)
    s.close()

    # Populate webApp from webAppYaml
    webArtifact.shortName = webAppYAML.shortName
    webArtifact.description = webAppYAML.description
    webArtifact.mediaList = webAppYAML.mediaList

    basePath = webAppYAML.basePath
    srcPath = webAppYAML.srcPath

  elif artifact == WebServiceArtifact:

    var
      webServiceYAML: WebServiceYAML
      s = newFileStream(&"{webAppConfPath}/{pathName}.yaml")

    load(s, webServiceYAML)
    s.close()

    # Populate webApp from webServiceYAML
    webArtifact.shortName = webServiceYAML.shortName
    webArtifact.description = webServiceYAML.description

    basePath = webServiceYAML.basePath
    srcPath = webServiceYAML.srcPath

  else:
    raise newException(
            ValueError,
            &"Unhandled artifact: {artifact}")

  # Set initial paths
  webArtifact.confPath = webAppConfPath
  webArtifact.basePath = basePath
  webArtifact.srcPath = srcPath

  # Enrich names and paths
  enrichWebArtifaceNamesAndPaths(webArtifact)

  # Some processing on webApp
  echo &"found {artifact}: \"{webArtifact.shortName}\" in " &
       &"package: \"{webArtifact.package}\""
  echo &".. basePath \"{webArtifact.basePath}\""
  echo &".. srcPath \"{webArtifact.srcPath}\""

  var envVarsExpanded: bool

  envVarsExpanded = parseFilenameExpandEnvVars(webArtifact.basePath)

  if envVarsExpanded:
    echo &".. basePath (expanded): \"{webArtifact.basePath}\""

  envVarsExpanded = parseFilenameExpandEnvVars(webArtifact.srcPath)

  if envVarsExpanded:
    echo &".. srcPath (expanded): \"{webArtifact.srcPath}\""

  # Add webArtifact to generatorInfo
  generatorInfo.webArtifacts.add(webArtifact)

  # Add webApp as module
  addWebArtifactAsModule(
    webArtifact,
    generatorInfo)


proc readWebArtifactDefinitionFilesPass1*(
       artifact: string,
       confPath: string,
       generatorInfo: var GeneratorInfo) =

  # Get path name
  let pathName =
        replace(
          artifact,
          '-',
          '_')

  # Formulate path and return if not found
  let webAppsConfPath = &"{confPath}{DirSep}{pathName}s{DirSep}"

  if not dirExists(webAppsConfPath):
    return

  # Walk dir
  for kind, path in walkDir(webAppsConfPath,
                            relative = true):

    if path[0] == '.' or
       not @[ pcDir, pcLinkToDir ].contains(kind):

      continue

    debug "readWebArtifactDefinitionFilesPass1()",
      path = path

    readWebArtifactDefinitionFilePass1(
      artifact,
      pathName,
      webAppConfPath = webAppsConfPath & path,
      generatorInfo)


proc readWebArtifactDefinitionsPass1*(
       confPath: string,
       generatorInfo: var GeneratorInfo) =

  readWebArtifactDefinitionFilesPass1(
    artifact = "web-app",
    confPath,
    generatorInfo)

  readWebArtifactDefinitionFilesPass1(
    artifact = "web-service",
    confPath,
    generatorInfo)

