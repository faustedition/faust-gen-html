<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"    
    xmlns:f="http://www.faustedition.net/ns" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs f" version="2.0" xmlns:ge="http://www.tei-c.org/ns/geneticEditions">
    
    <!-- 
    
        This stylesheet performs the basic steps to create the base version of the text. It removes basic
        add/del/subst stuff etc., character normalization, etc. It does not handle transpositions and delSpan.
        
    
    -->
    
    <xsl:import href="utils.xsl"/>
    <xsl:strip-space elements="app choice subst"/>
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
        
    <xsl:template match="add"/>
    
    <xsl:template match="del|restore">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="subst">
        <xsl:apply-templates select="del/node()"/>
    </xsl:template>
    
    <xsl:template match="supplied[contains(@evidence, 'typesetting-error')]"/>
    
    <xsl:template match="choice">
        <xsl:apply-templates select="(orig|abbr|sic)/node()"/>
    </xsl:template>

    <xsl:template match="app[lem]">
        <xsl:apply-templates select="lem/node()"/>
    </xsl:template>
    
    <xsl:template match="comment()" priority="1"/>

    <!--what to do with this? 
    
    <xsl:template match="supplied[matches(@evidence, 'internal')]" mode="emend">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="supplied[@reason = 'typesetting-error']" mode="emend"/>
 

    <xsl:template match="text()" priority="1" mode="emend">
        <xsl:value-of select="f:normalize-print-chars(.)"/>
    </xsl:template>
    <xsl:strip-space elements="app choice subst"/>
    
    <xsl:template match="@f:section-label" mode="emend">
        <xsl:attribute name="{name()}" select="f:normalize-print-chars(.)"/>                    
    </xsl:template>

    <xsl:template match="orig/text()[. = 'sſ']" mode="emend">ß</xsl:template>

    <!-\- only in emendation mode -\->
    <xsl:template match="choice|app" mode="emend">
        <xsl:apply-templates select="(orig|abbr|sic|lem)/node()" mode="#current"/>
    </xsl:template>-->

</xsl:stylesheet>
