# Coding Style

- Camel case for variable and proc names. This is strict camel case, so nexusYaml instead of nexusYAML. While the latter looks better for acronyms, you can get confusing cases, especially when acronyms are next to each other. E.g. nexusYamlDir is more readable than nexusYAMLDIR.
- Pascal case for complex types such as objects, with the same strict rule as for camel case. E.g. NexusYaml instead of NexusYAML.
- 2 spaces for indentation, which is the Nim standard.
- Double blank lines between proc and type definitions.
- Alphabetical listing of procs in source files. This is to make it easy to find procs and establish some sort of sort order in source files. Forward declarations can be used for procs that can't find those that are defined later in the same file.

