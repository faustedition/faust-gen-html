<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xmlns:f="http://www.faustedition.net/ns">
  <xsl:import href="config.xsl"/>
  
  <xsl:template match="/">
    <xsl:sequence select="f:config()"></xsl:sequence>
  </xsl:template>
</xsl:stylesheet>