xquery version "3.1";

declare default element namespace "http://www.w3.org/1999/xhtml";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace f   = "http://www.faustedition.net/ns";
declare variable $edition := '';

declare variable $xmlpath := request:get-attribute('xmlpath');
declare variable $data := collection((if ($xmlpath) then $xmlpath else '/db/apps/faust-dev/data') || '/textTranscript');
declare variable $sigil-labels := doc('xslt/sigil-labels.xml');
declare variable $lucene-options := <options>
                                        <default-operator>and</default-operator>
                                        <phrase-slop>1</phrase-slop>
                                        <leading-wildcard>no</leading-wildcard>
                                        <filter-rewrite>yes</filter-rewrite>
                                    </options>;

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

declare function local:query-or-cache($query as item()?, $highlight as xs:string?, $index as xs:string?, $sp as item()?, $order as xs:string?) as map() {
    
    let $key := ($query, $highlight, $index, $sp, $order),
        $cached := cache:get('faust', $key),
        $result := if (not(empty($cached))) then $cached else local:query-lucene($query, $highlight, $index, $sp, $order)
    return
        if (not(empty($cached)))
        then $result
        else (cache:put('faust', $key, $result), $result)
};


declare function local:query-lucene($query as item()?, $highlight as xs:string?, $index as xs:string?, $sp as item()?, $order as xs:string?) as map() {
  let $allhits := if ($sp = 'true') then $data//(tei:l|tei:p)[ft:query-field($index, $query)] 
          else $data//*[ft:query-field($index, $query)],
      $hitcount := count($allhits)
  return map { 'hits': $hitcount, 'results':
  for $line in $allhits
  let $sigil := root($line)//tei:idno[@type='faustedition']
  group by $sigil
  let $sigil_t := root($line[1])//tei:idno[@type='sigil_t'],
      $headnote := root($line[1])//tei:idno[@type='headNote'],
      (:$total-score := avg(for $l in $line return ft:score($l)),:)
      $sortcrit := switch ($order) 
                    case 'sigil' return number(root($sigil_t)/*/@f:number)
                    case 'genesis' return number(root($sigil_t)/*/@f:index)
                    default return -sum(for $l in $line return ft:score($l))
      order by $sortcrit
      return (:data-score="{$total-score}":)
        <section class="doc" data-subhits="{count($line)}"> 
          <h3><a href="{local:make-url($sigil_t)}">{data($sigil)}</a><span class="score"> {$sortcrit}</span></h3>
          {
            for $match in $line
            let 
              $score := ft:score($match),
              $n := data($match/@n),
              $page := ($match//tei:pb/@f:docTranscriptNo, $match/preceding::tei:pb[1]/@f:docTranscriptNo)[1],
              $section := $match/ancestor-or-self::*/@f:section[1],
              $breadcrumbs := for $bc in $match/ancestor-or-self::*[@f:label] return <f:breadcrumb>{$bc/@*}</f:breadcrumb>,
              $content := if ($highlight = 'true') then util:expand($match) else $match
            return 
            <div class="subhit" data-href="{local:make-url($sigil_t, $section, $page, $n)}">              
              <div class="subhit-content">
              {$content}              
              </div>
              <f:breadcrumbs>{$breadcrumbs}</f:breadcrumbs>
            </div>
          }        
        </section>
   }
};

declare function local:byverse($results as element()*) as element()* {
  for $subhit in $results//div[@class='subhit']
  let $schroer := number(($subhit//*/@f:schroer)[1])
  order by $schroer
  return <section class="subhit">
    <h3>{root($subhit)//h2/a} {$subhit//f:breadcrumbs}</h3>
    {$subhit/div/tei:*}
    </section>
};

let $query := request:get-parameter('q', 'pudel'),
    $highlight := request:get-parameter('highlight', 'true'),
    $index := request:get-parameter('index', 'text-de'),
    $sp := request:get-parameter('sp', ()),
    $order := request:get-parameter('order', ''), 
    $result := local:query-or-cache($query, $highlight, $index, $sp, $order),    
    $results := $result('results'),
    $docs := count($results),
    $hits := $result('hits'), (:sum($results/@data-subhits):)
    $raw := <article class="results" data-hits="{$hits}" data-docs="{$docs}">
          <h2>{$hits} Treffer in {$docs} Dokumenten{if ($sp = 'true') then <span class="extrainfo"> (nur Haupttext)</span> else ()}</h2>
          {if ($order = 'verse') then local:byverse($results) else $results}
          </article>
    return $raw