# vala-gir-parser

Proof of concept gir file parser in vala.

## Build and usage

Requires `libvala-0.56` to be installed where `pkg-config` can find it.

Build with meson:

```
meson setup _build
meson compile -C _build
```

Usage:

```
_build/gir-parser filename.gir
```

## Design

The parser is in `src/gir/parser.vala`. It uses the `MarkupReader` XML parser from libvala. It builds a tree of `Gir.Node` objects (see `src/gir/node.vala`) with the following properties:

- A parent Node
- A `Map<string, string>` of attributes (`name`, `c:type`, etc)
- A `List<Node>` of child nodes
- The contents of the XML element (for example in a `Gir.Doc` node)

Use the properties of the Node subclasses to access the data.
