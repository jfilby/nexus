import chronicles, os, streams, strformat, strutils, yaml
import nexus/core/service/format/filename_utils
import nexus/core/service/format/type_utils
import nexus/cmd/service/generate/modules/module_utils
import nexus/cmd/types/types


proc readConsoleAppDefinition*(
       consoleAppPath: string,
       generatorInfo: var GeneratorInfo) =

  debug "readConsoleAppDefinition()",
    consoleAppPath = consoleAppPath

  readLibraryDefinition(
    consoleAppPath,
    generatorInfo)

