<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <xsl:output indent="no"/>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()">
        <xsl:variable name="first" select="if (preceding-sibling::text()) then false() else true() "/>
        <xsl:variable name="more" select="if (following-sibling::text()) then false() else true() "/>
        <xsl:choose>
            <xsl:when test="ancestor::*[@xml:space][1]/@xml:space='preserve'">
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:when>
            <xsl:otherwise>
                <!-- Retain one leading space if node isn't first, has
                    non-space content, and has leading space.-->
                <xsl:if
                    test="not($first) and          
                    matches(.,'^\s') and          
                    normalize-space()!=''">
                    <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:value-of select="normalize-space(.)"/>
                <xsl:choose>
                    <!-- node is an only child, and has content but it's all space -->
                    <xsl:when
                        test="$first and not ($more) and
                        string-length()!=0 and
                        normalize-space()=''">
                        <xsl:text> </xsl:text>
                    </xsl:when>
                    <!-- node isn't last, isn't first, and has trailing space -->
                    <xsl:when test="not($first) and $more and matches(.,'\s$')">
                        <xsl:text> </xsl:text>
                    </xsl:when>
                    <!-- node isn't last, is first, has trailing space, and has non-space content   -->
                    <xsl:when
                        test="$first and $more and matches(.,'\s$') and
                        normalize-space()!=''">
                        <xsl:text> </xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
