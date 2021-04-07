<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns:f="http://www.faustedition.net/ns"  
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:ge="http://www.tei-c.org/ns/geneticEditions"
  xmlns="http://www.w3.org/1999/xhtml"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <xsl:import href="html-frame.xsl"/>
  <xsl:import href="html-common.xsl"/>    
  <xsl:import href="split.xsl"/>
  
  <xsl:param name="document"/>
  <xsl:param name="source"/>
  <xsl:param name="source-resolved" select="f:safely-resolve($source)"/>
  <xsl:param name="builddir">../../../../target/</xsl:param>
  <xsl:param name="builddir-resolved" select="f:safely-resolve($builddir)"/>

  <xsl:function name="f:shorten" as="xs:string">
    <xsl:param name="text" as="item()*"/>
    <xsl:param name="len" as="xs:integer"/>
    <xsl:variable name="text" select="string-join(for $item in $text return normalize-space($item), ' ')"/>
    <xsl:choose>
      <xsl:when test="string-length($text) > $len">
        <xsl:value-of select="concat(substring($text, 1, 50), '…')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$text"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!-- Iterate over collection. -->	
  <xsl:template name="collection">
    <xsl:call-template name="html-frame">
      <xsl:with-param name="content">
        <table class="pure-table sortable">
          <thead>
            <th>Zeuge</th>
            <th>Nr.</th>
            <th title="Paralipomenon, @n, ID oder Label">ID</th>
            <th>erster Vers</th>
            <th>letzter Vers</th>
            <th>Incipit</th>
            <th title="normale divs davor/danach • XPath">Kontext</th>
          </thead>
          <tbody>
            <xsl:apply-templates select="collection()"/>
          </tbody>
        </table>
      </xsl:with-param>
      <xsl:with-param name="breadcrumb-def" tunnel="yes">
        <a>div type='stueck'</a>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="/">
    <xsl:variable name="other-divs" select="descendant::div[not(ancestor-or-self::*[@type='stueck'])]"/>
    <xsl:for-each select="descendant::*[@type='stueck']">
      <xsl:variable name="section" select="f:get-section-number(.)"/>      
      <tr>
        <td><a href="/document?sigil={//id('sigil_t')}{if ($section) then concat('&amp;section=', $section) else ()}{if (@xml:id) then concat('#', @xml:id) else ()}">
          <xsl:value-of select="id('sigil')"/>
        </a></td>
        <td><xsl:number count="*[@type='stueck']" from="/" level="any"/></td>
        <td>
          <xsl:choose>
            <xsl:when test="descendant::milestone[@unit='paralipomenon']">
              <xsl:for-each select="descendant::milestone[@unit='paralipomenon']">
                <a href="{f:link-to(.)/@href}">
                  <xsl:value-of select="replace(@n, '^p', 'P ')"/>                   
                </a>
                <xsl:if test="position() != last()">, </xsl:if>                
              </xsl:for-each>
            </xsl:when>
            <xsl:when test="@n">n=<xsl:value-of select="@n"/></xsl:when>
            <xsl:when test="@xml:id">#<xsl:value-of select="@xml:id"/></xsl:when>            
            <xsl:when test="@f:label"><xsl:value-of select="f:shorten(@f:label, 50)"/></xsl:when>
          </xsl:choose>
        </td>
        <td><xsl:value-of select="(descendant::*/@f:schroer)[1]"/></td>
        <td><xsl:value-of select="(descendant::*/@f:schroer)[position() = last()]"/></td>
        <td><xsl:value-of select="f:shorten(*, 50)"/></td>
        <td>
          <xsl:value-of select="count(preceding::div[not(ancestor-or-self::div[@type='stueck'])])"/> /
          <xsl:value-of select="count(following::div[not(ancestor-or-self::div[@type='stueck'])])"/> •
          <code><xsl:value-of select="f:xpath(.)"/></code>
          <xsl:if test="/*/@f:split = 'true'"><mark>split!</mark></xsl:if>
        </td>
      </tr>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:function name="f:xpath">
    <xsl:param name="el"/>
    <xsl:variable name="steps">
      <xsl:text>/</xsl:text>      
      <xsl:for-each select="$el/ancestor-or-self::*">
        <xsl:variable name="parts" as="item()*">
          <xsl:variable name="name" select="name()"/>
          <xsl:value-of select="$name"/>
          <xsl:variable name="pos" select="count(preceding-sibling::*[name() = $name]) + 1"/>
          <xsl:variable name="more" select="count(following-sibling::*[name() = $name])"/>
          <xsl:if test='$pos + $more gt 1'>
            <xsl:value-of select="concat('[', $pos, ']')"/>
          </xsl:if>
          <xsl:if test="not(. is $el)">/</xsl:if>
        </xsl:variable>
        <xsl:value-of select="$parts" separator=""/>        
      </xsl:for-each>      
    </xsl:variable>
    <xsl:value-of select="$steps" separator=""/>
  </xsl:function>

  
</xsl:stylesheet>
