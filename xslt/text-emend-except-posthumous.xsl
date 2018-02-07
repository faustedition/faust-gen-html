<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:ge="http://www.tei-c.org/ns/geneticEditions"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!--
        
        This is like text-emend.xsl, except that it does the opposite
        for posthumous changes …
    
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
    
    <!-- 
        Iff $node is a node that is in the span some delSpan, key('delSpan-for-node', generate-id($node)) will return 
        the corresponding delSpan element (otherwise it's the empty sequence)
        
        This approach, inspired by Wendell Piez, is much faster than any complex checking in the template pattern
    -->
    <xsl:key name="delSpan-for-node" match="delSpan[not(@ge:stage='#posthumous')]|addSpan[@ge:stage='#posthumous']">
        <xsl:variable name="target" as="element()" select="id(substring(@spanTo, 2))"/>
        <xsl:variable name="nodes" select="following::node() except ($target//node(), $target/following::node())"/>
        <xsl:sequence select="for $node in $nodes return generate-id($node)"/>
    </xsl:key>     
    <xsl:template match="node()[key('delSpan-for-node', generate-id())]"/>    

    <xsl:template match="addSpan | delSpan | modSpan"/>    
</xsl:stylesheet>
