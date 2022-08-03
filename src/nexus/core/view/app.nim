import view/frontpage/homepage
import view/invite/invite_page
import jester, strutils


settings:
  port = Port(parseInt(getEnv("WEB_APP_PORT")))


router:

  get "/account/demo/login":
    resp demoLoginPage(request,
                       db,
                       webContext)


  get "/account/login":
    resp loginPage(request,
                   db,
                   webContext)


  post "/account/login":
    resp loginPagePost(request,
                       db,
                       webContext)


  get "/account/logout":
    resp logoutPage(request,
                    db,
                    webContext)


  get "/account/profile":
    resp profilePage(request,
                     db,
                     webContext)


  post "/account/profile":
    resp profilePagePost(request,
                         db,
                         webContext)


  get "/account/reset-password":
    resp resetPasswordPage(request,
                           db,
                           webContext)


  post "/account/reset-password":
    resp resetPasswordPagePost(request,
                               db,
                               webContext)


  get "/account/reset-password/verify":
    resp resetPasswordVerifyPage(request,
                                 db,
                                 webContext)


  post "/account/reset-password/verify":
    resp resetPasswordVerifyPagePost(request,
                                     db,
                                     webContext)


  get "/account/sign-up":
    resp signupPage(request,
                    db,
                    webContext)


  post "/account/sign-up":
    resp signupPagePost(request,
                        db,
                        webContext)


  get "/account/sign-up/verify":
    resp signupVerifyPage(request,
                          db,
                          webContext)


  post "/account/sign-up/verify":
    postSignUpVerifyAction(request,
                           db,
                           webContext)


  get "/account/sign-up/resend-code":
    resp signupResendCodePage(request,
                              db,
                              webContext)


  post "/account/sign-up/resend-code":
    resp signupResendCodePagePost(request,
                                  db,
                                  webContext)


  get "/account/sign-up/resend-code/verify":
    resp signupResendCodeVerifyPage(request,
                                    db,
                                    webContext)


  post "/account/sign-up/resend-code/verify":
    resp signupResendCodeVerifyPagePost(request,
                                        db,
                                        webContext)


  get "/invite/send":
    resp inviteSendPage(request,
                        db,
                        webContext)


  post "/invite/send":
    resp inviteSendPagePost(request,
                            db,
                            webContext)


  get "/invite/send/success":
    resp inviteSendSuccessfulPage(request,
                                  db,
                                  webContext)


