import chronicles, db_postgres, jester, options, strformat, uri
import karax / [karaxdsl, vdom, vstyles]
import nexus/core/data_access/account_user_data
import nexus/core/data_access/db_conn
import nexus/core/service/account/encrypt
import nexus/core/service/account/reset_password_action
import nexus/core/service/account/send_user_emails
import nexus/core/service/account/verify_reset_password_fields
import nexus/core/types/model_types
import nexus/core/types/view_types
import nexus/core/view/common/common_fields
import nexus/core/view/base_page
import account_fields, login_page


proc resetPasswordRequestPage*(
       webContext: WebContext,
       errorMessage: string = "",
       email: string = ""): string =

  # Setup pageContext
  var pageContext =
        newPageContext(pageTitle = "Reset Password")

  let formDiv =
        getFormFactorClass(
          webContext,
          desktopClass = "form_div")

  # Render form
  let vnode = buildHtml(tdiv(style = style(StyleAttr.width,
                                           webContext.formWidth))):

    if errorMessage != "":
      tdiv(style = style(StyleAttr.width,
                         webContext.formWidthNarrow)):
        errorMessage(errorMessage)

    tdiv(class = formDiv,
         style = style(StyleAttr.width,
                       webContext.formWidthNarrow)):

      form(`method` = "post"):
        emailAddressField(email,
                          autofocus = true)
        br()
        resetPasswordButton()

  baseForContent(webContext,
                 pageContext,
                 vnode)


proc resetPasswordRequestPagePost*(
       request: Request,
       webContext: WebContext): string =

  # Get email
  var email = ""

  if request.params.hasKey("email"):
    email = request.params["email"]

  # Reset password request action
  let docUiReturn = resetPasswordRequestAction(request)

  if docUiReturn.isVerified == true:

    # Redirect to verify page
    return redirectToURL("/account/reset-password/verify?email=" & email)

  # Error
  resetPasswordRequestPage(
    webContext,
    docUiReturn.errorMessage,
    email)


proc resetPasswordVerifyPage*(
       request: Request,
       webContext: WebContext,
       errorMessage: string = "",
       email: string = ""): string =

  # Setup pageContext
  var pageContext =
        newPageContext(pageTitle = "Reset Password")

  let formDiv =
        getFormFactorClass(
          webContext,
          desktopClass = "form_div")

  # Render form
  let vnode = buildHtml(tdiv(style = style(StyleAttr.width,
                                           webContext.formWidth))):

    if errorMessage != "":
      tdiv(style = style(StyleAttr.width,
                         webContext.formWidthNarrow)):
        errorMessage(errorMessage)

    tdiv(class = formDiv,
         style = style(StyleAttr.width,
                       webContext.formWidthNarrow)):

      p(): text "A verification code has been emailed to you. " &
                "Enter that code into the form below for verification."
      br()

      form(`method` = "post"):
        emailAddressHiddenField(email)
        resetPasswordCodeField(autofocus = true)
        signUpPasswordFields()
        br()
        resetPasswordButton()

  baseForContent(webContext,
                 pageContext,
                 vnode)


proc resetPasswordPageVerifyPost*(
       request: Request,
       webContext: WebContext): string =

  # Get email and password1
  var
    email = ""
    password1 = ""

  if request.params.hasKey("email"):
    email = request.params["email"]

  if request.params.hasKey("password1"):
    password1 = request.params["password1"]

  let docuiReturn = resetPasswordChangeAction(request)

  if docuiReturn.isVerified == true:

    # Redirect to verify page
    return redirectToURL("/account/reset-password/verify?email=" &
                         email &
                         "&password=" &
                         encodeUrl(password1))

  else:
    resetPasswordVerifyPage(
      request,
      webContext,
      docUIReturn.errorMessage,
      email)


proc resetPasswordSuccessPage*(
       request: Request,
       webContext: WebContext,
       email: string = ""): string =

  # Setup pageContext
  var pageContext =
        newPageContext(pageTitle = "Reset Password Successful")

  # Get accountUser record
  let accountUser =
        getAccountUserByEmail(
          nexusCoreDbContext,
          email)

  # Success message
  var
    login = false
    success = false
    message = ""

  if accountUser == none(AccountUser):
    message = &"Email address ({email}) not found; please retry."

  else:
    success = true
    message = "Your password has been reset."

  # Render message
  let vnode = buildHtml(tdiv()):

    if success == true:
      successMessage(message)
    else:
      errorMessage(message)

    tdiv():
      br()
      p()

    if login == true:
      loginForm(webContext,
                errorMessage = "",
                email)

  baseForContent(webContext,
                 pageContext,
                 vnode)

