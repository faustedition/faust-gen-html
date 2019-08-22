<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:f="http://www.faustedition.net/ns"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0">
  <p:input port="source">
    <p:inline>
      <doc>Hello world!</doc>      
    </p:inline>
  </p:input>
  <p:output port="result"/>
  <p:option name="paths" select="'paths.xml'"/>
  <p:identity/>
  
  <p:xslt>    
    <p:input port="stylesheet">
      <p:inline><xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
        <xsl:import href="xslt/config.xsl"/>
        <xsl:template match="/">
          <xsl:copy-of select="f:config()"/>
        </xsl:template>
      </xsl:stylesheet></p:inline>
    </p:input>
    <p:with-param name="path_config" select="$paths"/>
  </p:xslt>
  
</p:declare-step>