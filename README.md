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

