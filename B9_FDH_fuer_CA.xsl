<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns:f="http://www.faustedition.net/ns" xmlns="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xsl:output method="text"></xsl:output>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="add"/>
    <xsl:template match="app/text()"/>
    <xsl:template match="del">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="figure"/>
    <xsl:template match="fw[matches(@type, 'header')]">
        <p>
            <xsl:apply-templates select="@*|node()"/>
        </p>
    </xsl:template>
    <xsl:template match="fw[matches(@type, 'pageNum')]">
        <p>
            <xsl:apply-templates select="@*|node()"/>
        </p>
    </xsl:template>
    <xsl:template match="fw[matches(@type, 'sig')]">
        <p>
            <xsl:apply-templates select="@*|node()"/>
        </p>
    </xsl:template>
    <!-- Ersetzung der normalen <lb>s durch Leerzeichen. -->
    <xsl:template match="lb">
        <xsl:text> </xsl:text>
    </xsl:template>
    <!-- Entfernung der <lb>s bei Worttrennungen. -->
    <xsl:template match="lb[matches(@break, 'no')]">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="rdg[matches(@wit, 'B9_CA')]"/>
    <xsl:template match="rdg[matches(@wit, 'B9_FDH')]">
        <xsl:apply-templates/>
    </xsl:template>
    <!-- Entfernung der Trennstriche -->
    <xsl:template match="seg[matches(@f:questionedBy, '#go_bl')]">
        <xsl:apply-templates></xsl:apply-templates>
    </xsl:template>
    <xsl:template match="space">
        <xsl:text> </xsl:text>
    </xsl:template>
    <xsl:template match="subst">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="subst/text()"/>
    <xsl:template match="teiHeader"></xsl:template>
    <xsl:template match="text()">
        <xsl:value-of select="replace(.,'­','- ')"/>
    </xsl:template>
</xsl:stylesheet>
