xquery version "3.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace f   = "http://www.faustedition.net/ns";


<f:results xmlns="http://www.tei-c.org/ns/1.0">{

for $line in ft:query(//(
	  tei:l
	| tei:p
	| tei:head
	| tei:stage
	| tei:speaker
	| tei:note
	| tei:trailer
	| tei:label
	| tei:item
	), request:get-parameter('q', 'pudel'))
let $sigil := data(id('sigil', $line)),
    $n := data($line/@n),
	$headnote := data(id('headNote', $line)),
	$type := data($line/ancestor::tei:TEI/@type),
	$uri := id('fausturi', $line),
	$page := ($line//tei:pb/@f:docTranscriptNo, $line/preceding::tei:pb[1]/@f:docTransriptNo)[1],
	$transcript := id('fausttranscript', $line),
	$breadcrumbs := $line/ancestor-or-self::*[@f:scene-label]
order by ft:score($line)
return
	<f:hit
		sigil="{$sigil}"
		score="{ft:score($line)}"
		headnote="{$headnote}"
		type="{$type}"
		n="{$n}">
		<f:breadcrumbs count="{count($breadcrumbs)}">
		{for $div in $breadcrumbs return <f:breadcrumb>{$div/@f:*}</f:breadcrumb>}
		</f:breadcrumbs>
		{util:expand($line)}
	</f:hit>
}</f:results>