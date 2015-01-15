<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0"
    xmlns="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"><!-- exclude-result-prefixes="xs"  -->
    <!--<xsl:output method="text"></xsl:output>-->
    <xsl:template match="@*|node()">
        <xsl:apply-templates select="attribute::* | child::node()"/>
    </xsl:template>
    <xsl:template match="/">
        
            <xsl:apply-templates select="attribute::* | child::node()"/>
        
    </xsl:template>
    <xsl:template
        match="node()[ancestor-or-self::div[@type='conversation' and .//milestone[@unit='testimony']]] | @*[ancestor-or-self::div[@type='conversation' and .//milestone[@unit='testimony']]] ">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
