<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:f="http://www.faustedition.net/ns"
  xmlns:l="http://xproc.org/library" 
  type="f:list-transcripts" version="1.0">
  
  <p:input port="source">
    <p:empty/>
  </p:input>
  <p:option name="root" select="'/home/vitt/Faust/'"/>
  <p:output port="result"/>
  <p:serialization port="result" indent="true"/>
  
  <p:documentation>
    Dieser Pipelineschritt lädt alle Metadaten (aus dem document-Unterverzeichnis des Verzeichnisses, das über die Option $root angegeben wird),
    und erzeugt eine Liste der darin referenzierten Transcripte.
    
    Das Ergebnis ist eine XML-Datei aus f:textTranscript-Elementen mit den Attributen @uri (= Faust-URI) und @href (=aufgelöster Pfad relativ zu $root)
    und als Kindelementen 
  </p:documentation>

  <!--<p:serialization port="result" indent="true"/>-->

  <p:import href="http://xproc.org/library/recursive-directory-list.xpl"/>
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>

  <l:recursive-directory-list>
    <p:with-option name="path" select="'file:///home/vitt/Faust/document'"/>
  </l:recursive-directory-list>

  <p:for-each>
    <p:iteration-source select="//c:file"/>
    <p:variable name="filename" select="p:resolve-uri(/c:file/@name)"/>
    
    
    <p:load>
      <p:with-option name="href" select="$filename"/>
    </p:load>
    
    <p:xslt>
      <p:input port="stylesheet">
        <p:inline>
          <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
            xmlns="http://www.faustedition.net/ns" xpath-default-namespace="http://www.faustedition.net/ns"
            xmlns:tei="http://www.tei-c.org/ns/1.0"
            xmlns:f="http://www.faustedition.net/ns"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xmlns:c="http://www.w3.org/ns/xproc-step"
            exclude-result-prefixes="c tei xsi l">
            
            <xsl:import href="utils.xsl"/>
            
            <xsl:param name="root"/>

            <xsl:variable name="archivalSigs" select="( 'wa_faust', 'bohnenkamp', 'fischer_lamberg', 
              'landeck', 'fa', 'ma', 'aa_ls_helenaank', 'aa_wilhelmmeister', 'aa_duw', 'aa_ls_chines', 
              'aa_ls_aristpoet', 'aa_ls_kuaschemata', 'aa_ls_stoffgeh', 'aa_ls_wesentrag', 'wa_helenaank', 
              'wa_gedichte', 'wa_div', 'wa_naus', 'wa_tasso', 'wa_chines', 'wa_aristpoet', 'wa_wesentrag', 
              'wa_mur', 'wa_prologberltheat', 'wa_rueckkgrossh', 'wa_schlusspalneot', 'wa_zuwallenstlag', 
              'gsa_2', 'fdh_frankfurt', 'dla_marbach', 'sb_berlin', 'ub_leipzig', 'ub_bonn', 'veste_coburg', 
              'gm_duesseldorf', 'sa_hannover', 'thlma_weimar', 'bb_cologny', 'ub_basel', 'bj_krakow', 
              'agad_warszawa', 'bb_vicenza', 'bl_oxford', 'bl_london', 'ul_edinburgh', 'ul_yale', 
              'tml_new_york', 'ul_pennstate', 'mlm_paris', 'gsa_1')"/>
            <xsl:variable name="printSigs" select="( 'hagen', 'wa_faust', 'wa_gedichte', 
              'wa_I_53', 'hagen_nr', 'dla_marbach')"/>
            <xsl:variable name="sigil-set" 
              select="if (/f:archivalDocument) then $archivalSigs else $printSigs"/>
            <xsl:function name="f:sigil-priority">
              <xsl:param name="type"/>
              <xsl:value-of select="if ($type = $sigil-set) then index-of($sigil-set, $type) else 9999"/>
            </xsl:function>
            
            
            <xsl:template match="/">
              <f:transcript>
                <xsl:apply-templates select="//f:textTranscript"/>
              </f:transcript>
            </xsl:template>
            
            <xsl:template match="f:textTranscript[@uri]">
              <xsl:variable name="idnos">
                <xsl:apply-templates select="../f:idno[@type]">
                  <xsl:sort select="f:sigil-priority(@type)" data-type="number"/>
                </xsl:apply-templates>
              </xsl:variable>
              <xsl:variable name="preferred-idno">
                <xsl:sequence select="$idnos/f:idno[1]"/>
              </xsl:variable>
              
              <xsl:copy>                
                <xsl:variable name="uri" select="resolve-uri(@uri, (ancestor-or-self::*/@xml:base)[1])"></xsl:variable>
                <xsl:attribute name="uri" select="$uri"/>
                <xsl:attribute name="document" select="f:relativize($root, document-uri(/))"/>
                <xsl:attribute name="type" select="local-name(/*)"/>
                <xsl:variable name="file" select="replace($uri, '^faust://xml/', $root)"/>
                <xsl:variable name="href" select="if (ends-with($file, '.xml')) then $file else concat($file, '.xml')"/>
                <xsl:attribute name="href" select="$href"/>
                <xsl:if test="not(doc-available($href))">
                  <xsl:message select="concat('WARNING: Referenced transcript is missing: ', $href, ' (referred to from ', document-uri(/), ')')"/>
                </xsl:if>
                <xsl:attribute name="f:sigil" select="$preferred-idno">
                </xsl:attribute>
                <xsl:copy-of select="$idnos"/>
              </xsl:copy>
            </xsl:template>
            
            <xsl:template match="f:idno">
              <xsl:if test="normalize-space(.) != 'none'">
                <xsl:copy>
                  <xsl:copy-of select="@*"/>
                  <xsl:attribute name="uri" select="concat('faust://document/', @type, '/', replace(normalize-space(.), '\s+', '_'))"/>
                  <xsl:attribute name="priority" select="f:sigil-priority(@type)"/>
                  <xsl:value-of select="normalize-space(.)"/>
                </xsl:copy>
              </xsl:if>
            </xsl:template>
            
          </xsl:stylesheet>
        </p:inline>
      </p:input>
      <p:with-param name="root" select="$root"/>
    </p:xslt>
           
  </p:for-each>

  <p:wrap-sequence wrapper="f:doc"/>
    
  
</p:declare-step>
