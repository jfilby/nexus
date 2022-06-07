import chronicles, options, strformat
import karax / [karaxdsl, vdom, vstyles]
import nexus/core/types/view_types


proc verticalPaddingSpacer*(space: string): VNode =

  buildHtml():

    tdiv(style = style((StyleAttr.paddingTop, space)))

