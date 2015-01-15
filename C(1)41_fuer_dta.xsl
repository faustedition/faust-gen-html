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
    <xsl:template match="figure"/>
    <xsl:template match="fw"> </xsl:template>
    <xsl:template match="teiHeader"></xsl:template>
    <!-- Ersetzung der normalen <lb>s durch Leerzeichen. -->
    <xsl:template match="lb">
        <xsl:text> </xsl:text>
    </xsl:template>
    <!-- Entfernung der <lb>s bei Worttrennungen. -->
    <xsl:template match="lb[matches(@break, 'no')]"/>
    <xsl:template match="space">
        <xsl:text> </xsl:text>
    </xsl:template>
    <!-- Editorische Eingriffe -->
    <xsl:template match="choice">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="choice/text()"/>
    <xsl:template match="sic">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="corr"/>
    <xsl:template match="supplied"></xsl:template>
    <xsl:template match="supplied[@reason='printing-error']">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="text()">
        <!-- Entfernung der Trennstriche -->
        <xsl:variable name="tmp1"  select=" replace(.,'­','')"/>
        <xsl:variable name="tmp2" select=" replace($tmp1,'ſ','s')"/>
        <xsl:variable name="tmp3" select=" replace($tmp2,'—','–')"></xsl:variable>
        <xsl:value-of select="$tmp3"/>
    </xsl:template>

</xsl:stylesheet>
