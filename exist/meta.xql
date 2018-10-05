xquery version "3.1";

import module namespace config = "http://www.faustedition.net/search/config" at "config.xqm"; 

declare default element namespace "http://www.w3.org/1999/xhtml";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace f = "http://www.faustedition.net/ns";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "xhtml";
declare option output:media-type "application/xhtml+xml";

declare variable $sigil-labels := doc('xslt/sigil-labels.xml');



declare function local:sigil($query as xs:string) as element()* {
    for $idno in $config:transcripts//tei:idno[ngram:contains(., $query)][@type = $sigil-labels//f:label/@type]
    let $sigil_t := id('sigil_t', $idno)   
    group by $sigil_t    
    return 
        let $idno := $idno[1],
        $sigil_t := id('sigil_t', $idno),
        $sigil := data(id('sigil', $idno)),
      	$headnote := data(id('headNote', $idno)),
      	$type := data($idno/ancestor-or-self::tei:TEI/@type),
      	$number := data($idno[1]/ancestor-or-self::tei:TEI/@f:number),    	
      	$idno_label := data($sigil-labels//f:label[@type = $idno/@type])
        return
          <tr>
            <td href="/document?sigil={$sigil_t}&amp;view=structure">{util:expand($idno)}</td>
            <td>{$idno_label}</td>
            <td><a href="/document?sigil={$sigil_t}&amp;view=structure">{$sigil}</a></td>
            <td>{$headnote}</td>
          </tr>
};


declare function local:query-metadata($query as xs:string) as element()* {
  let $anc := $config:metadata//*[ngram:contains(., $query)],
      $closest := $anc except $anc/ancestor::*    
  for $match in $closest[not(@class='md-idno' or self::h2)]
  let $doc := root($match),
      $sigil_t := replace(document-uri($doc), '.*/(.*)\.html', '$1'),
      $sigil := $doc//h2/text()
  group by $sigil_t
  return <section class="doc" data-subhits="{count($match)}">
              <h3><a href="/document?sigil={$sigil_t}&amp;view=structure">{$sigil[1]}</a></h3>
              {
                  for $m in $match
                  return 
                  <div class="subhit metadata-container"><!-- {$m} -->{
                    if ($m[self::dd]) then <dl>{$m/preceding-sibling::dt[1], util:expand($m)}</dl> else util:expand($m)
                  }</div>
              }
          </section>
};

let $query := request:get-parameter('q', ()), 
    $results := local:query-metadata($query),
    $sigil-results := local:sigil($query),   
    $docs := count($results),
    $hits := sum($results/@data-subhits)
return <article class="results" data-hits="{$hits + count($sigil-results)}" data-docs="{$docs}" data-query="{$query}">
          {if ($sigil-results) then
          (<h2>{count($sigil-results)} Treffer in Siglen und Signaturen</h2>,
           <table class="pure-table">
            <thead>
              <tr>
                <th>Sigle / Signatur</th>
                <th>Siglen- / Signaturtyp</th>
                <th>Dokument</th>
                <th>Kurzbeschreibung</th></tr>              
            </thead>
            <tbody>{$sigil-results}</tbody>
           </table>) else ()}
          <h2>{$hits} Metadaten-Treffer in {$docs} Dokumenten</h2>
          {$results}
       </article>