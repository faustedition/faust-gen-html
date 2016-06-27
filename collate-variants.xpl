<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:f="http://www.faustedition.net/ns"
  xmlns:l="http://xproc.org/library" version="1.0" name="main" type="f:collate-variants">
  <p:input port="source">
    <p:empty/>
  </p:input>
  <p:input port="parameters" kind="parameter"/>
  <p:output port="result" primary="true"/>

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="apply-edits.xpl"/>
  <!--  <p:import href="collect-metadata.xpl"/>-->

  <!-- Parameter laden -->
  <p:parameters name="config">
    <p:input port="parameters">
      <p:document href="config.xml"/>
      <p:pipe port="parameters" step="main"/>
    </p:input>
  </p:parameters>

  <p:identity name="source">
    <p:input port="source">
      <p:pipe port="source" step="main"/>
    </p:input>
  </p:identity>

  <p:group name="body">
    <p:variable name="apphtml" select="//c:param[@name='apphtml']/@value">
      <p:pipe port="result" step="config"/>
    </p:variable>
    <p:variable name="builddir" select="resolve-uri(//c:param[@name='builddir']/@value)">
      <p:pipe port="result" step="config"/>
    </p:variable>


    <cx:message log="info">
      <p:with-option name="message" select="'Reading emended transcript files ...'"/>
    </cx:message>

    <!-- 
    Wir iterieren über die Transkripteliste, die vom Skript in collect-metadata.xpl generiert wird.
    Für die Variantengenerierung berücksichtigen wir dabei jedes dort verzeichnete Transkript.
  -->
    <p:for-each>
      <p:iteration-source select="//f:textTranscript"/>
      <p:variable name="transcriptFile" select="/f:textTranscript/@href"/>
      <p:variable name="transcriptURI" select="/f:textTranscript/@uri"/>
      <p:variable name="documentURI" select="/f:textTranscript/@document"/>
      <p:variable name="type" select="/f:textTranscript/@type"/>
      <p:variable name="sigil" select="/f:textTranscript/f:idno[1]/text()"/>
      <p:variable name="sigil-type" select="/f:textTranscript/f:idno[1]/@type"/>


      <!-- Das Transkript wird geladen ... -->
      <p:load>
        <p:with-option name="href" select="resolve-uri(concat('emended/', $documentURI), $builddir)"
        />
      </p:load>

      <!-- 
          nun extrahieren wir die Elemente ("lines"), die für den Variantenapparat
          verwendet werden sollen. Dazu werden nur Elemente, die eine Zeilenzählung
          enthalten, sowie deren Inhalt extrahiert. Die Elemente mit Zeilenzählung
          erhalten zusätzlich ein paar Metadaten als Attribute im Faust-Namespace: 
          URI, Sigle, und Siglentyp.          
        -->
      <p:xslt>
        <p:input port="stylesheet">
          <p:document href="xslt/extract-lines.xsl"/>
        </p:input>
        <p:input port="parameters">
          <p:pipe port="result" step="config"/>
        </p:input>
        <p:with-param name="documentURI" select="$documentURI"/>
        <p:with-param name="sigil" select="$sigil"/>
        <p:with-param name="sigil-type" select="$sigil-type"/>
        <p:with-param name="type" select="$type"/>
      </p:xslt>

    </p:for-each>

    <!-- 
    die aus den Transkripten generierten "Zeilenlisten"-Dokumente kleben wir nun
    zu einem großen XML-Dokument zusammen, auf dem dann der nächste Schritt agiert.
    
    Dieses Dokument wird zu Debuggingzwecken auch am result-Port dargeboten.
  -->

    <p:wrap-sequence wrapper="f:variants"/>
    <cx:message log="info">
      <p:with-option name="message" select="'Collecting lines from all transcripts ...'"/>
    </cx:message>
    <!-- 
      Das Stylesheet entfernt die überflüssigen f:lines-Statements und bewegt die Namespace-
      Deklarationen zum Wurzelelement: Dadurch wird v.a. das Debugging-Dokument übersichtlicher.:q
   -->
    <p:xslt>
      <p:input port="stylesheet">
        <p:inline>
          <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
            <xsl:template match="f:variants">
              <xsl:copy>
                <xsl:namespace name="">http://www.tei-c.org/ns/1.0</xsl:namespace>
                <xsl:namespace name="ge">http://www.tei-c.org/ns/geneticEditions</xsl:namespace>
                <xsl:namespace name="svg">http://www.w3.org/2000/svg</xsl:namespace>
                <xsl:apply-templates select="@*|node()"/>
              </xsl:copy>
            </xsl:template>
            <xsl:template match="node()|@*">
              <xsl:copy>
                <xsl:apply-templates select="@*|node()"/>
              </xsl:copy>
            </xsl:template>
            <xsl:template match="f:lines">
              <xsl:apply-templates select="node()"/>
            </xsl:template>
          </xsl:stylesheet>
        </p:inline>
      </p:input>
    </p:xslt>
    <p:identity name="collect-lines"/>


    <cx:message log="info" message="Collating the lines and writing variant HTMLs"/>

    <!-- hier werden nun tatsächlich die Varianten-HTML-Dateien erzeugt: -->
    <p:xslt name="variant-fragments">
      <p:input port="stylesheet">
        <p:document href="xslt/variant-fragments.xsl"/>
      </p:input>
      <p:input port="parameters">
        <p:pipe port="result" step="config"/>
      </p:input>
    </p:xslt>

    <p:sink/>

    <!-- Auf dem sekundären Port landen die ganzen variants/<group>.html, die wir nun speichern: -->
    <p:for-each>
      <p:iteration-source>
        <p:pipe port="secondary" step="variant-fragments"/>
      </p:iteration-source>

      <cx:message log="debug">
        <p:with-option name="message" select="concat('Writing fragment ', p:base-uri())"/>
      </cx:message>

      <p:store method="xhtml" omit-xml-declaration="false" indent="false">
        <p:with-option name="href" select="p:base-uri()"/>
      </p:store>
    </p:for-each>

  </p:group>
  
  <p:identity>
    <p:input port="source">
      <p:pipe port="result" step="source"/>
    </p:input>
  </p:identity>

</p:declare-step>
