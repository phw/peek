using Peek;

void test_get_video_folder () {
  var folder = DesktopIntegration.get_video_folder ();
  assert_nonnull (folder);
  assert (
    folder == Environment.get_user_special_dir (UserDirectory.VIDEOS)
    || folder == Environment.get_user_special_dir (UserDirectory.PICTURES)
    || folder == Environment.get_home_dir ()
  );
}

void main (string[] args) {
  Test.init (ref args);
  Gtk.init (ref args);

  Test.add_func ("/desktop-integration/test_get_video_folder", test_get_video_folder);

  Test.run ();
}
