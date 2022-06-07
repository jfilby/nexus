import jester, strutils


type
  ContentType* = enum
    Unhandled = -1,
    Form = 0,
    JSON = 1


proc getContentType*(request: Request): ContentType =

  # If headers' doesn't have a content-type, then assume a Form
  if not request.headers.hasKey("content-type"):
    return ContentType.Form

  # Handle content-type set
  if find(request.headers["content-type"],
          "application/json") >= 0:
  
    return ContentType.JSON

  elif find(request.headers["content-type"],
            "application/x-www-form-urlencoded") >= 0:
    
    return ContentType.Form

  else:
    return ContentType.Unhandled

