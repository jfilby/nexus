import chronicles, db_postgres, jester, options
import karax / [karaxdsl, vdom, vstyles]
import nexus/core/data_access/account_user_data
import nexus/core/data_access/db_conn
import nexus/core/service/account/encrypt
import nexus/core/service/account/send_user_emails
import nexus/core/service/account/verify_sign_up_code_fields
import nexus/core/service/email/send_email
import nexus/core/types/model_types
import nexus/core/types/view_types
import nexus/core/view/common/common_fields
import nexus/core/view/base_page
import account_fields


proc signUpResendSignUpCodePage*(
       request: Request,
       webContext: WebContext,
       errorMessage: string = "",
       email: string = ""): string =

  var pageContext = newPageContext(pageTitle = "Resend Sign Up Code")

  let formDiv = getFormFactorClass(
                  webContext,
                  desktopClass = "form_div")

  let vnode = buildHtml(tdiv()):

    if errorMessage != "":
      tdiv(style = style(StyleAttr.width,
                         webContext.formWidthNarrow)):
        errorMessage(errorMessage)

    tdiv(class = formDiv,
         style = style(StyleAttr.width,
                       webContext.formWidth)):
      form(`method` = "post"):
        emailAddressField(email,
                          autofocus = true)
        br()
        resendSignUpCodeButton()

  baseForContent(webContext,
                 pageContext,
                 vnode)


proc signUpResendSignUpCodePagePost*(
       request: Request,
       webContext: WebContext): string =

  var email = ""

  if request.params.hasKey("email"):
    email = request.params["email"]

  # Get accountUser record
  let accountUser =
        getAccountUserByEmail(
          nexusCoreDbContext,
          email)

  # Generate a new sign up code
  let signUpCode = generateSignUpCode()

  debug "signUpResendSignUpCodePagePost()",
    signUpCode = signUpCode

  # Verify fields
  let docuiReturn =
        verifySignUpCodeFields(
          nexusCoreDbContext,
          email,
          signUpCode,
          accountUser)

  # Update the user's sign up code
  let rowsAffected =
        updateAccountUserByPk(
          nexusCoreDbContext,
          accountUser.get,
          setFields = @[ "sign_up_code" ])

  # Resend code
  sendSignUpCodeEmail(
    email,
    signUpCode,
    "Test Site")

  return redirectToURL("/account/sign-up/verify?email=" & email)


proc signupResendCodeVerifyPage*(
       request: Request,
       webContext: WebContext,
       errorMessage: string = "",
       email: string = ""): string =

  signUpResendSignUpCodePage(
    request,
    webContext,
    errorMessage,
    email)

