/*
Peek Copyright (c) 2017 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

using Gnome.Shell;
using Peek.PostProcessing;

namespace Peek.Recording {

  public class GnomeShellDbusRecorder : BaseScreenRecorder {
    private Screencast screencast;

    private const string DBUS_NAME = "org.gnome.Shell.Screencast";

    public GnomeShellDbusRecorder () throws IOError {
      screencast = Bus.get_proxy_sync (
        BusType.SESSION,
        DBUS_NAME,
        "/org/gnome/Shell/Screencast");
    }

    public override bool record (RecordingArea area) {
      // Cancel running recording
      cancel ();

      bool success = false;

      var options = new HashTable<string, Variant> (null, null);
      options.insert ("framerate", new Variant.int32 (framerate));
      options.insert ("pipeline", build_gst_pipeline (area));

      if (!capture_mouse) {
        options.insert ("draw-cursor", false);
      }

      try {
        string file_template = Utils.create_temp_file (
          get_temp_file_extension ()
        );

        int width = area.width;
        int height = area.height;
        if (output_format == OUTPUT_FORMAT_MP4 ||
            output_format == OUTPUT_FORMAT_GIF) {
          width = Utils.make_even (width);
          height = Utils.make_even (height);
        }

        screencast.screencast_area (
          area.left, area.top, width, height,
          file_template, options, out success, out temp_file);

        if (success) {
          stdout.printf ("Recording to file %s\n", temp_file);
        } else {
          stdout.printf ("Could not start recording, already an active recording using org.gnome.Shell.Screencast?\n");
        }
      } catch (DBusError e) {
        stderr.printf ("Error: %s\n", e.message);
        return false;
      } catch (IOError e) {
        stderr.printf ("Error: %s\n", e.message);
        return false;
      } catch (FileError e) {
        stderr.printf ("Error: %s\n", e.message);
        return false;
      }

      is_recording = success;
      return success;
    }

    public static bool is_available () throws PeekError {
      // In theory the dbus service can be installed, but it will only work
      // if GNOME Shell is running.
      if (!DesktopIntegration.is_gnome ()) {
        return false;
      }

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

    protected override void stop_recording () {
      try {
        screencast.stop_screencast ();
        if (!is_cancelling) {
          finalize_recording ();
        }
      } catch (DBusError e) {
        stderr.printf ("Error: %s\n", e.message);
        if (!is_cancelling) {
          recording_aborted (0);
        }
      } catch (IOError e) {
        stderr.printf ("Error: %s\n", e.message);
        if (!is_cancelling) {
          recording_aborted (0);
        }
      }
    }

    private string build_gst_pipeline (RecordingArea area) {

      // Default pipeline is for GNOME Shell up to 2.22:
      // "vp8enc min_quantizer=13 max_quantizer=13 cpu-used=5 deadline=1000000 threads=%T ! queue ! webmmux"
      // GNOME Shell 3.24 will use vp9enc with same settings.
      var pipeline = new StringBuilder ();

      if (downsample > 1) {
        int width = area.width / downsample;
        int height = area.height / downsample;

        if (output_format == OUTPUT_FORMAT_MP4 ||
            output_format == OUTPUT_FORMAT_GIF) {
          width = Utils.make_even (width);
          height = Utils.make_even (height);
        }

        pipeline.append_printf (
          "videoscale ! video/x-raw,width=%i,height=%i ! ", width, height);
      }

      if (output_format == OUTPUT_FORMAT_WEBM) {
        pipeline.append ("vp8enc min_quantizer=10 max_quantizer=50 cq_level=13 cpu-used=5 deadline=1000000 threads=%T ! ");
        pipeline.append ("queue ! webmmux");
      } else if (output_format == OUTPUT_FORMAT_MP4) {
        pipeline.append ("x264enc speed-preset=fast threads=%T ! ");
        pipeline.append ("video/x-h264, profile=baseline ! ");
        pipeline.append ("queue ! mp4mux");
      } else {
        pipeline.append ("x264enc speed-preset=ultrafast quantizer=0 threads=%T ! ");
        pipeline.append ("queue ! mp4mux");
      }

      debug ("Using GStreamer pipeline %s", pipeline.str);
      return pipeline.str;
    }

    private string get_temp_file_extension () {
      var extension = output_format == OUTPUT_FORMAT_GIF ?
        "mp4" : Utils.get_file_extension_for_format (output_format);
      return extension;
    }
  }

}
