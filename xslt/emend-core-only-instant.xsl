<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:f="http://www.faustedition.net/ns"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <xsl:import href="unemend-core.xsl"/>
  
  <xsl:template match="del[contains(@f:revType, 'instant')]" priority="2">
    <xsl:apply-templates mode="del-emend"/>    
  </xsl:template>
  
  <xsl:template match="add[contains(@f:revType, 'instant')]" priority="2">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:template match="subst[contains(@f:revType, 'instant')]" priority="2">
    <xsl:apply-templates select="add/node()"/>
  </xsl:template>
  
  <xsl:template mode="del-emend" match="node()">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  
  <xsl:template mode="del-emend" match="restore">
    <xsl:apply-templates/>
  </xsl:template> 
  
</xsl:stylesheet>