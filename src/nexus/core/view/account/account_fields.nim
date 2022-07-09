import karax / [karaxdsl, vdom, vstyles]
import nexus/core/view/common/common_fields


proc APIKeyField*(apiKey: string): VNode =

  buildHtml(tdiv(class = "field")):
    label(class = "label"): text "API Key"
    tdiv(class = "control"):
      input(class = "input",
            type = "text",
            name = "",
            value = apiKey)


proc emailUpdatesCheckbox*(): VNode =

  let name = "emailUpdates"

  buildHtml(tdiv(class = "field")):
    input(class = "checkbox",
          type = "checkbox",
          name = name,
          id = name,
          checked = "Y")
    text " Receive news and updates"


proc nameField*(name: string,
                autofocus: bool = false): VNode =

  buildHtml(tdiv(class = "field")):
    label(class = "label"):
      text "Name"
      requiredAsterisk()
    tdiv(class = "control"):

      if autofocus == true:
        input(class = "input",
              type = "text",
              name = "name",
              value = name,
              autofocus = "")

      else:
        input(class = "input",
              type = "text",
              name = "name",
              value = name)


proc loginButton*(): VNode =

  submitButton(fieldName = "login",
               name = "Login",
               buttonStyle = "is-info")


proc emailAddressField*(email: string,
                        autofocus: bool = false): VNode =

  buildHtml(tdiv(class = "field")):
    label(class = "label"):
      text "Email"
      requiredAsterisk()
    tdiv(class = "control"):

      if autofocus == true:
        input(autocomplete = "on",
              autofocus = "",
              class = "input",
              type = "text",
              name = "email",
              value = email)

      else:
        input(autocomplete = "on",
              class = "input",
              type = "text",
              name = "email",
              value = email)


proc emailAddressHiddenField*(email: string): VNode =

  buildHtml(tdiv(class = "field")):
    input(type = "hidden",
          name = "email",
          value = email)


proc emailAddressMinimalField*(email: string,
                               autofocus: bool = false): VNode =

  buildHtml(tdiv(class = "field")):
    tdiv(class = "control"):

      if autofocus == true:
        input(autocomplete = "on",
              autofocus = "",
              class = "input",
              type = "text",
              name = "email",
              value = email,
              placeholder = "Email")

      else:
        input(autocomplete = "on",
              class = "input",
              type = "text",
              name = "email",
              value = email,
              placeholder = "Email")


proc emailAddressReadonlyField*(email: string): VNode =

  buildHtml(tdiv(class = "field")):
    label(class = "label"):
      text "Email"
    tdiv(class = "control"):
        text email


proc passwordField*(label: string,
                    fieldName: string,
                    autofocus: bool = false): VNode =

  buildHtml(tdiv(class = "field")):
    label(class = "label"):
      text label
      requiredAsterisk()
    tdiv(class = "control"):

      if autofocus == true:
        input(class = "input",
              type = "password",
              name = fieldName,
              autofocus = "")

      else:
        input(class = "input",
              type = "password",
              name = fieldName)


proc passwordMinimalField*(label: string,
                           fieldName: string,
                           password: string = "",
                           autofocus: bool = false): VNode =

  buildHtml(tdiv(class = "field")):
    tdiv(class = "control"):

      if autofocus == true:
        input(class = "input",
              type = "password",
              name = fieldName,
              autofocus = "",
              placeholder = "Password",
              value = password)

      else:
        input(class = "input",
              type = "password",
              name = fieldName,
              placeholder = "Password",
              value = password)


proc signUpButton*(color = "",
                   buttonStyle: string = "is-danger",
                   extraStyle: string = ""): VNode =

  var newButtonStyle = buttonStyle

  if color == "red":
    newButtonStyle = "is-danger"

  submitButton(fieldName = "sign_up",
               name = "Sign Up",
               buttonStyle = newButtonStyle,
               extraStyle = extraStyle)


proc signUpCodeField*(signUpCode: string): VNode =

  buildHtml(tdiv(class = "field")):
    label(class = "label"):
      text "Sign up code"
      requiredAsterisk()
    tdiv(class = "control"):
      input(class = "input",
            type = "text",
            name = "signUpCode",
            value = signUpCode)


proc signUpCodeField*(signUpCode: string,
                      autofocus: bool = false): VNode =

  buildHtml(tdiv(class = "field")):
    label(class = "label"):
      text "Sign up code"
      requiredAsterisk()
    tdiv(class = "control"):

      if autofocus == true:
        input(class = "input",
              type = "text",
              name = "signUpCode",
              value = signUpCode,
              autofocus = "")

      else:
        input(class = "input",
              type = "text",
              name = "signUpCode",
              value = signUpCode)


proc signUpPasswordFields*(autofocus: bool = false): VNode =

  buildHtml(tdiv(class = "field")):
    tdiv():
      p(style = style(StyleAttr.fontSize, "11pt")):
        text "The password must be at least 10 characters in length and " &
             "contain at least 1 lowercase character, 1 uppercase character " &
             "and 1 number."
    br()

    passwordField("Password",
                  "password1",
                  autofocus)

    passwordField("Verify password (confirm)",
                  "password2")


proc resendSignUpCodeButton*(): VNode =

  submitButton(fieldName = "resendSignUpCode",
               name = "Resend Sign Up Code")


proc resetPasswordButton*(): VNode =

  submitButton(fieldName = "reset_password",
               name = "Reset Password")


proc resetPasswordCodeField*(autofocus: bool = false): VNode =

  buildHtml(tdiv(class = "field")):
    label(class = "label"):
      text "Reset password code"
      requiredAsterisk()
    tdiv(class = "control"):

      if autofocus == true:
        input(class = "input",
              type = "text",
              name = "reset_password_code",
              autofocus = "")

      else:
        input(class = "input",
              type = "text",
              name = "reset_password_code")


proc verifyRegistionButton*(): VNode =

  submitButton(fieldName = "verify_sign_up",
               name = "Verify Sign Up")


proc verifyPasswordResetCodeButton*(): VNode =

  submitButton(fieldName = "verify_reset_password_code",
               name = "Verify Reset Password Code")

