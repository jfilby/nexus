import nexus/core/service/format/filename_utils
import nexus/core/service/format/name_utils
import nexus/cmd/types/types


proc enrichWebArtifaceNamesAndPaths*(webArtifact: var WebArtifact) =

  webArtifact.nameInCamelCase = getCamelCaseName(webArtifact.shortName)
  webArtifact.nameInPascalCase = getnameInPascalCase(webArtifact.shortName)
  webArtifact.nameInSnakeCase = getSnakeCaseName(webArtifact.shortName)
  webArtifact.confPath = resolveCrossPlatformPath(webArtifact.confPath)
  webArtifact.basePath = resolveCrossPlatformPath(webArtifact.basePath)
  webArtifact.srcPath = resolveCrossPlatformPath(webArtifact.srcPath)
  webArtifact.srcRelativePath = getRelativePath(webArtifact.srcPath)

