<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:f="http://faustedition.net/" version="1.0">
  <p:input port="source">
    <p:document href="/home/vitt/Faust/transcript/documents.xml"/>
  </p:input>
  <p:output port="result" primary="true"/>
  <p:serialization port="result" indent="true"/>
  <p:variable name="root" select="'/home/vitt/Faust'"/>

  <p:for-each>
    <p:iteration-source select="//f:file"/>
    <p:variable name="file" select="/f:file/@href"/>

    <p:load name="transcript">
      <p:with-option name="href" select="concat($root, '/transcript/', $file)"/>
    </p:load>

    <p:xslt>
      <p:input port="stylesheet">
        <p:inline>
          <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
            xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="c"
            version="2.0">
            <xsl:param name="f" select="document-uri(/)"/>
            <xsl:template match="/">
              <f:doc href="{$f}">
                <xsl:for-each select="//(l|speaker|stage|head)/@n">
                  <f:n n="{.}" element="{local-name(..)}"/>
                </xsl:for-each>
              </f:doc>
            </xsl:template>
          </xsl:stylesheet>
        </p:inline>
      </p:input>
      <p:with-param name="f" select="$file"/>
    </p:xslt>
  </p:for-each>

  <p:wrap-sequence wrapper="f:n"/>

</p:declare-step>
