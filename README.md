# vala-gir-parser

Reimplementation of vapigen: a tool to generate VAPI files from GIR files. The
tool is designed with a focus on easy maintainability.

## Build and usage

Requires `libvala-0.56` to be installed where `pkg-config` can find it.

Build with meson:

```
meson setup _build
meson compile -C _build
```

Usage:

```
_build/vapigen --library libraryname filename.gir
```

The tool can be used as a drop-in replacement for the existing `vapigen` tool.
Technically, it acts as a new back-end that `vapigen` will call.

Please be aware that this project is still in development and is not yet
finished.

## Design

The tool is split in two separate parts:

1. A parser that generates a GIR node tree from a GIR file
2. A Vala AST (abstract syntax tree) builder from the GIR node tree, that can be
   written into a VAPI file

A third component will be added later, to process metadata files.

### GIR parser

The GIR parser is in `src/gir/parser.vala`. It uses the `MarkupReader` XML
parser from libvala to build a tree of `Gir.Node` objects (see
`src/gir/node.vala`) with the following properties:

- A parent Node
- A `Map<string, string>` of attributes (`name`, `c:type`, etc)
- A `List<Node>` of child nodes
- The text contents of the XML element (for example in a `Gir.Doc` node)
- A Vala `SourceReference` with the location in the GIR XML file (for error
  reporting)

The GIR node tree can be displayed in an easy-to-read text format with
`to_string ()`, or in XML format with `to_xml ()`. The generated XML is
identical to the original GIR XML file, except the XML element attributes have a
different ordering (the attributes are kept in a `Vala.Map`, an unordered
collection).

### GIR transformations & GIR Metadata

Before generating a VAPI, a few transformations are applied to the GIR node
tree. For example, methods with one out-parameter that return void, are updated
to return the out-parameter value. Next, all instructions from the GIR metadata
file (if available) are applied to the GIR node tree.

### VAPI generator

The GIR node tree is converted into a Vala AST using a series of Builder classes
that convert a GIR node into Vala symbols. For example, `ClassBuilder` generates
a Vala Class with all its fields, methods etc. from a GIR class. The
`NamespaceBuilder` class ties it all together.

Implementing the builder classes is currently in progress.

The existing `vapigen` utility is still used to read command line arguments,
kick-off the parser process, and write the results into a VAPI file.

## Contributing

Contributions are welcome. The code is LGPL-licensed. Please post issues and
changes on [GitHub](https://github.com/jwharm/vala-gir-parser/).
