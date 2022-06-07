import chronicles, options, strformat
import karax / [karaxdsl, vdom, vstyles]
import nexus/core/types/view_types


proc bigLogo*(logo_fullpath: string,
              subtitle: string = ""): VNode =

  buildHtml():

    tdiv(style = style((StyleAttr.display, "block"),
                       (StyleAttr.textAlign, "center"),
                       (StyleAttr.marginTop, "1em"),
                       (StyleAttr.marginBottom, "2em"))):

      img(src = logo_fullpath)

      if subtitle != "":

        h2(class = "subtitle",
           style = style(StyleAttr.marginTop, "0.5em")): text subtitle

