<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:f="http://www.faustedition.net/ns" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs" version="2.0">
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="app">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="app/text()"/>
    <xsl:template match="encodingDesc"/>
    <xsl:template match="lb">
        <xsl:text> </xsl:text>
    </xsl:template>
    <xsl:template match="lb[matches(@ed, 'wa_I_14')]"/>
    <xsl:template match="lb[matches(@ed, 'A8')]"/>
    <xsl:template match="rdg[matches(@wit, '#wa_I_14')]">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="rdg[matches(@wit, '#wa_I_53')]"/>
    <xsl:template match="revisionDesc"/>
    <xsl:template match="sourceDesc">
        <sourceDesc>
            <p/>
        </sourceDesc>
    </xsl:template>
</xsl:stylesheet>
