xquery version "3.1";

import module namespace utils = "http://www.faustedition.net/search/utils" at "utils.xqm"; 

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "text";
declare option output:media-type "text/plain";

let $query := request:get-parameter('q', ''),
    $shortcut := utils:shortcut($query)
return if ($shortcut) 
    then $shortcut 
    else (response:set-status-code(404), "Valid shortcuts include verse numbers (1-12111), unique Faustedition sigils (e.g., 2 H) and paralipomenon numbers like P123.")