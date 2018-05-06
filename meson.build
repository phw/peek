project('peek', ['c', 'vala'],
  version: '1.3.1',
  meson_version: '>= 0.40.0',
)

i18n = import('i18n')

subdir('data')
subdir('src')
subdir('tests')
subdir('po')

meson.add_install_script('build-aux/meson/postinstall.py')
