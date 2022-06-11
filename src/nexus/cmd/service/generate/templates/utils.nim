import os, strformat
import nexus/cmd/service/generate/web_artifacts/utils
import nexus/cmd/types/types


proc getWebArtifactFromAppTemplate*(
       pathName: string,
       routes: Routes,
       appTemplate: AppTemplate,
       generatorInfo: GeneratorInfo): WebArtifact =

  # Validate
  if generatorInfo.package == "":

    raise newException(
            ValueError,
            "generatorInfo.package is blank")

  # Create WebArtifact object
  var webArtifact =
        WebArtifact(
          artifact: appTemplate.artifact,
          pathName: pathName,
          shortName: appTemplate.moduleName,
          confPath: &"{appTemplate.confPath}{DirSep}{pathName}",
          srcPath: &"{appTemplate.nimPathExpanded}{DirSep}" &
                   appTemplate.moduleNameLowerInSnakeCase,
          routes: routes)

  enrichWebArtifaceNamesAndPaths(webArtifact)

  # Return
  return webArtifact

