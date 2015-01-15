<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="milestone[not(@n)]">
        <xsl:variable name="my_position" select="count(./preceding::milestone)"/>
        <xsl:variable name="last_counted" select="./preceding::milestone[@n][1]"/>
        <xsl:variable name="last_counted_position" select="count($last_counted/preceding::milestone)"/>
        <milestone unit="refline" n="{number($last_counted/@n) + ($my_position - $last_counted_position)}">
            <!--<xsl:apply-templates select="@*|node()"> </xsl:apply-templates>-->
        </milestone>
    </xsl:template>
</xsl:stylesheet>
