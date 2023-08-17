project(
    'com.github.ryonakano.pk-test',
    'vala', 'c',
    version: '0.1.0',
)

sources = files(
    'src' / 'Application.vala',
    'src' / 'Installer.vala',
    'src' / 'MainWindow.vala'
)

executable(
    meson.project_name(),
    sources,
    dependencies: [
        dependency('gtk4'),
        dependency('packagekit-glib2')
    ],
    install: true
)
