<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:f="http://www.faustedition.net/ns"
  xmlns:ge="http://www.tei-c.org/ns/geneticEditions" xmlns:svg="http://www.w3.org/2000/svg"
  xmlns="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xs" version="2.0">

  <xsl:param name="href" select="document-uri(/)"/>
  <xsl:param name="base"/>
  <xsl:param name="documentURI"/>
  <xsl:param name="sigil"/>
  <xsl:param name="sigil-type"/>
  <xsl:param name="type"/>
  
  
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

  <xsl:template match='*[@n]'>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>      
      <xsl:attribute name="f:doc" select="$documentURI"/>
      <xsl:attribute name="f:href" select="$href"/>
      <xsl:attribute name="f:sigil" select="$sigil"/>
      <xsl:attribute name="f:sigil-type" select="$sigil-type"/>
      <xsl:attribute name="f:page" select="( preceding::pb | descendant::pb)[1]/@n"/>
      <xsl:attribute name="f:type" select="$type"/>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/">
    <f:lines>
      <xsl:if test="$base">
        <xsl:attribute name="xml:base" select="$base"/>
      </xsl:if>
      <xsl:apply-templates select='//*[@n and not(self::pb or self::div or self::milestone[@unit="paralipomenon"] or self::milestone[@unit="cols"] or @n[contains(.,"todo")] or @n[contains(.,"p")])]'/>
    </f:lines>
  </xsl:template>

</xsl:stylesheet>
