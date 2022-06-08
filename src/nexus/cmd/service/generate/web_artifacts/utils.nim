import nexus/core/service/format/filename_utils
import nexus/core/service/format/name_utils
import nexus/cmd/types/types


proc enrichWebArtifaceNamesAndPaths*(webArtifact: var WebArtifact) =

  webArtifact.camelCaseName = getCamelCaseName(webArtifact.shortName)
  webArtifact.pascalCaseName = getPascalCaseName(webArtifact.shortName)
  webArtifact.snakeCaseName = getSnakeCaseName(webArtifact.shortName)
  webArtifact.confPath = resolveCrossPlatformPath(webArtifact.confPath)
  webArtifact.basePath = resolveCrossPlatformPath(webArtifact.basePath)
  webArtifact.srcPath = resolveCrossPlatformPath(webArtifact.srcPath)
  webArtifact.srcRelativePath = getRelativePath(webArtifact.srcPath)

