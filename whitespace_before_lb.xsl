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
    <!-- catch text nodes that precede an <lb> and end in whitespace -->
    <xsl:template match="text()[following-sibling::node()[1][self::lb]]">
        <!-- strip trailing whitespace -->
        <xsl:value-of select="replace(.,'\s+$','')"/>
    </xsl:template>
    <!-- von mir hinzugefügt 
    \s = whitespace
    + = ggf. mehrere
    ^... = leading
    ...$ = trailing
    -->
    <!-- catch text nodes that FOLLOW an <lb> and START with whitespace -->
    <xsl:template match="text()[preceding-sibling::node()[1][self::lb]]">
        <!-- strip LEADING whitespace -->
        <xsl:value-of select="replace(.,'^\s+','')"/>
    </xsl:template>
    <!-- catch text nodes that fulfill both conditions -->
    <xsl:template match="text()[preceding-sibling::node()[1][self::lb] and following-sibling::node()[1][self::lb]]">
        <!-- strip leading AND trailing whitespace -->
        <xsl:value-of select="replace(.,'^\s+|\s+$','')"/>
    </xsl:template>
    <!-- replace <lb> by a single blank -->
    <!--<xsl:template match="lb">
        <xsl:text>&#x20;</xsl:text>
    </xsl:template>-->
</xsl:stylesheet>
