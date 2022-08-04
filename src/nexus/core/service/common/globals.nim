import nexus/core/service/common/get_env


let
  # OS env vars
  serverIsProduction* = getServerIsProduction()

