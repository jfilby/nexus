import strformat
import nexus/cmd/types/types
import gen_model_utils


# Code
proc generateModelFields(
       str: var string,
       model: var Model) =

  for field in model.fields:

    let nimType = getNimType(field,
                             withOption = true)

    # Raw type
    str &= &"    {field.camelCaseName}*: {nimType}\n"

    # Add a string type if the field type isn't string (option or not)
    if field.`type` != "string":
      str &= &"    {field.camelCaseName}Str*: string\n"

  str &= "\n"


proc generateModelTypes*(
       str: var string,
       model: var Model) =

  # Gen type for model (object)
  str &= &"  {model.pascalCaseName}* = object\n"

  generateModelFields(
    str,
    model)

  # Gen seq type for model (object)
  str &= &"  {model.pascalCaseNamePlural}* = seq[{model.pascalCaseName}]\n" &
          "\n" &
          "\n"

