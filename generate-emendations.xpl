<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:pxp="http://exproc.org/proposed/steps"
  xmlns:pxf="http://exproc.org/proposed/steps/file" xmlns:f="http://www.faustedition.net/ns"
  xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:l="http://xproc.org/library" name="main"
  type="f:generate-emendations" version="2.0">
  
  <p:input port="source"/>
  <p:input port="parameters" kind="parameter"/>
  <p:output port="result" sequence="true"/>
  <p:option name="paths" select="resolve-uri('paths.xml')"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="library/store.xpl"/>
  <p:import href="apply-edits.xpl"/>

  <p:identity name="transcript-list"/>
  
  
  <!-- Parameter laden -->
  <p:xslt name="config" template-name="param">
    <p:input port="source"><p:empty/></p:input>
    <p:input port="stylesheet"><p:document href="xslt/config.xsl"/></p:input>
    <p:with-param name="path_config" select="$paths"></p:with-param>
  </p:xslt>
  
  <p:group>
    <p:variable name="source" select="//c:param[@name='source']/@value"/>
    <p:variable name="html" select="//c:param[@name='html']/@value"/>
    <p:variable name="builddir" select="resolve-uri(//c:param[@name='builddir']/@value)"/>
    
    <p:for-each name="apply-edits">
      <p:iteration-source select="//f:textTranscript">
        <p:pipe port="result" step="transcript-list"/>
      </p:iteration-source>
      <p:variable name="transcriptFile" select="/f:textTranscript/@href"/>
      <p:variable name="transcriptURI" select="/f:textTranscript/@uri"/>
      <p:variable name="documentURI" select="/f:textTranscript/@document"/>
      <p:variable name="type" select="/f:textTranscript/@type"/>
      <p:variable name="sigil" select="/f:textTranscript/f:idno[1]/text()"/>
      <p:variable name="sigil_t" select="/f:textTranscript/@sigil_t"/>
      
      <p:load name="load-in-apply-edits">
        <p:with-option name="href" select="resolve-uri(concat('prepared/textTranscript/', $sigil_t, '.xml'), $builddir)"></p:with-option>
      </p:load>
      
      
      <p:choose>
        <p:when test="$type = 'lesetext'">
          <p:xslt>
            <p:input port="stylesheet"><p:document href="xslt/prose-to-lines.xsl"/></p:input>
          </p:xslt>
        </p:when>
        <p:otherwise>
          <!--<cx:message><p:with-option name="message" select="concat('Emending ', $sigil, ' (', $documentURI, ') ...')"/></cx:message>-->
          <f:apply-edits/>					
        </p:otherwise>
      </p:choose>
      
      <p:xslt>
        <p:input port="stylesheet"><p:document href="xslt/changenote.xsl"/></p:input>
        <p:with-param name="changenote-type" select="'emended'"/>
        <p:with-param name="changenote" select="'automatically applied emendation instructions'"/>
      </p:xslt>
      
      <p:store>
        <p:with-option name="href" select="resolve-uri(concat('emended/', $sigil_t, '.xml'), $builddir)"/>
      </p:store>
      
      <!-- Grundschicht -->
      <p:xslt>
        <p:input port="source"><p:pipe port="result" step="load-in-apply-edits"/></p:input>
        <p:input port="stylesheet"><p:document href="xslt/normalize-wsp.xsl"/></p:input>
        <p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
      </p:xslt>
      <p:xslt name="text-unemend">
        <p:input port="stylesheet"><p:document href="xslt/text-unemend.xsl"/></p:input>
        <p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
      </p:xslt>
      <p:xslt>
        <p:input port="stylesheet"><p:document href="xslt/unemend-core.xsl"/></p:input>
        <p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
      </p:xslt>
      <p:xslt>
        <p:input port="stylesheet"><p:document href="xslt/changenote.xsl"/></p:input>
        <p:with-param name="changenote" select="'Base layer without instant revisions'"/>
      </p:xslt>
      
      <p:store indent="true">
        <p:with-option name="href" select="resolve-uri(concat('grundschicht/', $sigil_t, '.xml'), $builddir)"/>
      </p:store>
      <p:xslt>
        <p:input port="source"><p:pipe port="result" step="text-unemend"/></p:input>
        <p:input port="stylesheet"><p:document href="xslt/emend-core-only-instant.xsl"/></p:input>
        <p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
      </p:xslt>
      <p:xslt>
        <p:input port="stylesheet"><p:document href="xslt/changenote.xsl"/></p:input>
        <p:with-param name="changenote" select="'Base layer plus instant revisions'"/>
      </p:xslt>
      <p:store indent="true">
        <p:with-option name="href" select="resolve-uri(concat('grundschicht-instant/', $sigil_t, '.xml'), $builddir)"/>
      </p:store>
    </p:for-each>
    <!-- Pipe through list of inputs -->
    <p:identity name="emended-version"><p:input port="source"><p:pipe port="result" step="transcript-list"/></p:input></p:identity>   
    
    
  </p:group>  
</p:declare-step>
