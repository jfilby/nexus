REM Paths
set NEXUS_PACKAGE=nexus
set NEXUS_BASE_PATH=C:\Home\NexusDev\nexus
set NEXUS_SRC_PATH=C:\Home\NexusDev\nexus\src\nexus
set NEXUS_BIN_PATH=C:\Home\NexusDev\Nexus\bin
set NEXUS_PLUS_BASE_PATH=C:\Home\NexusDev\nexus_plus
set NEXUS_PLUS_SRC_PATH=C:\Home\NexusDev\nexus_plus\src\nexus_plus

set NEXUS_CORE_SRC_PATH=%NEXUS_SRC_PATH%\core
set NEXUS_CORE_EXTRAS_SRC_PATH=%NEXUS_SRC_PATH%\core_extras
set NEXUS_CMD_SRC_PATH=%NEXUS_SRC_PATH%\cmd
set NEXUS_CRM_SRC_PATH=%NEXUS_SRC_PATH%\crm
set NEXUS_SOCIAL_SRC_PATH=%NEXUS_SRC_PATH%\social

set WEB_APP_INVITE_ONLY=Y
set WEB_APP_LOG_LEVEL=INFO
set WEB_APP_PORT=5000

REM set NIM_COMPILE_OPTIONS=--passL:"C:\Home\Development\openssl-1.0.2u-x64_86-win64\libeay32.dll" --passL:"C:\Home\Development\openssl-1.0.2u-x64_86-win64\ssleay32.dll" --path:"%DOCUI_SRC_PATH%" --path:"%EXS_SRC_PATH%" -d:ssl -d:chronicles_log_level:%WEB_APP_LOG_LEVEL% -d:chronicles_line_numbers -d:chronicles_colors:NativeColors -d:chronicles_sinks:json[file]

set NIM_COMPILE_OPTIONS=--passL:"C:\Home\Development\openssl-1.1.1m-light-x64_86-win64\libcrypto-1_1-x64.dll" --passL:"C:\Home\Development\openssl-1.1.1m-light-x64_86-win64\libssl-1_1-x64.dll" --path:"%DOCUI_SRC_PATH%" --path:"%EXS_SRC_PATH%" -d:ssl -d:chronicles_log_level:%WEB_APP_LOG_LEVEL% -d:chronicles_line_numbers -d:chronicles_colors:NativeColors -d:chronicles_sinks:json[file]

