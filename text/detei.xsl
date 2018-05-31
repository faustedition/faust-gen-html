<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:f="http://www.faustedition.net/ns"
  exclude-result-prefixes="xs f"
  version="2.0">
  
  <xsl:import href="../xslt/utils.xsl"/>
  
  <xsl:output method="text"/>
  
  <xsl:template match="l|stage|speaker|head|titlePart">
    <xsl:apply-templates/>
    <xsl:choose>
      <xsl:when test="following-sibling::*[1]/tokenize(@rend, '\s+')='inline'">
        <xsl:text> </xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>&#10;</xsl:text>              
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:template>
  
  <xsl:template match="teiHeader"/>
  <xsl:template match="note[@type='textcrit']"/>
  <xsl:template match="lb"><xsl:text>&#10;</xsl:text></xsl:template>
  
  <xsl:template match="text()[normalize-space(.) = '']"/>
  <xsl:template match="text()">
    <xsl:value-of select="f:contract-space(.)"/>
  </xsl:template>
  
</xsl:stylesheet>