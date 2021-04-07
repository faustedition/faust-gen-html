<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:f="http://www.faustedition.net/ns"
  name="main" type="f:bargraph"
  version="1.0">
  <p:input port="source">
    <p:documentation>sorted transcript list</p:documentation>
  </p:input>
  <p:output port="result" sequence="true"><p:empty/>
  </p:output>
  <p:option name="paths" select="resolve-uri('paths.xml')"/>
    
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  
  <!-- Parameter laden -->
  <p:xslt name="config" template-name="param">
    <p:input port="source"><p:empty/></p:input>
    <p:input port="stylesheet"><p:document href="xslt/config.xsl"/></p:input>
    <p:with-param name="path_config" select="$paths"></p:with-param>
  </p:xslt>
  
  <p:group>
    <p:variable name="builddir" select="//c:param[@name='builddir']/@value"><p:pipe port="result" step="config"/></p:variable>
  
    <p:for-each>
      <p:iteration-source select="//f:textTranscript[@type != 'lesetext' and not(contains(@document, 'test.xml'))]">
        <p:pipe port="source" step="main"/>
      </p:iteration-source>
      <p:variable name="sigil_t" select="/f:textTranscript/@sigil_t"/>
      
      <p:load>
        <p:with-option name="href" select="resolve-uri(concat('prepared/textTranscript/', $sigil_t, '.xml'), $builddir)"/>
      </p:load>
      
      <p:xslt name="bargraph-info">
        <p:input port="stylesheet"><p:document href="xslt/create-bargraph-info.xsl"/></p:input>
        <p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
      </p:xslt>
       
    
    </p:for-each>
    
    <p:wrap-sequence wrapper="f:documents"/>
    
    <p:xslt>
      <p:input port="stylesheet">
        <p:inline>
          <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
            <xsl:strip-space elements="*"/>
            <xsl:output method="text"/>
            <xsl:template match="/*">
              <wrapper>
                <xsl:text>[</xsl:text>
                <xsl:for-each select="*">
                  <xsl:value-of select="."/>
                  <xsl:if test="position() != last()">,</xsl:if>
                </xsl:for-each>
                <xsl:text>]</xsl:text>
              </wrapper>
            </xsl:template>
          </xsl:stylesheet>
        </p:inline>
      </p:input>
      <p:input port="parameters"><p:empty/></p:input>
    </p:xslt>
    
    <p:store method="text">
      <p:with-option name="href" select="resolve-uri('www/data/genetic_bar_graph.json', $builddir)"/>
    </p:store>
  
  </p:group>

  
</p:declare-step>