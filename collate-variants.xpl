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
      <p:with-option name="message" select="'Reading prepared transcript files ...'"/>
    </cx:message>

    <!-- 
    Wir iterieren über die Transkripteliste, die vom Skript in collect-metadata.xpl generiert wird.
    Für die Variantengenerierung berücksichtigen wir dabei jedes dort verzeichnete Transkript.
  -->
    <p:for-each>
      <p:iteration-source select="//f:textTranscript"/>
      <p:variable name="sigil_t" select="/f:textTranscript/@sigil_t"/>


      <!-- Das Transkript wird geladen ... -->
      <p:load name="load-prepared">
        <p:with-option name="href" select="resolve-uri(concat('prepared/textTranscript/', $sigil_t, '.xml'), $builddir)"
        />
      </p:load>
      
      <p:load name="load-emended">
        <p:with-option name="href" select="resolve-uri(concat('emended/', $sigil_t, '.xml'), $builddir)"
        />
      </p:load>
      
      <p:identity>
        <p:input port="source">
          <p:pipe port="result" step="load-emended"/>
          <p:pipe port="result" step="load-prepared"/>
        </p:input>        
      </p:identity>
    </p:for-each>
    
    <p:for-each>
      <p:xslt>
        <p:input port="stylesheet"><p:document href="xslt/prose-to-lines.xsl"/></p:input>
      </p:xslt>

      <!-- 
          nun extrahieren wir die Elemente ("lines"), die für den Variantenapparat
          verwendet werden sollen. Dazu werden nur Elemente, die eine Zeilenzählung
          enthalten, sowie deren Inhalt extrahiert. Die Elemente mit Zeilenzählung
          erhalten zusätzlich ein paar Metadaten als Attribute im Faust-Namespace: 
          URI, Sigle, und Siglentyp.          
        -->
      <p:xslt name="extract-lines">
        <p:input port="stylesheet">
          <p:document href="xslt/extract-lines.xsl"/>
        </p:input>
        <p:input port="parameters">
          <p:pipe port="result" step="config"/>
        </p:input>
      </p:xslt>

    </p:for-each>

    <!-- 
    die aus den Transkripten generierten "Zeilenlisten"-Dokumente kleben wir nun
    zu einem großen XML-Dokument zusammen, auf dem dann der nächste Schritt agiert.
        
  -->

    <p:wrap-sequence wrapper="f:variants"/>
    <cx:message log="info">
      <p:with-option name="message" select="'Collecting lines from all transcripts ...'"/>
    </cx:message>
    <!-- 
      Das Stylesheet entfernt die überflüssigen f:lines-Statements und bewegt die Namespace-
      Deklarationen zum Wurzelelement: Dadurch wird v.a. das Debugging-Dokument übersichtlicher.:q
   -->
    <p:xslt name="collect-lines-0">
      <p:input port="stylesheet">
        <p:inline>
          <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
            <xsl:template match="f:variants">
              <xsl:copy copy-namespaces="no">
                <xsl:namespace name="">http://www.tei-c.org/ns/1.0</xsl:namespace>
                <xsl:namespace name="ge">http://www.tei-c.org/ns/geneticEditions</xsl:namespace>
                <xsl:namespace name="svg">http://www.w3.org/2000/svg</xsl:namespace>
                <xsl:apply-templates select="@*|node()"/>
              </xsl:copy>
            </xsl:template>
            <xsl:template match="node()|@*">
              <xsl:copy copy-namespaces="no">
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
    
    <p:store method="xml" indent="true">
      <p:with-option name="href" select="resolve-uri('collected-lines.xml', $builddir)"/>
    </p:store>
    
    <p:identity name="collect-lines"><p:input port="source"><p:pipe port="result" step="collect-lines-0"></p:pipe></p:input></p:identity>


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
