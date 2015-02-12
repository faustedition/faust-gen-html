<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:f="http://www.faustedition.net/ns"
  xmlns:ge="http://www.tei-c.org/ns/geneticEditions" xmlns:svg="http://www.w3.org/2000/svg"
  xmlns="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xs" version="2.0">

  <xsl:param name="href" select="document-uri(/)"/>
  <xsl:param name="base"/>
  
  <xsl:output indent="yes"/>

  <xsl:function name="f:normalize-n">
    <xsl:param name="n"/>
    <xsl:value-of select="replace($n, '\D*(\d+).*', '$1')"/>
  </xsl:function>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="l|speaker|stage|head">
    <xsl:copy>
      <xsl:apply-templates select="@* except @n"/>
      <xsl:variable name="n" select="f:normalize-n(@n)"/>
      <xsl:attribute name="n" select="$n"/>
      <xsl:if test="$n != @n">
        <xsl:attribute name="f:n" select="@n"/>
      </xsl:if>
      <xsl:attribute name="f:src" select="$href"/>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/">
    <f:lines>
      <xsl:if test="$base">
        <xsl:attribute name="xml:base" select="$base"/>
      </xsl:if>
      <xsl:apply-templates select="//(l|speaker|stage|head)[@n]"/>
    </f:lines>
  </xsl:template>

</xsl:stylesheet>
