import chronicles, db_postgres, jester, options, strformat, uri
import karax / [karaxdsl, vdom, vstyles]
import nexus/core/data_access/account_user_data
import nexus/core/data_access/db_conn
import nexus/core/service/account/encrypt
import nexus/core/service/account/reset_password_action
import nexus/core/service/account/send_user_emails
import nexus/core/service/account/verify_reset_password_fields
import nexus/core/types/context_type
import nexus/core/types/model_types
import nexus/core/types/view_types
import nexus/core/view/common/common_fields
import nexus/core/view/base_page
import account_fields, login_page


proc resetPasswordRequestPage*(
       context: NexusCoreContext,
       errorMessage: string = "",
       email: string = ""): string =

  # Setup pageContext
  var pageContext =
        newPageContext(pageTitle = "Reset Password")

  let formDiv =
        getFormFactorClass(
          context.web.get,
          desktopClass = "form_div")

  # Render form
  let vnode = buildHtml(tdiv(style =
                style(StyleAttr.width,
                      context.web.get.formWidth))):

    if errorMessage != "":
      tdiv(style = style(StyleAttr.width,
                         context.web.get.formWidthNarrow)):
        errorMessage(errorMessage)

    tdiv(class = formDiv,
         style = style(StyleAttr.width,
                       context.web.get.formWidthNarrow)):

      form(`method` = "post"):
        emailAddressField(email,
                          autofocus = true)
        br()
        resetPasswordButton()

  baseForContent(context.web.get,
                 pageContext,
                 vnode)


proc resetPasswordRequestPagePost*(
       context: NexusCoreContext): string =

  # Get email
  var email = ""

  if context.web.get.request.params.hasKey("email"):
    email = context.web.get.request.params["email"]

  # Reset password request action
  let docUiReturn = resetPasswordRequestAction(context)

  if docUiReturn.isVerified == true:

    # Redirect to verify page
    return redirectToURL("/account/reset-password/verify?email=" & email)

  # Error
  resetPasswordRequestPage(
    context,
    docUiReturn.errorMessage,
    email)


proc resetPasswordVerifyPage*(
       context: NexusCoreContext,
       errorMessage: string = "",
       email: string = ""): string =

  # Setup pageContext
  var pageContext =
        newPageContext(pageTitle = "Reset Password")

  let formDiv =
        getFormFactorClass(
          context.web.get,
          desktopClass = "form_div")

  # Render form
  let vnode = buildHtml(tdiv(style =
                style(StyleAttr.width,
                context.web.get.formWidth))):

    if errorMessage != "":
      tdiv(style = style(StyleAttr.width,
                         context.web.get.formWidthNarrow)):
        errorMessage(errorMessage)

    tdiv(class = formDiv,
         style = style(StyleAttr.width,
                       context.web.get.formWidthNarrow)):

      p(): text "A verification code has been emailed to you. " &
                "Enter that code into the form below for verification."
      br()

      form(`method` = "post"):
        emailAddressHiddenField(email)
        resetPasswordCodeField(autofocus = true)
        signUpPasswordFields()
        br()
        resetPasswordButton()

  baseForContent(context.web.get,
                 pageContext,
                 vnode)


proc resetPasswordPageVerifyPost*(
       context: NexusCoreContext): string =

  # Get email and password1
  var
    email = ""
    password1 = ""

  if context.web.get.request.params.hasKey("email"):
    email = context.web.get.request.params["email"]

  if context.web.get.request.params.hasKey("password1"):
    password1 = context.web.get.request.params["password1"]

  let docuiReturn = resetPasswordChangeAction(context)

  if docuiReturn.isVerified == true:

    # Redirect to verify page
    return redirectToURL("/account/reset-password/verify?email=" &
                         email &
                         "&password=" &
                         encodeUrl(password1))

  else:
    resetPasswordVerifyPage(
      context,
      docUIReturn.errorMessage,
      email)


proc resetPasswordSuccessPage*(
       context: NexusCoreContext,
       email: string = ""): string =

  # Setup pageContext
  var pageContext =
        newPageContext(pageTitle = "Reset Password Successful")

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
      loginForm(context.web.get,
                errorMessage = "",
                email)

  baseForContent(context.web.get,
                 pageContext,
                 vnode)

