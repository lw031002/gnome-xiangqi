xiangqi_sources = [
  'gnome-xiangqi.vala',
  'xiangqi-window.vala',
  'xiangqi-view.vala',
  'xiangqi-scene.vala',
  'preferences-dialog.vala',
  'new-game-dialog.vala',
]

xiangqi_deps = [
  glib_dep,
  gtk_dep,
  libadwaita_dep,
  librsvg_dep,
  xiangqi_lib_dep,
]

executable('gnome-xiangqi',
  xiangqi_sources,
  dependencies: xiangqi_deps,
  include_directories: config_h_dir,
  install: true,
)