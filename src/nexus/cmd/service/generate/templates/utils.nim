import os, strformat
import nexus/cmd/service/generate/modules/module_utils
import nexus/cmd/service/generate/web_artifacts/utils
import nexus/cmd/types/types


proc getWebArtifactFromProjectTemplate*(
       pathName: string,
       routes: Routes,
       projectTemplate: ProjectTemplate,
       generatorInfo: var GeneratorInfo): WebArtifact =

  # Validate
  if generatorInfo.package == "":

    raise newException(
            ValueError,
            "generatorInfo.package is blank")

  # Create WebArtifact object
  var webArtifact =
        WebArtifact(
          package: generatorInfo.package,
          artifact: projectTemplate.artifact,
          pathName: pathName,
          shortName: projectTemplate.appName,
          confPath: &"{projectTemplate.confWebApp}",
          srcPath: &"{projectTemplate.nimPathExpanded}{DirSep}" &
                   projectTemplate.appNameLowerInSnakeCase,
          routes: routes)

  enrichWebArtifaceNamesAndPaths(webArtifact)

  # Add webApp as module
  addWebArtifactAsModule(
    webArtifact,
    generatorInfo)

  # Return
  return webArtifact

