<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   exclude-result-prefixes="xs"
   version="2.0"
   xpath-default-namespace="http://www.tei-c.org/ns/1.0">
   
   <!--<xsl:output indent="yes"/>-->
   
   <xsl:template match="*" mode="#default ws-munge">
      <xsl:copy>
         <xsl:copy-of select="@*"/>
         <xsl:apply-templates select="." mode="ws-handle"/>
      </xsl:copy>
   </xsl:template>
   
   <xsl:template match="div" mode="ws-handle">
      <xsl:call-template name="element-only"/>
   </xsl:template>
   
   <xsl:template match="pre" mode="ws-handle">
      <xsl:call-template name="ws-preserve"/>
   </xsl:template>
   
   <xsl:template match="* | p | item" mode="ws-handle">
      <xsl:call-template name="ws-munge"/>
   </xsl:template>
   
   <xsl:template name="element-only">
      <xsl:apply-templates select="node() except text()"/>
   </xsl:template>
   
   <xsl:template name="ws-preserve">
      <xsl:apply-templates/>
   </xsl:template>
   
   <xsl:template name="ws-munge">
      <xsl:apply-templates mode="ws-munge"/>
   </xsl:template>
   
   <xsl:template mode="ws-munge" priority="2"
      match="text()[empty(../node() except (.|../(comment() | processing-instruction())))]">
      <xsl:value-of select="normalize-space(string(.))"/>
   </xsl:template>
   
   <xsl:template mode="ws-munge"
      match="text()[empty(preceding-sibling::node() except ../(comment() | processing-instruction()))]">
      <xsl:variable name="trimmed-before" select="replace(.,'^\s+','')"/>
      <xsl:value-of select="replace($trimmed-before,'\s+',' ')"/>
   </xsl:template>
   
   <xsl:template mode="ws-munge"
      match="text()[empty(following-sibling::node() except ../(comment() | processing-instruction()))]">
      <xsl:variable name="trimmed-after" select="replace(.,'\s+$','')"/>
      <xsl:value-of select="replace($trimmed-after,'\s+',' ')"/>
   </xsl:template>
   
   <xsl:template mode="ws-munge" match="text()">
      <xsl:value-of select="replace(.,'\s+',' ')"/>
   </xsl:template>
   
   <xsl:template mode="#all" match="comment() | processing-instruction()">
      <xsl:copy-of select="."/>
   </xsl:template>
   
</xsl:stylesheet>