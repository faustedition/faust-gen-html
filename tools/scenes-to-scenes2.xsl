<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  exclude-result-prefixes="xs"
  xmlns="http://www.faustedition.net/ns"
  xpath-default-namespace="http://www.faustedition.net/ns"
  version="2.0">
  
  <xsl:strip-space elements="*"/>
  <xsl:output method="xml" indent="yes"/>
  
  <xsl:template match="/sceneLineMapping">
    <xsl:processing-instruction name="xml-model">href="scenes.rnc" type="application/relax-ng-compact-syntax"</xsl:processing-instruction>
    <scene-info>
      
      <xsl:apply-templates select="scene[starts-with(@n, '1.0')]"/>
      
      <part n="1">
        <title>Der Tragödie erster Teil</title>
        <xsl:apply-templates select="scene[starts-with(@n, '1.1')]"/>
      </part>
      
      <part n="2" title="Der Tragödie zweiter Teil">
        <xsl:variable name="context" select="."/>
        <xsl:for-each select="1 to 5">
          <xsl:variable name="act" select="."/>
          <act n="2.{$act}">
            <xsl:apply-templates select="$context/scene[starts-with(@n, concat('2.', $act))]"/>
          </act>
        </xsl:for-each>
      </part>
    </scene-info>
  </xsl:template>
  
  <xsl:template match="scene">
    <scene n="{@n}" first-line="{rangeStart}" last-line="{rangeEnd}">
      <title><xsl:value-of select="title"/></title>
    </scene>
  </xsl:template>
  
</xsl:stylesheet>
