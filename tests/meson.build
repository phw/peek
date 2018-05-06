# /desktop-integration/
test_desktop_integration = executable('test-desktop-integration',
  'test-desktop-integration.vala',
  join_paths(meson.source_root(), 'src/desktop-integration.vala'),
  join_paths(meson.source_root(), 'src/dbus/freedesktop-filemanager.vala'),
  dependencies: [
    dependency('gtk+-3.0'),
  ],
  install: false,
)
test('Testing desktop-integration', test_desktop_integration)

# /utils/
test_utils = executable('test-utils',
  'test-utils.vala',
  join_paths(meson.source_root(), 'src/defaults.vala'),
  join_paths(meson.source_root(), 'src/utils.vala'),
  dependencies: [
    dependency('gtk+-3.0'),
  ],
  install: false,
)
test('Testing utils', test_utils)

# /screen-recorder/recording-area/
test_utils = executable('test-cli-screen-recorder',
  'screen-recorder/test-cli-screen-recorder.vala',
  join_paths(meson.source_root(), 'src/post-processing/cli-post-processor.vala'),
  join_paths(meson.source_root(), 'src/post-processing/extract-frames-post-processor.vala'),
  join_paths(meson.source_root(), 'src/post-processing/ffmpeg-post-processor.vala'),
  join_paths(meson.source_root(), 'src/post-processing/gifski-post-processor.vala'),
  join_paths(meson.source_root(), 'src/post-processing/post-processing-pipeline.vala'),
  join_paths(meson.source_root(), 'src/post-processing/post-processor.vala'),
  join_paths(meson.source_root(), 'src/recording/recording-area.vala'),
  join_paths(meson.source_root(), 'src/recording/recording-config.vala'),
  join_paths(meson.source_root(), 'src/recording/screen-recorder.vala'),
  join_paths(meson.source_root(), 'src/recording/base-screen-recorder.vala'),
  join_paths(meson.source_root(), 'src/recording/cli-screen-recorder.vala'),
  join_paths(meson.source_root(), 'src/defaults.vala'),
  join_paths(meson.source_root(), 'src/errordomain.vala'),
  join_paths(meson.source_root(), 'src/utils.vala'),
  vala_args: ['--pkg', 'posix'],
  dependencies: [
    dependency('gtk+-3.0'),
  ],
  install: false,
)
test('Testing cli-screen-recorder', test_utils)
