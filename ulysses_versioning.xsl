<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" version="2.0">


    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:strip-space elements="app"/>
    <xsl:template match="app">
        <xsl:apply-templates/>
    </xsl:template>
    <!-- lem einsetzen -->
    <xsl:template match="lem[matches(@wit, '#LVL8.1')]">
        <xsl:apply-templates/>
    </xsl:template>
    <!-- rdg einsetzen -->
    <xsl:template match="rdg[matches(@wit, '#LVL8.1')]">
        <xsl:apply-templates/>
    </xsl:template>
    <!-- lem rauswerfen -->
    <xsl:template match="lem[not(matches(@wit, '#LVL8.1'))]"/>
    <!-- rdg rauswerfen -->
    <xsl:template match="rdg[not(matches(@wit, '#LVL8.1'))]"/>
    <!-- anchor raus -->
    <xsl:template match="anchor"/>
    <!-- wit raus -->
    <xsl:template match="wit"/>
</xsl:stylesheet>
