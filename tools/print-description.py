#!/bin/env python3

# Copyright (c) 2017 Philipp Wolfer <ph.wolfer@gmail.com>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# Extract summary and description from AppStream file in the selected locale.
# Run as `print-description.py [locales]`, e.g. `print-description.py de it`.

import gi
import os
import re
import sys
gi.require_version('AppStreamGlib', '1.0')
from gi.repository import AppStreamGlib
from html2text import HTML2Text
from subprocess import call

APP_ID = 'com.uploadedlobster.peek'
APPSTREAM_TMP_FILE = '/tmp/%s.appdata.xml' % APP_ID

DEFAULT_LOCALE = 'C'
locales = [DEFAULT_LOCALE]

if len(sys.argv) > 1:
    locales = sys.argv[1:]

# Configure html2text
html2text = HTML2Text()
html2text.body_width = 0
html2text.ignore_links = True
html2text.ignore_images = True
html2text.ul_item_mark = '-'


def format_description(text):
    text = html2text.handle(description).strip()
    text = re.sub(r"(\s*\n){3,}", "\n\n", text)
    return text


def translate_appstream_template(output_file):
    cwd = os.path.dirname(os.path.abspath(__file__))
    appstream_template = os.path.join(
        cwd, '../data/%s.appdata.xml.in' % APP_ID)
    call([
        'msgfmt', '--xml',
        '--template', appstream_template,
        '-d', os.path.join(cwd, '../po'),
        '-o', output_file
    ])


# Parse AppStream file
translate_appstream_template(APPSTREAM_TMP_FILE)
app = AppStreamGlib.App.new()
app.parse_file(APPSTREAM_TMP_FILE, AppStreamGlib.AppParseFlags.NONE)

for locale in locales:
    name = app.get_name(locale) or app.get_name(DEFAULT_LOCALE)
    summary = app.get_comment(locale) or app.get_comment(DEFAULT_LOCALE)
    description = app.get_description(
        locale) or app.get_description(DEFAULT_LOCALE)
    keywords = app.get_keywords(locale) or app.get_keywords(DEFAULT_LOCALE)

    text = """
{locale}
{name}
{summary}

{description}

{keywords}
---""".format(
        locale=locale,
        name=name,
        summary=summary,
        description=format_description(description),
        keywords=", ".join(keywords),
    )
    print(text)

# Cleanup temp file
os.remove(APPSTREAM_TMP_FILE)
