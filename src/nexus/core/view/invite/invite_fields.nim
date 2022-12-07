import chronicles, jester, options, strformat, uri
import karax / [karaxdsl, vdom, vstyles]
import nexus/core/view/common/common_fields


proc fromNameFieldAutofocus*(fromName: string): VNode =


  buildHtml(tdiv(class = "field")):
    tdiv(class = "field"):
      label(class = "label"):
        text "From Name "
        requiredAsterisk()
      tdiv(class = "control"):
        input(class = "input",
              type = "text",
              name = "fromName",
              value = fromName,
              autofocus = "")


proc fromEmailAddressField*(fromEmail: string): VNode =

  buildHtml(tdiv(class = "field")):
    tdiv(class = "field"):
      label(class = "label"):
        text "From Email "
        requiredAsterisk()
      tdiv(class = "control"):
        input(class = "input",
              type = "text",
              name = "fromEmail",
              value = fromEmail)


proc sendInviteButton*(): VNode =

  submitButton(fieldName = "send_invite",
               name = "Send Invite")


proc toNameField*(toName: string): VNode =

  buildHtml(tdiv(class = "field")):
    tdiv(class = "field"):
      label(class = "label"):
        text "To Name "
        requiredAsterisk()
      tdiv(class = "control"):
        input(class = "input",
              type = "text",
              name = "toName",
              value = toName)


proc toEmailAddressField*(toEmail: string): VNode =

  buildHtml(tdiv(class = "field")):
    tdiv(class = "field"):
      label(class = "label"):
        text "To Email "
        requiredAsterisk()
      tdiv(class = "control"):
        input(class = "input",
              type = "text",
              name = "toEmail",
              value = toEmail)

