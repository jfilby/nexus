import os, strformat, strutils
import nexus/cmd/service/generate/modules/gen_module_type
import nexus/cmd/service/generate/modules/module_utils
import nexus/cmd/service/generate/routes/read_route_files_file
import nexus/cmd/service/generate/tmp_dict/tmp_dict_utils
import nexus/cmd/types/types
import deploy_media_list
import gen_web_app_files


proc generateWebApp(
       basePath: string,
       webApp: var WebApp,
       generatorInfo: var GeneratorInfo) =

  echo &"Web app: name: {webApp.shortName} confPath: {webApp.confPath}"

  # Verify web app's conf path
  if dirExists(webApp.confPath) == false:

    raise newException(
            ValueError,
            &"{webApp.shortName}'s webApp.confPath doesn't exist: " &
            &"{webApp.confPath}")

  if find(webApp.confPath,
          "web_app") < 0 and
     find(webApp.confPath,
          "web_service") < 0:

    raise newException(
            ValueError,
            &"{webApp.shortName}'s webApp.confPath doesn't contain " &
            &"a webApp or web_service sub-path: {webApp.confPath}")

  # Process routes
  if fileChanged(
       filename = &"{webApp.confPath}{DirSep}routes{DirSep}all_routes.yaml",
       generatorInfo.tmpDict) == true or
     generatorInfo.refresh == true:

    readRoutesFilesFile(
      basePath,
      routesPath = &"{webApp.confPath}{DirSep}routes",
      srcPath = webApp.srcPath,
      filename = &"{webApp.confPath}{DirSep}routes{DirSep}all_routes.yaml",
      webApp = webApp,
      generatorInfo = generatorInfo)

  # Generate module global vars file
  generateModuleGlobalVarsFile(webApp)

  # Generate web app nim file
  generateWebAppFiles(webApp)

  # Deploy media list
  deployMediaList(webApp)


proc generateWebApps*(
       basePath: string,
       generatorInfo: var GeneratorInfo) =

  for webApp in generatorInfo.webApps.mitems:

    # Get module to skip unwanted routes
    let module = getModuleByName(webApp.shortName,
                                 generatorInfo)

    if module.imported == true and
       not module.generate.contains("routes"):
    
      continue

    # Generate web app
    generateWebApp(basePath,
                   webApp,
                   generatorInfo)

