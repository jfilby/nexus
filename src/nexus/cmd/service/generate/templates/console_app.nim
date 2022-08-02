import chronicles, os, strformat
import nexus/core/service/format/filename_utils
import nexus/cmd/service/generate/main_config/write_file
import nexus/cmd/types/types


proc generateConsoleProjectTemplate*(projectTemplate: ProjectTemplate) =

  debug "generateConsoleProjectTemplate"

  var
    programs = &"{projectTemplate.applPath}{DirSep}programs"
    consoleNim = &"{programs}{DirSep}{projectTemplate.appNameInSnakeCase}.nim"

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
    &"#    {projectTemplate.compileScript} {projectTemplate.appNameInSnakeCase}\n" &
     "# 2. Run with\n" &
    &"#    bin{DirSep}{projectTemplate.appNameInSnakeCase}\n")

  debug "generateConsoleProjectTemplate: done"

