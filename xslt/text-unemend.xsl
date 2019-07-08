<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- 
    
        * Removes everything covered by delSpan
        * Removes addSpan / delSpan elements and correponding anchors
        * Everything else, especially <add>/<del>, is passed through
    
    -->

    
    <xsl:strip-space elements="mod"/>
    
    <xsl:template match="node()|@*">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@*, node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!--xsl:template match="/">
        <xsl:for-each select="//addSpan[not(replace(@spanTo, '^#', '') = //anchor/@xml:id)]">
            <xsl:message select="concat('WARNING: ', document-uri(/),
                ': addSpan/@spanTo=&quot;', @spanTo, 
                '&quot; without corresponding anchor: YOU LOOSE TEXT!')"/>            
        </xsl:for-each>
        <xsl:next-match/>
    </xsl:template-->
    
    <!-- 
        Iff $node is a node that is in the span some delSpan, key('delSpan-for-node', generate-id($node)) will return 
        the corresponding delSpan element (otherwise it's the empty sequence)
        
        This approach, inspired by Wendell Piez, is much faster than any complex checking in the template pattern
    -->
    <xsl:key name="addSpan-for-node" match="addSpan">
        <xsl:variable name="target" as="element()?" select="id(substring(@spanTo, 2))"/>
        <xsl:choose>
            <xsl:when test="empty($target)">-*-*-*-</xsl:when>
            <xsl:otherwise>
                <xsl:variable name="nodes" select="following::node() except ($target//node(), $target/following::node(), $target/ancestor::node())"/>
                <xsl:sequence select="for $node in $nodes return generate-id($node)"/>                
            </xsl:otherwise>
        </xsl:choose>
    </xsl:key>     
    <xsl:template match="node()[key('addSpan-for-node', generate-id())]"/>    

    <xsl:template match="addSpan | delSpan | modSpan"/>    
</xsl:stylesheet>
