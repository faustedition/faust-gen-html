xquery version "3.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace f   = "http://www.faustedition.net/ns";
declare namespace fa   = "http://www.faustedition.net/ns"; (: OXYGEN DRIVES ME MAD!!!!!  :)
declare variable $edition := '';
declare variable $exist:controller external;
declare variable $data := collection('/db/apps/faust-dev/data');
declare variable $sigil-labels := doc('xslt/sigil-labels.xml');

declare function local:makeURL(
	$type as xs:string,
	$uri as xs:string,
	$transcript as xs:string?,
	$sec as xs:string?,
	$page as xs:string?) as xs:string
	{
		let $html := $transcript || (if ($sec) then '.'|| $sec else ()) 
		let $path := switch ($type)
			case 'archivalDocument' return concat('/documentViewer?faustUri=', $uri, "&amp;view=text&amp;page=", $page, "&amp;sec=", $html)
			default return '/print/' || $html
		return $edition || $path		
	};

declare function local:sigil($query as xs:string) as element()* {
    for $idno in $data//tei:idno[ngram:contains(., $query)][@type = $sigil-labels//f:label/@type]
    let $uri := id('fausturi', $idno)
    group by $uri
    return 
        let $idno := $idno[1],
        $sigil := data(id('sigil', $idno)),
    	$headnote := data(id('headNote', $idno)),
    	$type := data($idno/ancestor-or-self::tei:TEI/@type),
    	$transcript := id('fausttranscript', $idno),
    	$href := $edition || (if ($type = 'archivalDocument') then '/documentViewer?faustUri=' || $uri else '/print/' || $transcript),
    	$idno_label := data($sigil-labels//f:label[@type = $idno/@type])
    	
        return <f:idno-match
                    sigil="{$sigil}"
                    headnote="{$headnote}"
                    idno="{$idno}"
                    idno-label="{$idno_label}"
                    href="{$href}"
                    uri="{$uri}">{
                        util:expand($idno)
                }</f:idno-match>
};

declare function local:query($query as xs:string, $order as xs:string) as element(f:doc)* {
for $text in $data//tei:TEI[ft:query(., $query)]
let $sigil := data(id('sigil', $text)),
	$headnote := data(id('headNote', $text)),
	$type := data($text/ancestor-or-self::tei:TEI/@type),
	$uri := id('fausturi', $text),
	$transcript := id('fausttranscript', $text),
	$ann := util:expand($text),
	$score := ft:score($text),
	$number := $text/@n,
	$sortcrit := if ($order = 'sigil')
	             then $number
	             else -$score
order by $sortcrit
return
    <f:doc
        sigil="{$sigil}"
        headnote="{$headnote}"
        type="{$type}"
        uri="{$uri}"
        number="{$number}"
        transcript="{$transcript}"
        href="{local:makeURL($type, $uri, $transcript, (), ())}"
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
        	$breadcrumbs := $line/ancestor-or-self::*[@f:scene-label]
        return
        	<f:subhit
        	    page="{$page}"
        		n="{$n}"
        		href="{local:makeURL($type, $uri, $transcript, $line/ancestor-or-self::*/@f:section, $page)}"
        		>
        		{if ($breadcrumbs)
        		then
	        		<f:breadcrumbs>
	        		{for $div in $breadcrumbs return <f:breadcrumb>{$div/@f:*}</f:breadcrumb>}
	        		</f:breadcrumbs>
	        	else (),
        		$line}
        	</f:subhit>
        }</f:doc>
};

let $query := request:get-parameter('q', 'pudel'),
    $order  := request:get-parameter('order', 'score'),
    $sigils  := local:sigil($query),
	$results := local:query($query, $order)
return <f:results 
            docs="{count($results)}" 
            query="{$query}"
            order="{$order}"
            hits="{count($results//exist:match)}" 
            xmlns:exist="http://exist.sourceforge.net/NS/exist" 
            xmlns="http://www.tei-c.org/ns/1.0">
	        {if ($sigils) then <f:sigils>{$sigils}</f:sigils> else (),
	        <f:fulltext-results>{$results}</f:fulltext-results>}
</f:results>