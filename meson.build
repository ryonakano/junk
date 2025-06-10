project(
    'settings-page-bug',
    'vala', 'c',
    meson_version: '>= 0.58.0',
    version: '0.1.0'
)

gnome = import('gnome')
i18n = import('i18n')

gettext_name = 'io.github.ryonakano.' + meson.project_name()

prefix = get_option('prefix')
libdir = join_paths(prefix, get_option('libdir'))

switchboard_dep = dependency('switchboard-3')
switchboard_plugsdir = switchboard_dep.get_variable('plugsdir', pkgconfig_define: ['libdir', libdir])

plug_files = [
    'src/SettingsSidebarBugPlug.vala',
]

shared_module(
    meson.project_name(),
    plug_files,
    dependencies: [
        dependency('gio-2.0'),
        dependency('glib-2.0'),
        dependency('granite-7', version: '>=7.4.0'),
        dependency('gtk4'),
        switchboard_dep,
    ],
    install: true,
    install_dir : join_paths(switchboard_plugsdir, 'system')
)
