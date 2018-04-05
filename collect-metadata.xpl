<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:f="http://www.faustedition.net/ns"
  xmlns:pxf="http://exproc.org/proposed/steps/file"  
  xmlns:l="http://xproc.org/library" type="f:list-transcripts" name="main" version="1.0">

  <p:input port="source"><p:empty/></p:input>
  <p:input port="parameters" kind="parameter"/>
  <p:output port="result" primary="true" sequence="false"/>
  <p:serialization port="result" indent="true"/>


  <p:documentation> Dieser Pipelineschritt lädt alle Metadaten (aus dem document-Unterverzeichnis des
    Verzeichnisses, das über die Option $root angegeben wird), und erzeugt eine Liste der darin referenzierten
    Transcripte. Das Ergebnis ist eine XML-Datei aus f:textTranscript-Elementen mit den Attributen @uri (=
    Faust-URI) und @href (=aufgelöster Pfad relativ zu $root) und als Kindelementen </p:documentation>

  <p:import href="http://xproc.org/library/recursive-directory-list.xpl"/>
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

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
    <cx:message log="info">  
      <p:input port="source"><p:pipe port="source" step="main"></p:pipe></p:input>      
      <p:with-option name="message" select="concat('Collecting metadata from ', $source, ' (builddir=', $builddir, ')')"/>
    </cx:message>
        


    <l:recursive-directory-list>
      <p:with-option name="path" select="concat($source, '/document')"/>
    </l:recursive-directory-list>

    <p:for-each>
      <p:iteration-source select="//c:file[$debug or not(ends-with(@name, 'test.xml'))]"/>
      <p:variable name="filename" select="p:resolve-uri(/c:file/@name)"/>
      
      <cx:message log="debug">        
        <p:with-option name="message" select="concat('Reading metadata from ', $filename)"/>
      </cx:message>
      
      <p:load>
        <p:with-option name="href" select="$filename"/>
      </p:load>

      <p:xslt>
        <p:input port="stylesheet">
          <p:inline>
            <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
              xmlns="http://www.faustedition.net/ns" xpath-default-namespace="http://www.faustedition.net/ns"
              xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:f="http://www.faustedition.net/ns"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:c="http://www.w3.org/ns/xproc-step"
              exclude-result-prefixes="c tei xsi l">

              <xsl:import href="xslt/utils.xsl"/>

              <xsl:param name="source"/>  <!-- Der Wurzelordner der Faust-XML-Daten -->

              <!-- Rangfolge, in der die Signaturen berücksichtigt werden sollen. Werte von idno/@type  -->
              <xsl:variable name="archivalSigs"
                select="('faustedition', 'wa_faust', 'bohnenkamp', 'fischer_lamberg', 
              'landeck', 'fa', 'ma', 'aa_ls_helenaank', 'aa_wilhelmmeister', 'aa_duw', 'aa_ls_chines', 
              'aa_ls_aristpoet', 'aa_ls_kuaschemata', 'aa_ls_stoffgeh', 'aa_ls_wesentrag', 'wa_helenaank', 
              'wa_gedichte', 'wa_div', 'wa_naus', 'wa_tasso', 'wa_chines', 'wa_aristpoet', 'wa_wesentrag', 
              'wa_mur', 'wa_prologberltheat', 'wa_rueckkgrossh', 'wa_schlusspalneot', 'wa_zuwallenstlag', 
              'gsa_2', 'fdh_frankfurt', 'dla_marbach', 'sb_berlin', 'ub_leipzig', 'ub_bonn', 'veste_coburg', 
              'gm_duesseldorf', 'sa_hannover', 'thlma_weimar', 'bb_cologny', 'ub_basel', 'bj_krakow', 
              'agad_warszawa', 'bb_vicenza', 'bl_oxford', 'bl_london', 'ul_edinburgh', 'ul_yale', 
              'tml_new_york', 'ul_pennstate', 'mlm_paris', 'gsa_1')"/>
              
              <!-- Dito für die Drucke -->
              <xsl:variable name="printSigs"
                select="('faustedition', 'hagen', 'wa_faust', 'wa_gedichte', 
              'wa_I_53', 'hagen_nr', 'dla_marbach')"/>
              
              <!-- Auswahl anhand des aktuellen Dokuments ... -->
              <xsl:variable name="sigil-set"
                select="if (/f:archivalDocument) then $archivalSigs else $printSigs"/>
              
              <!-- Berechnet den Rang einer Sigle anhand der o.g. Listen -->
              <xsl:function name="f:sigil-rank">
                <xsl:param name="type"/>
                <xsl:value-of select="if ($type = $sigil-set) then index-of($sigil-set, $type) else 9999"/>
              </xsl:function>


              <xsl:template match="/">
                <f:transcript><!-- es muss ein XML-Dokument zurückgeliefert werden ... -->
                  <xsl:apply-templates select="//f:textTranscript | /*[not(descendant::f:textTranscript[@uri])]"/>
                </f:transcript>
              </xsl:template>

              <xsl:template match="f:textTranscript[@uri] | /*[not(descendant::f:textTranscript[@uri])]">                
                <!-- Wir sammeln alle <idno>s zum aktuellen Dokument ein, sortiert nach der Rangfolge, dann nach der document order.  -->
                <xsl:variable name="idnos">
                  <xsl:apply-templates select="//f:idno[@type]">
                    <xsl:sort select="f:sigil-rank(@type)" data-type="number" stable="yes"/>
                  </xsl:apply-templates>
                </xsl:variable>
                <!-- die erste gewählte wird unsere sigle -->         
                <xsl:variable name="preferred-idno">
                  <xsl:sequence select="$idnos/f:idno[1]"/>
                </xsl:variable>

                <xsl:copy copy-namespaces="no">
                  <!-- Ein paar Metadaten speichern wir mit unseren Transkripten: -->
                  
                  <!-- Die URI zum Transkript: -->
                  <xsl:variable name="uri" select="resolve-uri(@uri, (ancestor-or-self::*/@xml:base)[1])"/>
                  <xsl:attribute name="uri" select="$uri"/>
                  <!-- in aufgelöster, nur lokal funktionierender Form: -->
                  <xsl:variable name="file" select="replace($uri, '^faust://xml/', $source)"/>
                  <xsl:variable name="href"
                    select="if (ends-with($file, '.xml')) then $file else concat($file, '.xml')"/>
                  <xsl:attribute name="href" select="$href"/>
                  <xsl:if test="not(doc-available($href))">
                    <xsl:message
                      select="concat('WARNING: Referenced transcript is missing: ', $href, ' (referred to from ', document-uri(/), ')')"
                    />
                  </xsl:if>
                  
                  <!-- Die URL zum Metadatendokument (Sie baden grad ihre Hände drin): -->
                  <xsl:variable name="document" select="f:relativize($source, document-uri(/))"/>
                  <xsl:attribute name="document" select="$document"/>
                  <!--<xsl:message select="concat('Document path: ', document-uri(/), ' - ', $source, ' → ', $document)"/>-->
                  
                  <!-- print oder archivalDocument? -->
                  <xsl:attribute name="type" select="local-name(/*)"/>
                  
                  <!-- Sigle, also bevorzugte idno (brauchen wir das noch?) -->
                  <xsl:attribute name="f:sigil" select="$preferred-idno"/>
                  
                  <xsl:attribute name="id" select="replace($idnos//f:idno[@type='faustedition']/@uri, '^.*/', '')"/>
                  
                  <!-- Nun die nach Rangfolge sortierten <idno>s. Siehe unten. -->
                  <xsl:copy-of select="$idnos" copy-namespaces="no"/>
                                    
                  
                  <f:idno type="faust-doc-uri" rank="10000" uri="faust://xml/{$document}"><xsl:value-of select="concat('faust://xml/', $document)"/></f:idno>
                  <xsl:copy-of select="..//f:headNote" copy-namespaces="no"/>
                </xsl:copy>
              </xsl:template>

              <xsl:template match="f:idno">
                <!-- idnos werden nur übernommen, wenn da nicht 'none' drin steht. -->
                <xsl:if test="normalize-space(.) != 'none'">
                  <xsl:copy copy-namespaces="no">
                    <xsl:copy-of select="@*" copy-namespaces="no"/>
                    
                    <!-- außerdem berechnen wir noch die faust://-URI aus der idno, wie in macrogenesis verwendet: -->
                    <xsl:attribute name="uri"
                      select="concat('faust://document/', @type, '/', replace(normalize-space(.), '\s+', '_'))"/>
                    
                    <!-- zu Debuggingzwecken die Rangfolge nach der auch sortiert wird: -->
                    <xsl:attribute name="rank" select="f:sigil-rank(@type)"/>
                    
                    <!-- und die Signatur selbst. -->
                    <xsl:value-of select="normalize-space(.)"/>
                  </xsl:copy>
                </xsl:if>
              </xsl:template>

            </xsl:stylesheet>
          </p:inline>
        </p:input>
        
        <p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
      </p:xslt>
    </p:for-each>

    <!-- Nun noch zusammenkleben und ein wenig XML aufräumen -->
    <p:wrap-sequence wrapper="doc" wrapper-namespace="http://www.faustedition.net/ns"/>
    <p:namespace-rename from="http://www.tei-c.org/ns/1.0"/>
    <p:namespace-rename from="http://www.w3.org/2001/XMLSchema-instance"/>
    
    <p:xslt>
      <p:input port="stylesheet">
        <p:inline>
          <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" 
            xmlns="http://www.faustedition.net/ns" xmlns:f="http://www.faustedition.net/ns">
            
            <xsl:import href="xslt/utils.xsl"/>
            
            <xsl:param name="html"/>
            <xsl:param name="builddir"/>
            
                       
            
            <xsl:template match="node()|@*">
              <xsl:copy copy-namespaces="no">
                <xsl:apply-templates select="@*|node()"/>
              </xsl:copy>
            </xsl:template>
            <xsl:template match="/*">              
              <xsl:copy copy-namespaces="no">                
                <xsl:variable name="sorted-transcripts">
                  <!-- Lesetext: -->
                  <textTranscript xmlns:f="http://www.faustedition.net/ns" uri="faust://lesetext/faust.xml"
                    href="{resolve-uri('lesetext/faust.xml', $builddir)}" document="lesetext/faust.xml"
                    type="lesetext" f:sigil="Lesetext">
                    <idno type="faustedition">Lesetext</idno>
                  </textTranscript>

                  <xsl:apply-templates select="descendant-or-self::f:textTranscript">
                    <xsl:sort select="f:splitSigil(@f:sigil)[1]" stable="yes"/>
                    <xsl:sort select="f:splitSigil(@f:sigil)[2]" data-type="number"/>
                    <xsl:sort select="f:splitSigil(@f:sigil)[3]"/>
                  </xsl:apply-templates>
                </xsl:variable>
                <xsl:for-each select="$sorted-transcripts/*">
                  <xsl:copy copy-namespaces="no">
                    <xsl:attribute name="number"><xsl:number/></xsl:attribute>
                    <xsl:copy-of select="@*"/>
                    <xsl:copy-of select="node()"/>
                  </xsl:copy>
                </xsl:for-each>
              </xsl:copy>              
            </xsl:template>           
          </xsl:stylesheet>
        </p:inline>
      </p:input>
      <p:input port="parameters">
        <p:pipe port="result" step="config"/>
      </p:input>
      <p:with-param name="builddir" select="$builddir"/>
    </p:xslt>
    
    <p:unwrap match="f:transcript" name="cleanup"/>
    
  </p:group>

</p:declare-step>
