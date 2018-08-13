<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.tei-c.org/ns/1.0"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <!-- This script adds a changenote to the TEI header's revisionDesc, adding the latter if required -->
  
  <xsl:param name="changenote"/>
  <xsl:param name="changenote-who">faust-gen-html</xsl:param>
  <xsl:param name="changenote-when" select="format-date(current-date(), '[Y0001]-[M01]-[D01]')"/>
  <xsl:param name="changenote-type"/>  
     
  <xsl:template match="revisionDesc">
    <xsl:choose>
      <xsl:when test="$changenote">
        <xsl:copy>
          <xsl:copy-of select="@*" copy-namespaces="no"/>
          <xsl:apply-templates/>
          <xsl:call-template name="create-change"/>          
        </xsl:copy>        
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>        
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="teiHeader[not(revisionDesc)]">
    <xsl:choose>
      <xsl:when test="$changenote">
        <xsl:copy>
          <xsl:apply-templates select="@*, node()"/>
          <revisionDesc>
            <xsl:call-template name="create-change"/>
          </revisionDesc>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="create-change">
    <change who="{$changenote-who}" when="{$changenote-when}">
      <xsl:if test="$changenote-type">
        <xsl:attribute name="type" select="$changenote-type"/>
      </xsl:if>
      <xsl:sequence select="$changenote"/>
    </change>
  </xsl:template>
  
  
  <xsl:template match="node() | @*">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>