<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:f="http://www.faustedition.net/ns"
  exclude-result-prefixes="xs f"
  version="2.0">
  
  <xsl:import href="../xslt/utils.xsl"/>
 
  <xsl:output method="text"/>
  
  
  <xsl:template match="/">
    <xsl:variable name="text">
      <xsl:apply-templates/>
    </xsl:variable>
    <xsl:variable name="lines" select="tokenize($text, '\n+')"/>
    <xsl:value-of select="string-join($lines, '&#10;')"/>
  </xsl:template>
    
  <xsl:template match="Br"><xsl:text>&#10;</xsl:text></xsl:template>
  <xsl:template match="ParagraphStyleRange">
    <xsl:apply-templates/>
    <!--<xsl:text>&#10;</xsl:text>-->
  </xsl:template>
  
  <!-- things to throw away: -->
  <xsl:template match="Footnote"/>
  <xsl:template match="CharacterStyleRange[@AppliedCharacterStyle=(
    'CharacterStyle/Verszahl',
    'CharacterStyle/Transparent'
    )]"/>
  <xsl:template match="Content[matches(., '^\t+')]"/>
  <xsl:template match="Content[. = '&#x2028;']"><xsl:text>&#10;</xsl:text></xsl:template>
  
  <xsl:template match="Content"><xsl:value-of select="f:contract-space(.)"/></xsl:template>
  
  
  <xsl:template match="text()"/>


</xsl:stylesheet>