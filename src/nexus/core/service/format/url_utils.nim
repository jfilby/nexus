import chronicles, os, strformat, strutils
import name_utils


proc parseURLConvertModelNamesToSnakeCase*(url: var string): bool =

  debug "parseURLConvertModelNamesToSnakeCase",
    url = url

  var
    converted = false
    timeout = 10
    find_brace = find(url,
                      "{")

  # While env var dollar symbols are present
  while find_brace >= 0:

    var
      starting = -1
      ending = -1

    starting = find_brace
    ending = find(url,
                  "}")

    # If ending not found, raise an exception
    if starting < 0 or
       ending < 0:
      raise newException(
              ValueError,
              &"Failed to parse url: {url} due to incorrect env var formatting")

    # Env var substitution if found
    converted = true

    let
      var_name = url[starting + 1 .. ending - 1]
      var_name_snake_case = getSnakeCaseName(var_name)

    debug "parseURLConvertModelNamesToSnakeCase()",
      var_name = var_name,
      var_name_snake_case = var_name_snake_case

    url = replace(url,
                  "{" & var_name & "}",
                  var_name_snake_case)

    # Find another dollar
    find_brace = find(url,
                      "{")

    # Timeout
    timeout -= 1

    if timeout == 0:
      raise newException(ValueError,
                         "function timed out")

  debug "parseURLConvertModelNamesToSnakeCase()",
    url = url

  return converted

