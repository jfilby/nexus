import nexus/core/view/account/login_page
import nexus/core/service/account/login_action
import nexus/core/view/account/profile_page
import nexus/core/view/account/reset_password_page
import nexus/core/view/account/sign_up_page
import nexus/core/view/account/sign_up_verify_page
import nexus/core/view/account/sign_up_resend_signUpCode_page
import nexus/core/view/invite/invite_page
import chronicles, jester, os, strutils, uri
import nexus/core/service/common/globals
import nexus/core/types/module_globals as nexusCoreModule_globals
import nexus/social/types/module_globals as nexus_social_module_globals
import new_web_context


settings:
  port = Port(parseInt(getEnv("WEB_APP_PORT")))


routes:

  # Routes for: account_routes
  # Login
  get "/account/login":
    let webContext = newWebContext(request,
                                    nexusCoreModule)

    # Set cookie (useful to store detected mobile setting)
    if webContext.token != "":
      setCookie("token",
                webContext.token,
                daysForward(5),
                path = "/")

    # Render page
    resp loginPage(webContext)


  post "/account/login":
    let webContext = newWebContext(request,
                                    nexusCoreModule)

    postLoginAction(request,
                    webContext)


  get "/account/logout":

    let webContext = newWebContext(request,
                                    nexusCoreModule)

    logoutAction(request,
                 webContext)


  get "/account/profile":

    let webContext = newWebContext(request,
                                    nexusCoreModule)

    resp profilePage(request,
                     webContext)


  post "/account/profile":

    var webContext = newWebContext(request,
                                    nexusCoreModule)

    resp profilePagePost(request,
                         webContext)


  get "/account/profile/success":

    let webContext = newWebContext(request,
                                    nexusCoreModule)

    resp profileSuccessPage(request,
                            webContext,
                            emailChanged = decodeUrl(@"emailChanged"),
                            personalDetailsChanged = decodeUrl(@"personalDetailsChanged"),
                            passwordChanged = decodeUrl(@"passwordChanged"))


  get "/account/reset-password":

    let webContext = newWebContext(request,
                                    nexusCoreModule)

    resp resetPasswordPage(request,
                           webContext)


  post "/account/reset-password":

    var webContext = newWebContext(request,
                                    nexusCoreModule)

    resp resetPasswordPagePost(request,
                               webContext)


  get "/account/reset-password/verify":

    let webContext = newWebContext(request,
                                    nexusCoreModule)

    resp resetPasswordVerifyPage(request,
                                 webContext)


  post "/account/reset-password/verify":

    var webContext = newWebContext(request,
                                    nexusCoreModule)

    resp resetPasswordVerifyPagePost(request,
                                     webContext)


  options "/account/sign-up":
    resp(Http200, {"Allow": "GET, OPTIONS, POST",
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Methods": "GET,HEAD,OPTIONS,POST,PUT",
                    "Access-Control-Allow-Headers": "Origin,Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,locale"},
         "success")


  get "/account/sign-up":

    let webContext = newWebContext(request,
                                    nexusCoreModule)

    resp signupPage(request,
                    webContext,
                    email = decodeUrl(@"email"))


  post "/account/sign-up":

    var webContext = newWebContext(request,
                                    nexusCoreModule)

    resp signupPagePost(request,
                        webContext)


  get "/account/sign-up/success":

    let webContext = newWebContext(request,
                                    nexusCoreModule)

    resp signupSuccessPage(request,
                           webContext,
                           email = decodeUrl(@"email"))


  get "/account/sign-up/verify":

    let webContext = newWebContext(request,
                                    nexusCoreModule)

    resp signupVerifyPage(request,
                          webContext)


  post "/account/sign-up/verify":

    var webContext = newWebContext(request,
                                    nexusCoreModule)

    postSignUpVerifyAction(request,
                           webContext)


  get "/account/sign-up/resend-code":

    let webContext = newWebContext(request,
                                    nexusCoreModule)

    resp signupResendSignupCodePage(request,
                                    webContext)


  post "/account/sign-up/resend-code":

    var webContext = newWebContext(request,
                                    nexusCoreModule)

    resp signupResendSignupCodePagePost(request,
                                        webContext)


  get "/account/sign-up/resend-code/verify":

    let webContext = newWebContext(request,
                                    nexusCoreModule)

    resp signupResendCodeVerifyPage(request,
                                    webContext)


  # Routes for: invite_routes
  get "/invite/send":

    let webContext = newWebContext(request,
                                    nexusCoreModule)

    resp inviteSendPage(request,
                        webContext)


  post "/invite/send":

    var webContext = newWebContext(request,
                                    nexusCoreModule)

    resp inviteSendPagePost(request,
                            webContext)


  get "/invite/send/success":

    let webContext = newWebContext(request,
                                    nexusCoreModule)

    resp inviteSendSuccessfulPage(request,
                                  webContext,
                                  to_name = decodeUrl(@"to_name"),
                                  to_email = decodeUrl(@"to_email"))


