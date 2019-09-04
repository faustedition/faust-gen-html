<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:f="http://www.faustedition.net/ns"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0"
  type="f:whoami" name="whoami">
  <p:input port="source"><p:inline><doc></doc></p:inline></p:input>  
  <p:output port="result"/>
  <p:option name="paths" select="'paths.xml'"/>
  <p:serialization port="result" indent="true"/>
    
  
  <p:xslt name="whoami-xslt">
    <p:input port="stylesheet"><p:inline>
      <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0">
        <xsl:param name="xproc-pname"/>
        <xsl:param name="xproc-pversion"/>
        <xsl:param name="xproc-version"/>
        
        <xsl:import href="xslt/config.xsl"/>
        
        <xsl:template match="/">          
          <xsl:message xml:space="preserve">Information about the processing software:ca
XProc Processor
===============
<xsl:value-of select="$xproc-pname"/> Version <xsl:value-of select="$xproc-pversion"/>, supporting XProc <xsl:value-of select="$xproc-version"/>

XSLT Processor
==============
<xsl:value-of select="system-property('xsl:product-name')"/> Version <xsl:value-of select="system-property('xsl:product-version')"/>, supporting XSLT <xsl:value-of select="system-property('xsl:version')"/>

Configuration
=============
<xsl:copy-of select="f:config()"/>
          </xsl:message>
          <xsl:copy-of select="node()"/>
        </xsl:template>
      </xsl:stylesheet>
    </p:inline></p:input>
    <p:with-param name="xproc-pname" select="p:system-property('p:product-name')"/>
    <p:with-param name="xproc-pversion" select="p:system-property('p:product-version')"/>
    <p:with-param name="xproc-version" select="p:system-property('p:xproc-version')"/>
    <p:with-param name="path_config" select="$paths"/>
  </p:xslt>

  
</p:declare-step>
