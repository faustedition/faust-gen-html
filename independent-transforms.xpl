<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:f="http://www.faustedition.net/ns"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"   
  name="main" type="f:independent-transformations"
  xmlns:c="http://www.w3.org/ns/xproc-step" version="1.0">
  <p:input port="source"><p:empty/></p:input>
  <p:output port="result" sequence="true"><p:empty/></p:output>
  <p:option name="paths" select="'paths.xml'"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  
  
  <!-- Konfiguration laden -->
  <p:xslt name="config" template-name="param">
    <p:input port="source"><p:empty/></p:input>
    <p:input port="stylesheet"><p:document href="xslt/config.xsl"/></p:input>
    <p:with-param name="path_config" select="$paths"></p:with-param>
  </p:xslt>
  
  <p:group>
    <p:variable name="builddir" select="//c:param[@name='builddir']/@value"/>
    <p:variable name="source" select="//c:param[@name='source']/@value"/>
    
    <!-- Archivmetadaten -->
    <p:load><p:with-option name="href" select="resolve-uri('archives.xml', resolve-uri($source))"/></p:load>
    <cx:message log="info">
      <p:with-option name="message" select="'Converting archive metadata to js...'"/>
    </cx:message>
    <p:xslt name="archives">
      <p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
      <p:input port="stylesheet"><p:document href="xslt/create-archives-metadata.xsl"/></p:input>      
    </p:xslt>
    <p:store method="text">
      <p:with-option name="href" select="resolve-uri('www/data/archives.js', $builddir)"/>
    </p:store>
    
    
    <!-- scene line mapping -->
    <p:xslt name="scenes">
      <p:input port="source"><p:document href="xslt/scenes.xml"></p:document></p:input>
      <p:input port="stylesheet"><p:document href="xslt/scene-line-mapping.xsl"></p:document></p:input>
      <p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
    </p:xslt>
    <p:store method="text" encoding="utf-8">
      <p:with-option name="href" select="resolve-uri('www/data/scene_line_mapping.js', $builddir)"/>
    </p:store>
    
    
    
  </p:group>
  
  
</p:declare-step>