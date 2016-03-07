<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:f="http://www.faustedition.net/ns"
  xmlns:pxf="http://exproc.org/proposed/steps/file"  
  xmlns:l="http://xproc.org/library" type="f:metadata-js" name="main" version="1.0">

  <p:input port="source"><p:empty/></p:input>
  <p:input port="parameters" kind="parameter"/>
  
  

  <p:import href="http://xproc.org/library/recursive-directory-list.xpl"/>
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

  <!-- Parameter laden -->
  <p:parameters name="config">
    <p:input port="parameters">
      <p:document href="config.xml"/>
      <p:pipe port="parameters" step="main"></p:pipe>
    </p:input>
  </p:parameters>

  <p:group>
    <p:variable name="metahtml" select="//c:param[@name='metahtml']/@value"><p:pipe port="result" step="config"></p:pipe></p:variable>
    <p:variable name="source" select="//c:param[@name='source']/@value"><p:pipe port="result" step="config"/></p:variable>
    <p:variable name="debug" select="//c:param[@name='debug']/@value"><p:pipe port="result" step="config"/></p:variable>
    <p:variable name="builddir" select="resolve-uri(//c:param[@name='builddir']/@value)"><p:pipe port="result" step="config"/></p:variable>
    <cx:message log="info">  
      <p:input port="source"><p:pipe port="source" step="main"></p:pipe></p:input>      
      <p:with-option name="message" select="concat('Collecting metadata from ', $source)"/>
    </cx:message>
        


    <l:recursive-directory-list>
      <p:with-option name="path" select="concat($source, '/document')"/>
    </l:recursive-directory-list>

    <p:for-each name="convert-metadata">
      <p:iteration-source select="//c:file[$debug or not(ends-with(@name, 'test.xml'))]"/>
      <p:variable name="filename" select="p:resolve-uri(/c:file/@name)"/>
      <p:variable name="basename" select="replace(replace($filename, '.*/', ''), '.xml$', '')"/>
      <p:variable name="outfile" select="concat($metahtml, $basename, '.html')"/>
            
      <p:load>
        <p:with-option name="href" select="$filename"/>
      </p:load>

      <p:xslt name="generate-html">
        <p:input port="stylesheet"><p:document href="xslt/metadata2json.xsl"/></p:input>
        <p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
        <p:with-param name="document" select="replace($filename, $source, '')"/>
      </p:xslt>
    </p:for-each>
    
    <p:wrap-sequence wrapper="f:json"/>
    
    <p:xslt>
      <p:input port="parameters"><p:pipe port="result" step="config"></p:pipe></p:input>
      <p:input port="stylesheet">
        <p:inline>
          <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
            <xsl:template match="/f:json">
              <f:json>
              <xsl:text>var documentMetadata = {"metadata":[</xsl:text>
              <xsl:value-of select="string-join(f:document/text(), ',')"/>                
              <xsl:text>],"metadataPrefix":"faust://xml/document/","linkPrefix":"faust://xml/image-text-links/","imgPrefix":"faust://facsimile/","printPrefix":"faust://xml/print/","basePrefix":"faust://xml/"}</xsl:text>
                      
              </f:json>
            </xsl:template>
          </xsl:stylesheet>
        </p:inline>
      </p:input>
    </p:xslt>
    
    <p:store method="text">
      <p:with-option name="href" select="p:resolve-uri(concat($builddir, '/www/data/document_metadata.js'))"/>
    </p:store>
      
  </p:group>

</p:declare-step>
