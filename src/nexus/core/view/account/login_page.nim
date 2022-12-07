import chronicles, db_postgres, jester, json, options, strformat, strutils
import tables, times
import karax / [karaxdsl, vdom, vstyles]
import nexus/core/data_access/account_user_data
import nexus/core/data_access/account_user_role_data
import nexus/core/data_access/db_conn
import nexus/core/service/account/jwt_utils
import nexus/core/service/account/login_action
import nexus/core/service/account/verify_login_fields
import nexus/core/types/model_types
import nexus/core/types/types as nexus_core_types
import nexus/core/view/common/common_fields
import nexus/core/view/base_page
import nexus/core/types/context_type
import nexus/core/types/view_types
import account_fields


proc alreadyLoggedInForm*(context: NexusCoreContext): string =

  debug "alreadyLoggedInForm()",
    token = webContext.token

  let
    formDiv = getFormFactorClass(
                context.web.get,
                desktopClass = "form_div")

    vnode =
      buildHtml(tdiv(class = formDiv,
                     style = style(StyleAttr.width,
                                   context.web.get.formWidthNarrow))):
        br()
        p(): text "Already logged in."

  var pageContext = newPageContext(pageTitle = "Already logged in")

  return baseForContent(
           context.web.get,
           pageContext,
           vnode)


proc loginForm*(
       webContext: WebContext,
       errorMessage: string = "",
       email: string = "",
       isVerified: bool = false): VNode =

  let formDiv =
        getFormFactorClass(
          webContext,
          desktopClass = "form_div")

  buildHtml(tdiv(style =
    style(StyleAttr.width,
          webContext.formWidth))):

    # Error message
    if errorMessage != "":
      tdiv(style = style(StyleAttr.width,
                         webContext.formWidthNarrow)):

        errorMessage(errorMessage)

      if email != "" and isVerified == false:

        tdiv(class = formDiv,
             style = style(StyleAttr.width,
                           webContext.formWidthNarrow)):

          # Resend sign-up code button
          form(`method` = "post",
               action = "/account/sign-up/resend-code"):
            hiddenField("email",
                        email)
            resendSignUpCodeButton()

    # Email and password with login button
    # Reset password link beneath
    tdiv(class = formDiv,
         style = style(StyleAttr.width,
                       webContext.formWidthNarrow)):

      form(`method` = "post",
           action = "/account/login"):
        emailAddressField(email,
                          autofocus = true)
        passwordField("Password",
                      "password")
        br()
        loginButton()
        br()
        br()
        a(href = "/account/reset-password"): text "Reset Password"


proc loginMinimalForm*(
       webContext: WebContext,
       errorMessage: string = "",
       email: string = "",
       password: string = "",
       signUpLink: bool = true,
       isVerified = ""): VNode =

  buildHtml(tdiv(style = style(StyleAttr.width,
                               webContext.formWidth))):

    if errorMessage != "":
      tdiv(style = style(StyleAttr.width,
                         webContext.formWidthNarrow)):
        errorMessage(errorMessage)

#[
    if isVerified == "false":
      form(`method` = "post"):
        hiddenField("email",
                    email)
        resendSignUpCodeButton()
      br()
      br()
]#

    tdiv(style = style(StyleAttr.width,
                       webContext.formWidthNarrow)):

      form(`method` = "post",
           action = "/account/login"):

        emailAddressMinimalField(email,
                                 autofocus = true)
        passwordMinimalField("Password",
                             "password",
                             password)
        br()

        tdiv(style = style((StyleAttr.display, "inline-block"),
                           (StyleAttr.verticalAlign, "bottom"))):

          loginButton()

          tdiv(style = style((StyleAttr.display, "inline-block"),
                             (StyleAttr.marginLeft, "1em"),
                             (StyleAttr.marginTop, "1em"))):

            if sign_up_link == true:
              verbatim(" &nbsp; ")
              a(href = "/account/sign-up"): text "Sign Up"

            verbatim(" &nbsp; ")
            a(href = "/account/reset-password"): text "Reset Password"


proc loginPage*(context: NexusCoreContext,
                inErrorMessage: string = "",
                inEmail: string = ""): string =

  var pageContext = newPageContext(pageTitle = "Login")

  # If already logged in
  if context.web.get.loggedIn == true:

    return alreadyLoggedInForm(context)

  # Get vars
  var
    email = ""
    errorMessage = ""
    isVerified = true

  if inErrorMessage != "":
    errorMessage = inErrorMessage

  else:
    if context.web.get.request.params.hasKey("errorMessage"):
      errorMessage = context.web.get.request.params["errorMessage"]

  if inEmail != "":
    email = inEmail

  else:
    if context.web.get.request.params.hasKey("email"):
      email = context.web.get.request.params["email"]

  if context.web.get.request.params.hasKey("isVerified"):

    if context.web.get.request.params["isVerified"] == "f":
      isVerified = false

  debug "loginPage()",
    email = email,
    errorMessage = errorMessage

  let vnode =
        buildHtml(tdiv()):
          loginForm(context.web.get,
                    errorMessage,
                    email,
                    isVerified)

  baseForContent(context.web.get,
                 pageContext,
                 vnode)


proc loginPagePost*(context: NexusCoreContext):
                      (bool, string, string) =

  # Get email
  var email = ""

  if context.web.get.request.params.hasKey("email"):
    email = context.web.get.request.params["email"]

  # Check for resend sign up code button
  if context.web.get.request.params.hasKey("resendSignUpCode"):

    return (false,
            redirectToURL("/account/sign_up/resend_code?email=" & email),
            "")

  # Attempt login and get a JWT token
  let docUIReturn =
        loginAction(context,
                    none(JsonNode))

  debug "loginPagePost()",
    isVerified = $docUIReturn.isVerified,
    errorMessage = docUIReturn.errorMessage

  # Return errors if found/not verified
  var
    isVerified = docUIReturn.isVerified
    errorMessage = docUIReturn.errorMessage

  # If a valid token was returned then login was successful
  if docUIReturn.isVerified == true and
     docUIReturn.token == "":

    isVerified = false
    errorMessage = "Can't login because of an internal error (no token " &
                   "generated)"

  if isVerified == false:

    # Determine if the account is unverified
    var accountIsVerified = ""

    if find(errorMessage,
            AccountNotVerifiedByEmail) >= 0:

      # Get AccountUser record
      let accountUser =
            getAccountUserByEmail(
              context.db,
              email)

      if accountUser != none(AccountUser):

        accountIsVerified = $accountUser.get.isVerified
        accountIsVerified = $accountIsVerified[0]

    # On error go back to the sign up page
    return (false,
            &"/account/login?email={email}&errorMessage={errorMessage}" &
            &"&isVerified={accountIsVerified}",
            "")

  # Login successful
  return (true,
          "",
          docUIReturn.token)

