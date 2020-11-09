project('com.syabrocraft.Telegraph', ['c', 'vala', 'cpp'],
          version: '0.1.0',
    meson_version: '>= 0.50.0',
  default_options: [ 'warning_level=2',
  		     'buildtype=debugoptimized',
                   ],
)



conf_data = configuration_data()
conf_data.set_quoted('PROJECT_NAME', meson.project_name())
conf_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf_data.set_quoted('VERSION', meson.project_version())
conf_data.set_quoted('PREFIX', get_option('prefix'))
conf_data.set_quoted('TDAPI_HASH', get_option('api_hash'))
conf_data.set('TDAPI_ID', get_option('api_id'))

i18n = import('i18n')

add_project_arguments(['--vapidir', join_paths(meson.current_source_dir(), 'include')],
             language: 'vala')

#add_project_arguments('--enable-experimental-non-null', language:'vala')

subdir('tdjson')
subdir('data')
subdir('src')
subdir('po')

meson.add_install_script('build-aux/meson/postinstall.py')
