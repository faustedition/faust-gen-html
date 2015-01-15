<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:f="http://www.faustedition.net/ns" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs" version="2.0">

    <!--<xsl:output method="text"/>-->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="choice">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="choice/text()"/>
    <xsl:template match="corr"/>
    <!--<xsl:template match="supplied"/> muss drinbleiben, da im DTA auf schwer lesbare Buchstaben bezogen -->
    <xsl:template match="fw[matches(@type, 'header')]">
        <p>
            <xsl:apply-templates select="@*|node()"/>
        </p>
    </xsl:template>
    <xsl:template match="fw[matches(@type, 'sig')]">
        <p>
            <xsl:apply-templates select="@*|node()"/>
        </p>
    </xsl:template>
    <xsl:template match="teiHeader"></xsl:template>
    <!-- Zeichen -->
    <xsl:template match="text()">
        <xsl:variable name="tmp1" select=" replace(.,'aͤ','ä')"/>
        <xsl:variable name="tmp2" select=" replace($tmp1,'oͤ','ö')"/>
        <xsl:variable name="tmp3" select=" replace($tmp2,'uͤ','ü')"/>
        <xsl:variable name="tmp4" select=" replace($tmp3,' ','')"/>
        <xsl:value-of select="$tmp4"/>
    </xsl:template>
</xsl:stylesheet>
