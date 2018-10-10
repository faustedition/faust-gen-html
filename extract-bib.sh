#!/bin/bash

# Extracts additional citations from the given sets of files.
# Call with ./extract-bib ../faust-web/*.php > additional-citations.xml

echo '<citations xmlns="http://www.faustedition.net/ns">' 

egrep -ho '(bibliography#|faust://bibliography/)([a-zA-Z0-9/_.-]*[a-zA-Z0-9/_-]+)' -- "$@" |\
	sed -E -e 's,(bibliography#|faust://bibliography/)([a-zA-Z0-9/_.-]*[a-zA-Z0-9/_-]+), <citation>faust://bibliography/\2</citation>,' |\
	uniq

echo '</citations>'
