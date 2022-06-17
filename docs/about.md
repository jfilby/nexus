About Nexus
===

Nexus provides a high-level web framework for [Nim](https://nim-lang.org),
with batteries included. The goal is to create a similar framework for Nim as
Django is for Python or Rails is for Ruby. You can create web apps,
web-services and console applications.

The framework includes:
- A web view generator that provides the routing and source structure.
- An ORM (which currently supports PostgreSQL only).
- User login and maintenance functionality.
- Additional modules which aim to provide some basic CRM and blogging
  functionality (these are still in early development).

Nexus utilizes [Jester](https://github.com/dom96/jester) as the lower-level web
framework for serving web pages and web-services. There are plans to make this
choice pluggable, so that other web frameworks such as
[Prologue](https://github.com/planety/prologue) can be used instead.

The built-in web content is mostly created with:
- [Karax](https://github.com/karaxnim/karax) which defines HTML at compile-time
using Nim macros.
- [Bulma CSS framework](https://bulma.io).
- Standard Javascript.

Your own content can be generated using any available method,
including the use of Karax or
[Nimja](https://github.com/enthus1ast/nimja) to render HTML.

The framework can integrate with [DocUI](https://github.com/jfilby/DocUI) which
is a Flutter front-end which render UIs that can be defined at the back-end.
This works by defining UIs using the DocUI SDK in a web-service which
communicates with your Flutter app using JSON-encoded information.

Nexus has an ORM that generates SQL DDL (data definitions) and data access Nim
source files. There's an option to generate cached data access files in
addition to the regular data access files.


Modules
====

- Nexus CMD creates Nim source and SQL DDL files.
- Nexus Core provides the core web application framework.
- Nexus Core Extras provides additional utility functionality.
- Nexus CRM provides mailing list functionality.
- Nexus Social provides social media functionality.

Note that Nexus CRM and Nexus Social are both very minimal at this point.

