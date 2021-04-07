<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0" xmlns:f="http://www.faustedition.net/ns">
  
  <xsl:param name="path_config"/>

  <xsl:function name="f:safely-resolve">
    <xsl:param name="uri"/>
    <xsl:choose>
      <xsl:when test="empty(static-base-uri())">
        <xsl:value-of select="$uri"/>   <!-- eXist special case -->
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="resolved" select="resolve-uri($uri)"/>
        <xsl:variable name="result" select="if (ends-with($resolved, '/') or matches($resolved, '\.[^/.]{1,5}$')) then $resolved else concat($resolved, '/')"/>
        <xsl:if test="not(starts-with($uri, '/') or starts-with($uri, 'file:/'))">
          <xsl:message select="concat('WARNING: Configured non-absolute path ', $uri, ' resolved to ', $result, '&#10;')"/>
        </xsl:if>
        <xsl:sequence select="$result"/>        
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="f:safely-resolve">
    <xsl:param name="relative"/>
    <xsl:param name="base"/>
    <xsl:choose>
      <xsl:when test="empty(static-base-uri())">
        <xsl:sequence select="if (ends-with('/', $base)) then concat($base, $relative) else concat($base, '/', $relative)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="resolve-uri($relative, $base)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:template name="_internal_config">
    <xsl:variable name="paths_xml">
      <xsl:choose>
        <xsl:when test="$path_config != '' and not(doc-available($path_config))"><xsl:message terminate="yes">Someone passed us an invalid $path_config=<xsl:value-of select="$path_config"/></xsl:message></xsl:when>
        <xsl:when test="$path_config"><xsl:sequence select="doc($path_config)"/></xsl:when>
        <xsl:when test="doc-available('../paths.xml')"><xsl:sequence select="doc('../paths.xml')"/></xsl:when>
        <xsl:otherwise>
          <xsl:message terminate="yes">Path configuration not found: $path_config not set and <xsl:value-of select="f:safely-resolve('../paths.xml')"/> does not exist.</xsl:message>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
        
    
    <xsl:variable name="source" select="f:safely-resolve($paths_xml//f:source)"/>
    <xsl:variable name="builddir" select="f:safely-resolve($paths_xml//f:builddir)"/>
    
    <xsl:if test="not($source)">
      <xsl:message>ERROR: $source is empty! $path_config=<xsl:value-of select="$path_config"/>, $paths_xml:<xsl:copy-of select="$paths_xml"/></xsl:message>
    </xsl:if>
    
    <f:config>      
      <f:source><xsl:value-of select="$source"/></f:source>  
      <f:builddir><xsl:value-of select="$builddir"/></f:builddir>
      <f:www><xsl:value-of select="$builddir"/>/www/</f:www>
      <f:html><xsl:value-of select="f:safely-resolve('www/print/', $builddir)"/></f:html>
      <f:apphtml><xsl:value-of select="f:safely-resolve('www/app/', $builddir)"/></f:apphtml>
      <f:metahtml><xsl:value-of select="f:safely-resolve('www/meta/', $builddir)"/></f:metahtml>
      <f:path_config><xsl:value-of select="f:safely-resolve($path_config)"/></f:path_config>
      <!-- To be expanded -->
    </f:config>    
  </xsl:template>
  
  <xsl:function name="f:config"><xsl:call-template name="_internal_config"/></xsl:function>
  
  <xsl:template name="param">
    <c:param-set xmlns:c="http://www.w3.org/ns/xproc-step">
      <xsl:for-each select="f:config()//*">
        <c:param name="{local-name()}" value="{.}"/>
      </xsl:for-each>
    </c:param-set>
  </xsl:template>
  
  <xsl:template name="config">
    <xsl:sequence select="f:config()"/>
  </xsl:template>
  
</xsl:stylesheet>