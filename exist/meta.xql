xquery version "3.0";
declare default element namespace "http://www.w3.org/1999/xhtml";

declare function local:query-metadata($query as xs:string) as element()* {
  let $anc := collection('/db/apps/faust-dev/data/meta')//*[contains(., $query)],
      $closest := $anc except $anc/ancestor::*    
  for $match in $closest
  let $doc := root($match),
      $sigil_t := replace(document-uri($doc), '.*/(.*)\.html', '$1'),
      $sigil := $doc//h2/text()
  group by $sigil_t
  return <section class="doc" data-subhits="{count($match)}">    
              <h3><a href="/document?sigil={$sigil_t}&amp;view=structure">{$sigil[1]}</a></h3>
              {
                  for $m in $match
                  return 
                  <div class="subhit metadata-container">{
                    if ($m[self::dd]) then <dl>{$m/preceding-sibling::dt[1], $m}</dl> else $m
                  }</div>
              }
          </section>
};

let $query := request:get-parameter('q', ()), 
    $results := local:query-metadata($query),
    $docs := count($results),
    $hits := sum($results/@data-subhits)
return <article class="results" data-hits="{$hits}" data-docs="{$docs}">
          <h2>{$hits} Metadaten-Treffer in {$docs} Dokumenten</h2>
          {$results}
       </article>