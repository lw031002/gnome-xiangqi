xiangqi_lib_sources = [
  'xiangqi-piece.vala',
  'xiangqi-move.vala',
  'xiangqi-state.vala',
  'xiangqi-game.vala',
  'xiangqi-player.vala',
  'xiangqi-clock.vala',
]

xiangqi_lib = static_library('xiangqi',
  xiangqi_lib_sources,
  dependencies: [
    glib_dep,
    gtk_dep,
  ],
  include_directories: config_h_dir,
  vala_header: 'xiangqi.h',
  vala_vapi: 'xiangqi.vapi',
)

xiangqi_lib_dep = declare_dependency(
  link_with: xiangqi_lib,
  include_directories: include_directories('.')
)