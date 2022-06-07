import strformat
import nexus/cmd/types/types
import nexus/core/service/format/name_utils


proc routeYAMLtoRoute*(
       webApp: WebApp,
       routeYaml: RouteYAML): Route =

  var route = Route()

  route.name = routeYaml.name
  route.description = routeYaml.description
  route.group = routeYaml.group
  route.methods = routeYaml.methods
  route.route = routeYaml.route
  route.parameters = routeYaml.parameters
  route.defaults = routeYaml.defaults
  route.modelFields = routeYaml.modelFields

  route.groupSnakeCaseName = getSnakeCaseName(route.group)
  route.nameCamelCaseName = getCamelCaseName(route.name)
  route.nameSnakeCaseName = getSnakeCaseName(route.name)

  route.pagesImport =
    &"{webApp.snakeCaseName}/view/" &
    &"{route.groupSnakeCaseName}/{route.nameSnakeCaseName}"

  return route

