<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xd:doc xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Jul 20, 2013</xd:p>
            <xd:p><xd:b>Author:</xd:b> bruening</xd:p>
            <xd:p/>
        </xd:desc>
    </xd:doc>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <!-- Ersetzung der normalen <lb>s durch Leerzeichen. -->
    <xsl:template match="lb">
        <xsl:text> </xsl:text>
    </xsl:template>
    <!-- Entfernung der <lb>s bei Worttrennungen. -->
    <xsl:template match="lb[matches(@break, 'no')]"/>
    <!-- Entfernung der Trennstriche -->
    <xsl:template match="space"></xsl:template>
    <xsl:template match="text()">
        <xsl:variable name="tmp1" select="replace(.,'ſ','s')"></xsl:variable>
        <xsl:variable name="tmp2" select="replace($tmp1,'­','')"/>
        <xsl:variable name="tmp3" select="replace($tmp2,'Ae','Ä')"></xsl:variable>
        <xsl:variable name="tmp4" select="replace($tmp3,'Oe','Ö')"></xsl:variable>
        <xsl:variable name="tmp5" select="replace($tmp4,'Ue','Ü')"></xsl:variable>
        <xsl:value-of select="$tmp5"/>
    </xsl:template>
</xsl:stylesheet>
