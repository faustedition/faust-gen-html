xquery version "3.1";


declare default element namespace "http://www.w3.org/1999/xhtml";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace t   = "http://www.faustedition.net/ns/testimony";

declare option exist:serialize "method=xhtml enforce-xhtml=yes";

import module namespace kwic="http://exist-db.org/xquery/kwic";

declare variable $edition := '';

declare variable $xmlpath := request:get-attribute('xmlpath');
declare variable $data := collection((if ($xmlpath) then $xmlpath else '/db/apps/faust-dev/data') || '/testimony');


let $query := request:get-parameter('q', 'hauptgeschäft'),
    $matches := $data//(tei:text|t:field)[ft:query(., $query)],
    $hitcount := count($matches)
return <article class="results" data-hits="{$hitcount}">
          <h2>{$hitcount} Treffer</h2>{
for $match in $matches
let $root := root($match),
    $id := $root//t:testimony/@id,
    $title := $root//tei:title,
    $nr := number($root//t:field[@name='lfd-nr-neu-2']),
    $hit := if ($match[self::t:field]) 
                then <dl><dt>{data($match/@label)}</dt><dd>{data($match)}</dd></dl>
                else kwic:summarize($match, <config xmlns="" width="75" link="/testimony/{$id}#{$id}"/>)
order by $nr
group by $id
return <section class="hit metadata-container">
            <h3><a href="/testimony/{$id[1]}">{data($title[1])}</a></h3>
            {$hit}
        </section>
}</article>
