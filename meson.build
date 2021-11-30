project(
    'com.github.ryonakano.file-chooser-test',
    'vala', 'c',
    version: '0.1.0',
    meson_version: '>=0.49.0'
)

sources = files(
    'src' / 'Application.vala',
)

executable(
    meson.project_name (),
    sources,
    dependencies: [
        dependency('gtk+-3.0'),
    ],
    install: true
)
