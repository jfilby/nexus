import nexus/cmd/types/types


proc printGeneratorInfoResults*(generatorInfo: GeneratorInfo) =

  if generatorInfo.status == 'N':
    echo "Nothing to generate."

  elif generatorInfo.status == 'S':
    echo "Generate succeeded."

  elif generatorInfo.status == 'E':
    echo "Generate failed."
    echo "Error: " & generatorInfo.errorMessage

