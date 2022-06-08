import chronicles, os, strformat
import nexus/cmd/service/generate/modules/module_utils
import nexus/cmd/service/generate/web_artifacts/utils
import nexus/cmd/types/types
import nexus/core/service/format/filename_utils


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
                   appTemplate.moduleNameLowerSnakeCase,
          routes: routes)

  enrichWebArtifaceNamesAndPaths(webArtifact)

  # Return
  return webArtifact

