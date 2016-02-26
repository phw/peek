using Peek.Recording;

class TestCommandLineScreenRecorder : CommandLineScreenRecorder {
  public bool stop_command_called { get; set; default = false; }

  public override bool record (RecordingArea area) {
    is_recording = true;
    stop_command_called = false;
    return true;
  }

  protected override void stop_command () {
    stop_command_called = true;
  }
}

void test_cancel () {
  var recorder = new TestCommandLineScreenRecorder ();
  bool recording_aborted_called = false;
  recorder.recording_aborted.connect ((status) => {
    recording_aborted_called = true;
    assert (status == 0);
  });

  recorder.record (RecordingArea ());

  assert (recorder.is_recording);
  assert (!recorder.stop_command_called);

  recorder.cancel ();

  assert (!recorder.is_recording);
  assert (recorder.stop_command_called);
  assert (recording_aborted_called);
}

void main (string[] args) {
  GLib.Test.init (ref args);
  Gtk.init (ref args);

  GLib.Test.add_func (
    "/screen-recorder/command-line-screen-recorder/test_cancel",
    test_cancel);

  GLib.Test.run ();
}
