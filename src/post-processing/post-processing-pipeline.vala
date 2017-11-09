/*
Peek Copyright (c) 2017 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

namespace Peek.PostProcessing {

  /**
  * Uses ffmpeg to generate PNG images for each frame.
  */
  public class PostProcessingPipeline : Object, PostProcessor {
    private Array<PostProcessor> pipeline;
    private PostProcessor? active_post_processor = null;
    private bool cancelled = false;

    public PostProcessingPipeline () {
      pipeline = new Array<PostProcessor>();
    }

    public void add (PostProcessor post_processor) {
      pipeline.append_val (post_processor);
    }

    public async Array<File>? process_async (Array<File> files) {
      foreach (var post_processor in pipeline.data) {
        debug ("Running post processor %s with files %s", post_processor.get_type ().name (), files.length.to_string ());

        if (cancelled) {
          return null;
        }

        active_post_processor = post_processor;
        var new_files = yield post_processor.process_async (files);

        foreach (var file in files.data) {
          try {
            yield file.delete_async ();
          } catch (Error e) {
            stderr.printf ("Error deleting temporary file %s: %s\n", file.get_path (), e.message);
          }
        }

        if (new_files == null) {
          cancelled = true;
          active_post_processor = null;
          return null;
        }

        files = new_files;
      }

      active_post_processor = null;

      return files;
    }

    public void cancel () {
      if (active_post_processor != null && !cancelled) {
        cancelled = true;
        active_post_processor.cancel ();
        active_post_processor = null;
      }
    }
  }
}
