/*
Peek Copyright (c) 2015-2017 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

namespace Peek.Recording.Ffmpeg {
  public void add_output_parameters (
    Array<string> args, RecordingConfig config, out string extension) {
    if (config.output_format == OUTPUT_FORMAT_WEBM) {
      extension = Utils.get_file_extension_for_format (config.output_format);
      args.append_val ("-codec:v");
      // args.append_val ("libvpx-vp9");
      args.append_val ("libvpx");
      args.append_val ("-qmin");
      args.append_val ("10");
      args.append_val ("-qmax");
      args.append_val ("50");
      args.append_val ("-crf");
      args.append_val ("13");
      args.append_val ("-b:v");
      args.append_val ("1M");
    } else if (config.output_format == OUTPUT_FORMAT_MP4) {
      extension = Utils.get_file_extension_for_format (config.output_format);
      args.append_val ("-codec:v");
      args.append_val ("libx264");
      args.append_val ("-preset:v");
      args.append_val ("fast");
      args.append_val ("-profile:v");
      args.append_val ("baseline");
      args.append_val ("-pix_fmt");
      args.append_val ("yuv420p");
    } else {
      extension = "mkv";
      args.append_val ("-codec:v");
      args.append_val ("libx264rgb");
      args.append_val ("-preset:v");
      args.append_val ("ultrafast");
      args.append_val ("-crf");
      args.append_val ("0");
    }
  }
}
