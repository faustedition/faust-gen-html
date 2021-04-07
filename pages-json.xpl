<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" name="main" type="f:pages-json"
  xmlns:f="http://www.faustedition.net/ns"  
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0">
  <p:input port="source">
    <p:documentation>Transcript list</p:documentation>
  </p:input>
  <p:option name="paths" select="'paths.xml'"/>
  
  <p:output port="result" sequence="true">
    <p:empty/>
  </p:output>
  
  <p:identity name="input"/>
  
  <p:xslt name="config" template-name="param">
    <p:input port="source"><p:empty/></p:input>
    <p:input port="stylesheet"><p:document href="xslt/config.xsl"/></p:input>
    <p:with-param name="path_config" select="$paths"></p:with-param>
  </p:xslt>
  
  
  <p:xslt name="paths" template-name="config">
    <p:input port="source"><p:empty/></p:input>
    <p:input port="stylesheet"><p:document href="xslt/config.xsl"/></p:input>
    <p:with-param name="path_config" select="$paths"></p:with-param>
  </p:xslt>
    
    
  
  <p:group>
    <p:variable name="builddir" select="data(//f:builddir)"/>
    <p:variable name="html" select="data(//f:html)"/>
    <p:identity><p:input port="source"><p:pipe port="result" step="input"/></p:input></p:identity>
    
    <p:for-each>
      <p:iteration-source select="//f:textTranscript"></p:iteration-source>
      <p:variable name="sigil_t" select="/f:textTranscript/@sigil_t"/>			
      <p:load>
        <p:with-option name="href" select="resolve-uri(concat('prepared/textTranscript/', $sigil_t, '.xml'), $builddir)"/>				
      </p:load>
    </p:for-each>
    
    <p:xslt template-name="collection">
      <p:input port="parameters"><p:pipe port="result" step="config"></p:pipe></p:input>
      <p:input port="stylesheet"><p:document href="xslt/pagelist.xsl"/></p:input>
    </p:xslt>
    
    <p:store method="text" media-type="application/json">
      <p:with-option name="href" select="resolve-uri('pages.json', resolve-uri($html))"/>			
    </p:store>
  
  </p:group>
  
  
</p:declare-step>