/*
Peek Copyright (c) 2017-2018 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

namespace Peek {

  const string APP_ID = "com.uploadedlobster.peek";

  const int DEFAULT_FRAMERATE = 15;
  const int DEFAULT_DOWNSAMPLE = 1;
  const int DEFAULT_GIFSKI_QUALITY = 60;

  const string ISSUE_TRACKER_URL = "https://github.com/phw/peek/issues/new";

  public enum OutputFormat {
    APNG,
    GIF,
    MP4,
    WEBM;

    public string to_string() {
      switch (this) {
        case APNG:
          return "apng";
        case GIF:
          return "gif";
        case WEBM:
          return "webm";
        case MP4:
          return "mp4";
        default:
          assert_not_reached ();
      }
    }
  }
}
