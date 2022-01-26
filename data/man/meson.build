txt2man = find_program('txt2man', required: false)
gzip = find_program('gzip', required: false)

if not txt2man.found()
  message('txt2man not found; man pages will not be generated.')
elif not gzip.found()
  message('gzip not found; man pages will not be generated.')
else
  message('Found txt2man and gzip; man page will be built and installed')
  # We can't use install_man in combination with custom_target,
  # see https://github.com/mesonbuild/meson/issues/1550
  manpage = custom_target('peek.1.txt',
    command: [
      join_paths(meson.current_source_dir(), 'build_man.sh'),
      meson.project_name().to_upper(),
      meson.project_version(),
      join_paths(meson.current_source_dir(), 'peek.1.txt'),
      '@OUTPUT@'
    ],
    output: 'peek.1',
    install: true,
    install_dir: join_paths(get_option('mandir'), 'man1'))
endif
