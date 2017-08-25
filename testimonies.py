#!/usr/bin/env python3
# coding: utf-8

"""
This script reads the table of testimonies from an excel file in the wiki
and writes it to a simple HTML table.
"""

import pandas as pd
from lxml import etree
import sys
import unicodedata
import re
import logging
logger = logging.getLogger(__name__)

TABLE_URL = "https://faustedition.uni-wuerzburg.de/wiki/images/b/b5/Dokumente_zur_Entstehungsgeschichte.xls"
TARGET = "xslt/testimony-table.xml"

def sanitize_colname(orig_colname):
    colname = unicodedata.normalize('NFKC', orig_colname).lower()
    colname = colname.translate({ ord('ä'): 'ae', ord('ü'): 'ue', ord('ö'):
                                 'oe', ord('ß'): 'ss'})
    colname = re.sub(r'[\W_-]+', '-', colname).strip('-')
    logger.debug('Sanitized column name "%s" to "%s"', orig_colname, colname)
    return colname


def unfloat(number):
    """
    Iff number is a float that is (almost) equal to the corresponding int,
    return number cast to int. Otherwise, return number as is, so it is safe to
    paste something that isn't numeric.
    """
    if isinstance(number, float):
        if abs(number - int(number) < 1e-6):
            return int(number)
    return number

def to_id(row):
    for column, prefix in [('graef-nr', 'graef'), ('pniower-nr', 'pniower'),
                           ('quz', 'quz'), ('biedermann-herwignr', 'bie3'),
                           ('tille-nr', 'tille')]:
        if not pd.isnull(row[column]):
            ids = re.split(r'[,;]\s*', str(unfloat(row[column])))
            return prefix + '_' + ids[0]

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

def to_xml(testimony_df, orignames, output_file=None):
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
    xml = etree.ElementTree(root)
    if output_file is not None:
        xml.write(output_file, encoding='utf-8', xml_declaration=True,
                  pretty_print=True)
        logger.info("Wrote testimony XML to %s", output_file)


__all__ = [TABLE_URL, TARGET, read_testimonies, improve_testimony_table, to_xml]
