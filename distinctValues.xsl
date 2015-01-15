<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="text"/>

  <xsl:key name="attributes" match="@*" use="name()"/>
  <xsl:key name="elements" match="*" use="name()"/>

  <xsl:template match="/">
    <xsl:text>
      
  Elemente:

    </xsl:text>
    <xsl:for-each select="//*[generate-id(.)=generate-id(key('elements',name())[1])]">
      <xsl:sort select="name()"/>
      <xsl:for-each select="key('elements', name())">
        <xsl:if test="position()=1">
          <xsl:value-of select="name()"/>
          <xsl:text>
    </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each>

    <xsl:text>

  Attribute:

    </xsl:text>
    <xsl:for-each select="descendant-or-self::*//@*[generate-id(.)=generate-id(key('attributes',name())[1])]">
      <xsl:sort select="name()"/>
      <xsl:for-each select="key('attributes', name())">
        <xsl:if test="position()=1">
          <xsl:value-of select="name()"/>
          <xsl:text>
    </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>
    
</xsl:stylesheet>
