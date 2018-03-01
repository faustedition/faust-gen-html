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
  <xsl:import href="bibliography.xsl"/>
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
  <xsl:template match="*[f:hasvars(.)]" priority="-0.1">
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
    <xsl:text> </xsl:text>
  </xsl:template>
  
  <!-- Returns all elements that are referenced by the current apparatus' @from attribute -->
  <xsl:function name="f:referenced-segs" as="element()*">
    <xsl:param name="context"/>
    <xsl:variable name="apps" select="$context/descendant-or-self::app"/>
    <xsl:for-each select="$apps">
      <xsl:variable name="app" select="."/>
      <xsl:for-each select="tokenize(@from, '\s+')">
        <xsl:variable name="id" select="replace(., '^#', '')"/>
        <xsl:sequence select="id($id, $app)"/>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:function>
  
  <xsl:template match="note[@type='textcrit']" priority="1">
    <span>
      <xsl:attribute name="class" select="f:generic-classes(.), 'appnote'" separator=" "/>
      <xsl:call-template name="highlight-group">
        <xsl:with-param name="others" select="f:referenced-segs(.)"/>
      </xsl:call-template>
      <xsl:apply-templates/>
    </span>
  </xsl:template>
  
  <xsl:key name="app-for-seg" match="app" use="for $f in tokenize(@from, '\s+') return replace($f, '^#', '')"/>
  <xsl:template match="seg[@xml:id]">
    <xsl:variable name="id" select="@xml:id"/>
    <xsl:variable name="current-app" select="key('app-for-seg', $id)"/>
    <span>
      <xsl:attribute name="class" select="f:generic-classes(.), 'appnote'" separator=" "/>
      <xsl:call-template name="highlight-group">
        <xsl:with-param name="others" select="$current-app/.., f:referenced-segs($current-app)"/>
      </xsl:call-template>
      <xsl:apply-templates/>
    </span>
  </xsl:template>

  <xsl:template match="note[@type='textcrit']/app">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="note[@type='textcrit']/app/lem">
    <xsl:if test="node()">
      <xsl:variable name="lemma-tei" select="node() except ((note|wit)[1], (note|wit)[1]/following-sibling::node())"/>
      <xsl:variable name="lemma">
        <xsl:apply-templates select="f:normalize-space-xml($lemma-tei)"/>
      </xsl:variable>
      <span class="{string-join(f:generic-classes(.), ' ')}">
        <xsl:sequence select="$lemma"/>
      </span>
      <xsl:if test="not(matches(string-join($lemma, ''), '\s+$'))">
        <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:text>] </xsl:text>
      <xsl:apply-templates select="(note|wit)[1], (note|wit)[1]/following-sibling::node()"/>      
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="lem//wit | rdg//wit">
    <xsl:choose>
      <xsl:when test="@f:is-base">
        <strong>
          <xsl:sequence select="f:resolve-faust-doc(@wit, $transcript-list)"/>          
        </strong>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="f:resolve-faust-doc(@wit, $transcript-list)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  
  <xsl:template match="note[@type='textcrit']/app/rdg">
    <xsl:text> </xsl:text>
    <span class="{string-join(f:generic-classes(.), ' ')}">
      <xsl:apply-templates/>
      <xsl:if test="@wit">
        <xsl:comment select="concat('wit=', @wit, ' transcript-list=', $transcript-list)"/>        
      </xsl:if>
      <xsl:if test="@type">
        <xsl:value-of select="if (position() = last()) then ' ' else ' '"/>   <!-- em space before last type -->
        <a class="reading-type" href="app#{@type}" title="{@type}">
          <xsl:value-of select="concat('(', f:format-rdg-type(@type), ')')"/>
        </a>
      </xsl:if>
    </span>
  </xsl:template>
  
  <xsl:function name="f:format-rdg-type" as="xs:string">
    <xsl:param name="type"/>
    <xsl:variable name="typeno" select="replace($type, '^type_', '')"/>
    <xsl:variable name="formatted-typeno">
      <xsl:analyze-string select="$typeno" regex="\d+">
        <xsl:matching-substring>
          <xsl:number format="I" value="."/>
          <xsl:text> </xsl:text>
        </xsl:matching-substring>
        <xsl:non-matching-substring>
          <xsl:copy/>
        </xsl:non-matching-substring>
      </xsl:analyze-string>
    </xsl:variable>
    <xsl:value-of select="string-join($formatted-typeno, '')"/>
  </xsl:function>
  
  <xsl:template match="gap[@reason='ellipsis']">
    <i>
      <xsl:attribute name="class" select="f:generic-classes(.)" separator=" "/>
      <xsl:text> bis </xsl:text>
    </i>
  </xsl:template>
  
  
</xsl:stylesheet>
