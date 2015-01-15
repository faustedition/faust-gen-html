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
    <xsl:template match="add"/>
    <xsl:template match="app">
        <xsl:apply-templates></xsl:apply-templates>
    </xsl:template>
    <xsl:template match="app/text()"/>
    <xsl:template match="del">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="profileDesc"></xsl:template>
    <xsl:template match="rdg[matches(@wit, 'B9_CA')]"/>
    <xsl:template match="rdg[matches(@wit, 'B9_FDH')]">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="seg[matches(@f:questionedBy, '#go_bl')]">
        <xsl:apply-templates></xsl:apply-templates>
    </xsl:template>
    <xsl:template match="subst">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="subst/text()"/>
</xsl:stylesheet>
