import chronicles, os, strformat
import nexus/cmd/service/generate/tmp_dict/tmp_dict_utils
import nexus/cmd/types/types
import read_model_files


proc processAllModels*(
       confPath: string,
       generatorInfo: var GeneratorInfo) =

  var
    path: string
    modelConfPaths: seq[string]
    modelFileRead: seq[string]

  # Get all conf paths
  path = &"{confPath}{DirSep}models"
  modelConfPaths.add(path)

  debug "processAllModels(): added path",
    path = path

  # Get imported conf paths
  for module in generatorInfo.modules:

    path = &"{module.confPath}{DirSep}models{DirSep}{module.nameInSnakeCase}"

    debug "processAllModels(): possible import path",
      path = path,
      imported = module.imported,
      generate = module.generate

    if module.imported == true and
       module.generate.contains("models"):

      if fileChanged(path,
                     generatorInfo.tmpDict) or
         generatorInfo.refresh == true:

        modelConfPaths.add(path)

        debug "processAllModels(): added imported path",
          path = path

  # Read models from paths and process them
  readModelFilesPaths(modelFileRead,
                      confPath,
                      modelConfPaths,
                      generatorInfo)

