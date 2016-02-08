xquery version "3.0";

declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace f = "http://www.faustedition.net/ns";

declare variable $query := request:get-parameter("q", "Pudel");
declare variable $raw as xs:boolean := boolean(request:get-parameter("raw", false()));
declare variable $start := request:get-parameter('start', 0);
declare variable $items := request:get-parameter('items', 10);

declare variable $edition := '';
declare variable $data := collection('/db/apps/faust/data');
declare variable $session := session:create();

declare function f:makeURL(
	$type as xs:string,
	$uri as xs:string,
	$transcript as xs:string?,
	$sec as xs:string?,
	$page as xs:string?) as xs:string
	{
		let $html := $transcript || (if ($sec) then '.'|| $sec else ()) || '.html'
		let $path := switch ($type)
			case 'archivalDocument' return concat('/documentViewer?faustUri=', $uri, "&amp;view=text&amp;page=", $page, "&amp;sec=", $html)
			default return '/print/' || $html
		return $edition || $path		
	};
	
	
declare function f:query($query) as element()* {
    for $line in $data//tei:l[ft:query(., $query)]
			    | $data//tei:p[ft:query(., $query)]
			    | $data//tei:stage[ft:query(., $query)]
			    | $data//tei:speaker[ft:query(., $query)]
			    | $data//tei:head[ft:query(., $query)]
			    | $data//tei:note[ft:query(., $query)]
			    | $data//tei:trailer[ft:query(., $query)]
			    | $data//tei:label[ft:query(., $query)]
			    | $data//tei:item[ft:query(., $query)]
    let $sigil := string(id('sigil', $line)),
	    $headnote := string(id('headNote', $line)),
	    $n := data($line/@n),
	    $type := data($line/ancestor::tei:TEI/@type),
	    $sec := data($line/ancestor::tei:div[1]/@f:n),
	    $uri := id('fausturi', $line),
	    $page := ($line//tei:pb/@f:docTranscriptNo, $line/preceding::tei:pb[1]/@f:docTranscriptNo)[1],
	    $transcript := id('fausttranscript', $line)
    return
	    <f:hit 
		    sigil="{$sigil}" 
		    headnote="{$headnote}" 
		    type="{$type}" 
		    n="{$n}"
		    href="{f:makeURL($type, $uri, $transcript, $sec, $page)}"
		    >{util:expand($line)}</f:hit>	
};

declare function f:get-results($query) as element()* {
    let $stored-query := session:get-attribute('stored-query'),
        $results := session:get-attribute('results')
    return if ($stored-query eq $query and $results) 
            then $results 
            else f:query($query)
};


if ($raw) 
	then $results 
	else transform:transform(
		     <f:results query="{$query}" xmlns:f="http://www.faustedition.net/ns"
									    xmlns:exist="http://exist.sourceforge.net/NS/exist"
									    xmlns="http://www.tei-c.org/ns/1.0">{
		 	 f:get-results($query)
		     }</f:results>,
		     doc('xslt/search-results.xsl'), 
		     <parameters>
			    <param name="edition" value="{$edition}"/>
			    <param name="query" value="{$query}"/>
		     </parameters>)
