xquery version "3.1";

declare default element namespace "http://www.w3.org/1999/xhtml";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace f   = "http://www.faustedition.net/ns";
declare variable $edition := '';

declare variable $data := collection('/db/apps/faust-dev/data/textTranscript'); (: collection(request:get-attribute('xmlpath')); :)
declare variable $sigil-labels := doc('xslt/sigil-labels.xml');

declare function local:make-url($sigil_t as item()?) as xs:string {
  if ($sigil_t = 'faust') then '/print/faust' else '/document?sigil=' || data($sigil_t)
};
declare function local:make-url($sigil_t as xs:string?, $section as xs:string?, $page as xs:string?, $n as xs:string?) as xs:string {
   (if ($sigil_t = 'faust') 
      then '/print/faust' || (if ($section) then '.' || $section else '')
      else '/document?sigil=' 
        || $sigil_t 
        || (if ($section) then ('&amp;section=' || $section) else '')
        || (if ($page) then ('&amp;page=' || $page) else ''))
    || (if ($n) then ('#l' || $n) else '')
};


declare function local:query-lucene($query as item()?, $highlight as xs:string?) as element()* {
  for $line in ft:query-field('text', $query)
  let $sigil := id('sigil', $line)
  group by $sigil
  let $sigil_t := id('sigil_t', $line[1]),
      $headnote := id('headNote', $line[1]),
      $total-score := avg(for $l in $line return ft:score($l))
      return 
        <section class="doc" data-subhits="{count($line)}" data-score="{$total-score}">
          <h2><a href="{local:make-url($sigil_t)}">{data($sigil)}</a></h2>
          {
            for $match in $line
            let 
              $score := ft:score($match),
              $n := data($match/@n),
              $page := ($match//tei:pb/@f:docTranscriptNo, $match/preceding::tei:pb[1]/@f:docTranscriptNo)[1],
              $section := $match/ancestor-or-self::*/@f:section[1],
              $breadcrumbs := for $bc in $match/ancestor-or-self::*[@f:label] return element {node-name($bc)} {$bc/@*},
              $content := if ($highlight = 'true') then util:expand($match) else $match
            return 
            <div class="subhit">
              <a href="{local:make-url($sigil_t, $section, $page, $n)}">
                {$content}
              </a>
              <f:breadcrumbs>{$breadcrumbs}</f:breadcrumbs>
            </div>
          }        
        </section>
};

let $query := request:get-parameter('q', ()),
    $highlight := request:get-parameter('highlight', 'true'),
    $results := local:query-lucene($query, $highlight),
    $docs := count($results),
    $hits := sum($results/@data-subhits),
    $raw := <article class="results" data-hits="{$hits}" data-docs="{$docs}">
          <h2>{$hits} Treffer in {$docs} Dokumenten</h2>
          {$results}
          </article>
    return $raw