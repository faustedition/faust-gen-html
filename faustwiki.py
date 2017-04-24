#!/usr/bin/env python3

import requests
from getpass import getpass
import io
import codecs
import argparse
import shutil
import logging
logger = logging.getLogger(__name__)

import bibliography
import testimonies


class Wiki:

    def __init__(self, wiki="https://faustedition.uni-wuerzburg.de/wiki"):
        self.wiki = wiki
        self.api = wiki + "/api.php"
        self.index = wiki + "/index.php"
        self.session = requests.Session()
        self.session.verify = False
        self.token = None

    def login(self, user=None, passwd=None):
        if self.token is not None:
            return self.token

        if user is None:
            user = input("Wiki User: ")
        if passwd is None:
            passwd = getpass("Wiki password for {}: ".format(user))
        loginparams = dict(
            lgname=user,
            lgpassword=passwd,
            action='login',
            format='json')
        login1 = self.session.post(self.api, params=loginparams)
        logger.debug("First login step: %s", login1)
        token = login1.json()['login']['token']
        loginparams["lgtoken"] = token
        self.session.post(self.api, params=loginparams)
        self.token = token
        logger.info("Successfully authenticated with the wiki.")
        return token

    def get_binary(self, url):
        response = self.session.get(url, params=dict(token=self.login()))
        logger.info("Request for binary %s: %s", url, response)
        return io.BytesIO(response.content)

    def get_text(self, title, action="raw", split=True):
        response = self.session.get(self.index, params=dict(
            title=title,
            action=action,
            token=self.login()))
        text = codecs.decode(response.content, response.encoding)
        logger.info("Request for text '%s' action %s: %s",
                    title, action, response)
        if split:
            return text.split('\n')
        else:
            return text


FROM_WIKI="<Wiki>"

def parse_argv(argv=None):

    argparser = argparse.ArgumentParser(description="Fetches Faust data from the wiki and writes it to git managed XML files.",
                                        formatter_class=argparse.ArgumentDefaultsHelpFormatter,
                                        epilog="If neither -t or -b are given, fetch both.")


    bib_opts = argparser.add_argument_group("Bibliography")

    bib_opts.add_argument("-b", "--bibliography", nargs="?", const=FROM_WIKI,
                           help="Fetches the bibliography")
    bib_opts.add_argument("-B", "--bibliography-target", default=bibliography.TARGET,
                          type=argparse.FileType(mode="wt"),
                          help="Target file for the bibliography")


    test_opts = argparser.add_argument_group("Testimonies")

    test_opts.add_argument("-t", "--testimonies", nargs="?", const=FROM_WIKI,
                           help="Process the table of testimonies")
    test_opts.add_argument("-T", "--testimony-target", default=testimonies.TARGET,
                           help="Target file for the testimony URL")
    test_opts.add_argument("-x", "--testimony-source",
                           type=argparse.FileType(mode="wb"),
                           help="Save a copy of the testimony XLS file")
    test_opts.add_argument("--testimony-table",
                           metavar="XLS_OR_CSV",
                           help="Save a copy of the augmented testimony table")


    options = argparser.parse_args(argv)
    if not options.testimonies and not options.bibliography:
        options.testimonies = FROM_WIKI
        options.bibliography = FROM_WIKI
    return options



def main(argv=None):
    logging.basicConfig(level=logging.INFO)
    wiki = Wiki()
    options = parse_argv(argv)

    if options.bibliography:
        if options.bibliography == FROM_WIKI:
            bib_source = wiki.get_text(bibliography.BIBLIO_PAGE)
        else:
            with open(options.bibliography, "rt") as f:
                bib_source = f.read_lines()
        bibliography.wiki_to_xml(bib_source, outfile=options.bibliography_target)


    if options.testimonies:
        if options.testimonies == FROM_WIKI:
            testi_source = wiki.get_binary(testimonies.TABLE_URL)
        else:
            testi_source = open(options.testimonies, "rb")
        if options.testimony_source:
            shutil.copyfileobj(testi_source, options.testimony_source)
            options.testimony_source.close()
            logger.info("Saved copy of testimony table to %s", options.testimony_source.name)
            testi_source = open(options.testimony_source.name, "rb")

        orig_table = testimonies.read_testimonies(testi_source)
        table = testimonies.improve_testimony_table(orig_table)

        if options.testimony_table:
            if options.testimony_table.endswith("csv"):
                table.to_csv(options.testimony_table)
                logger.info("Saved adjusted testimony table to CSV file %s", options.testimony_table)
            else:
                table.to_excel(options.testimony_table)
                logger.info("Saved adjusted testimony table to Excel file %s", options.testimony_table)

        testimonies.to_xml(table, orig_table.columns, options.testimony_target)

if __name__ == '__main__':
    main()
