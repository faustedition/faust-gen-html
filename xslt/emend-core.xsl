<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"    
    xmlns:f="http://www.faustedition.net/ns" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs f" version="2.0" xmlns:ge="http://www.tei-c.org/ns/geneticEditions">
    
    <!-- 
    
        This stylesheet performs the basic steps to create the emended version of the text. It performs basic
        add/del/subst stuff etc., character normalization, etc. It does not handle transpositions and delSpan.
        
        This stylesheet can be run both standalone and included in other stylesheets. For the latter case
        there is a mode 'emend' that can be used to produce the preprocessing steps. The 'emend' mode also
        deals with some extra stuff that is usually used in HTML generation – corr etc. Users must ensure that
        the default mode rules don't apply accidently – i.e., import this stylesheet instead of including it
        and make sure you have matching rules for all nodes with higher import precedence. 
    
    -->
    
    <xsl:import href="utils.xsl"/>
    
    <xsl:template match="node()|@*" mode="#default emend">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
        
    <xsl:template match="add" mode="#default emend">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    <xsl:template match="add[@f:rejectedBy]" mode="#default emend"/>
    
    <xsl:template match="del" mode="#default"> <!-- FIXME modes are static – find a solution -->
        <xsl:apply-templates mode="del"/>
    </xsl:template>
    <xsl:template match="del" mode="emend"> <!-- FIXME modes are static – find a solution -->
        <xsl:apply-templates mode="del-emend"/>
    </xsl:template>
   
    <xsl:template mode="del" match="restore">
        <xsl:apply-templates mode="#default"/>
    </xsl:template>
    <xsl:template mode="del-emend" match="restore">
        <xsl:apply-templates mode="emend"/>
    </xsl:template>
    
    <xsl:template mode="del del-emend" match="node()">
        <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:template>
    
    <xsl:template match="restore/del" mode="#default emend">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>

    <xsl:template match="restore/subst" mode="#default emend">
      <xsl:apply-templates select="del/node()" mode="#current"/>
    </xsl:template>  

    <xsl:template match="subst/del/restore[../../add/del]" mode="del del-emend">
<!--        <xsl:message select="concat('Experimental suppression of del that will appear in add. del: ', normalize-space(.), ' in ', document-uri(/))"/>-->
    </xsl:template>
    
    
    <xsl:template match="subst/add/del[../../del/restore]" priority="1" mode="#default emend">
        <xsl:apply-templates select="../../del/restore" mode="#current"/>
<!--        <xsl:message select="concat('Experimental add/del-restore-substitution. add: ', normalize-space(..), 
            ' del: ', normalize-space(.), ' @', position(), ' in ', document-uri(/))"/>
-->    </xsl:template>

    <xsl:template match="restore" mode="#default emend">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="supplied[matches(@evidence, 'internal')]" mode="#default emend">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="supplied[@reason = 'typesetting-error']" mode="#default emend"/>
 
    <xsl:template match="subst" mode="#default emend">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>

    <xsl:template match="text()" priority="1" mode="#default emend">
        <xsl:value-of select="f:normalize-print-chars(.)"/>
    </xsl:template>
    <xsl:strip-space elements="app choice subst"/>
    
    <xsl:template match="@f:section-label" mode="#default emend">
        <xsl:attribute name="{name()}" select="f:normalize-print-chars(.)"/>                    
    </xsl:template>

    <xsl:template match="orig/text()[. = 'sſ']" mode="#default emend">ß</xsl:template>

    <!-- only in emendation mode -->
    <xsl:template match="choice|app" mode="emend">
        <xsl:apply-templates select="(orig|abbr|sic|lem)/node()" mode="#current"/>
    </xsl:template>

</xsl:stylesheet>
