project(
    'com.github.ryonakano.portal-location-demo',
    'vala', 'c',
    version: '0.1.0',
    meson_version: '>=0.57.0'
)

executable(
    meson.project_name (),
    'Application.vala',
    dependencies: [
        dependency('libportal'),
        dependency('gtk4')
    ],
    install: true
)

install_data(
    'portal-location-demo.desktop',
    install_dir: get_option('datadir') / 'applications'
)
