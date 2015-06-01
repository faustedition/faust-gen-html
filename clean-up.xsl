<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <!--<xsl:output method="text"></xsl:output>-->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="l[not(.//text())]"/>
    <!--<xsl:template match="l[not(normalize-space(.))]"/>-->
    <xsl:template match="sp[not(.//text())]"/>
    <!--<xsl:template match="sp[not(normalize-space(.))]"/>-->
    <xsl:template match="stage[not(.//text())]"/>
    <!--<xsl:template match="stage[not(normalize-space(.))]"/>-->
    <xsl:template match="author"/>
    <xsl:template match="byline"/>
    <xsl:template match="encodingDesc"/>
    <xsl:template match="fileDesc">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="profileDesc"></xsl:template>
    <xsl:template match="publicationStmt"/>
    <xsl:template match="respStmt"></xsl:template>
    <xsl:template match="sourceDesc"/>
    <xsl:template match="teiHeader">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="titleStmt">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="revisionDesc"/>
</xsl:stylesheet>
