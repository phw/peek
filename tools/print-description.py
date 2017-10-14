#!/bin/env python3

# Extract summary and description from AppStream file in the selectec locale.
# Run as `print-description.py [locales]`, e.g. `print-description.py de it`.

import sys
import gi
import re
gi.require_version('AppStreamGlib', '1.0')
from gi.repository import AppStreamGlib
from html2text import HTML2Text

# TODO: Use AppStream file from source tree (needs processing with gettext)
appstream_file = "/usr/share/metainfo/com.uploadedlobster.peek.appdata.xml"

default_locale = 'C'
locales = [ default_locale ]

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
    text = re.sub(r"\s*\n{3,}", "\n\n", text)
    return text

# Parse AppStream file
app = AppStreamGlib.App.new()
app.parse_file(appstream_file, AppStreamGlib.AppParseFlags.NONE)

for locale in locales:
  name = app.get_name(locale) or app.get_name(default_locale)
  summary = app.get_comment(locale) or app.get_comment(default_locale)
  description = app.get_description(locale) or app.get_description(default_locale)
  keywords = app.get_keywords(locale) or app.get_keywords(default_locale)

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
