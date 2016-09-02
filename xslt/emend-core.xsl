<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"    
    xmlns:f="http://www.faustedition.net/ns" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs f" version="2.0" xmlns:ge="http://www.tei-c.org/ns/geneticEditions"
    xmlns:fn="http://www.example.com/fn">
    
    <xsl:import href="utils.xsl"/>
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates select="node()|@*" mode="#current"/>
        </xsl:copy>
    </xsl:template>
        
    <xsl:template match="add">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="add[@f:rejectedBy]"/>
    
    <xsl:template match="del">
        <xsl:apply-templates mode="del"/>
    </xsl:template>
    <xsl:template mode="del" match="restore">
        <xsl:apply-templates mode="#default"/>
    </xsl:template>
    <xsl:template mode="del" match="node()">
        <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:template>
    <xsl:template match="restore/del">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="restore/subst">
      <xsl:apply-templates select="del/node()"/>
    </xsl:template>  

    <xsl:template match="subst/del/restore[../../add/del]" mode="del">
<!--        <xsl:message select="concat('Experimental suppression of del that will appear in add. del: ', normalize-space(.), ' in ', document-uri(/))"/>-->
    </xsl:template>
    <xsl:template match="subst/add/del[../../del/restore]" priority="1">
        <xsl:apply-templates select="../../del/restore"/>
<!--        <xsl:message select="concat('Experimental add/del-restore-substitution. add: ', normalize-space(..), 
            ' del: ', normalize-space(.), ' @', position(), ' in ', document-uri(/))"/>
-->    </xsl:template>

    <xsl:template match="restore">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="revisionDesc"/>
    
    
    <xsl:template match="supplied[matches(@evidence, 'internal')]">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="supplied[@reason = 'typesetting-error']"/>
 
    <xsl:template match="subst">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="text()" priority="1">
        <xsl:value-of select="f:normalize-print-chars(.)"/>
    </xsl:template>
    <xsl:strip-space elements="app choice subst"/>
    
    <xsl:template match="@f:section-label">
        <xsl:attribute name="{name()}" select="f:normalize-print-chars(.)"/>                    
    </xsl:template>

    <xsl:template match="orig/text()[. = 'sſ']">ß</xsl:template>
  
      

</xsl:stylesheet>
