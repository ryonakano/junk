project(
    'com.github.ryonakano.tweaks',
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
        dependency('gtk4'),
    ],
    install: true
)
