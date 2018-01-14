<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.w3.org/1999/xhtml" xmlns:xh="http://www.w3.org/1999/xhtml"
  xmlns:f="http://www.faustedition.net/ns"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xs f" version="2.0">

  <!-- 
    Erzeugt aus einem bereinigten TEI (Pipeline apply-edits) 
    eine vollständige HTML-Seite mit dem entsprechenden Rendering 
    und Variantenapparat. 
  -->

  <xsl:import href="html-frame.xsl"/>
  <xsl:include href="html-common.xsl"/>
  <xsl:include href="split.xsl"/>
  
  <xsl:param name="view">print</xsl:param>
  <xsl:param name="scriptAdditions"/>
  
  <xsl:output method="xhtml" include-content-type="yes"/>

  
  
  <!--
    
    Behandlung für "inhaltliche" TEI-Elemente
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    TODO was hiervon gemeinsam mit der Variantenerzeugung?
    
   -->
  
<!-- Die Behandlung von den meisten Elementen ist relativ gleich: -->
  <xsl:template match="*" priority="-0.1">
    <!-- # Varianten aus dem variants-Folder auslesen: -->
    <xsl:variable name="varinfo" as="node()*">
      <xsl:choose>
        <xsl:when test="@n">
          <xsl:variable name="n" select="@n"/>
          <xsl:variable name="variantfile" select="resolve-uri(concat(f:output-group($n), '.html'), resolve-uri($variants))"/>          
          <xsl:sequence
            select="document($variantfile)/xh:div/xh:div[@data-n = $n]"
          />
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="varcount" select="if ($varinfo) then $varinfo/@data-witnesses else 0"/>
    
    <!-- Dann ein Element erzeugen: div oder span oder p, siehe utils.xsl -->
    <xsl:element
      name="{f:html-tag-name(.)}">
      <xsl:if test="f:hasvars(.)">
        
        <!-- Ein paar (für's JS interessante) Daten speichern wir in data-Attributen: -->
        <xsl:attribute name="data-n" select="@n"/>
        <xsl:attribute name="data-varcount" select="$varcount"/>
        <xsl:attribute name="data-variants" select="if ($varinfo) then $varinfo/@data-variants else 0"/>
        <xsl:attribute name="data-vargroup" select="f:output-group(@n)"/>
        
        <!-- 
          Individuelles Styling via @style-Attribut. Der bevorzugte Weg ist über die Klassen, 
          style wird im Moment nur für den (berechneten) Einzug der Antilaben verwendet.
        -->
        <xsl:call-template name="generate-style"/>
      </xsl:if>
      
      <!--
          Die meisten interessanten Informationen werden im @class-Attribut festgehalten und können so über CSS gestylt
          oder via JS selektiert werden:
          • (lokaler) Name des TEI-Elements
          • Werte aus @rend, jeweils mit 'rend-' präfigiert, also z.B. rend-small
          • hasvars und varcount-n (mit n = Zahl) für Zeilen mit Varianten
          • antilabe und part-X für Antilaben
      -->
      <xsl:attribute name="class" select="string-join((f:generic-classes(.),
        if (f:hasvars(.)) then (
          'hasvars', 
          concat('varcount-', $varcount),
          concat('variants-', if ($varinfo) then $varinfo/@data-variants else 0),
          if ($varinfo/@ctext != normalize-space(.)) then 'real-variant' else () 
        ) else (),
        if (@n and @part) then ('antilabe', concat('part-', @part)) else ()), ' ')"/>
      
      <xsl:if test="@xml:id and key('alt', @xml:id)">
        <xsl:call-template name="highlight-group"/>
        <xsl:attribute name="title">zur Auswahl</xsl:attribute>
      </xsl:if>

      <!-- Zeilennummer als link, wird dann in textual-transcript.css weggestylt -->
      <xsl:call-template name="generate-lineno"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  
  
  <!-- Critical apparatus -->
  <xsl:template match="note[@type='textcrit']/ref">
    <span class="{string-join((f:generic-classes(.), 'lineno'), ' ')}">
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  
  <xsl:template match="note[@type='textcrit']/app/lem">
    <span class="{string-join(f:generic-classes(.), ' ')}">
      <xsl:apply-templates/>
    </span>
    <xsl:text>] </xsl:text>
  </xsl:template>
  
  <xsl:template match="note[@type='textcrit']/app/rdg">
    <span class="{string-join(f:generic-classes(.), ' ')}">
      <xsl:apply-templates/>
      <xsl:if test="@wit">
        <xsl:text> </xsl:text>
        <xsl:sequence select="f:doclink(@wit, (), ../@n)"/>
      </xsl:if>
      <xsl:if test="@type">
        <span class="reading-type">
          <xsl:value-of select="concat(' [Typ ', @type, ']')"/>
        </span>
      </xsl:if>
    </span>
  </xsl:template>
  
  


</xsl:stylesheet>
