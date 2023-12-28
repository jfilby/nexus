import chronicles, jester, options, strformat, times
import db_connector/db_postgres
import karax / [karaxdsl, vdom, vstyles]
import nexus/core/data_access/account_user_data
import nexus/core/data_access/account_user_role_data
import nexus/core/data_access/db_conn
import nexus/core/service/account/sign_up_action
import nexus/core/types/context_type
import nexus/core/types/model_types
import nexus/core/types/view_types
import nexus/core/view/common/common_fields
import nexus/core/view/base_page
import account_fields, login_page


proc signUpPage*(
       context: NexusCoreContext,
       errorMessage = "",
       infoMessage = "",
       name = "",
       inEmail = ""): string =

  var pageContext = newPageContext(pageTitle = "Sign Up")

  # If already logged in
  if context.web.get.loggedIn == true:

    return alreadyLoggedInForm(context)

  # Get vars
  var email = inEmail

  if context.web.get.request.params.hasKey("email"):
    email = context.web.get.request.params["email"]

  # Page
  let formDiv = getFormFactorClass(
                  context.web.get,
                  desktopClass = "form_div")

  let vnode = buildHtml(tdiv(style =
                style(StyleAttr.width,
                      context.web.get.formWidth))):

    if errorMessage != "":
      tdiv(style = style(StyleAttr.width,
                         context.web.get.formWidthNarrow)):
        errorMessage(errorMessage)

    if infoMessage != "":
      tdiv(style = style(StyleAttr.width,
                         context.web.get.formWidthNarrow)):
        infoMessage(infoMessage)

    tdiv(class = formDiv,
         style = style(StyleAttr.width,
                       context.web.get.formWidthNarrow)):

      form(`method` = "post"):
        nameField(name,
                  autofocus = true)
        emailAddressField(email,
                          autofocus = false)
        br()
        signUpPasswordFields()
        br()
        emailUpdatesCheckbox()
        br()
        signUpButton()

  baseForContent(context.web.get,
                 pageContext,
                 vnode)


proc signUpPagePost*(context: NexusCoreContext): string =

  var email = ""

  if context.web.get.request.params.hasKey("email"):
    email = context.web.get.request.params["email"]

  # Sign-up action
  let docuiReturn = signUpAction(context)

  # Sign up: new user (if verification succeeded)
  if docuiReturn.isVerified == true:

    # Go to the page to verify the sign-up code
    return redirectToURL("/account/sign-up/verify?email=" & email)

  else:
    # Get form data
    let
      name = context.web.get.request.params["name"]
      password1 = context.web.get.request.params["password1"]
      password2 = context.web.get.request.params["password2"]

    # On error go back to the sign up page
    return signUpPage(context,
                      docUIReturn.errorMessage,
                      name = name,
                      inEmail = email)


proc signUpSuccessPage*(context: NexusCoreContext): string =

  # Get vars
  var email = ""

  if context.web.get.request.params.hasKey("email"):
    email = context.web.get.request.params["email"]

  # Setup pageContext
  var pageContext = newPageContext(pageTitle = "Sign Up")

  # Get accountUser record
  let accountUser =
        getAccountUserByEmail(
          context.db,
          email)

  # Success message
  var
    login = false
    success = false
    message = ""

  if accountUser == none(AccountUser):
    message = &"Email address ({email}) not found; please retry."

  elif accountUser.get.isVerified == true:
    login = true
    success = true
    message = "You have been successfully verified. Login to proceeed."

  else:
    success = true
    message = "Sign up nearly completed! A verification code has been emailed to you."

  # Render message
  let vnode = buildHtml(tdiv()):

    br()

    if success == true:
      successMessage(message)
    else:
      errorMessage(message)

    tdiv():
      br()
      p()

    if login == true:
      loginForm(context.web.get,
                errorMessage = "",
                email)

  baseForContent(context.web.get,
                 pageContext,
                 vnode)

