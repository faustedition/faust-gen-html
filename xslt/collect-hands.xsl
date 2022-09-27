<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
                xmlns:f="http://www.faustedition.net/ns"
                xpath-default-namespace="http://www.tei-c.org/ns/1.0">
  
  <xsl:param name="source" select="resolve-uri('../../../../data/xml')"/>
  
  <xsl:output method="xml" indent="yes"/>
  
  <xsl:template match="@* | node()" mode="prepare">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>      
    </xsl:copy>
  </xsl:template>
  
<!--  <xsl:variable name="prepared">
    <xsl:apply-templates select="/" mode="prepare"/>
  </xsl:variable>
  
  <xsl:template match="/">
    <xsl:comment>
      <xsl:text>&#10;scribe&#9;extent&#10;</xsl:text>
      <xsl:for-each-group select="$prepared//*[@f:hand-extent]" group-by="@scribe">
        <xsl:variable name="sum" select="sum(current-group()/@f:hand-extent)"/>
        <xsl:variable name="scribe" select="@scribe"/>
        <xsl:value-of select="concat($scribe, '&#9;', $sum, '&#10;')"/>
      </xsl:for-each-group>      
    </xsl:comment>
    <xsl:copy-of select="$prepared"></xsl:copy-of>
  </xsl:template>
-->  
  
  <xsl:template match="/*" name="collect-hands">
    <f:handUsage sigil="{//f:idno[@type='faustedition']}">
      <xsl:variable name="handsByPage">
        <xsl:apply-templates select="//f:page" mode="collect-hands"/>
      </xsl:variable>
      <!--f:all-hands>
        <xsl:for-each-group select="$handsByPage//f:hand" group-by="@ref">
          <xsl:copy-of select="current-group()[1]"/>
        </xsl:for-each-group>
      </f:all-hands-->      
      <xsl:copy-of select="$handsByPage"/>
    </f:handUsage>
  </xsl:template>
  
  <xsl:template match="handShift[@new]|*[@hand]" mode="prepare">
    
    <xsl:variable name="text" select="
      if (self::handShift)
      then (following::text() except (*[@hand]//text(), following::handShift[@new]/following::text()))
      else (descendant::text() except descendant::*[@hand]//text())"/>
    <xsl:variable name="normalized" select="normalize-space(string-join(data($text)))"/>
    <xsl:variable name="ref" select="replace(@new | @hand, '#', '')"/>
    <xsl:variable name="split" select="tokenize($ref, '_')"/>
    <xsl:variable name="ex-attr" as="attribute()*" select="(@f:hand-extent, @f:hand-text, @scribe, @medium, @script)"/>
    
    
    <xsl:copy>      
      <xsl:attribute name="f:hand-extent" select="string-length($normalized)"/>
      <xsl:attribute name="f:hand-text" select="$normalized"/>
      <xsl:attribute name="f:hand-ref" select="$ref"/>
      <xsl:attribute name="scribe" select="$split[1]"/>
      <xsl:attribute name="medium" select="$split[2]"/>
      <xsl:if test="$split[3]">
        <xsl:attribute name="script" select="$split[3]"/>      
      </xsl:if>      
      <xsl:apply-templates select="@* except $ex-attr"/>
      
      
      <xsl:if test="$ex-attr">
        <xsl:message>Overwriting old attributes: <xsl:value-of select="serialize($ex-attr)"/></xsl:message>
      </xsl:if>      
      <xsl:apply-templates select="node()"/>
    </xsl:copy>    
  </xsl:template>
  
  <xsl:template match="f:page[.//f:docTranscript/@uri]" mode="collect-hands">
    <xsl:variable name="pageno" select="count(preceding::f:page) + 1"/>
    <xsl:variable name="transcript-uri"  select="resolve-uri(.//f:docTranscript[1]/@uri, base-uri(.))"/>
    <xsl:variable name="transcript-file" select="replace($transcript-uri, 'faust://xml', $source)"/>
    <xsl:variable name="transcript" select="document($transcript-file)"/>
    <xsl:variable name="prepared">
      <xsl:apply-templates mode="prepare" select="$transcript"/>
    </xsl:variable>
    <xsl:variable name="hands" select="$transcript//(handShift/@new|*/@hand)"/>    
    <xsl:variable name="result">
      <xsl:for-each-group select="$prepared//*[@f:hand-extent]" group-by="@f:hand-ref">
        <xsl:variable name="sum" select="sum(current-group()/@f:hand-extent)"/>
        <xsl:variable name="scribe" select="@scribe"/>
        <f:hand ref="{current-grouping-key()}" scribe="{@scribe}" material="{@medium}" script="{@script}" extent="{$sum}"><!--<xsl:value-of select="id($ref, .)"/>--></f:hand>
      </xsl:for-each-group>
    </xsl:variable>
    <f:hands page="{$pageno}" total-extent="{sum($result/*/@extent)}">
      <xsl:sequence select="$result"/>      
    </f:hands>
  </xsl:template>
  
</xsl:stylesheet>