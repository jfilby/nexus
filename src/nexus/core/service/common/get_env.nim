import os


proc getServerIsProduction*(): bool =

  let str = getEnv("SERVER_IS_PRODUCTION")

  if str == "Y":
    return true
  else:
    return false

