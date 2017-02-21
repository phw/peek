/*
Peek Copyright (c) 2017 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

using Gnome.Shell;
using Peek.PostProcessing;

namespace Peek.Recording {

  public class GnomeShellDbusRecorder : Object, ScreenRecorder {
    public bool is_recording { get; protected set; default = false; }

    public int framerate { get; set; default = DEFAULT_FRAMERATE; }

    public int downsample { get; set; default = DEFAULT_DOWNSAMPLE; }

    string temp_file;
    private Screencast screencast;

    private const string DBUS_NAME = "org.gnome.Shell.Screencast";

    public GnomeShellDbusRecorder () throws IOError {
      screencast = Bus.get_proxy_sync (
        BusType.SESSION,
        DBUS_NAME,
        "/org/gnome/Shell/Screencast");
    }

    public bool record (RecordingArea area) {
      bool success = false;

      var options = new HashTable<string, Variant> (null, null);
      options.insert ("framerate", new Variant.int32(framerate));
      options.insert ("pipeline", build_gst_pipeline (area));

      try {
        string file_template = Path.build_filename (
          Environment.get_tmp_dir (), "peek %d.avi");
        screencast.screencast_area (
          area.left, area.top, area.width, area.height,
          file_template, options, out success, out temp_file);
        stdout.printf ("Recording to file %s\n", temp_file);
      } catch (DBusError e) {
        stderr.printf ("Error: %s\n", e.message);
        return false;
      } catch (IOError e) {
        stderr.printf ("Error: %s\n", e.message);
        return false;
      }

      is_recording = success;
      return success;
    }

    public void stop () {
      stdout.printf ("Recording stopped\n");
      stop_recording ();

      run_post_processors_async.begin ((obj, res) => {
        var file = run_post_processors_async.end (res);
        remove_temp_file ();
        recording_finished (file);
      });
    }

    public void cancel () {
      if (is_recording) {
        stop_recording ();
        remove_temp_file ();
        recording_aborted (0);
      }
    }

    public static bool is_available () throws PeekError {
      try {
        Freedesktop.DBus dbus = Bus.get_proxy_sync (
          BusType.SESSION,
          "org.freedesktop.DBus",
          "/org/freedesktop/DBus");
        return dbus.name_has_owner (DBUS_NAME);
      } catch (DBusError e) {
        stderr.printf ("Error: %s\n", e.message);
        throw new PeekError.SCREEN_RECORDER_ERROR (e.message);
      } catch (IOError e) {
        stderr.printf ("Error: %s\n", e.message);
        throw new PeekError.SCREEN_RECORDER_ERROR (e.message);
      }
    }

    private void stop_recording () {
      if (is_recording) {
        try {
          screencast.stop_screencast ();
        } catch (DBusError e) {
          stderr.printf ("Error: %s\n", e.message);
        } catch (IOError e) {
          stderr.printf ("Error: %s\n", e.message);
        }
      }

      is_recording = false;
    }

    private async File? run_post_processors_async () {
      var file = File.new_for_path (temp_file);
      var postProcessor = new ImagemagickPostProcessor (framerate);
      file = yield postProcessor.process_async (file);
      return file;
    }

    private void remove_temp_file () {
      if (temp_file != null) {
        FileUtils.remove (temp_file);
        temp_file = null;
      }
    }

    private string build_gst_pipeline (RecordingArea area) {

      // Default pipeline is "videorate ! vp8enc quality=10 speed=2 threads=%T ! queue ! webmmux"
      var pipeline = new StringBuilder ();
      pipeline.append ("videorate ! ");

      if (downsample > 1) {
        int width = area.width / downsample;
        int height = area.height / downsample;
        pipeline.append_printf ("videoscale ! video/x-raw,width=%i,height=%i ! ", width, height);
      }

      pipeline.append ("x264enc speed-preset=ultrafast threads=%T ! ");
      pipeline.append ("queue ! avimux");

      debug ("Using GStreamer pipeline %s", pipeline.str);
      return pipeline.str;
    }
  }

}
