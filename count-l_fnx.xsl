<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns="http://www.tei-c.org/ns/1.0" xmlns:f="http://www.faustedition.net/ns" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="l[not(@f:nx)]">
        <xsl:variable name="my_position" select="count(./preceding::l)"/>
        <xsl:variable name="last_counted" select="./preceding::l[@f:nx][1]"/>
        <xsl:variable name="last_counted_position" select="count($last_counted/preceding::l)"/>
        <l f:nx="{number($last_counted/@f:nx) + ($my_position - $last_counted_position)}">
            <xsl:apply-templates select="@*|node()"> </xsl:apply-templates>
        </l>
    </xsl:template>
</xsl:stylesheet>
