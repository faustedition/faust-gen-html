<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:f="http://www.faustedition.net/ns"
  xmlns:pxf="http://exproc.org/proposed/steps/file"
  xmlns:l="http://xproc.org/library" type="f:bibliography" name="main" version="1.0">

  <p:input port="source" primary="true" sequence="true"/>
  <p:input port="parameters" kind="parameter"/>
  
  <!-- This pipeline generates a bibliography page from a bunch of 'citations' xml files. -->

  <!-- Parameter laden -->
  <p:parameters name="config">
    <p:input port="parameters">
      <p:document href="config.xml"/>
      <p:pipe port="parameters" step="main"></p:pipe>
    </p:input>
  </p:parameters>

  <p:group>
    <p:variable name="source" select="//c:param[@name='source']/@value"><p:pipe port="result" step="config"/></p:variable>
    <p:variable name="debug" select="//c:param[@name='debug']/@value"><p:pipe port="result" step="config"/></p:variable>
    <p:variable name="builddir" select="resolve-uri(//c:param[@name='builddir']/@value)"><p:pipe port="result" step="config"/></p:variable>
  
    <p:wrap-sequence wrapper="f:citations" name="wrapped-citations">
      <p:input port="source">
        <p:pipe port="source" step="main"/>
        <p:document href="additional-citations.xml"/>
      </p:input>
    </p:wrap-sequence>
        
    
    <p:xslt>
      <p:input port="stylesheet"><p:document href="xslt/create-bibliography.xsl"/></p:input>
      <p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
      <p:with-param name="builddir-resolved" select="p:resolve-uri($builddir)"></p:with-param>
    </p:xslt>
    
    <p:store method="xhtml" include-content-type="false" indent="true">
      <p:with-option name="href" select="concat($builddir, 'www/bibliography.html')"/>
    </p:store>
    <!-- For debugging: -->
    <p:store method="xml" indent="true">
      <p:with-option name="href" select="concat($builddir, 'citations.xml')"/>
      <p:input port="source">
        <p:pipe port="result" step="wrapped-citations"/>
      </p:input>
    </p:store>
  </p:group>

</p:declare-step>
