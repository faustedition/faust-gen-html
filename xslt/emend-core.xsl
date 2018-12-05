<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"    
    xmlns:f="http://www.faustedition.net/ns" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs f" version="2.0" xmlns:ge="http://www.tei-c.org/ns/geneticEditions">
    
    <!-- 
    
        This stylesheet performs the basic steps to create the emended version of the text. It performs basic
        add/del/subst stuff etc., character normalization, etc. It does not handle transpositions and delSpan.
        
        This stylesheet can be run both standalone and included in other stylesheets. There is a mode 'emend' 
        that can be used to produce the preprocessing steps. The 'emend' mode also
        deals with some extra stuff that is usually used in HTML generation – corr etc. To run the stylesheet
        standalone, you must supply the initial mode 'emend'.
    
    -->
    
    <xsl:import href="utils.xsl"/>
    
    <xsl:param name="changenote">Created emended version (final layer)</xsl:param>
    
    <xsl:template match="node()|@*" mode="emend">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
        
    <xsl:template match="add" mode="emend">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    <xsl:template match="add[@f:rejectedBy]" mode="emend"/>
    
    <xsl:template match="del" mode="emend">
        <xsl:apply-templates mode="del-emend"/>
    </xsl:template>
   
    <xsl:template mode="del-emend" match="restore">
        <xsl:apply-templates mode="emend"/>
    </xsl:template>
    
    <xsl:template mode="del-emend" match="node()">
        <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:template>
    
    <xsl:template match="restore/del" mode="emend">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>

    <xsl:template match="restore/subst|subst[@f:rejectedBy]" mode="emend">
      <xsl:apply-templates select="del/node()" mode="#current"/>
    </xsl:template>  

    <xsl:template match="subst/del/restore[../../add/del]" mode="del-emend">
<!--        <xsl:message select="concat('Experimental suppression of del that will appear in add. del: ', normalize-space(.), ' in ', document-uri(/))"/>-->
    </xsl:template>
    
    
    <xsl:template match="subst/add/del[../../del/restore]" priority="1" mode="emend">
        <xsl:apply-templates select="../../del/restore" mode="#current"/>
<!--        <xsl:message select="concat('Experimental add/del-restore-substitution. add: ', normalize-space(..), 
            ' del: ', normalize-space(.), ' @', position(), ' in ', document-uri(/))"/>
-->    </xsl:template>

    <xsl:template match="restore" mode="emend">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="supplied[matches(@evidence, 'internal')]" mode="emend">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="supplied[@reason = 'typesetting-error']" mode="emend"/>
 
    <xsl:template match="subst" mode="emend">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>

    <xsl:template match="text()" priority="1" mode="emend">
        <xsl:value-of select="f:normalize-print-chars(.)"/>
    </xsl:template>
    <xsl:strip-space elements="app choice subst"/>
    
    <xsl:template match="@f:section-label" mode="emend">
        <xsl:attribute name="{name()}" select="f:normalize-print-chars(.)"/>                    
    </xsl:template>

    <xsl:template match="orig/text()[. = 'sſ']" mode="emend">ß</xsl:template>

    <!-- only in emendation mode -->
    <xsl:template match="choice|app" mode="emend">
        <xsl:apply-templates select="(orig|abbr|sic|lem)/node()" mode="#current"/>
    </xsl:template>

</xsl:stylesheet>
