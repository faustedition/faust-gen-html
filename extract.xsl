<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <!--<xsl:output method="text"></xsl:output>-->
    <xsl:template match="@*|node()">
        <xsl:apply-templates select="attribute::* | child::node()"/>
    </xsl:template>
    <xsl:template match="/">
        <root>
            <xsl:apply-templates select="attribute::* | child::node()"/>
        </root>
    </xsl:template>
    <xsl:template
        match="node()[ancestor-or-self::div[@n='2.3']] | @*[ancestor-or-self::div[@n='2.3']] ">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="div[@type='contents']"/>
    <xsl:template match="docImprint"/>
    <xsl:template match="docTitle[child::titlePart//text()[contains(.,'Werke')]]"/>
    <xsl:template match="docTitle[child::titlePart//text()[contains(.,'Schriften')]]"/>
</xsl:stylesheet>
