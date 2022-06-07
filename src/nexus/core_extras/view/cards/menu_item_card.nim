import json, options, strformat, tables
import docui/service/sdk/docui_elements
import docui/service/sdk/docui_types
import docui/service/sdk/docui_utils


proc menuItemCard*(title: string,
                   description: string,
                   route: string): JsonNode =

  # Create parameters
  var routeParameters: Table[string, string]

  routeParameters[DocUI_SelectedMenuName] = title
  routeParameters[DocUI_SelectedMenuUrl] = route

  var
    children: seq[JsonNode]
    backgroundColor: string
    fontColor: string
    divStyle: JsonNode

  # Colors
  backgroundColor = "white"
  fontColor = "black"

  divStyle = style(
    backgroundColor = some(backgroundColor),
    fontColor = some(fontColor)
  )

  # Title
  children.add(
    division(
      children = @[
        subtitle(title)
      ],
      style = some(divStyle)
    )
  )

  # Description
  children.add(
    division(
      children = @[
        textBody(description)
      ],
      paddingLeft = some("10"),
      paddingRight = some("10"),
      style = some(divStyle)
    )
  )

  # Card
  let cardStyle = style(
                    color = some(backgroundColor))

  return card(
           children,
           marginBottom = some("10"),
           marginTop = some("10"),
           width = some("35%"),
           route = some(route),
           routeParameters = some(%* routeParameters),
           style = some(cardStyle))

