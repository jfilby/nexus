import chronicles
import nexus/cmd/service/generate/modules/gen_context_procs
import nexus/cmd/service/generate/modules/gen_context_type
import nexus/cmd/types/types


proc generateContextCodeProjectTemplate*(
       module: Module,
       generatorInfo: GeneratorInfo) =

  debug "generateContextCodeProjectTemplate()"

  generateContextProc(
    module,
    generatorInfo)

  generateContextType(
    module,
    generatorInfo)

