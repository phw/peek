/*
Peek Copyright (c) 2016-2017 by Philipp Wolfer <ph.wolfer@gmail.com>

This file is part of Peek.

This software is licensed under the GNU General Public License
(version 3 or later). See the LICENSE file in this distribution.
*/

namespace Peek.PostProcessing {

  public interface PostProcessor : Object {
    public abstract async File[]? process_async (File[] file);

    public abstract void cancel ();
  }

}
