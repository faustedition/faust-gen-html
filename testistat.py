#!/usr/bin/env python3

from lxml import etree
from collections import Counter
import sys
import json
import re

ns=dict(f='http://www.faustedition.net/ns')
table = etree.parse('xslt/testimony-table.xml')
dates = table.xpath('//f:field[@name="datum-von"]/text()', namespaces=ns)
years = [int(re.search(r'\d{4}', date).group(0)) for date in dates if date]
stats = Counter(years)
maximum = max(stats.values())

data = dict(counts=stats, max=maximum)
json.dump(data, sys.stdout, sort_keys=True)
