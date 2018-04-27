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
  
  <xsl:param name="apptypes" select="doc('../text/apptypes.xml')"/>
  
  <xsl:output method="xhtml" include-content-type="yes"/>

  
  
  <!--
    
    Behandlung für "inhaltliche" TEI-Elemente
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    TODO was hiervon gemeinsam mit der Variantenerzeugung?
    
   -->
  
  <!-- liefert für ein $n den entsprechenden Apparat-HTML-Block -->
  <xsl:function name="f:variant-info">
    <xsl:param name="n" as="item()?"/>
    <xsl:choose>
      <xsl:when test="$n">        
        <xsl:variable name="variantfile" select="resolve-uri(concat(f:output-group($n), '.html'), resolve-uri($variants))"/>          
        <xsl:sequence
          select="document($variantfile)/xh:div/xh:div[@data-n = $n]"
        />
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:function>
  
  <!-- Die Behandlung der meisten Elemente ist relativ gleich: -->
  <xsl:template match="*[f:hasvars(.)]" priority="-0.1" name="variant-line">
    <xsl:param name="content"/>
    <!-- # Varianten aus dem variants-Folder auslesen: -->
    <xsl:variable name="varinfo" as="node()*" select="f:variant-info(@n)"/>
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
      <xsl:choose>
        <xsl:when test="$content">
          <xsl:copy-of select="$content"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="#current"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="space[@unit='lines'][f:hasvars(.)]" priority="5">
    <xsl:call-template name="variant-line">
      <xsl:with-param name="content">
        <xsl:next-match/>
      </xsl:with-param>
    </xsl:call-template>
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
      <xsl:variable name="lemma-after-bracket" select="((note|wit)[1], (note|wit)[1]/following-sibling::node())"/>
      <xsl:variable name="lemma-before-bracket" select="node() except $lemma-after-bracket"/>
      <xsl:variable name="lemma-str" select="f:normalize-space($lemma-before-bracket)"/>      
      <span class="{string-join(f:generic-classes(.), ' ')}">
        <xsl:apply-templates select="$lemma-before-bracket"/>
      </span>
      <xsl:if test="not(matches($lemma-str, '\s+$'))">
        <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:if test="not(normalize-space($lemma-str) = '')">
        <span class="generated-text">] </span>
      </xsl:if>
      <xsl:apply-templates select="$lemma-after-bracket"/>      
    </xsl:if>
  </xsl:template>
  
  <xsl:template match="lem//wit | rdg//wit">
    <xsl:variable name="varinfo" select="f:variant-info(ancestor::*[f:hasvars(.)][1]/@n)"/>
    <xsl:variable name="sigil-link" select="f:resolve-faust-doc(@wit, $transcript-list)"/>
    <xsl:variable name="link-from-varinfo" select="($varinfo//xh:a[data(.) = data($sigil-link)])[1]"/>
    <xsl:variable name="witness-link" select="if ($link-from-varinfo) then $link-from-varinfo else $sigil-link"/>
    <xsl:choose>
      <xsl:when test="@f:is-base">
        <strong>
          <xsl:sequence select="$witness-link"/>
        </strong>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$witness-link"/>
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
        <xsl:variable name="types" select="tokenize(@type, '\s+')"/>
        <xsl:choose>
          <xsl:when test="count($types) > 1">
            <xsl:text>(</xsl:text>
            <xsl:for-each select="$types">
              <a class="reading-type" href="app#{.}" title="{.}">
                <xsl:value-of select="f:format-rdg-type(.)"/>                
              </a>
              <xsl:if test="position() != last()">, </xsl:if>
            </xsl:for-each>
            <xsl:text>)</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <a class="reading-type" href="app#{$types}" title="{f:rdg-type-descr($types)}">
                <xsl:value-of select="concat('(', f:format-rdg-type($types), ')')"/>
            </a>            
          </xsl:otherwise>
        </xsl:choose>
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
  
  <xsl:function name="f:rdg-type-descr" as="xs:string">
    <xsl:param name="type"/>
    <xsl:variable name="exact-match" select="$apptypes//f:apptype[@type=$type]"/>
    <xsl:variable name="start-match" select="$apptypes//f:apptype[starts-with($type, @type)][1]"/>
    <xsl:variable name="result">
      <xsl:choose>
        <xsl:when test="$exact-match[self::f:apptype]">
          <xsl:value-of select="$exact-match"/>
        </xsl:when>
        <xsl:when test="$start-match">
          <xsl:value-of select="$start-match"/>
          <xsl:variable name="rest" select="substring($type, string-length($start-match/@type)+1)"/>
          <xsl:choose>
            <xsl:when test="$rest = '*'"> (nicht übernommen)</xsl:when>
            <xsl:otherwise> (<xsl:value-of select="$rest"/>)<xsl:message select="concat('WARNING: Label for app type ', $type, ' incomplete: rest »', $rest, '«')"/></xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$type"/>
          <xsl:message select="concat('ERROR: No apparatus type description for ', $type)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$result"/>
  </xsl:function>
  
  <xsl:template match="gap[@reason='ellipsis']">
    <i>
      <xsl:attribute name="class" select="f:generic-classes(.), 'generated-text'" separator=" "/>
      <xsl:text> bis </xsl:text>
    </i>
  </xsl:template>
  
  
</xsl:stylesheet>
