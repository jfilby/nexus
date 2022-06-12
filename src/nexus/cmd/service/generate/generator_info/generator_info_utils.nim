import os, strformat
import nexus/core/service/format/name_utils
import nexus/cmd/types/types


proc getModuleAndBasePathAndSrcPathByProgram*(
       package: string,
       shortName: string,
       generatorInfo: GeneratorInfo):
         (string,
          string,
          string) =

  # Search libraries
  for library in generatorInfo.libraries:

    if library.package == package and
       library.shortName == shortName:

      if not dirExists(library.basePath):
        raise newException(
                ValueError,
                &"library.basePath not found: {library.basePath} " &
                &"for package: {library.package} and " &
                &"for shortName: {library.shortName}")

      if not dirExists(library.srcPath):
        raise newException(
                ValueError,
                &"library.srcPath not found: {library.srcPath} " &
                &"for package: {library.package} and " &
                &"for shortName: {library.shortName}")

      return (getSnakeCaseName(library.shortName),
              library.basePath,
              library.srcPath)

  # Search web apps
  for webArtifact in generatorInfo.webArtifacts:

    if webArtifact.package == package and
       webArtifact.shortName == shortName:

      if not dirExists(webArtifact.basePath):
        raise newException(
                ValueError,
                &"webArtifact.basePath not found: {webArtifact.basePath} " &
                &"for package: {webArtifact.package} and " &
                &"for shortName: {webArtifact.shortName}")

      if not dirExists(webArtifact.srcPath):
        raise newException(
                ValueError,
                &"webArtifact.srcPath not found: {webArtifact.srcPath} " &
                &"for package: {webArtifact.package} and " &
                &"shortName: {webArtifact.shortName}")

      return (getSnakeCaseName(webArtifact.shortName),
              webArtifact.basePath,
              webArtifact.srcPath)

  # Not found
  echo &"Module with package: {package} shortName: {shortName} not found"

  if len(generatorInfo.libraries) > 0:

    echo ".. searched libraries:"

    for library in generatorInfo.libraries:

      echo &".. package: {library.package} shortName: {library.shortName}"

  if len(generatorInfo.webArtifacts) > 0:

    echo ".. searched web-apps and web-services:"

    for webArtifact in generatorInfo.webArtifacts:

        echo &".. package: {webArtifact.package} " &
             &"shortName: {webArtifact.shortName}"

  quit(1)

