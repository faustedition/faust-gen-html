<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <!--<xsl:template match="@*|node()">
        <xsl:choose>
            <xsl:when test="name()='//speaker/@rend'"/>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@*|node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>-->
    <!--<xsl:template match="author"/>
    <xsl:template match="byline"/>-->
    <xsl:template match="comment()"/>
    <xsl:template match="damage">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="encodingDesc"/>
    <xsl:template match="fileDesc">
        <xsl:apply-templates/>
    </xsl:template>
    <!--<xsl:template match="div[@type='contents']"/>-->
    <!--<xsl:template match="div[@type='half-title']"/>-->
    <!--<xsl:template match="docImprint"/>-->
    <!--    <xsl:template match="titlePage[.//titlePart//text()[contains(.,'Werke')]]"/>-->
    <xsl:template match="titlePage[.//titlePart//text()[contains(.,'Alterthum')]]"/>
    <!--<xsl:template match="figure"/>-->
    <xsl:template match="fw"/>
    <xsl:template match="lb">
        <xsl:text> </xsl:text>
    </xsl:template>
    <xsl:template match="lb[matches(@break, 'no')]"/>
    <xsl:template match="pb">
        <xsl:text> </xsl:text>
    </xsl:template>
    <xsl:template match="pb[matches(@break, 'no')]"/>
    <xsl:template match="publicationStmt"/>
    <xsl:template match="sourceDesc"/>
    <xsl:template match="space"/>
    <!--<xsl:template match="TEI">
        <xsl:apply-templates/>
    </xsl:template>-->
    <xsl:template match="teiHeader">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="titleStmt">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="revisionDesc"/>
    <xsl:template match="text()">
        <!-- Entfernung der Trennstriche -->
        <xsl:value-of select=" replace(.,'­','')"/>
    </xsl:template>
    <!--<xsl:template match="trailer"/>-->
    <!-- Ausscheiden von Textteilen -->
    <!--<xsl:template
        match="text[parent::group and child:: *//text()[contains(.,'Wenn der Blüthen Frühlings-Regen')]]"/>
    <xsl:template match="text[parent::group and child:: *//text()[contains(.,'Paralipomena')]]"/>
    <xsl:template match="text[parent::group and child:: *//text()[contains(.,'Berichtigungen')]]"/>-->
    <!-- Editorische Eingriffe -->
    <xsl:template match="choice">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="sic">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="sic[parent::choice[child::corr[@type='correction']]]"/>
    <!--<xsl:template match="sic[parent::choice[child::corr[@type='emendation']]]"/>-->
    <xsl:template match="corr"/>
    <xsl:template match="corr[@type='correction']">
        <xsl:apply-templates/>
    </xsl:template>
    <!--<xsl:template match="corr[@type='emendation']">
        <xsl:apply-templates/>
        </xsl:template>-->
    <xsl:template match="supplied"/>
    <xsl:template match="supplied[@reason='printing-error']">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="supplied[parent::damage]">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:strip-space elements="choice"/>
</xsl:stylesheet>
