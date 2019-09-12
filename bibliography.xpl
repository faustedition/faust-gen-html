<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:f="http://www.faustedition.net/ns"
  xmlns:pxf="http://exproc.org/proposed/steps/file"
  xmlns:l="http://xproc.org/library" type="f:bibliography" name="main" version="1.0">

  <p:input port="source" primary="true" sequence="true"/>
  <p:input port="parameters" kind="parameter"/>
  <p:option name="paths" select="'paths.xml'"/>
  
  <p:import href="library/recursive-directory-list.xpl"/>
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>  
  
  
  <!-- This pipeline generates a bibliography page from a bunch of 'citations' xml files. -->
  
  <p:sink/>

  <!-- Konfiguration laden -->
  <p:xslt name="config" template-name="param">
    <p:input port="source"><p:empty/></p:input>
    <p:input port="stylesheet"><p:document href="xslt/config.xsl"/></p:input>
    <p:with-param name="path_config" select="$paths"/>
  </p:xslt>
  
  <p:group>
    <p:variable name="source" select="//c:param[@name='source']/@value"><p:pipe port="result" step="config"/></p:variable>
    <p:variable name="debug" select="//c:param[@name='debug']/@value"><p:pipe port="result" step="config"/></p:variable>
    <p:variable name="builddir" select="resolve-uri(//c:param[@name='builddir']/@value)"><p:pipe port="result" step="config"/></p:variable>
    


    <!-- Collect the citations from all macrogenesis files -->
    <l:recursive-directory-list name="list-macrogenesis" include-filter=".*\.xml$">
      <p:with-option name="path" select="concat($source, '/macrogenesis')"/>
    </l:recursive-directory-list>
    
    <p:for-each>
      <p:iteration-source select="//c:file"/>
      <p:variable name="filename" select="p:resolve-uri(/c:file/@name)"/>
      <p:load>
        <p:with-option name="href" select="$filename"/>
      </p:load>      
    </p:for-each>
    
    <p:wrap-sequence wrapper="f:wrapper"/>
    
    <p:xslt name="macrogenesis-citations">
      <p:input port="stylesheet">
        <p:inline>
          <xsl:stylesheet xmlns:f="http://www.faustedition.net/ns" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" exclude-result-prefixes="#all">
            <xsl:template match="/">
              <f:citations>
                <xsl:for-each-group select="//f:source" group-by="@uri">
                  <f:citation><xsl:value-of select="current-grouping-key()"/></f:citation>
                </xsl:for-each-group>
              </f:citations>
            </xsl:template>
          </xsl:stylesheet>
        </p:inline>
      </p:input>
      <p:input port="parameters"><p:empty/></p:input>
    </p:xslt>

  
    <p:wrap-sequence wrapper="f:citations" name="wrapped-citations">
      <p:input port="source">
        <p:pipe port="source" step="main"/>
        <p:pipe port="result" step="macrogenesis-citations"/>
        <p:document href="additional-citations.xml"/>
      </p:input>
    </p:wrap-sequence>
    
    <cx:message message="Creating bibliography ..."/>    
    
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
