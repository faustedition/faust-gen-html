<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <!--<xsl:output indent="no"/>-->
    <xsl:output method="text"/>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <!--<xsl:template match="text()">
        <xsl:value-of select="normalize-space()"></xsl:value-of>
    </xsl:template>-->
    <!--<xsl:template match="text()">
        <xsl:choose>
            <xsl:when test="ancestor::*[@xml:space][1]/@xml:space='preserve'">
                <xsl:value-of select="."/>
            </xsl:when>
            <xsl:otherwise>
                <!-\- Retain one leading space if node isn't first, has
                    non-space content, and has leading space.-\->
                <xsl:if
                    test="position()!=1 and 
                    matches(.,'^\s') and 
                    normalize-space()!=''">
                    <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:value-of select="."/>
                <xsl:choose>
                    <!-\- node is an only child, and has content but it's all space -\->
                    <xsl:when test="last()=1 and string-length()!=0 and normalize-space()=''">
                        <xsl:text> </xsl:text>
                    </xsl:when>
                    <!-\- node isn't last, isn't first, and has trailing space -\->
                    <xsl:when test="position()!=1 and position()!=last() and matches(.,'\s$')">
                        <xsl:text> </xsl:text>
                    </xsl:when>
                    <!-\- node isn't last, is first, has trailing space, and has non-space content   -\->
                    <xsl:when test="position()=1 and matches(.,'\s$') and normalize-space()!=''">
                        <xsl:text> </xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        </xsl:template>-->
    <!-- Normalize unpreserved white space. -->
<!--    <xsl:template match="text()[not(ancestor::*[@xml:space][1]/@xml:space='preserve')]">
        <!-\- Retain one leading space if node isn't first, has non-space content, and has leading space.-\->
        <xsl:if
            test="position()!=1 and normalize-space(substring(., 1, 1)) = '' and normalize-space()!=''">
            <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:value-of select="normalize-space()"/>
        <!-\- Retain one trailing space if node isn't last, isn't first, and has trailing space 
            or node isn't last, is first, has trailing space, and has any non-space content  
            or node is an only child, and has content but it's all space-\->
        <xsl:if
            test="position()!=last() and position()!=1 and normalize-space(substring(., string-length())) = ''
            or position()!=last() and position() =1 and normalize-space(substring(., string-length())) = '' and normalize-space()!=''
            or last()=1 and string-length()!=0 and normalize-space()='' ">
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>
-->    <xsl:template match="workcomment"></xsl:template>
</xsl:stylesheet>
