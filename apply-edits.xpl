<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  version="1.0" name="apply-edits">
  <p:input port="source" primary="true"/>
  <p:output port="result" primary="true"/>

  <p:documentation> Applies the edits to one single document </p:documentation>


  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="textTranscr_pre_transpose.xsl"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>

  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="textTranscr_transpose.xsl"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>

  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="textTranscr_fuer_Drucke.xsl"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>

  <p:xslt>
    <p:input port="stylesheet">
      <p:document href="text-emend.xsl"/>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>


</p:declare-step>
