REM Paths
set NEXUS_BASE_PATH=C:\Dev\Nexus\src
set NEXUS_BIN_PATH=C:\Dev\Nexus\bin

set NEXUS_CORE_SRC_PATH=%NEXUS_BASE_PATH%\core
set NEXUS_CORE_EXTRAS_SRC_PATH=%NEXUS_BASE_PATH%\core_extras
set NEXUS_CMD_SRC_PATH=%NEXUS_BASE_PATH%\cmd
set NEXUS_CRM_SRC_PATH=%NEXUS_BASE_PATH%\crm
set NEXUS_SOCIAL_SRC_PATH=%NEXUS_BASE_PATH%\social

set WEB_APP_INVITE_ONLY=Y
set WEB_APP_LOG_LEVEL=INFO
set WEB_APP_PORT=5000

REM set NIM_COMPILE_OPTIONS=--passL:"path_to_openssl\libeay32.dll" --passL:"path_to_openssl\ssleay32.dll" --path:"%DOCUI_SRC_PATH%" --path:"%EXS_SRC_PATH%" -d:ssl -d:chronicles_log_level:%WEB_APP_LOG_LEVEL% -d:chronicles_line_numbers -d:chronicles_colors:NativeColors -d:chronicles_sinks:json[file]

set NIM_COMPILE_OPTIONS=--passL:"path_to_openssl\libcrypto-1_1-x64.dll" --passL:"path_to_openssl\libssl-1_1-x64.dll" --path:"%DOCUI_SRC_PATH%" --path:"%EXS_SRC_PATH%" -d:ssl -d:chronicles_log_level:%WEB_APP_LOG_LEVEL% -d:chronicles_line_numbers -d:chronicles_colors:NativeColors -d:chronicles_sinks:json[file]

