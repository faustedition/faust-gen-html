xquery version "3.0";

declare default element namespace "http://exist.sourceforge.net/NS/exist";
declare namespace tei = "http://www.tei-c.org/ns/1.0";
declare namespace f = "http://www.faustedition.net/ns";

import module namespace utils = "http://www.faustedition.net/search/utils" at "utils.xqm";


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
  if ($exist:path = '/meta') then
    <dispatch>
        <forward url="{concat($exist:controller, '/meta.xql')}">			        	
        	<set-attribute name="xquery.report-errors" value="yes"/>
        	<set-attribute name="xmlpath" value="{$xmlpath}"/>
        </forward>
        <view>
            <forward servlet="XSLTServlet">
                <set-attribute name="xslt.stylesheet" value="{concat($exist:root, $exist:controller, '/xslt/search-light.xsl')}"/>
            </forward>
        </view>
    </dispatch>
  else if ($exist:path = '/text') then
  			    <dispatch>
			        <forward url="{concat($exist:controller, '/text.xql')}">			        	
			        	<set-attribute name="xquery.report-errors" value="yes"/>
			        	<set-attribute name="xmlpath" value="{$xmlpath}"/>
			        </forward>
			        
			        <view>
			            <forward servlet="XSLTServlet">
			                <set-attribute name="xslt.stylesheet" value="{concat($exist:root, $exist:controller, '/xslt/search-light.xsl')}"/>
			            </forward>
			        </view> 
			    </dispatch>
    else if ($exist:path = '/testimony') then
        <dispatch>
            <forward url="{concat($exist:controller, '/testimony.xql')}">
                    	<set-attribute name="xquery.report-errors" value="yes"/>
			        	<set-attribute name="xmlpath" value="{$xmlpath}"/>
			</forward>
		</dispatch>
	else if ($exist:path = '/info') then
	    <dispatch>
	        <forward url="{concat($exist:controller, '/info.xql')}">
                    	<set-attribute name="xquery.report-errors" value="yes"/>
			        	<set-attribute name="xmlpath" value="{$xmlpath}"/>
			</forward>
		</dispatch>
	else if ($exist:path = '/shortcut') then
	    <dispatch>
	        <forward url="{concat($exist:controller, '/shortcut.xql')}">
                    	<set-attribute name="xquery.report-errors" value="yes"/>
			        	<set-attribute name="xmlpath" value="{$xmlpath}"/>
			</forward>
		</dispatch>
	else if ($exist:path = ('', '/', '/query')) then
		let $query := request:get-parameter('q', ''),
			$rooturl := 'http://' || request:get-header('X-Forwarded-Host'),
			$shortcut := utils:shortcut($query)
		return if ($shortcut)
			then 
				<dispatch>
					<redirect url="{
					     $rooturl || $shortcut
					}"/>
				</dispatch>
		    else
			    <dispatch>
			        <redirect url="{$rooturl || '/search?' || request:get-query-string()}"/>
			    </dispatch>
    else <ignore/>
