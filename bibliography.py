#!/usr/bin/env python3

import re
import sys
import logging
logger = logging.getLogger(__name__)

BIBLIO_PAGE = "Bibliographische Verweise"
TARGET = "xslt/bibliography.xml"


URI = re.compile(r'^\*\s*(faust://bibliography/\S*)')
SHORT = re.compile(r'^\*{2}\s*(.*)')
LONG = re.compile(r'^\*{3}\s*(.*)')

ENTRY = """
    <f:bib uri="{uri}">
        <f:citation>{short}</f:citation>
        <f:reference>{full}</f:reference>
    </f:bib>
"""

START = """<?xml version="1.0" encoding="utf-8"?>
<!-- This file has been generated from:
    https://faustedition.uni-wuerzburg.de/wiki/index.php/Bibliographische_Verweise
    Please edit there
-->
<?xml-model href="bibliography.rnc"?>
<f:bibliography
    xmlns:f="http://www.faustedition.net/ns"
    xmlns="http://www.w3.org/1999/xhtml">
"""
STOP = """
</f:bibliography>
"""


def cleanup(lines):
    URL = re.compile(r"\[(https?://\S+)\s+([^]]+)\]")
    UNSMALL = re.compile(r"<small>.*?</small>")
    UNCOMMENT = re.compile(r"<!--.*?-->")
    STRONG = re.compile(r"'''(.*?)'''")
    EMPH = re.compile(r"''(.*?)''")
    for line in lines:
        line = UNSMALL.sub('', line)
        line = UNCOMMENT.sub('', line)
        line = line.replace('&nbsp;', ' ')
        line = line.replace('&', '&amp;')
        line = line.replace('<', '&lt;')
        line = STRONG.sub(r'<strong>\1</strong>', line)
        line = EMPH.sub(r'<emph>\1</emph>', line)
        line = URL.sub(r'<a href="\1">\2</a>', line)
        yield line


def wiki_to_xml(lines, outfile=sys.stdout):
    lines = iter(cleanup(lines))
    entrycount = 0
    try:
        outfile.write(START)
        line = next(lines)
        while True:
            uri = URI.match(line)
            if uri:
                entry = {"uri": uri.group(1)}
                line = next(lines)
                short = SHORT.match(line)
                if short:
                    entry["short"] = short.group(1)
                    line = next(lines)
                    full = LONG.match(line)
                    if full:
                        entry["full"] = full.group(1)
                        outfile.write(ENTRY.format_map(entry))
                        entrycount += 1
                        line = next(lines)
            else:
                line = next(lines)
    except StopIteration:
        outfile.write(STOP)
    logger.info("Wrote %d bibliography entries to %s", entrycount, outfile)


__all__ = [BIBLIO_PAGE, TARGET, wiki_to_xml]
