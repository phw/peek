i18n.gettext(meson.project_name(), preset: 'glib')

add_project_arguments([
    '-DGETTEXT_PACKAGE="' + meson.project_name() + '"',
    '-DLOCALEDIR="' + join_paths(get_option('prefix'), get_option('localedir')) + '"',
  ], language: 'c')

run_target('peek-update-linguas',
  command : ['python3', '-c',
  'import os; print(" ".join((f[:-3] for f in sorted(os.listdir(".")) if f.endswith(".po"))), file=open("LINGUAS", "w"))'
])
