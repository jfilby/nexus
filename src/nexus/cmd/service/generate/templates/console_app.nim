import chronicles, os, strformat
import nexus/core/service/format/filename_utils
import nexus/cmd/service/generate/main_config/write_file
import nexus/cmd/types/types


proc generateConsoleAppTemplate*(appTemplate: AppTemplate) =

  debug "generateConsoleAppTemplate"

  var
    programs = &"{appTemplate.modulePath}{DirSep}programs"
    consoleNim = &"{programs}{DirSep}{appTemplate.moduleNameInSnakeCase}.nim"

  discard parseFilenameExpandEnvVars(programs)
  discard parseFilenameExpandEnvVars(consoleNim)

  echo ".. creating programs path: " & programs
  createDir(programs)

  # Check if consoleNim file already exists, prompt for overwrite
  promptToOverwriteFile(
     "A console program file already exists:\n" &
    &"{consoleNim}\n" &
     "Would you like to overwrite this file?",
    consoleNim,
     "# Write your console app here then:\n" &
     "# 1. Compile with:\n" &
    &"#    {appTemplate.compileScript} {appTemplate.moduleNameInSnakeCase}\n" &
     "# 2. Run with\n" &
    &"#    bin{DirSep}{appTemplate.moduleNameInSnakeCase}\n")

  debug "generateConsoleAppTemplate: done"

