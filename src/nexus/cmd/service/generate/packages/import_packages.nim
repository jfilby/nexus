import chronicles, os, sequtils, streams, strformat, yaml
import nexus/cmd/service/generate/modules/module_utils
import nexus/cmd/types/types


# Forward declarations
proc readImportsPackageFile(
       filename: string,
       generatorInfo: var GeneratorInfo)


# Code
proc importPackages*(
       confPath: string,
       generatorInfo: var GeneratorInfo) =

  # Check if conf/imports exists
  let importsPath = &"{confPath}{DirSep}imports"

  echo "importing: " & importsPath

  if dirExists(importsPath) == false:

    # If the imports path doesn't exist, then there are no imports
    # (not an error)
    debug "import directory doesn't exist",
      importsPath = importsPath

    return

  # Process each import package file
  for dirInfo in walkDir(importsPath,
                         relative = true):

    if dirInfo.path[0] == '.':
      continue

    echo ".. " & dirInfo.path

    readImportsPackageFile(
      &"{importsPath}{DirSep}{dirInfo.path}",
      generatorInfo)


proc readImportsPackageFile(
       filename: string,
       generatorInfo: var GeneratorInfo) =

  debug "readImportsPackageFile()",
    filename = filename

  # Import packages YAML (imported modules)
  var
    packagesYaml: PackagesYAML
    s = newFileStream(filename)

  load(s, packagesYaml)
  s.close()

  # Place into generatorInfo.packages
  var package = Package()

  for packageYaml in packagesYaml:

    # Verify generate options
    for genArtifacts in packageYaml.generate:

      if not @[ "models",
                "routes" ].contains(genArtifacts):

        raise newException(
                ValueError,
                "Imported packages can only generate models and routes. " &
                &"Specified artifact {genArtifacts} is not supported")

    # This call will also add the module to generatorInfo.modules
    let modules =
          getPackageModules(
            packageYaml,
            generatorInfo)

    package.modules =
      concat(package.modules,
             modules)

  generatorInfo.packages.add(package)

