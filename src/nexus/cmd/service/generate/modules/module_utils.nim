import chronicles, options, os, streams, strformat, strutils, yaml
import nexus/core/service/format/filename_utils
import nexus/core/service/format/case_utils
import nexus/cmd/types/types


# Forward declarations
proc addModule(module: Module,
               generatorInfo: var GeneratorInfo,
               ignoreDuplicate: bool = false)
proc enrichModuleNaming*(module: var Module)


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
    &"{libraryYaml.basePath}{DirSep}conf{DirSep}{module.nameInSnakeCase}"
  module.srcPath = resolveCrossPlatformPath(libraryYaml.srcPath)
  module.srcRelativePath = getRelativePath(module.srcPath)

  module.imported = false

  # Set isWeb
  module.isWeb = false

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
  debug "addModule(): adding module"

  generatorInfo.modules.add(module)


proc findAndLoadLibraryYAMLFile(
       confPath: string,
       module: Module): LibraryYAML =

  # Formulate and verify path
  let path = resolveCrossPlatformPath(
               &"{confPath}{DirSep}{module.shortNameInSnakeCase}" &
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

  debug "getPackageModules()",
    packageName = packageName,
    packageConfPath = packageConfPath,
    dirSep = $DirSep

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

    debug "getPackageModules()",
      moduleConfPath = module.confPath

    # Load library
    var library =
          findAndLoadLibraryYAMLFile(
            module.confPath,
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

    # Set isWeb
    module.isWeb = false

    # Add library as module
    addLibraryAsModule(library,
                       generatorInfo,
                       some(packageYaml))

    # Add to libraries
    generatorInfo.libraries.add(library)

    # Add to modules
    debug "getPackageModules(): adding module"

    modules.add(module)

  return modules


proc addModules*(modules: var Modules,
                 modulesToAdd: Modules) =

  for moduleToAdd in modulesToAdd:

    var module_exists = false

    for module in modules:

      if moduleToAdd.name == module.name:
        module_exists = true

    if module_exists == false:
      debug "addModules(): adding module"

      modules.add(moduleToAdd)


proc addWebArtifactAsModule*(
       webArtifact: WebArtifact,
       generatorInfo: var GeneratorInfo) =

  # Module
  var module = Module()

  # Naming
  module.package = generatorInfo.package
  module.shortName = webArtifact.shortName

  debug "addWebArtifactAsModule",
    modulePackage = module.package,
    moduleShortName = module.shortName

  enrichModuleNaming(module)

  # Additional paths
  module.basePath = resolveCrossPlatformPath(webArtifact.basePath)
  module.confPath =
    resolveCrossPlatformPath(
      &"{webArtifact.basePath}{DirSep}conf{DirSep}web_apps{DirSep}" &
      &"{webArtifact.nameInSnakeCase}")

  module.srcPath = resolveCrossPlatformPath(webArtifact.srcPath)
  module.srcRelativePath = getRelativePath(module.srcPath)

  # Set isWeb
  module.isWeb = true

  # Not imported
  module.imported = false

  # Add module
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
    hasModule = false
    modules: Modules

  for model in models:

    hasModule = false

    for module in modules:
      if module.name == model.module.name:
        hasModule = true
        break

    if hasModule == false:
      debug "getModulesByModels(): adding module"

      modules.add(model.module)

  return modules


proc getModuleByWebArtifact*(
       webArtifact: WebArtifact,
       generatorInfo: GeneratorInfo): Module =

  for module in generatorInfo.modules:

    if module.shortName == webArtifact.shortName and
       module.package == webArtifact.package:
      return module

  raise newException(
          ValueError,
          &"Module not found by " &
          &"webArtifact.shortName: {webArtifact.shortName} and " &
          &"webArtifact.package: {webArtifact.package}")


proc getModules*(models: Models,
                 webArtifact: WebArtifact,
                 generatorInfo: GeneratorInfo): Modules =

  var modules =
        getModulesByModels(
          models,
          generatorInfo)

  let webAppModule =
        getModuleByWebArtifact(
          webArtifact,
          generatorInfo)

  var webArtifactModuleFound = false

  for module in modules:

    if module.shortName == webArtifact.shortName and
       module.package == webArtifact.package:

      webArtifactModuleFound = true

  if webArtifactModuleFound == false:
    debug "getModules(): adding module"

    modules.add(webAppModule)

  # Verify
  if len(modules) == 0 and
     len(models) > 0:

    raise newException(ValueError,
                       "No modules found, but expected")

  return modules


proc getModelTypesImportByModule*(module: Module): string =

  return module.nameInSnakeCase & &"{DirSep}types{DirSep}model_types"


proc enrichModuleNaming*(module: var Module) =

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
  let packageSnakeCase = inSnakeCase(module.package)

  if module.package != packageSnakeCase:
    raise newException(
            ValueError,
            "Package name is expected to be in snake case")

  module.name = &"{packageSnakeCase} {module.shortName}"

  module.nameInCamelCase = inCamelCase(module.name)
  module.nameInPascalCase = inPascalCase(module.name)
  module.nameInSnakeCase = inSnakeCase(module.name)
  module.shortNameInSnakeCase = inSnakeCase(module.shortName)

  # Import path
  module.importPath = &"{module.package}/{module.shortNameInSnakeCase}"

