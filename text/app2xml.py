#!/usr/bin/env python3

import logging
from itertools import chain

from lxml import etree
import json

import regex as re
from lxml.builder import ElementMaker
from collections import defaultdict

from lxml.etree import ParseError

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


def parse_xml(text, container=None, namespace=TEI_NS):
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
        log.error('Failed to parse %s as xml, using unparsed version instead', text, exc_info=True)
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
        except:
            log.error('Failed saving secondary sigils file %s', secondary_filename, exc_info=True)
    except IOError:
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
        \s*(?<lemma>.*?)\s*<i>(?<lwitness>.*?)<\/i>\]
        (?<readings>.*)''', flags=re.X)

def parse_app2norm(app_text='app2norm.txt'):
    with open(app_text, encoding='utf-8-sig') as app2norm:
        for line in app2norm:
            yield etree.Comment(line[:-1])
            match = APP.match(line)
            if match:
                log.info('Parsed: %s', line[:-1])
                parsed = match.groupdict()
                if parsed['insert'] == '=':
                    parsed['insert'] = parsed['replace']
                ns = parsed['n'].split('|')
                app = T.app(n=' '.join(ns))
                for n, replace, insert in zip(ns, parsed['replace'].split('|'), parsed['insert'].split('|')):
                    app.append(F.replace(replace, n=n))
                    app.append(parse_xml(insert, F.ins(n=n), TEI_NS))
                app.append(T.ref(parsed['reference']))
                app.append(parse_xml(parsed['lemma'], T.lem(wit=parsed['lwitness']), TEI_NS))

                readings = parse_readings(parsed['readings'])
                app.extend(readings)
                log.debug('-> %s', etree.tostring(app, encoding='unicode', pretty_print=False))
                yield app
            else:
                log.error("No match: %s", line[:-1])

# a reading, i.e. last part of app line
READING = re.compile(r'\s*(?<text>.*?)\s*<i>(?<references>.*?)\s*(\[(type=|Typ\s+)(?<type>\w+)\]\s*)?~?<\/i>')
HANDS = {'G', 'Gö', 'Ri', 'Re'}

def parse_readings(reading_str):
    readings = []
    carry = None
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
                elif ref in HANDS:
                    hands.append(ref)
                elif ref == ":":
                    carry = wits
                else:
                    notes.append(ref)

            rdg = parse_xml(reading['text'], T.rdg(), TEI_NS)
            if wits:
                rdg.set('wit', ' '.join(wits))
            if hands:
                rdg.set('hand', ' '.join(hands))
            if notes:
                rdg.append(T.note(' '.join(notes)))
        if 'type' in reading and reading['type']:
            rdg.set('type', reading['type'])
        readings.append(etree.Comment(match.group(0)))
        readings.append(rdg)
        log.debug(' - Reading "%s" -> %s', reading_str, etree.tostring(rdg, encoding='unicode', pretty_print=False))

    if not readings:
        log.error("No reading found in %s", reading_str)

    return readings

def app2xml(apps, filename):
    xml = F.apparatus()
    xml.extend(apps)
    with open(filename, 'wb') as outfile:
        outfile.write(etree.tostring(xml, pretty_print=True, encoding='utf-8', xml_declaration=True))

if __name__ == '__main__':
    logging.basicConfig(level=logging.WARNING, format='%(levelname)s: %(message)s')
    app2xml(list(parse_app2norm('app1norm.txt')), 'app1norm.xml')
    app2xml(list(parse_app2norm('app2norm.txt')), 'app2norm.xml')
