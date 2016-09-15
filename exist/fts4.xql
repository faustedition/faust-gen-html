xquery version "3.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace f   = "http://www.faustedition.net/ns";


<f:results xmlns="http://www.tei-c.org/ns/1.0">{

for $text in //tei:text[ft:query(., request:get-parameter('q', 'pudel'))]
let $sigil := data(id('sigil', $text)),
	$headnote := data(id('headNote', $text)),
	$type := data($text/ancestor::tei:TEI/@type),
	$uri := id('fausturi', $text),
	$transcript := id('fausttranscript', $text),
	$ann := util:expand($text),
	$score := ft:score($text)
order by $score descending
return
    <f:doc
        sigil="{$sigil}"
        headnote="{$headnote}"
        type="{$type}"
        uri="{$uri}"
        transcript="{$transcript}"
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
        		n="{$n}">
        		<f:breadcrumbs>
        		{for $div in $breadcrumbs return <f:breadcrumb>{$div/@f:*}</f:breadcrumb>}
        		</f:breadcrumbs>
        		{$line}
        	</f:subhit>
        }</f:doc>
}</f:results>