# Application Architecture

At a high-level a Nexus application consists of:
- Config files
- Environment scripts
- Source files organized into modules


## Config Files

Config files are written in YAML and describe the application and artifacts
such as models and views. These are used to generate source by the nexus CLI.


## Environment Scripts

These are shell scripts which set environment variables used for:
- Defining compile variables, especially NIM_COMPILE_OPTIONS.
- Define database connection parameters.
- Define other application environment variables.


## Source Modules

Source file modules could be web-apps, web-services, console programs or
libraries.

It's even possible that a module could be written in a different programming
language than Nim, e.g. if you want a Next.js front-end that talks to a Nim
web-service.

When you create your application with the nexus CLI, you will be prompted for
the name of your initial module.

