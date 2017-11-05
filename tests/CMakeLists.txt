enable_testing()

# /desktop-integration/
vala_precompile(VALA_TEST_DESKTOP_INTEGRATION_C
    test-desktop-integration.vala
    ../src/desktop-integration.vala
    ../src/dbus/freedesktop-filemanager.vala
  PACKAGES
    gtk+-3.0
)

add_executable(
  ${PROJECT_NAME}-test-desktop-integration
  ${VALA_TEST_DESKTOP_INTEGRATION_C})

add_test(
  test-desktop-integration
  ${PROJECT_NAME}-test-desktop-integration)

# /utils/
vala_precompile(VALA_TEST_UTILS_C
    test-utils.vala
    ../src/defaults.vala
    ../src/utils.vala
  PACKAGES
    gtk+-3.0
)

add_executable(
  ${PROJECT_NAME}-test-utils
  ${VALA_TEST_UTILS_C})

add_test(
  test-utils
  ${PROJECT_NAME}-test-utils)

# /screen-recorder/recording-area/
vala_precompile(VALA_TEST_RECORDING_AREA_C
    screen-recorder/test-recording-area.vala
    ../src/recording/recording-area.vala
  PACKAGES
    gtk+-3.0
)

add_executable(
  ${PROJECT_NAME}-screen-recorder-test-recording-area
  ${VALA_TEST_RECORDING_AREA_C})

add_test(
  screen-recorder-test-recording-area
  ${PROJECT_NAME}-screen-recorder-test-recording-area)

# /screen-recorder/command-line-screen-recorder/
vala_precompile(VALA_TEST_COMMAND_LINE_SCREEN_RECORDER_C
    screen-recorder/test-command-line-screen-recorder.vala
    ../src/post-processing/post-processor.vala
    ../src/post-processing/extract-frames-post-processor.vala
    ../src/post-processing/ffmpeg-post-processor.vala
    ../src/post-processing/gifski-post-processor.vala
    ../src/post-processing/imagemagick-post-processor.vala
    ../src/recording/recording-area.vala
    ../src/recording/screen-recorder.vala
    ../src/recording/base-screen-recorder.vala
    ../src/recording/command-line-screen-recorder.vala
    ../src/defaults.vala
    ../src/utils.vala
  PACKAGES
    gtk+-3.0
    posix
)

add_executable(
  ${PROJECT_NAME}-test-screen-recorder-command-line-screen-recorder
  ${VALA_TEST_COMMAND_LINE_SCREEN_RECORDER_C})

add_test(
  test-screen-recorder-command-line-screen-recorder
  ${PROJECT_NAME}-test-screen-recorder-command-line-screen-recorder)
