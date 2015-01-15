<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:f="http://www.faustedition.net/ns" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs" version="2.0">
    <!-- Idenity Transformation -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="add">
        <xsl:apply-templates/>
    </xsl:template>
    <!--
    <xsl:template match="app/text()"/>
    <xsl:template match="choice/text()"/>
    <xsl:template match="choice">
        <xsl:apply-templates></xsl:apply-templates>
    </xsl:template>-->
    <xsl:template match="del"></xsl:template>
    <!-- Ersetzung der normalen <lb>s durch Leerzeichen. -->
    <xsl:template match="lb">
        <xsl:text> </xsl:text>
    </xsl:template>
    <!-- Entfernung der <lb>s bei Worttrennungen. -->
    <xsl:template match="lb[matches(@break, 'no')]"/>
    <xsl:template match="subst">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="subst/text()"/>
    <!-- Entfernung der Trennstriche -->
    <xsl:template match="text()">
        <xsl:value-of select="replace(.,'­','')"/>
    </xsl:template>
</xsl:stylesheet>
