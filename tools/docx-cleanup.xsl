<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" version="2.0">
    
    <!-- drop @style when font-size:10pt -->
    <xsl:template match="hi[@style = 'font-size:10pt']/@style"/>
    
    <!-- drop hi when not having an @rend -->
    <xsl:template match="hi[not(@rend)]">
        <xsl:apply-templates/>
    </xsl:template>
    
    <!-- transform centered p element into head element -->
    <xsl:template match="p[@style = 'text-align:center;']">
        <head rend="center">
            <xsl:apply-templates/>
        </head>
    </xsl:template>
    
    <!-- transform right-justified p element into p element with @rend="right" -->
    <xsl:template match="p[@style = 'text-align:right;']">
        <p rend="right">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    
    <xsl:template match="hi[@rend = 'footnote_reference']">
        <ref type="footnote">
            <xsl:apply-templates/>
        </ref>
    </xsl:template>
    
    <xsl:template match="seg[@style = 'font-size:10pt']">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="text()">
        <xsl:analyze-string regex="\[(\d+)\]" select=".">
            <xsl:matching-substring>
                <pb n="{regex-group(1)}"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <!-- Pass through unchanged everything else. -->
    <xsl:template match="node() | @*">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@*, node()"/>
        </xsl:copy>
    </xsl:template>
    
</xsl:stylesheet>