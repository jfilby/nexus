import _


proc mailingListSignupEmbed*(request: Request,
                             webContext: WebContext): VNode =

  let vnode = buildHtml(tdiv()):

    h1(class = "title"): text "Join the Mailing List"

    input(class = "input", name = "email", type = "input", placeholder = "Your email address")
    input(class = "button", name = "signup", type = "submit", value = "Join")


proc mailingListSignupPost*(request: Request,
                            webContext: WebContext): VNode =

  # Get posted values
  var email = ""

  if request.params.hasKey("email"):
    email = request.params["email"]

  # Check for an existing value
  _

  # Insert a new record
  _

  # Redirect to signed-up page
  _

