#!/usr/bin/env python3
# coding: utf-8

"""
This script reads the table of testimonies from an excel file in the wiki
and writes it to a simple HTML table.


Attributes:

    selected_columns (list): Labels of the columns in the original table that should be selected.
    column_labels (list): New labels for the selected_columns

"""

import pandas as pd
from lxml import etree
import requests
from getpass import getpass
import io
import sys
import unicodedata
import re

def sanitize_colname(colname):
    colname = unicodedata.normalize('NFKC', colname).lower()
    colname = colname.translate({ ord('ä'): 'ae', ord('ü'): 'ue', ord('ö'):
                                 'oe', ord('ß'): 'ss'})
    colname = re.sub(r'[\W_-]+', '-', colname).strip('-')
    return colname

def to_id(row):
    for column, prefix in [('graef-nr', 'graef'), ('pniower-nr', 'pniower'),
                           ('quz', 'quz'), ('biedermann-herwignr', 'bie3')]:
        if not pd.isnull(row[column]):
            return prefix + '_' + str(row[column])


def fetch_table():
    """
    Fetches the excel file from the wiki, interactively asking for a password
    """
    api = "https://faustedition.uni-wuerzburg.de/wiki/api.php"
    xlsurl = "https://faustedition.uni-wuerzburg.de/wiki/images/b/b5/Dokumente_zur_Entstehungsgeschichte.xls"
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
    s.post(api, params=loginparams)
    response = s.get(xlsurl, params=dict(token=token))
    return io.BytesIO(response.content)

def read_testimonies(buf, **kwargs):
    """
    Reads the table from the given object

    Args:
        buf: cf. :func:`pd.read_excel`
        kwargs: passed on to pandas

    Returns:
        pd.DataFrame
    """
    return pd.read_excel(buf, **kwargs)

def improve_testimony_table(testimonies):
    testimonies = testimonies.copy()
    testimonies.columns = [ sanitize_colname(col) for col in testimonies.columns ]

    for col in testimonies.columns:
        if col.startswith('datum'):
            testimonies.loc[:,col] = testimonies.loc[:,col].str.replace('00\.', '')
    testimonies.loc[:,'ID'] = testimonies.apply(to_id, axis=1)
    return testimonies

def to_xml(testimony_df, orignames):
    ns = "http://www.faustedition.net/ns"
    NS = "{"+ns+"}"
    nsmap = {None : ns}
    root = etree.Element(NS + "testimonies", nsmap=nsmap)
    root.addprevious(etree.Comment("This document is sporadically re-generated from an Excel sheet in the wiki. Please don't edit it directly"))

    header = root.makeelement(NS + "header")
    header.append(etree.Comment("These fields have been found in the excel table:"))
    for col, orig in zip(testimony_df.columns, orignames):
        if col != 'ID':
            el = header.makeelement(NS + "fieldspec",
                                    attrib=dict(name=col, spreadsheet=orig))
            header.append(el)
    root.append(header)

    for __, row in testimony_df.iterrows():
        row_el = root.makeelement(NS + "testimony")
        if not pd.isnull(row.ID):
            row_el.attrib['id'] = row.ID
        for label, value in row.iteritems():
            if label is 'ID':    # -> attribute
                continue
            if pd.isnull(value) or value == '':        # skip empty fields for brevity
                continue
            if isinstance(value, float) and int(value) == value:
                value = int(value)    # there's no nan in int
            el = row_el.makeelement(NS + 'field', attrib=dict(name=label))
            el.text = str(value)
            row_el.append(el)
        root.append(row_el)
    return etree.ElementTree(root)


def main():
    pd.set_option('max_colwidth', 10000)
    if len(sys.argv) > 1:
        df = read_testimonies(sys.argv[1])
    else:
        df = read_testimonies(fetch_table())
    # write_html("src/main/web/archive_testimonies.php", html_table(df))
    sanitized = improve_testimony_table(df)
    xml = to_xml(sanitized, df.columns)
    xml.write('xslt/testimony-table.xml',
              encoding='utf-8',
              xml_declaration=True,
              pretty_print=True)

if __name__ == '__main__':
    main()
