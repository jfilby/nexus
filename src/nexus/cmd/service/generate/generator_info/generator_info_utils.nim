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
  for webApp in generatorInfo.webApps:

    if webApp.package == package and
       webApp.shortName == shortName:

      if not dirExists(webApp.basePath):
        raise newException(
                ValueError,
                &"webApp.basePath not found: {webApp.basePath} " &
                &"for package: {webApp.package} and " &
                &"for shortName: {webApp.shortName}")

      if not dirExists(webApp.srcPath):
        raise newException(
                ValueError,
                &"webApp.srcPath not found: {webApp.srcPath} " &
                &"for package: {webApp.package} and " &
                &"shortName: {webApp.shortName}")

      return (getSnakeCaseName(webApp.shortName),
              webApp.basePath,
              webApp.srcPath)

  raise newException(
          ValueError,
          &"Module with package: {package} shortName: {shortName} not found")

