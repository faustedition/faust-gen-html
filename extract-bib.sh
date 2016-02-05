#!/bin/bash

# Extracts additional citations from the given sets of files.
# Call with ./extract-bib ../faust-web/*.php > additional-citations.xml

echo '<citations xmlns="http://www.faustedition.net/ns">' 
egrep -ho 'faust://bibliography/[a-zA-Z0-9/_.-]*[a-zA-Z0-9/_-]+' -- "$@" |\
	sed -e 's,.*, <citation>\0</citation>,' 

echo '</citations>'
