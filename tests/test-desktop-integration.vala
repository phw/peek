void test_get_video_folder () {
  var folder = DesktopIntegration.get_video_folder ();
  assert_nonnull (folder);
  assert (
    folder == GLib.Environment.get_user_special_dir (GLib.UserDirectory.VIDEOS)
    || folder == GLib.Environment.get_user_special_dir (GLib.UserDirectory.PICTURES)
    || folder == GLib.Environment.get_home_dir ()
  );
}

void main (string[] args) {
  GLib.Test.init (ref args);
  Gtk.init (ref args);

  GLib.Test.add_func ("/desktop-integration/test_get_video_folder", test_get_video_folder);

  GLib.Test.run ();
}
