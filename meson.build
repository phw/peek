project('peek', ['c', 'vala'],
  version: '1.5.0',
  meson_version: '>= 0.37.0',
)

add_project_arguments([
    '-DVERSION="' + meson.project_version() + '"',
  ], language: 'c')

i18n = import('i18n')

subdir('data')
subdir('po')
subdir('src')
subdir('tests')

meson.add_install_script('build-aux/meson/postinstall.py')
