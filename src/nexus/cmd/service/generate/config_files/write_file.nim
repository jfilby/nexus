import chronicles, os


proc promptForOverwrite*(prompt: string): bool =

  debug "promptForOverwrite()"

  echo ""
  echo prompt
  echo ""

  stdout.write("y/Y to overwrite> ")
  let overwrite = readLine(stdin)

  if @[ "y",
        "Y" ].contains(overwrite):

    return true

  else:
    return false


proc promptToOverwriteFile*(
       prompt: string,
       filename: string,
       contents: string) =

  debug "promptToOverwriteFile()",
    filename = filename

  # Check if models.yaml file already exists, prompt for overwrite
  var writeFile = true

  if fileExists(filename) == true:

    if promptForOverwrite(prompt) == false:
      writeFile = false

  debug "promptToOverwriteFile()",
    writeFile = $writeFile

  if writeFile == true:

    writeFile(filename,
              contents)

