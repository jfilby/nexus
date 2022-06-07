import chronicles, jester, os, strutils, uri
import nexus/core/service/common/globals
import nexus/core/types/module_globals as nexus_core_module_globals
import nexus/cmd/types/module_globals as nexus_cmd_globals
import new_web_context


settings:
  port = Port(parseInt(getEnv("WEB_APP_PORT")))


routes:

