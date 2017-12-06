from lxml import etree

import regex as re
from lxml.builder import ElementMaker
from ruamel.yaml import YAML
from collections import defaultdict

APP = re.compile(
    r'''(?<n>\w+?)
        \[(?<replace>.*?)\]
        \{(?<insert>.*?)\}
        \s*<i>(?<reference>.*?)<\/i>
        \s*(?<lemma>.*?)\s*<i>(?<lwitness>.*?)<\/i>\]
        (?<readings>.*)''', flags=re.X)
READING = re.compile(r'\s*(?<text>.*?)\s*<i>(?<references>.*?)\s*(\[type=(?<type>\w+)\]\s*)?~?<\/i>')

def parse_app2norm(app_text='app2norm.txt'):
    with open(app_text, encoding='utf-8-sig') as app2norm:
        for line in app2norm:
            match = APP.match(line)
            if match:
                app = defaultdict(str, match.groupdict())
                app['readings'] = list(parse_readings(app['readings']))
                yield app
            else:
                print("ERROR: No match: ", line[:-1])

def parse_readings(reading_str):
    readings = []
    for match in READING.finditer(reading_str):
        reading = defaultdict(str, match.groupdict())
        if 'references' in reading:
            reading['references'] = reading['references'].split()
            # TODO sigil vs. hand vs. comment
        readings.append(reading)

    if not readings:
        print("ERROR: No reading found in:", reading_str)

    return readings

def app2yaml(app, filename):
    with open(filename, 'wt') as out:
        yaml = YAML()
        yaml.dump(app, out)

def app2xml(apps, filename):
    E = ElementMaker(namespace='http://www.faustedition.net/ns', nsmap={None: 'http://www.faustedition.net/ns'})
    xml = E.apparatus()
    for app in apps:
        xml.append(E.app(
            E.delete(app['replace']),
            E.insert(app['insert']),
            E.reference(app['reference']),
            E.lemma(app['lemma'], witness=app['lwitness']),
            E.readings(
                *[E.reading(r['text'],
                           *[E.ref(ref) for ref in r['references']])
                 for r in app['readings']]
            ),

            n=app['n']
        ))
    with open(filename, 'wb') as outfile:
        outfile.write(etree.tostring(xml, pretty_print=True, encoding='utf-8', xml_declaration=True))

if __name__ == '__main__':
    app = list(parse_app2norm('app2norm.txt'))
    app2xml(app, 'app2norm.xml')
