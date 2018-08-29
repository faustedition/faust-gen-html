<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:f="http://www.faustedition.net/ns"
  exclude-result-prefixes="xs f"
  version="2.0">
  
  <xsl:import href="../xslt/utils.xsl"/>
  
  <xsl:preserve-space elements="*"/>
  
  <xsl:output method="text"/>
  
  <xsl:template match="/">
    <xsl:apply-templates select="//note[@type='textcrit'][not(.//rdg[@type=('type_8','type_4a')])]"/>
<!--    <xsl:text>====&#10;</xsl:text>
    <xsl:apply-templates select="//note[@type='textcrit'][.//rdg[@type=('type_8','type_4a')]]"/>
-->  </xsl:template>
  
  <xsl:template match="note[@type='textcrit']">
    <xsl:variable name="content"><xsl:apply-templates/></xsl:variable>
    <xsl:value-of select="concat((:normalize-space:)(f:contract-space($content)), '&#10;')"/>
  </xsl:template>
  
  <xsl:template match="ref">
    <xsl:apply-templates/>
    <xsl:text> </xsl:text>
  </xsl:template>
  
  <xsl:template match="lem[child::node()]">
    <xsl:apply-templates select="node() except (wit | note[wit])"/>    
    <xsl:text>&#x2009;] </xsl:text>
    <xsl:apply-templates select="wit | note[wit]"/>
    <xsl:text>  </xsl:text>
  </xsl:template>
  
  <xsl:template match="rdg">
    <xsl:text> </xsl:text>
    <xsl:apply-templates/>
    <xsl:text> </xsl:text>
  </xsl:template>
  
  <xsl:template match="rdg//wit">
    <xsl:value-of select="concat(' ', ., ' ')"/>
  </xsl:template>
  
  <xsl:template match="gap[@reason='ellipsis']"> bis </xsl:template>
  
  <xsl:template match="subst[del, add]">
    <xsl:apply-templates select="del"/>
    <xsl:text> : </xsl:text>
    <xsl:apply-templates select="add"/>
  </xsl:template>
  
  <xsl:template match="teiHeader"/>  
  <xsl:template match="lb"><xsl:text>&#10;</xsl:text></xsl:template>
  
  <xsl:template match="text()[ends-with(., '&#x00AD;')][following-sibling::*[1][self::lb][@break='no']]">
    <xsl:value-of select="replace(f:contract-space(.), '&#x00AD;$', '-')"/>
  </xsl:template>
  
  <xsl:template match="text()[normalize-space(.) = '']"/>
  <xsl:template match="text()">
    <xsl:value-of select="replace(., '‸', '^')"/>
  </xsl:template>
  
</xsl:stylesheet>