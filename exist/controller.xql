xquery version "3.0";

declare default element namespace "http://exist.sourceforge.net/NS/exist";
declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare variable $exist:root external;
declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;

declare variable $xmlpath := $exist:root || $exist:controller || '/data';

(:  :if (ends-with($exist:resource, '.xql')) then
    <ignore>
        <cache-control cache="no"/>
    </ignore>
else :) 
	if ($exist:path = ('', '/search')) then
		let $query := request:get-parameter('q', ''),
			$rooturl := 'http://' || request:get-header('X-Forwarded-Host'),
			$idno := //tei:idno[@type = 'sigil_n'][. = lower-case(replace($query, '[ .*]', ''))]
		return if (count($idno) eq 1)
			then 
				<dispatch>
					<redirect url="{
						let $uri := data(id('fausturi', $idno))
						return
							switch (data($idno/ancestor::tei:TEI/@type))
							case 'archivalDocument' 
								return $rooturl || '/documentViewer?faustUri=' || $uri
							default return $rooturl || '/print/' || data(id('fausttranscript', $idno))					
					}"/>
				</dispatch>
			else
			    <dispatch>
			        <forward url="{concat($exist:controller, '/fts4.xql')}">			        	
			        	<set-attribute name="xquery.report-errors" value="yes"/>
			        	<set-attribute name="xmlpath" value="{$xmlpath}"/>
			        </forward>
			        <view>
			            <forward servlet="XSLTServlet">
			                <set-attribute name="xslt.stylesheet" value="{concat($exist:root, $exist:controller, '/xslt/search-results.xsl')}"/>
			            </forward>
			        </view>
			    </dispatch>
else if ($exist:path = ('/raw'))
then
	<dispatch>
		<forward url="{concat($exist:controller, '/fts4.xql')}"/>
	</dispatch>
else <ignore/>