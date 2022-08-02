import os, strformat
import nexus/cmd/service/generate/main_config/write_file
import nexus/cmd/types/types


# Forward declarations
proc getPlatformVars*(projectTemplate: ProjectTemplate): PlatformVars


# Code
proc genAppNexusScript(projectTemplate: ProjectTemplate) =

  # Vars
  let dbPrefix = projectTemplate.projectNameInUpperSnakeCase

  # OS-specific vars
  var
    scriptFilename = &"{projectTemplate.basePath}{DirSep}env{DirSep}" &
      "nexus_app."

  let p = getPlatformVars(projectTemplate)

  # Add scriptFileExtension to scriptFilename
  scriptFilename &= p.scriptFileExtension

  # Define script content
  var scriptContent =
    &"{p.set} SERVER_IS_PRODUCTION=\"N\"\n" &
    &"{p.set} WEB_APP_INVITE_ONLY=N\n" &
    &"{p.set} WEB_APP_LOG_LEVEL=INFO\n" &
    &"{p.set} WEB_APP_PORT=5000\n" &
     "\n" &
     "\n" &
    &"{p.set} DEFAULT_DB_PREFIX={dbPrefix}\n" &
    &"{p.set} {dbPrefix}_DB_HOST={projectTemplate.dbServer}\n" &
    &"{p.set} {dbPrefix}_DB_PORT={projectTemplate.dbPort}\n" &
    &"{p.set} {dbPrefix}_DB_NAME={projectTemplate.dbName}\n" &
    &"{p.set} {dbPrefix}_USERNAME={projectTemplate.dbUsername}\n" &
    &"{p.set} {dbPrefix}_PASSWORD={projectTemplate.dbPassword}\n" &
     "\n" &
     "\n" &
    &"{p.set} {projectTemplate.projectNameInUpperSnakeCase}_BASE_PATH=" &
      &"{projectTemplate.basePath}\n" &
    &"{p.set} {projectTemplate.nimSrcPathEnvVar}=" &
      &"{projectTemplate.nimPath}\n" &
     "\n" &
     "\n"

  if projectTemplate.docUi == true:
    scriptContent &=
      &"{p.comment} DocUI path\n" &
      &"{p.set} DOCUI_SRC_PATH=\n" &
       "\n" &
       "\n"

  scriptContent &=
    &"{p.comment} Nexus paths\n" &
    &"{p.set} NEXUS_BASE_PATH={p.envStart}NEXUS_BASE_PATH{p.envEnd}{DirSep}src\n" &
     "\n" &
    &"{p.set} NEXUS_CORE_BASE_PATH={p.envStart}NEXUS_BASE_PATH{p.envEnd}{DirSep}" &
      "nexus_core\n" &
    &"{p.set} NEXUS_CORE_SRC_PATH={p.envStart}NEXUS_CORE_BASE_PATH{p.envEnd}" &
      &"{DirSep}src\n" &
     "\n" &
    &"{p.set} NEXUS_CORE_EXTRAS_BASE_PATH={p.envStart}NEXUS_BASE_PATH" &
      &"{p.envEnd}{DirSep}nexus_core_extras\n" &
    &"{p.set} NEXUS_CORE_EXTRAS_SRC_PATH={p.envStart}NEXUS_CORE_EXTRAS_BASE_PATH" &
      &"{p.envEnd}{DirSep}src\n" &
     "\n" &
    &"{p.set} NEXUS_SOCIAL_BASE_PATH={p.envStart}NEXUS_BASE_PATH{p.envEnd}" &
      &"{DirSep}nexus_social\n" &
    &"{p.set} NEXUS_SOCIAL_SRC_PATH={p.envStart}NEXUS_SOCIAL_BASE_PATH{p.envEnd}" &
      &"{DirSep}src\n" &
     "\n" &
     "\n" &
    &"{p.comment} Nim compile options\n" &
    &"{p.set} NIM_COMPILE_OPTIONS={p.docUiPath}" &
      &"--path:{p.envStart}NEXUS_CORE_SRC_PATH{p.envEnd} --threads:on " &
       "--verbosity:0 " &
      &"-d:chronicles_log_level:{p.envStart}WEB_APP_LOG_LEVEL{p.envEnd} " &
       "-d:chronicles_line_numbers -d:chronicles_colors:NativeColors\n" &
     "\n" &
    &"{p.set} EMAIL_FROM_ADDRESS=\n" &
    &"{p.set} EMAIL_FROM_SMTP_SERVER=\n" &
    &"{p.set} EMAIL_FROM_PORT=\n" &
    &"{p.set} EMAIL_FROM_USERNAME=\n" &
    &"{p.set} EMAIL_FROM_PASSWORD=\n" &
    &"{p.set} EMAIL_USE_SSL=\n" &
     "\n"

  # Write script file
  promptToOverwriteFile(
     "An environment script already exists:\n" &
    &"{scriptFilename}\n" &
     "Would you like to overwrite this file?",
    scriptFilename,
    scriptContent)


proc genEnvScripts*(projectTemplate: ProjectTemplate) =

  genAppNexusScript(projectTemplate)
  # genAppNexusWebScript(projectTemplate)


proc getPlatformVars*(projectTemplate: ProjectTemplate): PlatformVars =

  var p = PlatformVars()

  if projectTemplate.isUnix == true:
    p.scriptFileExtension = "sh"
    p.comment = "#"
    p.set = "export"
    p.envStart = "$"

    if projectTemplate.docUi == true:
      p.docUiPath = "--path:$DOCUI_SRC_PATH "

  else:
    p.scriptFileExtension = "bat"
    p.comment = "REM"
    p.set = "set"
    p.envStart = "%"
    p.envEnd = "%"

    if projectTemplate.docUi == true:
      p.docUiPath = "--path:\"%DOCUI_SRC_PATH%\" "

  # Return
  return p

