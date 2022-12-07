import strformat
import nexus/core/service/email/send_email


proc sendResetPasswordRequestEmail*(
       email: string,
       resetPasswordCode: string,
       siteName: string) =

  let
    subject = &"Confirm password reset request at {siteName}"
    body = &"Please verify that you have requested a password reset at {siteName} by entering the following code on " &
           &"the verification page:\n\n{resetPasswordCode}"

  sendEmail(toAddress = email,
            subject,
            body)


proc sendSignUpCodeEmail*(
       email: string,
       signUpCode: string,
       siteName: string) =

  let
    subject = &"Confirm email account with {siteName}"
    body = &"Please verify that you have signed up with {siteName} by entering the following code on " &
           &"the sign up verification page:\n\n{signUpCode}"

  sendEmail(toAddress = email,
            subject,
            body)

