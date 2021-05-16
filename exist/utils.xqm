xquery version "3.1";
module namespace utils = "http://www.faustedition.net/search/utils";

import module namespace config = "http://www.faustedition.net/search/config" at "config.xqm"; 

declare default element namespace "http://www.w3.org/1999/xhtml";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace f = "http://www.faustedition.net/ns";


declare function utils:unique-sigil($query as xs:string) as xs:string? {
    let $idno := $config:transcripts//tei:idno[@type = 'sigil_n'][. = lower-case(replace($query, '[ .*]', ''))]
    return if (count($idno) = 1) 
    then 
        let $sigil_t := data(id('sigil_t', $idno))
        return '/document?sigil=' || $sigil_t
    else ()
};

declare function utils:text-verse($query as xs:string) as xs:string? {
    if (matches($query, '\d+') and number($query) <= 12111)
    then 
        let $file := $config:xmlpath || '/textTranscript/faust.xml',
            $line := doc($file)//tei:l[@n=$query],
            $section := $line[1]/ancestor::*[@f:section][1]/@f:section
        return
            '/print/faust.' || $section || '#l' || $query
    else ()
};

declare function utils:paralipomenon($query as xs:string) as xs:string? {
    if (matches($query, '^[pP]\s*\d+$'))
    then
        let $pnr := replace($query, '[pP]\s*(\d+)', '$1'),
            $pid := 'p' || $pnr,
            $milestones := $config:transcripts//tei:milestone[@unit='paralipomenon'][@n=$pid]
        return
            if ($milestones)
            then 
                let $first := $milestones[1],
                $sigil_t := data(id('sigil_t', $first)),
                $sigil_n := data(id('sigil_n', $first)),
                $section := $first/ancestor::*[@f:section][1]/@f:section,
                $anchor := 'para_' || $pnr || '_' || $sigil_n
            return 
                if (count($milestones) = 1)
                then
                    '/document?sigil=' || $sigil_t || '&amp;view=text&amp;section=' || $section || '#' || $anchor
                else if (count($milestones) > 1)
                then
                    '/paralipomena#' || $anchor
                else ()
            else ()
    else ()
};

declare function utils:shortcut($query as xs:string) as xs:string? {
    (utils:text-verse($query), utils:unique-sigil($query), utils:paralipomenon($query))[1]
};