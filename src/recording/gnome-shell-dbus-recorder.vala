/*
Peek Copyright (c) 2017-2018 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

#if ! DISABLE_GNOME_SHELL

using Gnome.Shell;
using Peek.PostProcessing;

namespace Peek.Recording {

  public class GnomeShellDbusRecorder : BaseScreenRecorder {
    private Screencast screencast;

    private const string DBUS_NAME = "org.gnome.Shell.Screencast";

    private uint wait_timeout = 0;

    public GnomeShellDbusRecorder () throws IOError {
      base ();
      screencast = Bus.get_proxy_sync (
        BusType.SESSION,
        DBUS_NAME,
        "/org/gnome/Shell/Screencast");
    }

    ~GnomeShellDbusRecorder () {
      if (wait_timeout != 0) {
        Source.remove (wait_timeout);
      }
    }

    protected override void start_recording (RecordingArea area) throws RecordingError {
      bool success = false;

      var options = new HashTable<string, Variant> (null, null);
      options.insert ("framerate", new Variant.int32 (config.framerate));
      options.insert ("pipeline", build_gst_pipeline (area));

      if (!config.capture_mouse) {
        options.insert ("draw-cursor", false);
      }

      try {
        string file_template = Utils.create_temp_file (
          get_temp_file_extension ()
        );

        int width = area.width;
        int height = area.height;
        if (config.output_format == OutputFormat.MP4) {
          width = Utils.make_even (width);
          height = Utils.make_even (height);
        }

        screencast.screencast_area (
          area.left, area.top, width, height,
          file_template, options, out success, out temp_file);

        if (success) {
          stdout.printf ("Recording to file %s\n", temp_file);
        } else {
          var message = new StringBuilder ();
          message.append("Could not start GNOME Shell recorder.\n\n");
          if (config.output_format == OutputFormat.MP4) {
            message.append("Make sure you have the GStreamer ugly plugins installed for MP4 recording.");
          } else {
            message.append("Missing codec or another active screen recording using org.gnome.Shell.Screencast?");
          }

          message.append("\n\nPlease see the FAQ at https://github.com/phw/peek#what-is-the-cause-for-could-not-start-gnome-shell-recorder-errors");
          throw new RecordingError.INITIALIZING_RECORDING_FAILED (message.str);
        }
      } catch (DBusError e) {
        throw new RecordingError.INITIALIZING_RECORDING_FAILED (e.message);
      } catch (IOError e) {
        throw new RecordingError.INITIALIZING_RECORDING_FAILED (e.message);
      } catch (FileError e) {
        throw new RecordingError.INITIALIZING_RECORDING_FAILED (e.message);
      }

      is_recording = success;
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
          // Add a small timeout after GNOME Shell recorder was stopped.
          // The recorder will stop the GST pipeline, but there might be still
          // some cleanup / finalization to do. Without this the post-processing
          // sometimes fails.
          wait_timeout = Timeout.add_full (GLib.Priority.LOW, 400, () => {
            Source.remove (wait_timeout);
            wait_timeout = 0;
            finalize_recording ();
            return true;
          });
        }
      } catch (DBusError e) {
        stderr.printf ("Error: %s\n", e.message);
        if (!is_cancelling) {
          recording_aborted (new RecordingError.RECORDING_ABORTED (e.message));
        }
      } catch (IOError e) {
        stderr.printf ("Error: %s\n", e.message);
        if (!is_cancelling) {
          recording_aborted (new RecordingError.RECORDING_ABORTED (e.message));
        }
      }
    }

    private string build_gst_pipeline (RecordingArea area) {

      // Default pipeline is for GNOME Shell up to 2.22:
      // "vp8enc min_quantizer=13 max_quantizer=13 cpu-used=5 deadline=1000000 threads=%T ! queue ! webmmux"
      // GNOME Shell 3.24 will use vp9enc with same settings.
      // See https://gitlab.gnome.org/GNOME/gnome-shell/blob/master/src/shell-recorder.c#L149
      var pipeline = new StringBuilder ();

      if (config.downsample > 1) {
        int width = area.width / config.downsample;
        int height = area.height / config.downsample;

        if (config.output_format == OutputFormat.MP4) {
          width = Utils.make_even (width);
          height = Utils.make_even (height);
        }

        pipeline.append_printf (
          "videoscale ! video/x-raw,width=%i,height=%i ! ", width, height);
      }

      if (config.output_format == OutputFormat.WEBM) {
        pipeline.append ("videoconvert ! queue ! videorate ! vp9enc min_quantizer=10 max_quantizer=50 cq_level=13 cpu-used=5 deadline=1000000 threads=%T ! queue ! ");
        if (config.capture_sound) {
          pipeline.append ("mux. pulsesrc ! queue !  audioconvert ! vorbisenc ! ");
        }
        pipeline.append ("queue ! mux. webmmux name=mux");
      } else if (config.output_format == OutputFormat.MP4) {
        pipeline.append ("videoconvert ! queue ! videorate ! x264enc speed-preset=fast threads=%T ! ");
        pipeline.append ("video/x-h264, profile=baseline ! queue !");
        if (config.capture_sound) {
          pipeline.append ("mux. pulsesrc ! queue !  audioconvert ! lamemp3enc ! ");
        }
        pipeline.append ("queue ! mux. mp4mux name=mux");
      } else {
        // We could use lossless x264 here, but x264enc is part of
        // gstreamer1.0-plugins-ugly and not always available.
        // Being near lossless here is important to avoid color distortions and
        // dirty frames in the final GIF.
        pipeline.append ("vp9enc min_quantizer=0 max_quantizer=0 cq_level=0 cpu-used=5 deadline=1000000 threads=%T ! ");
        pipeline.append ("queue ! webmmux");
      }

      debug ("Using GStreamer pipeline %s", pipeline.str);
      debug ("Debug with gst-launch-1.0 --gst-debug=3 ximagesrc %s ! filesink location=screencast", pipeline.str);
      return pipeline.str;
    }

    private string get_temp_file_extension () {
      string extension;
      if (config.output_format == OutputFormat.GIF
        || config.output_format == OutputFormat.APNG) {
        extension = "webm";
      } else {
        extension = Utils.get_file_extension_for_format (config.output_format);
      }

      return extension;
    }
  }

}

#endif
