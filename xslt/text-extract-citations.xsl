<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:f="http://www.faustedition.net/ns"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <xsl:output method="xml" indent="yes"/>
  
  <xsl:template match="text()"/>
  <xsl:template match="/">
    <xsl:processing-instruction name="xml-model">type="application/relax-ng-compact-syntax" href="<xsl:value-of select="f:safely-resolve('../citations.rnc', static-base-uri())"/>"</xsl:processing-instruction>
    <f:citations>
      <xsl:apply-templates select="//app"></xsl:apply-templates>
    </f:citations>
  </xsl:template>
  <xsl:template match="app//*[starts-with(@target, 'faust://bibliography')]">
    <xsl:variable name="tcnote" select="ancestor::note[@type='textcrit']"/>
    <f:citation app="{$tcnote/@xml:id}" ref="{$tcnote/ref}" section="{$tcnote/ancestor::*[@f:section][1]/@f:section}">
      <xsl:value-of select="@target"/>
    </f:citation>
  </xsl:template>
  
</xsl:stylesheet>