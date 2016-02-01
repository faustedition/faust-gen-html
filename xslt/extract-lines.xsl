<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:f="http://www.faustedition.net/ns"
  xmlns:ge="http://www.tei-c.org/ns/geneticEditions" xmlns:svg="http://www.w3.org/2000/svg"
  xmlns="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xs" version="2.0">

  <xsl:param name="href" select="document-uri(/)"/>
  <xsl:param name="source"/>
  <xsl:param name="documentURI"/>
  <xsl:param name="sigil"/>
  <xsl:param name="sigil-type"/>
  <xsl:param name="type"/>
  
  
  
  <xsl:variable name="metadata" select="document(resolve-uri($documentURI, $source))"/>
  
  <xsl:variable name="document-id" select="//teiHeader//idno[@type='fausttranscript']" as="xs:string"/>
  
  <xsl:function name="f:getPageNo">
    <xsl:param name="refs"/>
    <xsl:for-each select="tokenize($refs, '\s+')">
      <xsl:variable name="n" select="."/>
      <xsl:variable name="pattern" select="concat('0*(', $n, ')(\.xml)?')"/>
      <xsl:variable name="pageElem" select="$metadata//f:docTranscript[matches(@uri, $pattern)]/ancestor::f:page[1]"/>
      <xsl:variable name="pageNo">
        <xsl:for-each select="$pageElem[1]">
          <xsl:number format="1" level="any" from="f:archivalDocument|f:print"/>
        </xsl:for-each>
      </xsl:variable>
      <xsl:message select="concat($documentURI, ': for ', $n, ' in ', string-join($refs, ' '), ' found ', string-join(for $i in $pageNo return string($i), ' '))"/>
      <xsl:value-of select="$pageNo"/>
    </xsl:for-each>
  </xsl:function>
  
  
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
      <xsl:variable name="pb" select="(preceding::pb[1] | descendant::pb[1])[1]"/>
      <xsl:if test="$pb">
        <xsl:attribute name="f:page-n" select="$pb/@n"/>
        <xsl:attribute name="f:page" select="$pb/@f:docTranscriptNo"/>
      </xsl:if>      
      <xsl:attribute name="f:type" select="$type"/>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/">
    <f:lines>
      <xsl:if test="$source">
        <xsl:attribute name="xml:base" select="$source"/>
      </xsl:if>
      <f:standoff>
        <xsl:apply-templates select="//alt|//ge:transposeGrp|//join"/>
      </f:standoff>
      <xsl:apply-templates select='//*[@n and not(self::pb or self::div or self::milestone[@unit="paralipomenon"] or self::milestone[@unit="cols"] or @n[contains(.,"todo")] or @n[contains(.,"p")])]'>
        <xsl:sort select="f:normalize-n(@n)"/>
      </xsl:apply-templates>
    </f:lines>
  </xsl:template>
  
  <xsl:template match="@xml:id">
    <xsl:attribute name="xml:id" select="concat(., '.', $document-id)"/>
  </xsl:template>
  <xsl:template match="@target|@targets|@href">
    <xsl:attribute name="{name(.)}" select="
      string-join(
      for $target in tokenize(., '\s+') 
        return if (starts-with(., '#')) 
          then concat($target, '.', $document-id) 
          else .,
       ' ')"/>
  </xsl:template>

</xsl:stylesheet>
