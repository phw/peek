using Peek.Recording;

void test_equals () {
  var area = RecordingArea () {
    left = 100,
    top = 200,
    width = 300,
    height = 400
  };

  assert (area.equals (area));
  assert (!area.equals (null));
  assert (!area.equals (RecordingArea ()));
  assert (area.equals (RecordingArea () {
    left = 100,
    top = 200,
    width = 300,
    height = 400
    })
  );
  assert (!area.equals (RecordingArea () {
    left = 101,
    top = 200,
    width = 300,
    height = 400
    })
  );
  assert (!area.equals (RecordingArea () {
    left = 100,
    top = 201,
    width = 300,
    height = 400
    })
  );
  assert (!area.equals (RecordingArea () {
    left = 100,
    top = 200,
    width = 301,
    height = 400
    })
  );
  assert (!area.equals (RecordingArea () {
    left = 100,
    top = 200,
    width = 300,
    height = 401
    })
  );
}

void main (string[] args) {
  Test.init (ref args);
  Gtk.init (ref args);

  Test.add_func (
    "/screen-recorder/recording-area/test_equals",
    test_equals);

  Test.run ();
}
