import chronicles, strformat
import karax / [karaxdsl, vdom, vstyles]
import nexus/core/types/view_types


# Forward declarations
proc requiredAsterisk*(): VNode {.gcsafe.}
proc submitButton*(fieldName: string,
                   name: string,
                   value: string = name,
                   isLight: string = "",
                   buttonStyle: string = "is-link",
                   extraStyle: string = ""): VNode {.gcsafe.}
proc tableHeaderRow*(headers: seq[string],
                     align: seq[string]): VNode {.gcsafe.}
proc tableRows*(tableRows: seq[seq[VNode]],
                align: seq[string]): VNode {.gcsafe.}


# Code
proc addButton*(): VNode {.gcsafe.} =

  submitButton(fieldName = "add",
               name = "Add")


proc cancelButton*(): VNode =

  submitButton(fieldName = "cancel",
               name = "Cancel",
               buttonStyle = "is-black")


proc closeButton*(): VNode =

  submitButton(fieldName = "cancel",
               name = "Close",
               buttonStyle = "is-black")


proc createButton*(): VNode {.gcsafe.} =

  submitButton(fieldName = "create",
               name = "Create")


proc createAsYAMLButton*(): VNode {.gcsafe.} =

  submitButton(fieldName = "create_as_yaml",
               name = "Create as YAML")


proc errorMessage*(errorMessage: string): VNode {.gcsafe.} =

  let vnode = buildHtml(tdiv()):
    tdiv(class = "message is-danger",
         style = style((StyleAttr.marginBottom, "1em"),
                       (StyleAttr.marginTop, "1em"))):
      tdiv(class = "message-header"):
        p: text "Error"
      tdiv(class = "message-body"): verbatim errorMessage

  return vnode


proc getFormFactorClass*(webContext: WebContext,
                         desktopClass: string = "",
                         mobile_class: string = ""): string =

  if webContext.mobileDefault == false:
    return desktopClass
  else:
    return mobile_class


proc h1Title*(heading: string): VNode =

  buildHtml():
    h1(class = "title"): text "Screenshots"


proc hiddenField*(fieldName: string,
                  value: string): VNode =

  let vnode = buildHtml(input(type = "hidden",
                              name = fieldName,
                              value = value))

  return vnode


proc infoMessage*(infoMessage: string): VNode {.gcsafe.} =

  let vnode = buildHtml(tdiv()):
    tdiv(class = "message is-info",
         style = style((StyleAttr.marginBottom, "1em"),
                       (StyleAttr.marginTop, "1em"))):
      tdiv(class = "message-header"):
        p: text "Information"
      tdiv(class = "message-body"): text infoMessage
    br()

  return vnode


proc inputField*(name: string,
                 fieldName: string,
                 value: string,
                 required: bool): VNode =

  let vnode = buildHtml(tdiv(class = "field")):
    label(class = "label"):
      text name
      if required == true:
        requiredAsterisk()
    tdiv(class = "control"):
      input(class = "input",
            type = "text",
            name = fieldName,
            value = value)

  return vnode


proc requiredAsterisk*(): VNode {.gcsafe.} =

  let vnode = buildHtml():
    span(style = style(StyleAttr.color, "red")):
      text " *"

  return vnode


proc requiredAsteriskString*(): string {.gcsafe.} =

  return &"<span style=\"color: red\">*</span>"


proc successMessage*(successMessage: string): VNode {.gcsafe.} =

  let vnode = buildHtml(tdiv()):
    tdiv(class = "message is-success"):
      tdiv(class = "message-header"):
        p: text "Success"
      tdiv(class = "message-body"): text successMessage
    br()

  return vnode


proc searchButton*(): VNode {.gcsafe.} =

  submitButton(fieldName = "search",
               name = "Search")


proc submitButton*(fieldName: string,
                   name: string,
                   value: string = name,
                   isLight: string = "",
                   buttonStyle: string = "is-link",
                   extraStyle: string = ""): VNode {.gcsafe.} =

  var class = "button is-rounded"

  if buttonStyle != "":
    class &= " " & buttonStyle

  if isLight != "":
    class &= " " & isLight

  if extraStyle != "":
    class &= " " & extraStyle

  let vnode = buildHtml(tdiv(class = "field mr-4",
                             style = style(StyleAttr.display, "inline"))):
    tdiv(class = "control", style = style(StyleAttr.display, "inline")):
      button(class = class,
             id = &"""{fieldName}""",
             name = &"""{fieldName}""",
             value = &"""{value}"""): text name

  return vnode


proc table*(headers: seq[string],
            table_rows: seq[seq[VNode]],
            align: seq[string],
            width: string = ""): VNode {.gcsafe.} =

  let vnode = buildHtml(table(class = "table",
                              style = style(StyleAttr.width,
                                            width))):
    tableHeaderRow(headers,
                   align)

    tableRows(table_rows,
              align)

  return vnode


proc tableHeaderRow*(headers: seq[string],
                     align: seq[string]): VNode {.gcsafe.} =

  var i = 0

  let vnode = buildHtml():

    tr:
      for header in headers:
        if align[i] == "left":
          th: text header
        else:
          th(style = style(StyleAttr.textAlign, align[i])): text header

        i += 1

  return vnode


proc tableRows*(table_rows: seq[seq[VNode]],
                align: seq[string]): VNode {.gcsafe.} =

  debug "tableRows(): start"

  let vnode = buildHtml(tdiv()):

    for tableRow in tableRows:
      tr:

        var i = 0

        for field in tableRow:
          if align[i] == "left":
            td: field
          else:
            td(style = style(StyleAttr.textAlign,
                             align[i])): field

          i += 1

  debug "tableRows(): return"

  return vnode


proc updateButton*(): VNode {.gcsafe.} =

  submitButton(fieldName = "update",
               name = "Update",
               button_style = "")

