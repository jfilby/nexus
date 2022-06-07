import chronicles, os, streams, strformat, yaml
import nexus/core/service/format/filename_utils
import nexus/core/service/format/name_utils
import nexus/cmd/service/generate/modules/module_utils
import nexus/cmd/types/types


proc readWebServiceDefinitionPass1(
       webAppConfPath: string,
       generatorInfo: var GeneratorInfo) =

  debug "readWebServiceDefinitionPass1()",
    webAppConfPath = webAppConfPath

  # Import web app YAML
  var
    webAppYaml: WebAppYAML
    s = newFileStream(&"{webAppConfPath}{DirSep}web_service.yaml")

  load(s, webAppYaml)
  s.close()

  # Populate webApp from webAppYaml
  var webApp = WebApp()

  webApp.appOrService = WebTypes.webService
  webApp.shortName = webAppYaml.shortName
  webApp.package = generatorInfo.package
  webApp.camelCaseName = getCamelCaseName(webApp.shortName)
  webApp.pascalCaseName = getPascalCaseName(webApp.shortName)
  webApp.snakeCaseName = getSnakeCaseName(webApp.shortName)
  webApp.description = webAppYaml.description
  webApp.confPath = resolveCrossPlatformPath(webAppConfPath)
  webApp.basePath = resolveCrossPlatformPath(webAppYaml.basePath)
  webApp.srcPath = resolveCrossPlatformPath(webAppYaml.srcPath)
  webApp.srcRelativePath = getRelativePath(webApp.srcPath)
  webApp.mediaList = webAppYaml.mediaList

  # Some processing on webApp
  echo &"found web app: \"{webApp.shortName}\" in " &
       &"package: \"{webApp.package}\""
  echo &".. basePath \"{webApp.basePath}\""
  echo &".. srcPath \"{webApp.srcPath}\""

  var envVarsExpanded: bool

  envVarsExpanded = parseFilenameExpandEnvVars(webApp.basePath)

  if envVarsExpanded:
    echo &".. basePath (expanded): \"{webApp.basePath}\""

  envVarsExpanded = parseFilenameExpandEnvVars(webApp.srcPath)

  if envVarsExpanded:
    echo &".. srcPath (expanded): \"{webApp.srcPath}\""

  # Add webApp to generatorInfo
  generatorInfo.webApps.add(webApp)

  # Add webApp as module
  addWebAppAsModule(
    webApp,
    generatorInfo)


proc readWebServiceDefinitionsPass1*(
       confPath: string,
       generatorInfo: var GeneratorInfo) =

  # Formulate path and return if not found
  let webAppsConfPath = &"{confPath}{DirSep}web_services{DirSep}"

  if not dirExists(webAppsConfPath):
    return

  # Walk dir
  for kind, path in walkDir(webAppsConfPath,
                            relative = true):

    if path[0] == '.' or
       not @[ pcDir,
              pcLinkToDir ].contains(kind):

      continue

    debug "readWebServiceDefinitionsPass1()",
      path = path

    readWebServiceDefinitionPass1(
      webAppConfPath = webAppsConfPath & path,
      generatorInfo)

