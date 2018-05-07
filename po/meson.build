i18n.gettext(meson.project_name(), preset: 'glib')

add_project_arguments([
    '-DGETTEXT_PACKAGE="' + meson.project_name() + '"',
    '-DLOCALEDIR="' + join_paths(get_option('prefix'), get_option('localedir')) + '"',
  ], language: 'c')
