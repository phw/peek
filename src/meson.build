peek_sources = [
  'main.vala',
  'application.vala',
  'desktop-integration.vala',
  'defaults.vala',
  'errordomain.vala',
  'gtk-helper.vala',
  'utils.vala',
  'dbus/freedesktop-dbus.vala',
  'dbus/freedesktop-filemanager.vala',
  'dbus/gnome-shell-screencast.vala',
  'post-processing/cli-post-processor.vala',
  'post-processing/extract-frames-post-processor.vala',
  'post-processing/ffmpeg-post-processor.vala',
  'post-processing/gifski-post-processor.vala',
  'post-processing/post-processing-pipeline.vala',
  'post-processing/post-processor.vala',
  'recording/base-screen-recorder.vala',
  'recording/cli-screen-recorder.vala',
  'recording/ffmpeg-screen-recorder.vala',
  'recording/ffmpeg.vala',
  'recording/gnome-shell-dbus-recorder.vala',
  'recording/recording-area.vala',
  'recording/recording-config.vala',
  'recording/screen-recorder-factory.vala',
  'recording/screen-recorder.vala',
  'ui/about-dialog.vala',
  'ui/application-window.vala',
  'ui/error-dialog.vala',
  'ui/preferences-dialog.vala',
  'ui/shortcut-label.vala',
  'vapi/config.vapi',
]

add_project_arguments([
    '--vapidir', join_paths(meson.current_source_dir(), 'vapi'),
  ], language: 'vala')

add_project_arguments([
    '-DGETTEXT_PACKAGE="' + meson.project_name() + '"',
    '-DLOCALEDIR="/usr/share/locale"',
    '-DVERSION="' + meson.project_version() + '"',
  ], language: 'c')

peek_deps = [
  dependency('cairo'),
  dependency('gio-2.0', version: '>= 2.42'),
  dependency('glib-2.0', version: '>= 2.38'),
  dependency('gmodule-2.0'),
  dependency('gtk+-3.0', version: '>= 3.14'),
  dependency('keybinder-3.0'),
]

gnome = import('gnome')

configuration_data = configuration_data()
configuration_data.set('PEEK_VERSION_FULL', meson.project_version())
about_ui_file = configure_file(
  input: '../ui/about.ui.in',
  output: 'about.ui',
  configuration: configuration_data
)

peek_sources += gnome.compile_resources('peek-resources',
  '../ui/peek.gresource.xml',
  source_dir: '../ui/',
  c_name: 'peek',
  dependencies: [about_ui_file]
)

executable('peek', peek_sources,
  vala_args: [
    '--target-glib=2.50',
    '--pkg', 'posix',
    '--header', 'application.h',
    '--use-header',
    '--includedir', '../..',
  ],
  dependencies: peek_deps,
  install: true,
)
