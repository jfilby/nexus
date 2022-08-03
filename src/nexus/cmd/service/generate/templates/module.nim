import nexus/core/service/format/filename_utils
import nexus/cmd/service/generate/modules/module_utils
import nexus/cmd/types/types


proc createModuleFromProjectTemplate*(
       projectTemplate: ProjectTemplate,
       generatorInfo: GeneratorInfo):
         Module =

  var module = Module()

  # Naming
  module.package = generatorInfo.package
  module.shortName = projectTemplate.appName

  enrichModuleNaming(module)

  # Additional paths
  module.basePath = resolveCrossPlatformPath(projectTemplate.basePath)
  module.confPath = projectTemplate.confPath
  module.srcPath = resolveCrossPlatformPath(projectTemplate.appPath)
  module.srcRelativePath = getRelativePath(module.srcPath)

  # isWeb
  if @[ "web-app",
        "web-service" ].contains(projectTemplate.artifact):
    module.isWeb = true

  else:
    module.isWeb = false

  # Not imported
  module.imported = false

  return module

