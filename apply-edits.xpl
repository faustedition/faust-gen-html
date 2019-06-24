<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:f="http://www.faustedition.net/ns" xmlns:tei="http://www.tei-c.org/ns/1.0" 
  version="1.0" type="f:apply-edits">
  <p:input port="source" primary="true"/>
  <p:output port="result" primary="true"/>
  <p:output port="emended-version">
    <p:pipe port="result" step="emended-version"/>
  </p:output>

  <p:documentation> Applies the edits to one single document </p:documentation>

  <p:xslt name="normalize-characters">
    <p:input port="stylesheet">
      <p:document href="xslt/normalize-characters.xsl"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>

  <p:xslt name="pre-transpose">
    <p:input port="stylesheet">
      <p:document href="xslt/textTranscr_pre_transpose.xsl"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>

  <p:xslt name="transpose">
    <p:input port="stylesheet">
      <p:document href="xslt/textTranscr_transpose.xsl"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>

  <p:xslt initial-mode="emend" name="emend-core">
    <p:input port="stylesheet">
      <p:document href="xslt/emend-core.xsl"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>

  <p:choose>
    <p:when test="//tei:delSpan | //tei:modSpan | //tei:addSpan">
      <p:xslt name="emend-spans">
        <p:input port="stylesheet">
          <p:document href="xslt/text-emend.xsl"/>
        </p:input>
        <p:input port="parameters">
          <p:empty/>
        </p:input>
      </p:xslt>
    </p:when>
    <p:otherwise>
      <p:identity/>
    </p:otherwise>
  </p:choose>
  
  <p:xslt name="clean-up">
    <p:input port="stylesheet">
      <p:document href="xslt/clean-up.xsl"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>
  
  <p:xslt name="fix-punct-wsp">
    <p:input port="stylesheet">
      <p:document href="xslt/fix-punct-wsp.xsl"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>

  <p:identity name="emended-version"/>
  
  <p:xslt name="prose-to-lines">
    <p:input port="source">
      <p:pipe port="result" step="emended-version"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="xslt/prose-to-lines.xsl"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>

  <p:xslt name="harmonize-antilabes">
    <p:input port="stylesheet">
      <p:document href="xslt/harmonize-antilabes.xsl"/>      
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>

</p:declare-step>
