<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:f="http://www.faustedition.net/ns"  
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  name="main" type="f:reading-text-extras"
  version="1.0">
  <p:input port="source">
    <p:documentation>Reading text</p:documentation>
  </p:input>  
  <p:output port="result" sequence="true"><p:empty/></p:output>
  <p:option name="paths" select="'paths.xml'"/>
  
  <p:identity name="generate-reading-text"/>
  
  <!-- Konfiguration laden -->
  <p:xslt name="config" template-name="param">
    <p:input port="source"><p:empty/></p:input>
    <p:input port="stylesheet"><p:document href="xslt/config.xsl"/></p:input>
    <p:with-param name="path_config" select="$paths"></p:with-param>
  </p:xslt>
  
  <p:group>
    <p:variable name="builddir" select="//c:param[@name='builddir']/@value"/>
    
    <!-- ### Step 3c: Reading text apparatus list -->
    <p:xslt name="reading-text-md">
      <p:input port="source"><p:pipe port="result" step="generate-reading-text"/></p:input>
      <p:input port="stylesheet"><p:document href="xslt/add-metadata.xsl"/></p:input>
      <p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
      <p:with-param name="type" select="'lesetext'"/>
      <p:with-param name="sigil_t" select="'faust'"/>
    </p:xslt>
    <p:xslt>
      <p:input port="stylesheet"><p:document href="xslt/text-applist.xsl"/></p:input>
      <p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
    </p:xslt>
    <p:store method="xhtml">
      <p:with-option name="href" select="resolve-uri('www/print/app.html', $builddir)"/>
    </p:store>
    <p:store>
      <p:input port="source"><p:pipe port="result" step="reading-text-md"/></p:input>
      <p:with-option name="href" select="resolve-uri('lesetext/faust-md.xml', $builddir)"/>
    </p:store>
    
    <!-- ### Step 3c': Reading text apparatus reflist -->
    <p:xslt>
      <p:input port="source"><p:pipe port="result" step="reading-text-md"/></p:input>
      <p:input port="stylesheet"><p:document href="xslt/text-applist.xsl"/></p:input>
      <p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
      <p:with-param name="output-type" select="'reflist'"></p:with-param>
    </p:xslt>
    <p:store method="xhtml">
      <p:with-option name="href" select="resolve-uri('www/print/reflist.html', $builddir)"/>
    </p:store>
    
    <!-- ### Step 3c'': Reading text app list by scene instead -->
    <p:xslt>
      <p:input port="source"><p:pipe port="result" step="reading-text-md"/></p:input>
      <p:input port="stylesheet"><p:document href="xslt/text-applist.xsl"/></p:input>
      <p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
      <p:with-param name="output-type" select="'byscene'"></p:with-param>
    </p:xslt>
    <p:store method="xhtml">
      <p:with-option name="href" select="resolve-uri('www/print/app-by-scene.html', $builddir)"/>
    </p:store>			
    
    <!-- ### Step 3d: Reading text word index -->
    <p:xslt>
      <p:input port="source"><p:pipe port="result" step="reading-text-md"/></p:input>
      <p:input port="stylesheet"><p:document href="xslt/word-index.xsl"></p:document></p:input>
      <p:input port="parameters"><p:pipe port="result" step="config"></p:pipe></p:input>
      <p:with-param name="limit" select="0"/>
      <p:with-param name="title" select="'Tokens im Text'"/>
    </p:xslt>
    <p:store method="xhtml">
      <p:with-option name="href" select="resolve-uri('www/print/faust.wordlist.html', $builddir)"/>
    </p:store>    
  </p:group>
  
  
  
</p:declare-step>