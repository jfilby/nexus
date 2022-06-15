import chronicles, strformat
import nexus/cmd/types/types
import nexus/core/service/format/name_utils


# Forward declarations
proc verifyRouteStringParameter(
       paramStr: string,
       route: Route): RouteParameter


# Code
proc enrichRouteNamesAndPaths*(
       route: var Route,
       moduleSnakeCaseName: string) =

  route.groupInSnakeCase = getSnakeCaseName(route.group)
  route.nameInCamelCase = getCamelCaseName(route.name)
  route.nameInSnakeCase = getSnakeCaseName(route.name)

  route.pagesImport =
    &"{moduleSnakeCaseName}/view/" &
    &"{route.groupInSnakeCase}/{route.nameInSnakeCase}"


proc routeParametersYAMLtoRouteParameters(
       routeParametersYAML: RouteParametersYAML): RouteParameters =

  var routeParameters: RouteParameters

  for routeParameterYAML in routeParametersYAML:

    var routeParameter =
          RouteParameter(
            name: routeParameterYAML.name,
            `type`: routeParameterYAML.`type`,
            constraints: routeParameterYAML.constraints,
            description: routeParameterYAML.description,
            nameInCamelCase: getCamelCaseName(routeParameterYAML.name))

    routeParameters.add(routeParameter)

  return routeParameters


proc routeYAMLtoRoute*(
       webArtifact: WebArtifact,
       routeYAML: RouteYAML): Route =

  var route = Route()

  route.name = routeYAML.name
  route.description = routeYAML.description
  route.group = routeYAML.group
  route.methods = routeYAML.methods
  route.route = routeYAML.route
  route.defaults = routeYAML.defaults
  route.modelFields = routeYAML.modelFields

  enrichRouteNamesAndPaths(
    route,
    webArtifact.nameInSnakeCase)

  route.parameters =
    routeParametersYAMLtoRouteParameters(
      routeYAML.parameters)

  return route


proc parseRoute*(route: var Route) =

  # Reset jesterRoute
  route.jesterRoute = ""

  # Parse route
  var
    inParamStr = false
    paramStart = -1

  for i in 0 .. len(route.route) - 1:

    if route.route[i] == '{':

      # Check for error: open curly braces within open curly braces
      if inParamStr == true:

        echo "Incorrectly formatted route: { found within {"
        echo "Route: " & route.route
        quit(1)

      else:
        inParamStr = true
        paramStart = i

        continue

      # Check for error: end of curly braces without matching open curly braces
    elif route.route[i] == '}':

      if inParamStr == false:

        echo "Incorrectly formatted route: } found without matching {"
        echo "Route: " & route.route
        quit(1)

      else:
        # Format parameter string
        let routeParameter =
              verifyRouteStringParameter(
                route.route[paramStart + 1 .. i - 1],
                route)

        # Add to jesterRoute
        route.jesterRoute &= routeParameter.nameInCamelCase

        # Reset param vars and continue
        inParamStr = false
        paramStart = -1

        continue

    else:
      # Append non-parameter char
      route.jesterRoute &= route.route[i]

  # Unclose curly braces
  if inParamStr == true:

    echo "Incorrectly formatted route: no matching }"
    echo "Route: " & route.route
    quit(1)


proc verifyRouteStringParameter(
       paramStr: string,
       route: Route): RouteParameter =

  debug "verifyRouteStringParameter()",
    paramStr = paramStr

  # Verify that the parameter is found
  for routeParameter in route.parameters:

    if paramStr == routeParameter.name:
      return routeParameter

  # Parameter not found
  echo &"The parameter \"{paramStr}\" in the route string wasn't found in " &
        "the YAML listing of parameters"

  quit(1)

