project(
  'gtk4-template',
  'vala', 'c',
  version: '0.1.0'
)

files = [
  'src/Application.vala',
  'src/MainWindow.vala',
]

executable(
  meson.project_name(),
  files,
  dependencies: [
    #dependency('gio-2.0'),
    #dependency('glib-2.0'),
    #dependency('granite-7'),
    dependency('gtk4'),
  ],
  install: true,
)
