<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="div[@type='contents']"/>
    <xsl:template match="docImprint"/>
    <xsl:template match="docTitle[child::titlePart//text()[contains(.,'Werke')]]"/>
    <xsl:template match="docTitle[child::titlePart//text()[contains(.,'Schriften')]]"/>
    
    <!--<xsl:template
        match="text[parent::group and child:: *//text()[contains(.,'Wenn der Blüthen Frühlings-Regen')]]"/>-->

</xsl:stylesheet>
