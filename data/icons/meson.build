icon_dir = join_paths(get_option('datadir'), 'icons/hicolor')

icon_sizes = ['16x16', '24x24', '32x32', '48x48', '64x64', '128x128', '256x256', '512x512']

foreach size : icon_sizes
  install_data(size + '/com.uploadedlobster.peek.png',
    install_dir: join_paths(icon_dir, size, 'apps'))
endforeach
