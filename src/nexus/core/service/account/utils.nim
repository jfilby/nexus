import jester, os, strutils


# The session cookie carries a bearer token that is only protected by its
# signature, so it must never be readable by scripts. SameSite is Lax so the
# token is not attached to cross-site requests, which blocks CSRF.
const tokenCookieName = "token"
const tokenCookieDays = 5

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


# setTokenCookie(): sets (or clears, with an empty token) the session cookie.
# Must be a template: jester's setCookie writes into the enclosing route's
# response headers.
template setTokenCookie*(token: string) =

  # Only require the Secure flag in production, where the app is served over
  # HTTPS; requiring it locally would stop the browser storing the cookie at all
  # on plain HTTP.
  let secure =
        if getEnv("SERVER_IS_PRODUCTION") == "Y": true
        else: false

  setCookie(tokenCookieName,
            token,
            daysForward(tokenCookieDays),
            path = "/",
            httpOnly = true,
            secure = secure,
            sameSite = SameSite.Lax)

