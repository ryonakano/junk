project(
    'io.github.ryonakano.portal-dynamic-launcher-demo',
    'vala', 'c',
    version: '0.1.0',
    meson_version: '>=0.57.0'
)

executable(
    meson.project_name(),
    'Application.vala',
    dependencies: [
        dependency('libportal'),
        dependency('libportal-gtk4'),
        dependency('gtk4')
    ],
    install: true
)

install_data(
    'portal-dynamic-launcher-demo.desktop',
    rename: meson.project_name() + '.desktop',
    install_dir: get_option('datadir') / 'applications'
)

install_data(
    'portal-dynamic-launcher-demo.svg',
    rename: meson.project_name() + '.svg',
    install_dir: get_option('datadir') / 'icons' / 'hicolor' / '128x128' / 'apps'
)
