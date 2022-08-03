import chronicles, db_postgres, jester, json, options, strformat
import karax / [karaxdsl, vdom, vstyles]
import nexus/core/data_access/account_user_data
import nexus/core/data_access/db_conn
import nexus/core/data_access/nexus_setting_data
import nexus/core/service/account/encrypt
import nexus/core/service/account/login_action
import nexus/core/service/account/verify_sign_up_action
import nexus/core/service/account/verify_sign_up_fields
import nexus/core/service/account/verify_sign_up_code_fields
import nexus/core/service/email/send_email
import nexus/core/types/model_types
import nexus/core/types/view_types
import nexus/core/view/common/common_fields
import nexus/core/view/base_page
import account_fields


proc signUpVerifyPage*(
       request: Request,
       webContext: WebContext,
       errorMessage = "",
       inEmail = ""): string =

  # Get vars
  var
    email = ""
    signUpCode = ""
    autoScript = ""

  if request.params.hasKey("email"):
    email = request.params["email"]

  elif inEmail != "":
    email = inEmail

  if request.params.hasKey("code"):
    signUpCode = request.params["code"]

  # Get autoScript if possible
  if errorMessage == "" and
     email != "" and
     signUpCode != "":

    autoScript =
      "<script type=\"text/javascript\">\n" &
      "window.onload=function() {\n" &
      "    document.forms[\"signUpVerify\"].submit();\n" &
      "}\n" &
      "</script>\n"

  # Page
  var pageContext = newPageContext(pageTitle = "Verify Sign Up")

  let formDiv = getFormFactorClass(webContext,
                                   desktopClass = "form_div")

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

      form(`method` = "post",
           name = "signUpVerify"):

        if email != "":
          emailAddressReadonlyField(email)
          signUpCodeField(signUpCode,
                          autofocus = true)

        else:
          emailAddressField(email,
                            autofocus = true)
          signUpCodeField(signUpCode,
                          autofocus = false)

        br()
        verifyRegistionButton()

      verbatim(autoScript)

  # Render
  baseForContent(webContext,
                 pageContext,
                 vnode)


proc signUpVerifyPagePost*(
       request: Request,
       webContext: WebContext): (bool, string, string, string, string) =

  var
    email = ""
    signUpCode = ""

  if request.params.hasKey("email"):
    email = request.params["email"]

  if request.params.hasKey("signUpCode"):
    signUpCode = request.params["signUpCode"]

  # Verify sign-up action
  var docuiReturn = verifySignUpAction(request)

  # On error go back to the signUp page
  if docuiReturn.isVerified == false:

    return (false,
            email,
            "Incorrect sign-up code",
            "",
            "")

  # Login action
  docUIReturn = loginActionByEmailVerified(
                  nexusCoreDbContext,
                  webContext,
                  email)

  # On success
  let
    module = "Nexus Core"
    key = "URL after email validation"

    nexusSetting =
      getNexusSettingByModuleAndKey(
        nexusCoreDbContext,
        module,
        key)

  if nexusSetting == none(NexusSetting):

    raise newException(
            ValueError,
            "NexusSetting not found for " &
            &"module: \"{module}\" " &
            &"key: \"{key}\"")

  return (true,
          email,
          "",
          docUIReturn.token,
          &"{nexusSetting.get.value.get}?email={email}")


template postSignUpVerifyAction*(request: Request,
                                 webContext: WebContext) =

  var
    email: string
    verified: bool
    errorMessage: string
    token: string
    redirectToURL: string

  (verified,
   email,
   errorMessage,
   token,
   redirectToURL) = signUpVerifyPagePost(request,
                                         webContext)

  if verified == true:

    debug "postSignUpVerifyAction(): verified; setting logged in cookie"

    # Set cookie
    setCookie("token",
              token,
              daysForward(5),
              path = "/")

    myRedirect redirectToURL

  else:
    resp signUpVerifyPage(request,
                          webContext,
                          errorMessage,
                          email)

