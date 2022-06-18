import nexus/core/service/format/filename_utils
import nexus/core/service/format/case_utils
import nexus/cmd/types/types


proc enrichWebArtifaceNamesAndPaths*(webArtifact: var WebArtifact) =

  webArtifact.nameInCamelCase = inCamelCase(webArtifact.shortName)
  webArtifact.nameInPascalCase = inPascalCase(webArtifact.shortName)
  webArtifact.nameInSnakeCase = inSnakeCase(webArtifact.shortName)
  webArtifact.confPath = resolveCrossPlatformPath(webArtifact.confPath)
  webArtifact.basePath = resolveCrossPlatformPath(webArtifact.basePath)
  webArtifact.srcPath = resolveCrossPlatformPath(webArtifact.srcPath)
  webArtifact.srcRelativePath = getRelativePath(webArtifact.srcPath)

