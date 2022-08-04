import chronicles, os, streams, strformat, strutils, yaml
import nexus/core/service/format/filename_utils
import nexus/core/service/format/type_utils
import nexus/cmd/service/generate/modules/module_utils
import nexus/cmd/types/types


proc readLibraryDefinition*(
       libraryPath: string,
       generatorInfo: var GeneratorInfo) =

  debug "readLibraryDefinition()",
    libraryPath = libraryPath

  # Validate path
  if libraryPath == "":

    raise newException(
            ValueError,
            "libraryPath is blank")

  # Import library YAML
  var
    library: LibraryYAML
    s = newFileStream(libraryPath)

  load(s, library)
  s.close()

  echo &"found library: {library.shortName} with " &
       &"basePath: {library.basePath}, " &
       &"srcPath: {library.srcPath}"

  # Validate
  if isLowerAscii(library.package) == false:

    echo &"Error: library package isn't all lowercase: {library.package}"
    quit(1)

  # Path processing
  let
    originalBasePath = library.basePath
    originalSrcPath = library.srcPath

  var envVarsExpanded: bool
  envVarsExpanded = parseFilenameExpandEnvVars(library.basePath)
  envVarsExpanded = parseFilenameExpandEnvVars(library.srcPath)

  if envVarsExpanded:
    echo &".. basePath (expanded): {library.basePath}"
    echo &".. srcPath (expanded): {library.srcPath}"

  # Validate expanded vars
  if library.basePath == "":

    raise newException(
            ValueError,
            &"basePath \"{originalBasePath}\" evaluates to a blank string")

  if library.srcPath == "":

    raise newException(
            ValueError,
            &"srcPath \"{originalSrcPath}\" evaluates to a blank string")

  # Add library to generatorInfo
  generatorInfo.libraries.add(library)

  # Add library as module
  addLibraryAsModule(library,
                     generatorInfo)


proc readLibraryDefinitionsPass1*(
       confPath: string,
       generatorInfo: var GeneratorInfo) =

  debug "readLibraryDefinitionsPass1()",
    confPath = confPath

  # Validate path
  if confPath == "":

    raise newException(
            ValueError,
            "confPath is blank")

  # Read directories under the libraries directory
  let librariesPath = &"{confPath}{DirSep}libraries{DirSep}"

  debug "readLibraryDefinitionsPass1()",
    librariesPath = librariesPath

  var libraryFiles: seq[string]

  for filename in walkDirRec(librariesPath):

    echo &".. filename: {filename}"

    if find(filename,
            ".yaml") > 0:

      let libraryFile = filename

      # echo &"!  libraryFile: {libraryFile}"

      libraryFiles.add(libraryFile)

  # Read library definitions
  for libraryFile in libraryFiles:

    readLibraryDefinition(
      libraryFile,
      generatorInfo)



proc readLibraryDefinitionsPass2*(
       confPath: string,
       generatorInfo: var GeneratorInfo) =

  debug "readLibraryDefinitionsPass2"

