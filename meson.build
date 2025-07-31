project('gnome-xiangqi', 'c', 'vala',
  version: '1.0.0',
  meson_version: '>= 0.50.0',
  license: 'GPL-3.0-or-later'
)

# GNOME模块
gnome = import('gnome')
i18n = import('i18n')

# 核心依赖
glib_dep = dependency('glib-2.0', version: '>= 2.44.0')
gtk_dep = dependency('gtk4', version: '>= 4.0.0')
libadwaita_dep = dependency('libadwaita-1', version: '>= 1.0.0')
librsvg_dep = dependency('librsvg-2.0', version: '>= 2.46.0', required: false)

# 配置文件
conf = configuration_data()
conf.set_quoted('GETTEXT_PACKAGE', meson.project_name())
conf.set_quoted('LOCALEDIR', join_paths(get_option('prefix'), get_option('localedir')))
conf.set_quoted('VERSION', meson.project_version())
conf.set_quoted('PACKAGE_NAME', meson.project_name())
conf.set_quoted('PACKAGE_VERSION', meson.project_version())
conf.set_quoted('PACKAGE_STRING', '@0@ @1@'.format(meson.project_name(), meson.project_version()))
conf.set_quoted('PACKAGE_DATADIR', join_paths(get_option('prefix'), get_option('datadir'), meson.project_name()))

configure_file(
  output: 'config.h',
  configuration: conf
)

config_h_dir = include_directories('.')

# 子目录
subdir('data')
subdir('lib')
subdir('src')