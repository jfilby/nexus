# Paths
export NEXUS_BASE_PATH=/opt/dev/nexus/src/nim
export NEXUS_BIN_PATH=/opt/dev/nexus/bin

export NEXUS_CORE_SRC_PATH=$NEXUS_BASE_PATH/core
export NEXUS_CORE_EXTRAS_SRC_PATH=$NEXUS_BASE_PATH/core_extras
export NEXUS_CRM_SRC_PATH=$NEXUS_BASE_PATH/crm
export NEXUS_CMD_SRC_PATH=$NEXUS_BASE_PATH/cmd
export NEXUS_SOCIAL_SRC_PATH=$NEXUS_BASE_PATH/social

export WEB_APP_INVITE_ONLY=Y
export WEB_APP_LOG_LEVEL=INFO
export WEB_APP_PORT=5000

export NIM_COMPILE_OPTIONS="--path:../.. --path:$DOCUI_SRC_PATH --path:$EXS_SRC_PATH -d:ssl -d:chronicles_log_level:$WEB_APP_LOG_LEVEL -d:chronicles_line_numbers -d:chronicles_colors:NativeColors -d:chronicles_sinks:json[file]"

