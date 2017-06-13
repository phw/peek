using Peek;

void test_make_even () {
  assert(Utils.make_even (3) == 2);
  assert(Utils.make_even (4) == 4);
  assert(Utils.make_even (0) == 0);
  assert(Utils.make_even (-7) == -6);
  assert(Utils.make_even (-12) == -12);
}

void main (string[] args) {
  GLib.Test.init (ref args);
  Gtk.init (ref args);

  GLib.Test.add_func ("/utils/test_make_even", test_make_even);

  GLib.Test.run ();
}
