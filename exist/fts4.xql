xquery version "3.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace f   = "http://www.faustedition.net/ns";
declare namespace fa   = "http://www.faustedition.net/ns"; (: OXYGEN DRIVES ME MAD!!!!!  :)
declare variable $edition := '';
(:  declare variable $exist:controller external; :)
declare variable $data := collection(request:get-attribute('xmlpath'));
declare variable $sigil-labels := doc('xslt/sigil-labels.xml');

declare function local:makeURL(
	$type as xs:string,
	$sigil_t as xs:string,
	$sec as xs:string?,
	$page as xs:string?) as xs:string
	{
		let $html := $sigil_t || (if ($sec) then '.'|| $sec else ()) 
		let $path := switch ($type)
			case 'archivalDocument' return concat('/document?sigil=', $sigil_t, "&amp;view=text&amp;page=", $page, "&amp;sec=", $html)
			default return '/print/' || $html
		return $edition || $path		
	};

declare function local:sigil($query as xs:string) as element()* {
    for $idno in $data//tei:idno[ngram:contains(., $query)][@type = $sigil-labels//f:label/@type]
    let $sigil_t := id('sigil_t', $idno)   
    group by $sigil_t    
    return 
        let $idno := $idno[1],
        $sigil_t := id('sigil_t', $idno),
        $sigil := data(id('sigil', $idno)),
    	$headnote := data(id('headNote', $idno)),
    	$type := data($idno/ancestor-or-self::tei:TEI/@type),
    	$number := data($idno[1]/ancestor-or-self::tei:TEI/@f:number),
    	$href := $edition || (if ($type = 'archivalDocument') then '/document?sigil=' || $sigil_t else '/print/' || $sigil_t),
    	$idno_label := data($sigil-labels//f:label[@type = $idno/@type])
        return <f:idno-match
                    sigil="{$sigil}"
                    number="{$number}"
                    headnote="{$headnote}"
                    idno="{$idno}"
                    idno-label="{$idno_label}"
                    href="{$href}"
                    sigil_t="{$sigil_t}">{
                        util:expand($idno)
                }</f:idno-match>
};

declare function local:query($query as item(), $order as xs:string) as element(f:doc)* {
for $text in $data//tei:TEI[ft:query(., $query)]
let $sigil := data(id('sigil', $text)),
    $sigil_t := data(id('sigil_t', $text)),
	$headnote := data(id('headNote', $text)),
	$type := data($text/ancestor-or-self::tei:TEI/@type),
	$ann := util:expand($text),
	$score := ft:score($text),
	$number := $text/@f:number,
	$sortcrit := if ($order = 'sigil')
	             then $number
	             else -$score
order by $sortcrit
return
    <f:doc
        sigil_t="{$sigil_t}"
        sigil="{$sigil}"
        headnote="{$headnote}"
        type="{$type}"
        number="{$number}"
        href="{local:makeURL($type, $sigil_t, (), ())}"
        score="{$score}">{
        
        for $line in $ann//exist:match/(
        	  ancestor::tei:l
        	| ancestor::tei:p
        	| ancestor::tei:head
        	| ancestor::tei:stage
        	| ancestor::tei:speaker
        	| ancestor::tei:note
        	| ancestor::tei:trailer
        	| ancestor::tei:label
        	| ancestor::tei:item
        	)
        let
            $n := data($line/@n),
        	$page := ($line//tei:pb/@f:docTranscriptNo, $line/preceding::tei:pb[1]/@f:docTranscriptNo)[1],
        	$breadcrumbs := $line/ancestor-or-self::*[@f:label]
        return
        	<f:subhit
        	    page="{$page}"
        		n="{$n}"
        		href="{local:makeURL($type, $sigil_t, $line/ancestor-or-self::*/@f:section, $page)}"
        		>
        		{if ($breadcrumbs)
        		then
	        		<f:breadcrumbs>
	        		{for $div in $breadcrumbs return <f:breadcrumb>{$div/@* except $div/@xml:id}</f:breadcrumb>}
	        		</f:breadcrumbs>
	        	else (),
        		$line}
        	</f:subhit>
        }</f:doc>
};

declare function local:wrapped-sigil($query as xs:string) as element()* {
  try {
  	let $result := local:sigil($query)
  	return if ($result) then <f:sigils hits="{count($result)}">{$result}</f:sigils> else ()
  } catch * {
  	<exist:exception where="sigil" code="{$err:code}" location="{string-join(($err:module, $err:line-number, $err:column-number), ':')}">{$err:description}</exist:exception> 
  }
};

declare function local:format-results($results as item()*, $order as xs:string) as element()* {
    if ($results) then 
  		<f:fulltext-results
            docs="{count($results)}" 
            hits="{count($results//exist:match)}">{
	        if ($order = 'verse')
	        then
	        	for $subhit in $results//f:subhit
	        	order by number(replace($subhit/@n, '\D*(\d+)\D*', '$1'))
	        	return element f:hit {
	        		$subhit/@*,
	        		$subhit/../@* except $subhit/../@href,
	        		$subhit/node()
	        	}
	        else
	        	$results	     
  	}</f:fulltext-results>
  	else ()
};

declare function local:wrapped-query($query as xs:string, $order as xs:string) as element()* {
  try {
  	let $results := local:query($query, $order)
  	return local:format-results($results, $order)
  } catch * {
    try {
        let $results := local:query(<query>{$query}</query>, $order)
        return local:format-results($results, $order)
    } catch * {
  	    <exist:exception where="fulltext" code="{$err:code}" location="{string-join(($err:module, $err:line-number, $err:column-number), ':')}">{$err:description}</exist:exception> 
    }
  }
};

let $query := request:get-parameter('q', 'pudel'),
    $order  := request:get-parameter('order', 'score')
return <f:results 
            query="{$query}"
            order="{$order}"
            xmlns:exist="http://exist.sourceforge.net/NS/exist" 
            xmlns="http://www.tei-c.org/ns/1.0">
	        {
	       	local:wrapped-sigil($query),
	       	local:wrapped-query($query, $order)
	        }
</f:results>
(:} catch * {
	<exist:exception>
		<div xmlns="http://www.w3.org/1999/xhtml" class="pure-alert pure-alert-danger">
			<h3>Fehler: {$err:code}</h3>
			<pre>{$err:description}</pre>
			<p>{$err:module}:{$err:line-number}:{$err:column-number} Value: {$err:value}, Additional: {$err:additional}</p>
		</div>
	</exist:exception>
}:)
