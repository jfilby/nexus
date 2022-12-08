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
import nexus/core/types/context_type
import nexus/core/types/model_types
import nexus/core/types/view_types
import nexus/core/view/common/common_fields
import nexus/core/view/base_page
import account_fields


proc signUpVerifyPage*(
       context: NexusCoreContext,
       errorMessage = "",
       inEmail = ""): string =

  # Get vars
  var
    email = ""
    signUpCode = ""
    autoScript = ""

  if context.web.get.request.params.hasKey("email"):
    email = context.web.get.request.params["email"]

  elif inEmail != "":
    email = inEmail

  if context.web.get.request.params.hasKey("code"):
    signUpCode = context.web.get.request.params["code"]

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

    tdiv(class = formDiv,
         style = style(StyleAttr.width,
                       context.web.get.formWidthNarrow)):

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
  baseForContent(context.web.get,
                 pageContext,
                 vnode)


proc signUpVerifyPagePost*(context: NexusCoreContext):
       (bool, string, string, string, string) =

  var
    email = ""
    signUpCode = ""

  if context.web.get.request.params.hasKey("email"):
    email = context.web.get.request.params["email"]

  if context.web.get.request.params.hasKey("signUpCode"):
    signUpCode = context.web.get.request.params["signUpCode"]

  # Verify sign-up action
  var docuiReturn = verifySignUpAction(context)

  # On error go back to the signUp page
  if docuiReturn.isVerified == false:

    return (false,
            email,
            "Incorrect sign-up code",
            "",
            "")

  # Login action
  docUIReturn =
    loginActionByEmailVerified(
      context,
      email)

  # On success
  let
    module = "Nexus Core"
    key = "URL after email validation"

    nexusSetting =
      getNexusSettingByModuleAndKey(
        context.db,
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


template postSignUpVerifyAction*(context: NexusCoreContext) =

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
   redirectToURL) = signUpVerifyPagePost(context)

  if verified == true:

    debug "postSignUpVerifyAction(): verified; setting logged in cookie"

    # Set cookie
    setCookie("token",
              token,
              daysForward(5),
              path = "/")

    myRedirect redirectToURL

  else:
    resp signUpVerifyPage(context,
                          errorMessage,
                          email)

