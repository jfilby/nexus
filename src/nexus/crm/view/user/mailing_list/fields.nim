import karax / [karaxdsl, vdom, vstyles]
import nexus/core/view/common/common_fields


proc unsubscribeButton*(): VNode =

  buildHtml(tdiv()):
    form(`method` = "post"):
      submitButton(fieldName = "unsubscribe",
                   name = "Unsubscribe")

