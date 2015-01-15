<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:f="http://www.faustedition.net/ns" xmlns:ge="http://www.tei-c.org/ns/geneticEditions"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" version="2.0">
    <xsl:template match="@*|node()">
        <xsl:choose>
            <xsl:when test="name()='new'"/>
            <xsl:when test="name()='rend'"/>
            <xsl:when test="name()='hand'"/>
            <xsl:when test="name()='f:bottom'"/>
            <xsl:when test="name()='f:bottom-top'"/>
            <xsl:when test="name()='f:top'"/>
            <xsl:when test="name()='f:top-bottom'"/>
            <xsl:when test="name()='f:left'"/>
            <xsl:when test="name()='f:left-right'"/>
            <xsl:when test="name()='f:right'"/>
            <xsl:when test="name()='f:right-left'"/>
            <xsl:when test="name()='xml:id'"/>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="app/text()"/>
    <xsl:template match="app">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="hi">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="lem">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="anchor"/>
    <xsl:template match="handShift[not(preceding-sibling::text())]"/>
    <xsl:template match="rdg"/>
    <xsl:template match="seg[not(@rend='inbetween')]">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="ge:line[@type='inter']">
        <add>
            <xsl:apply-templates/>

        </add>
    </xsl:template>
    <xsl:template match="ge:line">

        <xsl:apply-templates/>

    </xsl:template>
    <xsl:template match="f:grLine"></xsl:template>
    <xsl:template match="f:ins">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="f:overw">
        <subst>
            <xsl:apply-templates/>
        </subst>
    </xsl:template>
    <xsl:template match="f:over">
        <add>
            <xsl:apply-templates/>
        </add>
    </xsl:template>
    <xsl:template match="f:under">
        <del>
            <xsl:apply-templates/>
        </del>
    </xsl:template>
    <xsl:template match="f:hspace"/>
    <xsl:template match="f:st">
        <del>
            <xsl:apply-templates/>
        </del>
    </xsl:template>
    <xsl:template match="ge:used"/>
    <xsl:template match="ge:rewrite">
        <xsl:apply-templates/>
    </xsl:template>
</xsl:stylesheet>
