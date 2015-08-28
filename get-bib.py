#!/usr/bin/env python3

import requests
from getpass import getpass
import codecs
import re
import sys

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
<f:bibliography
    xmlns:f="http://www.faustedition.net/ns"
    xmlns="http://www.w3.org/1999/xhtml">
"""
STOP = """
</f:bibliography>
"""
URL = re.compile(r"\[(https?://\S+)\s+([^]]+)\]")


def cleanup(lines):
    for line in lines:
        line = line.replace('&nbsp;', ' ')
        line = line.replace('&', '&amp;')
        line = line.replace('<', '&lt;')
        line = URL.sub(r'<a href="\1">\2</a>', line)
        yield line


def wiki_to_xml(lines, outfile=sys.stdout):
    lines = iter(cleanup(lines))
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
                        line = next(lines)
            else:
                line = next(lines)
    except StopIteration:
        outfile.write(STOP)


def fetch_bib():
    api = "https://faustedition.uni-wuerzburg.de/wiki/api.php"
    index = "https://faustedition.uni-wuerzburg.de/wiki/index.php"
    lguser = input("Wiki User: ")
    lgpass = getpass("Wiki Password: ")

    s = requests.Session()
    s.verify = False

    loginparams = dict(
        lgname=lguser,
        lgpassword=lgpass,
        action='login',
        format='json')
    login1 = s.post(api, params=loginparams)
    token = login1.json()['login']['token']
    loginparams["lgtoken"] = token
    login2 = s.post(api, params=loginparams)
    page = s.get(index, params=dict(
        title="Bibliographische Verweise",
        action="raw",
        token=token))
    text = codecs.decode(page.content, page.encoding)
    return text.split('\n')

if __name__ == "__main__":
    with open("bibliography.xml", "w", encoding="UTF-8") as outfile:
        wiki_to_xml(fetch_bib(), outfile)
