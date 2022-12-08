import nexus/cmd/types/types


proc printGeneratorInfoResults*(generatorInfo: GeneratorInfo) =

  # Print result status
  if generatorInfo.status == 'N':
    echo "Nothing to generate."

  elif generatorInfo.status == 'S':
    echo "Generate succeeded."

  elif generatorInfo.status == 'E':
    echo "Generate failed."
    echo "Error: " & generatorInfo.errorMessage

  # For new apps, print the next steps
  if @[ "console-app",
        "web-app",
        "web-service",
        "library" ].contains(generatorInfo.artifact):

    echo ""
    echo "Next steps:"
    echo "1. Create a Nimble package in the project directory."
    echo "   Run `nimble init` to do this."
    echo "2. Run `nimble develop` to install the package locally."
    echo "   This is necessary for some generated imports."

