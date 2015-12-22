/*
Peek Copyright (c) 2015 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

public class PeekApplication : Gtk.Application {
  private Gtk.Window main_window;
  private ScreenRecorder recorder;

  public PeekApplication () {
    Object (application_id: "de.uploadedlobster.peek",
      flags: ApplicationFlags.FLAGS_NONE);
  }

  public override void activate () {
    recorder = new ScreenRecorder ();
    main_window = new PeekApplicationWindow (this, recorder);
    main_window.present ();
  }

  public override void startup () {
    base.startup ();

    GLib.SimpleAction action;

    /*var action = new GLib.SimpleAction ("preferences", null);
    action.activate.connect (preferences);
    add_action (action);*/

    action = new GLib.SimpleAction ("about", null);
    action.activate.connect (show_about);
    add_action (action);

    action = new GLib.SimpleAction ("quit", null);
    action.activate.connect (quit);
    add_action (action);
  }

  public override void shutdown () {
    recorder.cancel ();
    base.shutdown ();
  }

  private void show_about () {
    var dialog = new PeekAboutDialog (main_window);
    dialog.show ();
  }
}
