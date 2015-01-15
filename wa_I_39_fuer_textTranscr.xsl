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
    <xsl:template match="choice/text()"/>
    <xsl:template match="choice">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="corr"/>
    <xsl:template match="orig"/>
    <xsl:template match="reg">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="sic">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="supplied"></xsl:template>
    <xsl:template match="text()">
        <xsl:value-of select=" replace(.,'ſ','s')"/>
    </xsl:template>
</xsl:stylesheet>
