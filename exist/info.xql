xquery version "3.1";

declare default element namespace "http://www.w3.org/1999/xhtml";

declare option exist:serialize "method=xhtml5 enforce-xhtml=yes";

import module namespace kwic="http://exist-db.org/xquery/kwic";

declare variable $xmlpath := request:get-attribute('xmlpath');
declare variable $data := collection((if ($xmlpath) then $xmlpath else '/db/apps/faust-dev/data') || '/info');
declare variable $lucene-options := <options>
                                        <default-operator>and</default-operator>
                                        <phrase-slop>1</phrase-slop>
                                        <leading-wildcard>no</leading-wildcard>
                                        <filter-rewrite>yes</filter-rewrite>
                                    </options>;


let $query := request:get-parameter('q', 'Hybridausgabe'),
    $all := $data//(p|ul|ol|dt|dd|h1|h2|h3|h4|h5|h6)[ft:query(., $query, $lucene-options)],
    $hitcount := count($all),
    $results := for $hit in $all
                let $docid := util:document-id($hit)
                group by $docid
                let $doc := root($hit[1]),
                    $name := replace(document-uri($doc), '^.*/data/info/(.*)\.html$', '$1'),
                    $title := data($doc//*/@data-title[1]),
                    $score := sum(for $match in $hit return ft:score($match))
                order by $score descending
                return  <section class="doc" data-hits="{count($hit)}" data-score="{$score}">
                            <h3><a href="/{$name}">{$title}</a></h3>
                            {
                                for $match in $hit
                                let $subhead := ($match/ancestor-or-self::* | $match/preceding::*)[@xml:id | @id][position()=last()],
                                    $sublink := if ($subhead) then '#' || $subhead/(@xml:id, @id)[1] else '',
                                    $subtitle := if ($subhead[self::dt | self::h1 | self::h2 | self::h3 | self::h4 | self::h5 | self::h6])
                                                 then data($subhead)
                                                 else data($subhead/(h1|h2|h3|h4|h5|h6)[1])
                                return 
                                    (if ($subtitle) then <h4><a href="/{$name}{$sublink}">{$subtitle}</a></h4> else (),
                                    kwic:summarize($match, <config xmlns="" link="/{$name}{$sublink}"/>)) 
                            }
                        </section>
return  <article class="results" data-hits="{$hitcount}">
          <h2>{$hitcount} Treffer auf {count($results)} Seiten</h2>
          {$results}
        </article>
    