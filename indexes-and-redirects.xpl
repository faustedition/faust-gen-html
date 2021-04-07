<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 	xmlns:f="http://www.faustedition.net/ns"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  type="f:indexes-and-redirects" name="indexes-and-redirects"
  version="1.0">
  <p:input port="source">
    <p:documentation>List of Transcripts</p:documentation>
  </p:input>
  <p:output port="result" sequence="true"><p:empty/></p:output>
  <p:option name="paths" select="'paths.xml'"/>
  
  <p:identity name="save-transcripts"/>
  
  
  <!-- Konfiguration laden -->
  <p:xslt name="config" template-name="param">
    <p:input port="source"><p:empty/></p:input>
    <p:input port="stylesheet"><p:document href="xslt/config.xsl"/></p:input>
    <p:with-param name="path_config" select="$paths"></p:with-param>
  </p:xslt>
  
  <p:group>
    <p:variable name="builddir" select="//c:param[@name='builddir']/@value"/>

    <!-- ## Step 2c: prints index -->
    <p:xslt>
      <p:input port="source"><p:pipe port="result" step="save-transcripts"/></p:input>			
      <p:input port="stylesheet"><p:document href="xslt/prints-index.xsl"/></p:input>
      <p:with-param name="path_config" select="$paths"/>
    </p:xslt>
    <p:store method="xhtml" indent="true">
      <p:with-option name="href" select="resolve-uri('www/archive_prints.html', $builddir)"/>
    </p:store>
    
    
    
    <!-- ## Step 2e: Redirect-Tabellen für /print /meta /app -->
    <p:xslt>
      <p:input port="source"><p:pipe port="result" step="save-transcripts"></p:pipe></p:input>			
      <p:input port="stylesheet"><p:document href="xslt/generate-htaccess.xsl"/></p:input>			
      <p:with-param name="rewrite-base" select="'/print'"/>
      <p:with-param name="old-source" select="'texttranscript'"/>
    </p:xslt>
    <p:store method="text"><p:with-option name="href" select="resolve-uri('www/print/.htaccess', $builddir)"/></p:store>
    
    <p:xslt>
      <p:input port="source"><p:pipe port="result" step="save-transcripts"></p:pipe></p:input>			
      <p:input port="stylesheet"><p:document href="xslt/generate-htaccess.xsl"/></p:input>			
      <p:with-param name="rewrite-base" select="'/app'"/>
      <p:with-param name="old-source" select="'texttranscript'"/>
    </p:xslt>
    <p:store method="text"><p:with-option name="href" select="resolve-uri('www/app/.htaccess', $builddir)"/></p:store>		
    
    <p:xslt>
      <p:input port="source"><p:pipe port="result" step="save-transcripts"></p:pipe></p:input>			
      <p:input port="stylesheet"><p:document href="xslt/generate-htaccess.xsl"/></p:input>		
      <p:with-param name="rewrite-base" select="'/meta'"/>
      <p:with-param name="old-source" select="'document'"/>
    </p:xslt>
    <p:store method="text"><p:with-option name="href" select="resolve-uri('www/meta/.htaccess', $builddir)"/></p:store>		
    
  </p:group>
  
  
  
</p:declare-step>