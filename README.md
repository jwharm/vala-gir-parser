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

The parser is in `src/gir/parser.vala`. It uses the `MarkupReader` XML parser from libvala to build a tree of `Gir.Node` objects (see `src/gir/node.vala`) with the following properties:

- A parent Node
- A `Map<string, string>` of attributes (`name`, `c:type`, etc)
- A `List<Node>` of child nodes
- The contents of the XML element (for example in a `Gir.Doc` node)

Use the properties of the Node subclasses to access the data. For example, the `Class` node contains properties `name`, `parent`, `glib_type_struct`, `methods`, `functions`, `vitual_methods` and so on. This very closely follows the [gir schema](https://gitlab.gnome.org/GNOME/gobject-introspection/-/blob/main/docs/gir-1.2.rnc).

To use the Gir repository after parsing, simply access the nodes and their children. The following examples demonstrate this, but be aware that all checks for `null` and array sizes were omitted here:

```vala
var parser = new Gir.Parser ();
var repository = parser.parse ("Adw-1.gir");

// Get the first method of the third class
var method = repository.namespace.classes[2].methods[0];

// Access the parent node
var cls = method.parent_node as Gir.Class;

// Change the C identifier of the method
method.c_identifier = "my_identifier";

// Generate Gir xml representation
string xml = repository.to_xml ();
```

## Contributing

Contributions are welcome. The code is LGPL-licensed. Please post issues and changes on [GitHub](https://github.com/jwharm/vala-gir-parser/).

