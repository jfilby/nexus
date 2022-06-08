import strformat
import nexus/cmd/types/types
import nexus/core/service/format/name_utils


proc enrichRouteNamesAndPaths*(
       route: var Route,
       moduleSnakeCaseName: string) =

  route.groupSnakeCaseName = getSnakeCaseName(route.group)
  route.nameCamelCaseName = getCamelCaseName(route.name)
  route.nameSnakeCaseName = getSnakeCaseName(route.name)

  route.pagesImport =
    &"{moduleSnakeCaseName}/view/" &
    &"{route.groupSnakeCaseName}/{route.nameSnakeCaseName}"


proc routeYAMLtoRoute*(
       webArtifact: WebArtifact,
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

  enrichRouteNamesAndPaths(
    route,
    webArtifact.snakeCaseName)

  return route

