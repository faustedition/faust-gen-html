<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:f="http://www.faustedition.net/ns"
  xmlns:l="http://xproc.org/library" 
  type="f:list-transcripts" version="1.0">
  
  <p:input port="source">
    <p:empty/>
  </p:input>
  <p:option name="root" select="'/home/vitt/Faust/'"/>
  <p:output port="result"/>
  <p:serialization port="result" indent="true"/>
  
  <p:documentation>
    Dieser Pipelineschritt lädt alle Metadaten (aus dem document-Unterverzeichnis des Verzeichnisses, das über die Option $root angegeben wird),
    und erzeugt eine Liste der darin referenzierten Transcripte.
    
    Das Ergebnis ist eine XML-Datei aus f:textTranscript-Elementen mit den Attributen @uri (= Faust-URI) und @href (=aufgelöster Pfad relativ zu $root)
    und als Kindelementen 
  </p:documentation>

  <!--<p:serialization port="result" indent="true"/>-->

  <p:import href="http://xproc.org/library/recursive-directory-list.xpl"/>
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

  <l:recursive-directory-list>
    <p:with-option name="path" select="'file:///home/vitt/Faust/document'"/>
  </l:recursive-directory-list>

  <p:for-each>
    <p:iteration-source select="//c:file"/>
    <p:variable name="filename" select="p:resolve-uri(/c:file/@name)"/>
    
    
    <p:load>
      <p:with-option name="href" select="$filename"/>
    </p:load>
    
    <p:xslt>
      <p:input port="stylesheet">
        <p:inline>
          <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
            xmlns="http://www.faustedition.net/ns" xpath-default-namespace="http://www.faustedition.net/ns"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:f="http://www.faustedition.net/ns"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            exclude-result-prefixes="c tei xsi l">
            
            <xsl:import href="utils.xsl"/>
            
            <xsl:param name="root"/>            
            
            <xsl:template match="/">
              <f:transcript>
                <xsl:apply-templates select="//f:textTranscript"/>
              </f:transcript>
            </xsl:template>
            
            <xsl:template match="f:textTranscript[@uri]">
              <xsl:copy>
                <xsl:variable name="uri" select="resolve-uri(@uri, (ancestor-or-self::*/@xml:base)[1])"></xsl:variable>
                <xsl:attribute name="uri" select="$uri"/>
                <xsl:attribute name="document" select="f:relativize($root, document-uri(/))"/>
                <xsl:variable name="file" select="replace($uri, '^faust://xml/', $root)"/>
                <xsl:variable name="href" select="if (ends-with($file, '.xml')) then $file else concat($file, '.xml')"/>
                <xsl:attribute name="href" select="$href"/>
                <xsl:if test="not(doc-available($href))">
                  <xsl:message select="concat('WARNING: Referenced transcript is missing: ', $href, ' (referred to from ', document-uri(/), ')')"/>
                </xsl:if>
                <xsl:attribute name="f:sigil">
                  <xsl:choose>
                    <xsl:when test="../f:idno[@type='wa_faust'] and ../f:idno[@type='wa_faust'] != 'none'">
                      <xsl:value-of select="../f:idno[@type='wa_faust']"/>
                    </xsl:when>
                    <xsl:when test="../f:idno[@type='bohnenkamp']">
                      <xsl:value-of select="../f:idno[@type='bohnenkamp']"/>
                    </xsl:when>
                    <xsl:when test="../f:idno">
                      <xsl:value-of select="../f:idno[1]"/>
                    </xsl:when>
                    <xsl:otherwise>???</xsl:otherwise>
                  </xsl:choose>
                </xsl:attribute>
                <xsl:copy-of select="../f:idno"/>
              </xsl:copy>
            </xsl:template>                  
            
          </xsl:stylesheet>
        </p:inline>
      </p:input>
      <p:with-param name="root" select="$root"/>
    </p:xslt>
           
  </p:for-each>

  <p:wrap-sequence wrapper="f:doc"/>
    
  
</p:declare-step>
