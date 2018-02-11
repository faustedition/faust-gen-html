#!/usr/bin/env python3

import logging
from itertools import chain

import sys
from lxml import etree
import json

import regex as re
from lxml.builder import ElementMaker
from collections import defaultdict

from lxml.etree import ParseError
import os

log = logging.getLogger(__name__)

FAUST_NS = 'http://www.faustedition.net/ns'
TEI_NS = 'http://www.tei-c.org/ns/1.0'
NSMAP_ = { 'tei': TEI_NS, 'f': FAUST_NS }
NSMAP = { None: TEI_NS, 'f': FAUST_NS }

F = ElementMaker(namespace=FAUST_NS, nsmap=NSMAP)
T = ElementMaker(namespace=TEI_NS, nsmap=NSMAP)


for prefix, uri in NSMAP_.items():
    etree.register_namespace(prefix, uri)

def namespaceify(tree: etree._Element, namespace=TEI_NS):
    """Moves every element in the subtree that does _not_ have a namespace into the given namespace"""
    prefix = '{' + namespace + '}'
    for el in chain([tree], tree.iterdescendants()):
        if '{' not in el.tag:
            el.tag = prefix + el.tag


def parse_xml(text, container=None, namespace=TEI_NS) -> etree._Element:
    """parses a fragment that may contain xml elements to a tree.

    Args:
        container (str or etree._Element): container element around everything, by default 'root'
        namespace (str): Namespace URI for the parsed elements.
    """
    root_tag = container if isinstance(container, str) else 'root'
    pseudo_xml = "<{tag}>{text}</{tag}>".format_map(dict(tag=root_tag, text=text))
    try:
        xml = etree.fromstring(pseudo_xml)
    except ParseError as e:
        log.warning('Failed to parse %s as xml, using unparsed version instead', text, exc_info=True)
        xml = etree.Element('root')
        xml.text = text
    if namespace is not None:
        namespaceify(xml, namespace)
    if isinstance(container, etree._Element):
        container.text = xml.text
        container.extend(xml)
        xml = container
    return xml

def read_sigils(filename='../../../../target/faust-transcripts.xml', secondary_filename='sigils.json'):
    """parses faust-transcripts.xml and returns a mapping machine-readable sigil : human-readable sigil"""
    try:
        xml = etree.parse(filename)
        idnos = xml.xpath('//f:idno[@type="faustedition" and @uri]', namespaces={'f': FAUST_NS})
        short_sigil = re.compile('faust://document/faustedition/(\S+)') # re.Regex
        sigils = { short_sigil.match(idno.get('uri')).group(1) : idno.text  for idno in idnos }
        try:
            with open(secondary_filename, 'wt', encoding='utf-8') as out:
                json.dump(sigils, out, ensure_ascii=False, indent=True, sort_keys=True)
        except IOError:
            log.error('Failed saving secondary sigils file %s', secondary_filename, exc_info=True)
    except:
        log.warning('Failed loading generated sigils file %s, trying fallback %s', filename, secondary_filename, exc_info=True)
        with open(secondary_filename, 'rt', encoding='utf-8') as f:
            sigils = json.load(f)
    return sigils



sigils = read_sigils()

# one app line
APP = re.compile(
    r'''(?<n>(\w|\|)+?)
        \[(?<replace>.*?)\]
        \{(?<insert>.*?)\}
        \s*<i>(?<reference>.*?)<\/i>
        \s*(?<lemmapart>.*?)\]
        (?<readings>.*)''', flags=re.X)

def parse_app2norm(app_text='app2norm.txt'):
    SPECIAL_REPLACEMENTS = {
        '^': dict(place='before'),
        '$': dict(place='after'),
        '@lg': dict(place='enclosing-lg')
    }
    with open(app_text, encoding='utf-8-sig') as app2norm:
        for raw_line in app2norm:
            line = raw_line[:-1]
            yield etree.Comment('       ' + line)
            # fix some easily replacable issues from previous processing steps
            line = re.sub('</?(font|color).*?>', '', line)
            line = re.sub(r'\^?&gt;', '>', line)
            line = re.sub(r'\^?&lt;', '<', line)
            if line != raw_line[:-1]:
                yield etree.Comment('FIXED: ' + line)
            match = APP.match(line)
            if match:
                log.info('Parsed: %s', line)
                parsed = match.groupdict()
                if parsed['insert'] == '=':
                    parsed['insert'] = parsed['replace']
                ns = parsed['n'].split('|')
                app = T.app(n=' '.join(ns))
                for n, replace, insert in zip(ns, parsed['replace'].split('|'), parsed['insert'].split('|')):
                    if replace == '@lg':
                        attrs = parse_attrs(insert)
                        ins_element = F.ins(T.lg(**attrs), n=n)
                    else:
                        ins_element = parse_xml(insert, F.ins(n=n), TEI_NS)
                    if replace in SPECIAL_REPLACEMENTS:
                        ins_element.attrib.update(SPECIAL_REPLACEMENTS[replace])
                    else:
                        app.append(F.replace(replace, n=n))
                    app.append(ins_element)
                app.append(T.ref(parsed['reference']))
                # app.append(parse_xml(parsed['lemma'], T.lem(wit=parsed['lwitness']), TEI_NS))
                lemmas = parse_readings(parsed['lemmapart'], tag='lem')
                if lemmas:
                    if len(lemmas) != 2:
                        log.error('Lemma section »%s« parses to %d lemmas instead of one', parsed['lemmapart'], len(lemmas)/2)
                    app.extend(lemmas)
                else:
                    app.append(parse_xml(parsed['lemmapart'], T.lem())) # error msg from parse_readings already there

                readings = parse_readings(parsed['readings'])
                app.extend(readings)
                log.debug('-> %s', etree.tostring(app, encoding='unicode', pretty_print=False))
                yield app
            else:
                log.error("No match: %s", line)


def parse_attrs(attr_spec: str) -> dict:
    """
    Parses a pseudo-attribute string to a dictionary.

    Argument is a whitespace-separated string with items of the form
    key=value or key="value with spaces" or key='value ' or key=
    """
    ATTR = re.compile(r'''(?<name>\w+)=(["']?)(?<value>[^"']*)\2(\s+?|$)''')
    matches = ATTR.finditer(attr_spec)
    attrs = {gd['name']: gd['value']
             for gd in [match.groupdict()
                        for match in matches]}
    return attrs


# a reading, i.e. last part of app line
READING = re.compile(r'\s*(?<text>.*?)\s*<i>(?<references>.*?)\s*(\[(type=|Typ\s+)(?<type>\w+\*?)\]\s*)?~?<\/i>')
HANDS = {'G', 'Gö', 'Ri', 'Re'}

def append_text(element: etree.ElementBase, text: str):
    try:
        if element[-1].tail:
            element[-1].tail += text
        else:
            element[-1].tail = text
    except IndexError:
        if element.text:
            element.text += text
        else:
            element.text = text



def parse_readings(reading_str, tag='rdg'):
    readings = []
    carry = None
    reading_str = reading_str.replace('^', '<pc>‸</pc>')
    for match in READING.finditer(reading_str):
        reading = match.groupdict()
        if 'references' in reading:
            if carry:
                wits = carry
                carry = []
            else:
                wits = []
            hands = []
            notes = []
            for ref in reading['references'].split():
                if ref in sigils:
                    wits.append(ref)
                elif ref == 'none':
                    carry = wits  # otherwise drop, cf. #225
                elif ref in HANDS:
                    hands.append(ref)
                    notes.append('<seg type="hand">{}</seg>'.format(ref))
                elif ref == ":":
                    carry = wits
                else:
                    notes.append(ref)

            rdg = parse_xml(reading['text'], T(tag), TEI_NS)
            if wits:
                rdg.set('wit', ' '.join(wits))
            if hands:
                rdg.set('hand', ' '.join(hands))
            if notes:
                append_text(rdg, ' ')
                rdg.append(parse_xml(' '.join(notes), T.note()))
        if 'type' in reading and reading['type']:
            rdg.set('type', reading['type'])
        readings.append(etree.Comment(match.group(0)))
        readings.append(rdg)
        log.debug(' - Reading »%s« -> %s', reading_str, etree.tostring(rdg, encoding='unicode', pretty_print=False))

    if not readings:
        log.warning("Failed to parse »%s« as %s", reading_str, tag)

    return readings

def app2xml(apps, filename):
    xml = F.apparatus()
    xml.extend(apps)
    with open(filename, 'wb') as outfile:
        outfile.write(etree.tostring(xml, pretty_print=True, encoding='utf-8', xml_declaration=True))

def setup_logging():
    # logging.basicConfig(level=logging.WARNING, format='%(levelname)s: %(message)s')
    logger = logging.getLogger()
    logger.setLevel(logging.INFO)
    consoleHandler = logging.StreamHandler()
    consoleHandler.setLevel(logging.WARNING)
    consoleHandler.setFormatter(logging.Formatter('%(levelname)s: %(message)s'))
    logger.addHandler(consoleHandler)
    logfile = logging.FileHandler('app2xml.log', mode='wt')
    logfile.setFormatter(logging.Formatter('%(levelname)s:%(funcName)s: %(message)s'))
    logger.addHandler(logfile)

if __name__ == '__main__':
    setup_logging()
    for file in 'app1norm.txt', 'app2norm.txt', 'app2norm_test-cases.txt':
        app2xml(list(parse_app2norm(file)), os.path.splitext(file)[0] + '.xml')
