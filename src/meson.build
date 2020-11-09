project_deps = [
	dependency('gio-2.0'),
	dependency('gtk+-3.0'),
	dependency('json-glib-1.0'),
	dependency('libhandy-1'),
	dependency('gee-0.8'),
	tdlib,
]

config_src = configure_file(
    input: 'config.vala.in',
    output: '@BASENAME@',
    configuration: conf_data
)

project_sources = files(
  'main.vala',
  'Core/Application.vala',
  'Core/User.vala',
  #'Core/Settings.vala',
  'Core/TDInterface.vala',
  'Core/ChatListModel.vala',
  #'Core/ChatData.vala',
  'Core/MessagesListModel.vala',
  'Core/MessageData.vala',
  'UI/MainWindow.vala',
  'UI/ElementChatList.vala',
  'UI/AuthWindow.vala',
  'UI/MessageElement.vala',
)

executable(meson.project_name(), project_resources, [project_sources, config_src],
  dependencies: project_deps,
  link_args: '-Wl,-Map=' + meson.build_root() + '/src/' + meson.project_name() + '.map',
  install: true,
)
