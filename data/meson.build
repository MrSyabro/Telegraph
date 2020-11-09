desktop_file = i18n.merge_file(
  input: meson.project_name() + '.desktop.in',
  output: meson.project_name() + '.desktop',
  type: 'desktop',
  po_dir: '../po',
  install: true,
  install_dir: join_paths(datadir, 'applications')
)

desktop_utils = find_program('desktop-file-validate', required: false)
if desktop_utils.found()
  test('Validate desktop file', desktop_utils,
    args: [desktop_file]
  )
endif

appstream_file = i18n.merge_file(
  input: meson.project_name() + '.metainfo.xml.in',
  output: meson.project_name() + '.metainfo.xml',
  po_dir: '../po',
  install: true,
  install_dir: join_paths(datadir, 'metainfo')
)

appstream_util = find_program('appstream-util', required: false)
if appstream_util.found()
  test('Validate appstream file', appstream_util,
    args: ['validate', appstream_file]
  )
endif

install_data(meson.project_name() + '.gschema.xml',
  install_dir: join_paths(datadir, 'glib-2.0', 'schemas')
)

compile_schemas = find_program('glib-compile-schemas', required: false)
if compile_schemas.found()
  test('Validate schema file', compile_schemas,
    args: ['--strict', '--dry-run', meson.current_source_dir()]
  )
endif

subdir('icons')

gnome = import('gnome')

project_resources = gnome.compile_resources('resources',
	'project.gresource.xml',
	c_name: 'resources'
)
