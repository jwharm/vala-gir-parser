project('vala-gir-parser', 'vala', 'c',
		version: '0.0.1',
		license: 'LGPL')

add_project_arguments('-Wno-discarded-qualifiers', language: 'c')
add_project_arguments('-Wno-unused-variable', language: 'c')
add_project_arguments('-Wno-unused-but-set-variable', language: 'c')

dependencies = [
    dependency('glib-2.0', version: '>=2.70'),
    dependency('gobject-2.0'),
    dependency('libvala-0.56'),
]

sources = files(
		'src/gir-parser.vala',
		'src/vapigen.vala',
		'src/builders/boxed-builder.vala',
		'src/builders/class-builder.vala',
		'src/builders/constant-builder.vala',
		'src/builders/datatype-builder.vala',
		'src/builders/enum-builder.vala',
		'src/builders/field-builder.vala',
		'src/builders/identifier-builder.vala',
		'src/builders/info-attrs-builder.vala',
		'src/builders/interface-builder.vala',
		'src/builders/method-builder.vala',
		'src/builders/namespace-builder.vala',
		'src/builders/parameters-builder.vala',
		'src/builders/property-builder.vala',
		'src/builders/struct-builder.vala',
		'src/gir/filtered-node-list.vala',
		'src/gir/node.vala',
		'src/gir/parser.vala',
		'src/gir/transformations.vala',
		'src/gir-metadata/metadata-parser.vala',
		'src/gir-metadata/metadata-processor.vala',
)

executable('vapigen', sources, dependencies: dependencies)
