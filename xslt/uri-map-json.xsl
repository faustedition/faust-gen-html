<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace="http://www.faustedition.net/ns"
  xmlns:f="http://www.faustedition.net/ns"
  xmlns:j="http://www.faustedition.net/ns/json"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:ge="http://www.tei-c.org/ns/geneticEditions"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <xsl:import href="jsonutils.xsl"/>
  <xsl:import href="utils.xsl"/>
  
  <xsl:param name="document"/>
  <xsl:param name="source"/>
  <xsl:param name="source-resolved" select="resolve-uri($source)"/>
  <xsl:param name="builddir">../../../../target/</xsl:param>
  <xsl:param name="builddir-resolved" select="resolve-uri($builddir)"/>
  
  
  <!-- Iterate over collection. -->	
  <xsl:template name="collection">
    <xsl:variable name="json">
      <j:array>
        <xsl:for-each select="collection()/*">
          <xsl:call-template name="document"/>
        </xsl:for-each>      
      </j:array>      
    </xsl:variable>
    <f:json>
      <xsl:apply-templates select="$json"/>
    </f:json>
  </xsl:template>


  <xsl:template name="document">
    <j:object>
      <xsl:variable name="sigil" select="//idno[@type='faustedition']"/>
      <j:string name="sigil" value="{$sigil}"/>
      <j:string name="sigil_t" value="{f:sigil-for-uri($sigil)}"/>
      <j:string name="uri" value="faust://document/faustedition/{f:sigil-for-uri($sigil)}"/>
      <j:object name="other_sigils">
        <xsl:for-each select=".//idno[@type != 'faustedition'][. != ('none', 'n.s.')]">
          <j:string name="faust://document/{@type}/{f:sigil-for-uri(.)}" value="{.}"/>
        </xsl:for-each>
      </j:object>
        <xsl:variable name="base-uri" select="base-uri(//textTranscript)"/>
        <xsl:choose>
          <xsl:when test="$base-uri != ''">
            <!--<xsl:variable name="transcript-uri" select="resolve-uri(//textTranscript/@uri, $base-uri)"/>
            <xsl:variable name="transcript-path" select="replace($transcript-uri, '^faust://xml/', $source-resolved)"/>-->
            <xsl:variable name="sigil_t" select="f:sigil-for-uri(//idno[@type='faustedition'])"/>
            <xsl:variable name="transcript-path" select="resolve-uri(concat('prepared/textTranscript/', $sigil_t, '.xml'), $builddir-resolved)"/>
            <xsl:choose>
              <xsl:when test="doc-available($transcript-path)">
                <xsl:variable name="text" select="document($transcript-path)"/>
                <j:array name="inscriptions" dropempty="true">
                  <xsl:variable name="inscriptions" select="$text//ge:stageNote[@type='segment']"/>
                  <xsl:for-each select="$inscriptions">
                    <j:string value="{@xml:id}"/>
                  </xsl:for-each>            
                </j:array>
                <j:number name="min-verse" value="{$text/tei:TEI/tei:text/@f:min-verse}" dropempty="true"/>
                <j:number name="max-verse" value="{$text/tei:TEI/tei:text/@f:max-verse}" dropempty="true"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:message select="concat($sigil, ': Textual Transcript ', $transcript-path, ' not found.')"/>
              </xsl:otherwise>
            </xsl:choose>                    
          </xsl:when>
          <xsl:otherwise>
            <xsl:message select="concat($sigil, ': No textual transcript')"/>
          </xsl:otherwise>          
        </xsl:choose>        
      <j:string name="type" value="{local-name(/*)}"/>
    </j:object>
  </xsl:template>
  
</xsl:stylesheet>