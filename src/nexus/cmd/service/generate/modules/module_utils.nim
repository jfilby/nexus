import chronicles, options, os, streams, strformat, strutils, yaml
import nexus/core/service/format/filename_utils
import nexus/core/service/format/name_utils
import nexus/cmd/types/types


# Forward declarations
proc addModule(module: Module,
               generatorInfo: var GeneratorInfo,
               ignoreDuplicate: bool = false)
proc enrichModuleNaming(module: var Module)


# Code
proc addLibraryAsModule*(
       libraryYaml: LibraryYAML,
       generatorInfo: var GeneratorInfo,
       package: Option[PackageYAML] = none(PackageYAML)) =

  debug "addLibraryAsModule()"

  # Create module
  var module = Module()

  # Naming
  module.package = generatorInfo.package
  module.shortName = libraryYaml.shortName

  enrichModuleNaming(module)

  # Additional paths
  module.basePath = resolveCrossPlatformPath(libraryYaml.basePath)
  module.confPath =
    &"{libraryYaml.basePath}{DirSep}conf{DirSep}{module.snakeCaseName}"
  module.srcPath = resolveCrossPlatformPath(libraryYaml.srcPath)
  module.srcRelativePath = getRelativePath(module.srcPath)

  module.imported = false

  # Debug
  debug "addLibraryAsModule()",
    moduleName = module.name

  # Set package details
  if package != none(PackageYAML):

    module.package = package.get.package
    module.generate = package.get.generate
    module.imported = true

  # Add module
  addModule(module,
            generatorInfo)


proc addModule(module: Module,
               generatorInfo: var GeneratorInfo,
               ignoreDuplicate: bool = false) =

  # Verify
  if module.package == "":
    raise newException(
      ValueError,
      &"module.package is \"\" for module.shortName: {module.shortName}")

  # Unique name check
  for existingModule in generatorInfo.modules:

    if existingModule.name == module.name:

      if ignoreDuplicate == true:
        return

      raise newException(ValueError,
                         &"Module: {module.name} already exists")

  # Add module
  generatorInfo.modules.add(module)


proc findAndLoadLibraryYAMLFile(
       confPath: string,
       module: Module): LibraryYAML =

  # Formulate and verify path
  let path = resolveCrossPlatformPath(
               &"{confPath}{DirSep}{module.snakeCaseShortName}" &
               &"{DirSep}libraries")

  if not dirExists(path):

    raise newException(
            ValueError,
            &"Library path not found: {path}")

  # Formulate filename and load YAML
  let filename = &"{path}{DirSep}library.yaml"

  debug "findAndLoadLibraryYAMLFile()",
    filename = filename

  if not fileExists(filename):

    raise newException(
            ValueError,
            &"Library file not found: {filename}")

  var
    library: LibraryYAML
    s = newFileStream(filename)

  load(s, library)
  s.close()

  return library


proc getPackageModules*(
       packageYaml: PackageYAML,
       generatorInfo: var GeneratorInfo): Modules =

  # Debug
  let
    packageName = packageYaml.package
    packageConfPath = packageYaml.confPath

  debug "getPackageAsModule()",
    packageName = packageName,
    packageConfPath = packageConfPath

  discard packageName
  discard packageConfPath

  var modules: Modules

  for moduleShortName in packageYaml.moduleShortNames:

    # Module
    var module = Module()

    module.shortName = moduleShortName
    module.package = packageYaml.package

    enrichModuleNaming(module)

    # Additional paths
    module.confPath = resolveCrossPlatformPath(packageYaml.confPath)

    # Load library
    var library = findAndLoadLibraryYAMLFile(
                    packageYaml.confPath,
                    module)

    let
      moduleShortNameLower = toLowerAscii(module.shortName)
      libraryShortNameLower = toLowerAscii(library.shortName)

    # Verify imported library name
    if moduleShortNameLower != libraryShortNameLower or
       module.package != library.package:

      raise newException(
              ValueError,
              &"Import module: {moduleShortNameLower} (lowercased) " &
              &"package: {module.package} doesn't match " &
              &"library module: {libraryShortNameLower} (lowercased) " &
              &"package: {library.package}")

    # Get cross-platform paths
    library.basePath = resolveCrossPlatformPath(packageYaml.generateBasePath)
    library.srcPath = resolveCrossPlatformPath(packageYaml.generateSrcPath)

    # Verify library paths
    if not dirExists(library.basePath):

      raise newException(ValueError,
                         "Imported library basePath doesn't exist: " &
                         &"{library.basePath}")

    # Verify library paths
    if not dirExists(library.srcPath):

      raise newException(ValueError,
                         "Imported library srcPath doesn't exist: " &
                         &"{library.srcPath}")

    # Add library as module
    addLibraryAsModule(library,
                       generatorInfo,
                       some(packageYaml))

    # Add to libraries
    generatorInfo.libraries.add(library)

    # Add to modules
    modules.add(module)

  return modules


proc addModules*(modules: var Modules,
                 modules_to_add: Modules) =

  for moduleToAdd in modules_to_add:

    var module_exists = false

    for module in modules:

      if moduleToAdd.name == module.name:
        module_exists = true

    if module_exists == false:
      modules.add(moduleToAdd)


proc addWebAppAsModule*(
       webApp: WebApp,
       generatorInfo: var GeneratorInfo) =

  # Module
  var module = Module()

  # Naming
  module.package = generatorInfo.package
  module.shortName = webApp.shortName

  debug "addWebAppAsModule",
    modulePackage = module.package,
    moduleShortName = module.shortName

  enrichModuleNaming(module)

  # Additional paths
  module.basePath = resolveCrossPlatformPath(webApp.basePath)
  module.confPath =
    resolveCrossPlatformPath(
      &"{webApp.basePath}{DirSep}conf{DirSep}web_apps{DirSep}" &
      &"{webApp.snakeCaseName}")

  module.srcPath = resolveCrossPlatformPath(webApp.srcPath)
  module.srcRelativePath = getRelativePath(module.srcPath)

  module.imported = false

  addModule(module,
            generatorInfo,
            ignoreDuplicate = true)


proc getModuleByName*(shortName: string,
                      generatorInfo: GeneratorInfo): Module =

  for module in generatorInfo.modules:

    if module.package == generatorInfo.package and
       module.shortName == shortName:

      return module

  raise newException(
          ValueError,
          &"Module not found by package: {generatorInfo.package} and " &
          &"shortName: {shortName}")


proc getModuleByLibrary*(
       libraryYaml: LibraryYAML,
       generatorInfo: GeneratorInfo): Module =

  let libraryShortNameLower = toLowerAscii(libraryYaml.shortName)

  for module in generatorInfo.modules:

    let moduleShortNameLower = toLowerAscii(module.shortName)

    debug "getModuleByLibrary(): comparing..",
      moduleShortNameLower = moduleShortNameLower,
      libraryShortNameLower = libraryShortNameLower,
      modulePackage = module.package,
      libraryYamlPackage = libraryYaml.package

    if moduleShortNameLower == libraryShortNameLower and
       module.package == libraryYaml.package:
      return module

  raise newException(
          ValueError,
          &"Module not found by " &
          &"libraryYaml.shortName: {libraryShortNameLower} (lowercased) and " &
          &"libraryYaml.package: {libraryYaml.package}")


proc getModulesByModels*(
       models: Models,
       generatorInfo: GeneratorInfo): Modules =

  var
    has_module = false
    modules: Modules

  for model in models:

    has_module = false

    for module in modules:
      if module.name == model.module.name:
        has_module = true
        break

    if has_module == false:
      modules.add(model.module)

  return modules


proc getModuleByWebApp*(webApp: WebApp,
                        generatorInfo: GeneratorInfo): Module =

  for module in generatorInfo.modules:

    if module.shortName == webApp.shortName and
       module.package == webApp.package:
      return module

  raise newException(
          ValueError,
          &"Module not found by " &
          &"webApp.shortName: {webApp.shortName} and " &
          &"webApp.package: {webApp.package}")


proc getModules*(models: Models,
                 webApp: WebApp,
                 generatorInfo: GeneratorInfo): Modules =

  var modules =
        getModulesByModels(
          models,
          generatorInfo)

  let webAppModule =
        getModuleByWebApp(
          webApp,
          generatorInfo)

  var webAppModuleFound = false

  for module in modules:

    if module.shortName == webApp.shortName and
       module.package == webApp.package:

      webAppModuleFound = true

  if webAppModuleFound == false:
    modules.add(webAppModule)

  # Verify
  if len(modules) == 0 and
     len(models) > 0:

    raise newException(ValueError,
                       "No modules found, but expected")

  return modules


proc getModelTypesImportByModule*(module: Module): string =

  return module.snakeCaseName & &"{DirSep}types{DirSep}model_types"


proc enrichModuleNaming(module: var Module) =

  # Validation
  if module.shortName == "":

    raise newException(
            ValueError,
            "module.shortName is a blank string")

  if module.package == "":

    raise newException(
            ValueError,
            "module.package is a blank string")

  # Name conversions and assignments
  let
    packagePascalCase = getPascalCaseName(module.package)
    packageSnakeCase = getSnakeCaseName(module.package)

  if module.package != packageSnakeCase:
    raise newException(
            ValueError,
            "Package name is expected to be in snake case")

  module.name = &"{packageSnakeCase} {module.shortName}"

  module.camelCaseName = getCamelCaseName(module.name)
  module.pascalCaseName = getPascalCaseName(module.name)
  module.snakeCaseName = getSnakeCaseName(module.name)
  module.snakeCaseShortName = getSnakeCaseName(module.shortName)

  # Import path
  module.importPath = &"{module.package}/{module.snakeCaseShortName}"

