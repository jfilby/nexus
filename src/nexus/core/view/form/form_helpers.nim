import karax / [karaxdsl, vdom, vstyles]
import nexus/core/view/common/common_fields


proc formField*(label: string,
                required: bool = false,
                control: VNode): VNode =

  buildHtml(tdiv(class = "field")):

      label(class = "label"):
        text label
        if required == true:
          verbatim(" ")
          requiredAsterisk()
      tdiv(class = "control"):
        control


proc formCheckboxField*(label: string,
                        name: string,
                        value: string,
                        checked_value: string): VNode =

  buildHtml(tdiv(class = "field")):
    tdiv(class = "field"):
      label(class = "label"):
        text ""
      tdiv(class = "control"):
        label(class = "checkbox",
              style = style(StyleAttr.width, "8em")):

          if value == checked_value:
            input(class = "checkbox",
                  type = "checkbox",
                  name = name,
                  id = name,
                  checked = "")
            text " " & label

          else:
            input(class = "checkbox",
                  type = "checkbox",
                  name = name,
                  id = name)
            text " " & label


proc formInputField*(label: string,
                     maxlength: string = "",
                     name: string,
                     placeholder: string = "",
                     size: string = "",
                     value: string,
                     width: string = "",
                     autofocus: bool = false,
                     required: bool = false): VNode =

  var style = style()

  if width != "":
    style = style(StyleAttr.width, width)

  if autofocus == true:
    formField(label,
              control = buildHtml(input(class = "input",
                                        type = "text",
                                        maxlength = maxlength,
                                        name = name,
                                        placeholder = placeholder,
                                        size = size,
                                        style = style,
                                        value = value,
                                        autofocus = "")))

  else:
    formField(label,
              control = buildHtml(input(class = "input",
                                        type = "text",
                                        maxlength = maxlength,
                                        name = name,
                                        placeholder = placeholder,
                                        size = size,
                                        style = style,
                                        value = value)))


proc formLinkField*(label: string,
                    href_value: string,
                    text_value: string): VNode =

  let control = buildHtml(span()):
    a(href = href_value): text text_value

  formField(label,
            control = control)


proc formTextField*(label: string,
                    value: string): VNode =

  formField(label,
            control = buildHtml(verbatim(value)))

