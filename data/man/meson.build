txt2man = find_program('txt2man', required: false)

if not txt2man.found()
  message('txt2man not found; man pages will not be generated.')
else
  message('Found txt2man; man page will be built and installed')
  manpage = run_command([
    join_paths(meson.current_source_dir(), 'build_man.sh'),
    '-t', meson.project_name().to_upper(),
    '-r', meson.project_version(),
    '-s', '1',
    '-v', '"User commands"',
    join_paths(meson.current_source_dir(), 'peek.1.txt'),
  ])
  install_man(join_paths(meson.current_build_dir(), 'peek.1'))
endif
