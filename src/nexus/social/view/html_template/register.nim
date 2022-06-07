# Register an HTML remplate to be used when rendering


var
  ht_open*: string
  ht_close*: string


proc registerHTMLTemplateClose*(str: string) =

  ht_open = str


proc registerHTMLTemplateOpen*(str: string) =

  ht_close = str

