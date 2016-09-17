xquery version "3.0";

declare default element namespace "http://exist.sourceforge.net/NS/exist";

declare variable $exist:root external;
declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;

(:  :if (ends-with($exist:resource, '.xql')) then
    <ignore>
        <cache-control cache="no"/>
    </ignore>
else :) if ($exist:path = '/search') then
    <dispatch>
        <forward url="{concat($exist:controller, '/fts4.xql')}"/>
        <view>
            <forward servlet="XSLTServlet">
                <set-attribute name="xslt.stylesheet" value="{concat($exist:root, $exist:controller, '/xslt/search-results.xsl')}"/>
            </forward>
        </view>
    </dispatch>
else <ignore/>