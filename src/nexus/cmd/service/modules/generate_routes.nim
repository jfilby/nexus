import chronicles, sets, strformat, tables
import nexus/cmd/types/config_types


proc generateRoutes*(settings: Settings) =

  var
    routesStr = ""
    imports_set: OrderedSet[string]

  # Iterate through moduleConfigs and get the unique set of modules
  for moduleConfig in settings.moduleConfigs:
    for route in moduleConfig.routes:

      if not imports_set.contains(route.`import`):

        imports_set.incl(route.`import`)

  # Add imports to routesStr
  for `import` in imports_set:

    routesStr &= &"import {`import`}\n"

  routesStr &= "\n" &
               "\n" &
               &"routes:\n" &
               &"\n"

  # Iterate through moduleConfigs and generate routes
  for moduleConfig in settings.moduleConfigs:
    for route in moduleConfig.routes:

      debug "generateRoutes()",
        route = route.route

      let routeStr = &"  get \"{route.route}\":\n" &
                      &"    let webContext = initWebContext(request)\n" &
                      "\n" &
                      &"    resp {route.proc}(webContext)\n" &
                      "\n" &
                      &"\n"

      routesStr &= routeStr

  # Write routes file
  # let nexus_srcPath = 
  writeFile(&"{settings.envTable[""NEXUS_SRC_PATH""]}{DirSep}web_app{DirSep}nexus.nim",
            routesStr)

 