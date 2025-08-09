valadoc = find_program('valadoc', required: true)

valadoc_pkgs = []
foreach dep : gir_deps
  valadoc_pkgs += '--pkg=' + dep.name()
endforeach

vala_sources = []
foreach source : gir_sources
  vala_sources += source.full_path()
endforeach

docs_dir = join_paths(meson.current_build_dir(), 'valadoc')
valadoc = custom_target('valadoc',
  input: vala_sources,
  output: ['valadoc', 'Valagir-1.0.gir'],
  command: [valadoc,
    '-o', docs_dir,
    '--package-name=Gir',
    '--package-version=0',
    '--gir=@OUTPUT1@',
#    '--vapidir=', join_paths(src_dir, 'config.vapi'),
    valadoc_pkgs,
    '@INPUT@'
  ],
)


gidocgen = find_program('gi-docgen')

custom_target('gi-docgen',
  input: [ 'valagir.toml' ], #valadoc[1] ], # valadoc generated GIR crashes gi-docgen, see https://gitlab.gnome.org/GNOME/vala/-/issues/707
  output: 'valagir-1.0',
  command: [
    gidocgen,
    'generate',
    '--quiet',
    '--config=@INPUT0@',
    '--output-dir=@OUTPUT@',
    '--no-namespace-dir',
    '--content-dir=@0@'.format(meson.current_source_dir()),
    #'@INPUT1@',
    root_build_dir / 'Valagir-1.0.gir',
  ],
  build_by_default: true,
  install: true,
  install_dir: docs_dir,
  depends: libvalagir,
)

