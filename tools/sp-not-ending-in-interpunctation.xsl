<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <!-- Identitätstransformation ... -->
  <xsl:template match="node()|@*">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates mode="#current" select="@*, node()"/>
    </xsl:copy>
  </xsl:template>
  
  <!-- Apparat raus -->
  <xsl:template match="note[@type='textcrit']"/>
  
  <!-- Terminale sp raus -->
  <xsl:template match="sp/stage[position()=last()]"/>
  
  <xsl:template match="/">
    <xsl:variable name="cleaned-text">
      <xsl:apply-templates/>
    </xsl:variable>
    
    <!-- letztes Element in sp, das nach whitespacenormalisierung auf buchstabe oder zahl (\w) endet: -->
    <xsl:for-each select="$cleaned-text//sp/*[position()=last()][matches(normalize-space(.), '\w$')]">
      <xsl:text>&#10;###########&#10;</xsl:text>
      <xsl:copy-of select="."/>
    </xsl:for-each>
    
  </xsl:template>
  
</xsl:stylesheet>