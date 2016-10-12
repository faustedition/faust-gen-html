#!/usr/bin/env python3

with open("unified-speakers.txt") as speakerfile:
    with open("xslt/unified-speakers.xml", "w", encoding="UTF-8") as out:
        out.write('<?xml version="1.0" encoding="UTF-8"?>')
        out.write('<listPerson xmlns="http://www.faustedition.net/ns">\n')
        for line in speakerfile:
            alternatives = line.split()
            out.write('\t<person xml:id="{}">\n'.format(alternatives[0]))
            for alternative in alternatives:
                out.write('\t\t<alias>{}</alias>\n'.format(alternative))
            out.write('\t</person>\n')
        out.write('</listPerson>\n')
