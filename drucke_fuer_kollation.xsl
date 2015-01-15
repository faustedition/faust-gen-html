<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <!--<xsl:output method="text"></xsl:output>-->
    <!--<xsl:template match="@*|node()">
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
    </xsl:template>-->
    <xsl:template match="@*|node()">
        <!-- @ entfernen-->
        <xsl:choose>
            <xsl:when test="name()='n'"/>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="fw"/>
    <!--<xsl:template match="figure"/>-->
    <!-- Ersetzung der normalen <lb>s durch Leerzeichen. -->
    <!--<xsl:template match="lb">
        <xsl:text> </xsl:text>
    </xsl:template>-->
    <!-- Entfernung der <lb>s bei Worttrennungen. -->
    <!--<xsl:template match="lb[matches(@break, 'no')]"/>-->
    <xsl:template match="space"></xsl:template>
    <xsl:template match="pb"></xsl:template>
    <xsl:template match="teiHeader"></xsl:template>
    <!-- Entfernung der Trennstriche -->
    <!--<xsl:template match="text()">
        <xsl:value-of select="replace(.,'­','')"/>
    </xsl:template>-->
</xsl:stylesheet>
