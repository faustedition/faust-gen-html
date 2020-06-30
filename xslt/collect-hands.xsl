<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:f="http://www.faustedition.net/ns"
                xpath-default-namespace="http://www.tei-c.org/ns/1.0">
  
  <xsl:param name="source" select="resolve-uri('../../../../data/xml')"/>
  
  <xsl:output method="xml" indent="yes"/>
  
  <xsl:template match="/*" name="collect-hands">
    <f:handUsage sigil="{//f:idno[@type='faustedition']}">
      <xsl:variable name="handsByPage">
        <xsl:apply-templates select="//f:page" mode="collect-hands"/>
      </xsl:variable>
      <f:all-hands>
        <xsl:for-each-group select="$handsByPage//f:hand" group-by="@ref">
          <xsl:copy-of select="current-group()[1]"/>
        </xsl:for-each-group>
      </f:all-hands>      
      <xsl:copy-of select="$handsByPage"/>
    </f:handUsage>
  </xsl:template>
  
  <xsl:template match="f:page[.//f:docTranscript/@uri]" mode="collect-hands">
    <xsl:variable name="pageno" select="count(preceding::f:page) + 1"/>
    <xsl:variable name="transcript-uri"  select="resolve-uri(.//f:docTranscript[1]/@uri, base-uri(.))"/>
    <xsl:variable name="transcript-file" select="replace($transcript-uri, 'faust://xml', $source)"/>
    <xsl:variable name="transcript" select="document($transcript-file)"/>
    <xsl:variable name="hands" select="$transcript//(handShift/@new|*/@hand)"/>
    <f:hands page="{$pageno}">
      <xsl:for-each-group select="$hands" group-by=".">
        <xsl:variable name="ref" select="replace(., '#', '')"/>
        <xsl:variable name="split" select="tokenize($ref, '_')"/>
        <f:hand ref="{$ref}" scribe="{$split[1]}" material="{$split[2]}"><xsl:value-of select="id($ref, .)"/></f:hand>
      </xsl:for-each-group>
    </f:hands>
  </xsl:template>
  
</xsl:stylesheet>