resource_data = files(
  'xiangqi-window.ui',
)

subdir('pieces')

gnome.compile_resources('gnome-xiangqi',
  'xiangqi.gresource.xml',
  source_dir: '.',
  dependencies: resource_data,
  c_name: 'resources'
)

install_data('xiangqi.gresource.xml',
  install_dir: join_paths(get_option('datadir'), meson.project_name())
)

install_data('org.gnome.Xiangqi.gschema.xml',
  install_dir: join_paths(get_option('datadir'), 'glib-2.0', 'schemas')
)