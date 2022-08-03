import os, strformat, strutils
import nexus/cmd/service/generate/modules/module_utils
import nexus/cmd/service/generate/routes/read_route_files
import nexus/cmd/service/generate/tmp_dict/tmp_dict_utils
import nexus/cmd/types/types
import deploy_media_list
import gen_initial_views
import gen_web_artifact_files


proc generateWebArtifact*(
       basePath: string,
       webArtifact: var WebArtifact,
       generatorInfo: var GeneratorInfo) =

  # Get module
  let module =
        getModuleByWebArtifact(
          webArtifact,
          generatorInfo)

  # echo &"Web artifact: name: {webArtifact.shortName}"
  # echo &"confPath: {webArtifact.confPath}"

  # Verify web app's conf path
  if dirExists(webArtifact.confPath) == false:

    raise newException(
            ValueError,
            &"{webArtifact.shortName}'s webArtifact.confPath doesn't exist: " &
            &"{webArtifact.confPath}")

  if find(webArtifact.confPath,
          "web_app") < 0 and
     find(webArtifact.confPath,
          "web_service") < 0:

    raise newException(
            ValueError,
            &"{webArtifact.shortName}'s webArtifact.confPath doesn't " &
            &"contain a web-app or web-service sub-path: " &
            &"{webArtifact.confPath}")

  # Process routes
  if fileChanged(
       filename = &"{webArtifact.confPath}{DirSep}routes{DirSep}all_routes.yaml",
       generatorInfo.tmpDict) == true or
     generatorInfo.refresh == true:

    readRoutesFiles(
      basePath,
      routesPath = &"{webArtifact.confPath}{DirSep}routes",
      srcPath = webArtifact.srcPath,
      webArtifact = webArtifact,
      generatorInfo = generatorInfo)

  # Generate web artifact nim file
  generateWebArtifactFiles(
    webArtifact,
    generatorInfo)

  # Generate initial views
  generateInitialViews(
    module,
    webArtifact)

  # Deploy media list
  deployMediaList(webArtifact)


proc generateWebArtifacts*(
       basePath: string,
       generatorInfo: var GeneratorInfo) =

  for webArtifact in generatorInfo.webArtifacts.mitems:

    # Get module to skip unwanted routes
    let module =
          getModuleByName(webArtifact.shortName,
                          generatorInfo)

    if module.imported == true and
       not module.generate.contains("routes"):
    
      continue

    # Generate web app
    generateWebArtifact(
      basePath,
      webArtifact,
      generatorInfo)

