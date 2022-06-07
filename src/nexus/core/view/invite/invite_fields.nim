import chronicles, jester, options, strformat, uri
import karax / [karaxdsl, vdom, vstyles]
import nexus/core/view/common/common_fields


proc fromNameFieldAutofocus*(from_name: string): VNode =


  buildHtml(tdiv(class = "field")):
    tdiv(class = "field"):
      label(class = "label"):
        text "From Name "
        requiredAsterisk()
      tdiv(class = "control"):
        input(class = "input",
              type = "text",
              name = "from_name",
              value = from_name,
              autofocus = "")


proc fromEmailAddressField*(from_email: string): VNode =

  buildHtml(tdiv(class = "field")):
    tdiv(class = "field"):
      label(class = "label"):
        text "From Email "
        requiredAsterisk()
      tdiv(class = "control"):
        input(class = "input",
              type = "text",
              name = "from_email",
              value = from_email)


proc sendInviteButton*(): VNode =

  submitButton(fieldName = "send_invite",
               name = "Send Invite")


proc toNameField*(to_name: string): VNode =

  buildHtml(tdiv(class = "field")):
    tdiv(class = "field"):
      label(class = "label"):
        text "To Name "
        requiredAsterisk()
      tdiv(class = "control"):
        input(class = "input",
              type = "text",
              name = "to_name",
              value = to_name)


proc toEmailAddressField*(to_email: string): VNode =

  buildHtml(tdiv(class = "field")):
    tdiv(class = "field"):
      label(class = "label"):
        text "To Email "
        requiredAsterisk()
      tdiv(class = "control"):
        input(class = "input",
              type = "text",
              name = "to_email",
              value = to_email)

