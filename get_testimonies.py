#!/usr/bin/env python3
# coding: utf-8

"""
This script reads the table of testimonies from an excel file in the wiki
and writes it to a simple HTML table.


Attributes:

    selected_columns (list): Labels of the columns in the original table that should be selected.
    column_labels (list): New labels for the selected_columns

"""

selected_columns = ['Gräf-Nr.', 'Pniower-Nr.',  'QuZ', ' Biedermann-HerwigNr.',
                    'Datum.(von)', 'Dokumenttyp', 'Verfasser', 'Adressat', 'Druckort']
column_labels = ['Gräf', 'Pniower', 'QuZ', 'Bie3',
                 'Datum', 'Quellengattung', 'Verfasser', 'Adressat', 'Druckort']


import pandas as pd
from lxml import html, etree
import requests
from getpass import getpass
import io
import sys


def to_id(row):
    for column, prefix in [('Gräf', 'graef'), ('Pniower', 'pniower'),
                           ('QuZ', 'quz'), ('Bie3', 'bie3')]:
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
    Reads the table from the given object and filters the interesting columns.

    Args:
        buf: cf. :func:`pd.read_excel`
        kwargs: passed on to pandas

    Returns:
        pd.DataFrame
    """
    raw_testimonies = pd.read_excel(buf, **kwargs)
    testimonies = raw_testimonies[selected_columns]
    testimonies.columns = pd.Index(column_labels)
    testimonies.loc[:,'Datum'] = testimonies.loc[:,'Datum'].str.replace('00\.', '')
    testimonies.loc[:,'ID'] = testimonies.apply(to_id, axis=1)
    return testimonies

def to_xml(testimony_df):
    ns = "http://www.faustedition.net/ns"
    NS = "{"+ns+"}"
    nsmap = {None : ns}
    root = etree.Element(NS + "testimonies", nsmap=nsmap)
    root.addprevious(etree.Comment("This document is sporadically re-generated from an Excel sheet in the wiki. Please don't edit it directly"))
    for __, row in testimony_df.iterrows():
        row_el = root.makeelement(NS + "testimony")
        if not pd.isnull(row.ID):
            row_el.attrib['id'] = row.ID
        for label, value in row.iteritems():
            if label is 'ID':
                continue
            el = row_el.makeelement(NS + 'field', attrib=dict(label=label))
            if not pd.isnull(value):
                el.text = str(value)
            row_el.append(el)
        root.append(row_el)
    return etree.ElementTree(root)


def html_table(testimony_df):
    """
    Converts the dataframe to an HTML table, and adds appropriate attributes.
    """
    table = html.fromstring(testimony_df.to_html(na_rep='', index=False))

    table.attrib['data-sortable'] = 'true'
    table.attrib['class'] = 'pure-table'
    headerrow = table.find('thead').find('tr')
    del headerrow.attrib['style']
    ths = headerrow.findall('th')
    for th in ths:
        th.attrib['data-sorted'] = 'false'
        if th.text in ['Gräf', 'Pniower']:
            th.attrib['data-sortable-type'] = 'numericplus'
        elif th.text == 'Datum':
            th.attrib['data-sortable-type'] = 'date-de'
        elif th.text == 'Druckort':
            th.attrib['data-sortable-type'] = 'bibliography'
        else:
            th.attrib['data-sortable-type'] = 'alpha'
    return table

def test():
    table = html_table(read_testimonies('Dokumente_zur_Entstehungsgeschichte.xls'))
    print(html.tostring(table, encoding="unicode"))


def write_html(output, table):
    prefix = """
<?php $showFooter = false; ?>
<?php /* ATTENTION: This file is generated by get_testimonies.py. DO NOT EDIT HERE */ ?>
<?php include "includes/header.php"; ?>
<section>

  <article>
      <div id="testimony-table-container">
"""
    suffix = """
      </div>
  </article>

</section>
<script type="text/javascript">
  // set breadcrumbs
  document.getElementById("breadcrumbs").appendChild(Faust.createBreadcrumbs([{caption: "Archiv", link: "archive"}, {caption: "Dokumente zur Entstehungsgeschichte"}]));
</script>

<?php include "includes/footer.php"; ?>
"""
    with open(output, mode="wt", encoding="utf-8") as out:
        out.write(prefix)
        out.write(html.tostring(table, encoding="unicode"))
        out.write(suffix)

def main():
    pd.set_option('max_colwidth', 10000)
    if len(sys.argv) > 1:
        df = read_testimonies(sys.argv[1])
    else:
        df = read_testimonies(fetch_table())
    # write_html("src/main/web/archive_testimonies.php", html_table(df))
    xml = to_xml(df)
    xml.write('src/main/xproc/xslt/testimony-table.xml',
              encoding='utf-8',
              xml_declaration=True,
              pretty_print=True)

if __name__ == '__main__':
    main()