<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:f="http://www.faustedition.net/ns"
  xmlns:l="http://xproc.org/library" type="f:list-transcripts" version="1.0">
  <p:input port="source">
    <p:empty/>
  </p:input>
  <p:option name="root" select="'/home/vitt/Faust/'"/>
  <p:output port="result" primary="true">
    <p:pipe port="result" step="sort-lines"/>
  </p:output>
  <p:serialization port="result" indent="true"/>

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

  <!--  <p:import href="collect-metadata.xpl"/>
-->
  <p:import href="apply-edits.xpl"/>

  <p:load>
    <p:with-option name="href" select="'faust-transcripts.xml'"/>
  </p:load>


  <p:for-each>
    <p:iteration-source select="//f:textTranscript"/>
    <p:variable name="transcriptFile" select="/f:textTranscript/@href"/>
    <p:variable name="transcriptURI" select="/f:textTranscript/@uri"/>
    <p:variable name="documentURI" select="/f:textTranscript/@document"/>
    <p:variable name="sigil" select="/f:textTranscript/@f:sigil"/>

    <cx:message>
      <p:with-option name="message" select="concat('Reading ', $transcriptFile)"/>
    </cx:message>

    <p:try>

      <p:group>

        <p:load>
          <p:with-option name="href" select="$transcriptFile"/>
        </p:load>

        <f:apply-edits/>

        <p:xslt>
          <p:input port="stylesheet">
            <p:document href="extract-lines.xsl"/>
          </p:input>
          <p:with-param name="documentURI" select="$documentURI"/>
          <p:with-param name="sigil" select="$sigil"/>
        </p:xslt>

      </p:group>
      <p:catch>        
        <p:identity>          
          <p:input port="source">
            <p:empty/>
          </p:input>
        </p:identity>
      </p:catch>

    </p:try>
  </p:for-each>

  <p:wrap-sequence wrapper="f:doc"/>
  
  <p:xslt name="sort-lines">
    <p:input port="stylesheet">
      <p:inline>
        <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
          xmlns:ge="http://www.tei-c.org/ns/geneticEditions"
          xmlns:svg="http://www.w3.org/2000/svg"
          xmlns="http://www.tei-c.org/ns/1.0"
          >

          <xsl:template match="@*|node()">
            <xsl:copy>
              <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
          </xsl:template>
          
          <xsl:function name="f:extract-number">
            <xsl:param name="n"/>
            <xsl:value-of select="number(replace($n, '\D*(\d+).*', '$1'))"/>
          </xsl:function>
          
          <xsl:template match="f:doc">
            <f:sorted-lines
              xmlns:ge="http://www.tei-c.org/ns/geneticEditions"
              xmlns:svg="http://www.w3.org/2000/svg"
              xmlns="http://www.tei-c.org/ns/1.0"
              xmlns:f="http://www.faustedition.net/ns"
              >
            <xsl:apply-templates select="f:lines/*[@n]">
              <xsl:sort select="f:extract-number(@n)" data-type="number"/>              
            </xsl:apply-templates>
              <xsl:comment>Jetzt der Kram ohne @n</xsl:comment>
            <xsl:apply-templates select="f:lines/*[not(@n)]"/>
            </f:sorted-lines>
          </xsl:template>
          
        </xsl:stylesheet>
      </p:inline>
    </p:input>
    <p:input port="parameters">
      <p:empty/>
    </p:input>
  </p:xslt>

  <p:xslt name="variant-fragments">
    <p:input port="stylesheet">
      <p:document href="variant-fragments.xsl"/>
    </p:input>    
    <p:with-param name="output" select="'variants/'"></p:with-param>
    <p:with-param name="docbase" select="'https://faustedition.uni-wuerzburg.de/new'"/>        
  </p:xslt>
    
  
  <p:for-each>
    <p:iteration-source>
      <p:pipe port="result" step="variant-fragments"/>
      <p:pipe port="secondary" step="variant-fragments"/>
    </p:iteration-source>
    <p:store>
      <p:with-option name="href" select="p:base-uri()"/>
    </p:store>
  </p:for-each>
  
   
</p:declare-step>
