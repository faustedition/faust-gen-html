<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xpath-default-namespace="http://www.faustedition.net/ns"    
    version="2.0">
    
    <!--xsl:output method="text"/-->
    
    <xsl:param name="rewrite-base">/print</xsl:param>
    <xsl:param name="old-source">texttranscript</xsl:param>
    
    <xsl:template match="/">
        <htaccess><!-- to please xproc -->
        <xsl:text>RewriteEngine on&#10;</xsl:text>
        <xsl:text>RewriteBase "</xsl:text><xsl:value-of select="$rewrite-base"/><xsl:text>"&#10;</xsl:text>
        <xsl:text></xsl:text>
        <xsl:for-each select="//textTranscript">
            <xsl:variable name="old" select="replace(
                if ($old-source = 'texttranscript') 
                then @href
                else @document,
                '^.*/(.*).xml$', '$1')"/>
            <xsl:variable name="new" select="@sigil_t"/>
            <xsl:if test="$old != $new">                
                <xsl:value-of select="concat('RewriteRule &quot;^', $old, '(.*)&quot; &quot;', $new, '$1&quot; [R=301,L]&#10;')"/>
            </xsl:if>
        </xsl:for-each>
        </htaccess>
    </xsl:template>
    
</xsl:stylesheet>