<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:ge="http://www.faustedition.net/ns">
    <!--<xsl:output method="text"></xsl:output>-->
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Dec 9, 2012</xd:p>
            <xd:p><xd:b>Author:</xd:b> bruening</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <!--<xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>-->
    <xsl:template match="@*|node()">
        <xsl:choose>
            <xsl:when test="name()='n'"/>
            <!--<xsl:when test="name()='//speaker/rend'"/>-->
            <!--<xsl:when test="name()='rend'"/>-->
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--    <xsl:template match="figure"/>-->
    <!--<xsl:template match="fw"/>-->
        <xsl:template match="milestone[@unit='refline']"/>
    <!--<xsl:template match="l[not(.//text())]"></xsl:template>-->
    <!--<xsl:template match="lb[parent::l]"/>-->
    <!--<xsl:template match="pb"/>-->
    <!--<xsl:template match="seg"></xsl:template>-->
    <!--<xsl:template match="space"/>-->
    <!--<xsl:template match="entry">
        <p>
            <xsl:apply-templates></xsl:apply-templates>
        </p>
    </xsl:template>-->
    <!--<xsl:template match="keyword">
        <hi>
            <xsl:apply-templates></xsl:apply-templates>
        </hi>
    </xsl:template>-->
    <!--<xsl:template match="frequency">
        <xsl:text> (</xsl:text>
        <xsl:apply-templates></xsl:apply-templates>
        <xsl:text>)</xsl:text>
    </xsl:template>-->
    <!--<xsl:template match="reference">
        
            <xsl:apply-templates/>
        
    </xsl:template>-->
    <!--<xsl:template match="verse">
        <xsl:apply-templates/>
    </xsl:template>-->
    <!--<xsl:template match="cont"/>-->
</xsl:stylesheet>
