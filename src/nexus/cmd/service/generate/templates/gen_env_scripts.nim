import os, strformat
import nexus/cmd/service/generate/main_config/write_file
import nexus/cmd/types/types


# Forward declarations
proc getPlatformVars*(appTemplate: AppTemplate): PlatformVars


# Code
proc genAppNexusScript(appTemplate: AppTemplate) =

  # Vars
  let dbPrefix = appTemplate.appNameInUpperSnakeCase

  # OS-specific vars
  var
    scriptFilename = &"{appTemplate.basePath}{DirSep}env{DirSep}" &
      "nexus_app."

  let p = getPlatformVars(appTemplate)

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
    &"{p.set} {dbPrefix}_DB_HOST={appTemplate.dbServer}\n" &
    &"{p.set} {dbPrefix}_DB_PORT={appTemplate.dbPort}\n" &
    &"{p.set} {dbPrefix}_DB_NAME={appTemplate.dbName}\n" &
    &"{p.set} {dbPrefix}_USERNAME={appTemplate.dbUsername}\n" &
    &"{p.set} {dbPrefix}_PASSWORD={appTemplate.dbPassword}\n" &
     "\n" &
     "\n" &
    &"{p.set} {appTemplate.appNameInUpperSnakeCase}_BASE_PATH=" &
      &"{appTemplate.basePath}\n" &
    &"{p.set} {appTemplate.nimSrcPathEnvVar}=" &
      &"{appTemplate.nimPath}\n" &
     "\n" &
     "\n"

  if appTemplate.docUi == true:
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


proc genEnvScripts*(appTemplate: AppTemplate) =

  genAppNexusScript(appTemplate)
  # genAppNexusWebScript(appTemplate)


proc getPlatformVars*(appTemplate: AppTemplate): PlatformVars =

  var p = PlatformVars()

  if appTemplate.isUnix == true:
    p.scriptFileExtension = "sh"
    p.comment = "#"
    p.set = "export"
    p.envStart = "$"

    if appTemplate.docUi == true:
      p.docUiPath = "--path:$DOCUI_SRC_PATH "

  else:
    p.scriptFileExtension = "bat"
    p.comment = "REM"
    p.set = "set"
    p.envStart = "%"
    p.envEnd = "%"

    if appTemplate.docUi == true:
      p.docUiPath = "--path:\"%DOCUI_SRC_PATH%\" "

  # Return
  return p

