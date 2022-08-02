import os, strformat
import nexus/cmd/service/generate/web_artifacts/utils
import nexus/cmd/types/types


proc getWebArtifactFromProjectTemplate*(
       pathName: string,
       routes: Routes,
       projectTemplate: ProjectTemplate,
       generatorInfo: GeneratorInfo): WebArtifact =

  # Validate
  if generatorInfo.package == "":

    raise newException(
            ValueError,
            "generatorInfo.package is blank")

  # Create WebArtifact object
  var webArtifact =
        WebArtifact(
          artifact: projectTemplate.artifact,
          pathName: pathName,
          shortName: projectTemplate.appName,
          confPath: &"{projectTemplate.confWebApp}",
          srcPath: &"{projectTemplate.nimPathExpanded}{DirSep}" &
                   projectTemplate.appNameLowerInSnakeCase,
          routes: routes)

  enrichWebArtifaceNamesAndPaths(webArtifact)

  # Return
  return webArtifact

