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
  
  <xsl:param name="appabbrs" select="doc('../text/abbreviations.xml')"/>
  
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
        <xsl:variable name="variantfile" select="f:safely-resolve(concat(f:output-group($n), '.html'), f:safely-resolve($variants))"/>          
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
  
  <xsl:template match="note[@type='textcrit']//text()">
    <xsl:analyze-string select="." regex="[⟨⟩〈〉]+">
      <xsl:matching-substring>
        <span class="generated-text">
          <xsl:value-of select="."/>
        </span>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:value-of select="."/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
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
  
  <xsl:template match="note[@type='textcrit'][preceding-sibling::*[1][self::space[@unit='lines']]]" mode="#default"/>   
  
  <xsl:template match="note[@type='textcrit']" priority="1" mode="#default force">
    <span>
      <xsl:attribute name="class" select="f:generic-classes(.), 'appnote'" separator=" "/>
      <xsl:call-template name="highlight-group">
        <xsl:with-param name="others" select="f:referenced-segs(.)"/>
      </xsl:call-template>
      <xsl:apply-templates/>
      <xsl:variable name="prevapp" select="preceding::note[@type='textcrit'][1]"/>
      <xsl:variable name="nextapp" select="following::note[@type='textcrit'][1]"/>
      <span class="applinks">
        <xsl:if test="$prevapp">
          <a href="{f:link-to($prevapp)/@href}" title="vorheriger Apparateintrag"><i class="fa fa-up-dir"></i></a>        
        </xsl:if>
        <xsl:if test="$nextapp">
          <a href="{f:link-to($nextapp)/@href}" title="nächster Apparateintrag"><i class="fa fa-down-dir"></i></a>        
        </xsl:if>        
      </span>
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
    </span>
  </xsl:template>
  
  <xsl:template match="ref[starts-with(@target, 'faust://app/')]">
    <xsl:variable name="type_id" select="substring-after(@target, 'faust://app/')"/>
    <a title="{f:rdg-type-descr($type_id)}" href="{$edition}/print/app#{$type_id}">
      <xsl:attribute name="class" select="f:generic-classes(.)" separator=" "/>
      <xsl:apply-templates/>
    </a>
  </xsl:template>
  
  
  <xsl:template match="app//subst">
    <xsl:apply-templates select="*[1]"/>
    <span class="generated-text note"> : </span>
    <xsl:apply-templates select="*[2]"/>
    <xsl:if test="not(empty(subsequence(*, 3))) or text()[normalize-space(.) != '']">
      <xsl:message>ERROR: extra content in subst: <xsl:copy-of select="."/></xsl:message>
      <xsl:apply-templates select="node() except (*[1], *[2])"/>
    </xsl:if>
  </xsl:template>
    
  <xsl:template match="gap[@reason='ellipsis']">
    <i>
      <xsl:attribute name="class" select="f:generic-classes(.), 'generated-text'" separator=" "/>
      <xsl:text> bis </xsl:text>
    </i>
  </xsl:template>

  <xsl:template match="abbr[$appabbrs//abbr/text() = text()]">
    <xsl:variable name="current-text" select="data(.)"/>
    <xsl:variable name="expansion" select="$appabbrs//abbr[. = $current-text]/../expan"/>
    <abbr>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="class" select="f:generic-classes(.)" separator=" "/>
      <xsl:if test="$expansion">
        <xsl:attribute name="title" select="$expansion"/>
      </xsl:if>
      <xsl:apply-templates/>
    </abbr>
  </xsl:template>
  
  <xsl:template match="ref[starts-with(@target, 'faust://bibliography/')]" priority="1">
    <xsl:sequence select="f:cite(@target, false(), node())"/>
  </xsl:template>
  

  <xsl:template name="extra-nav" match="f:extra-nav"> <!-- FIXME need better criterion -->					
    <div class="print-guide">
      <h4>Legende</h4>
      <div>
        <span class="variants-1"> 1 </span>
        <span class="variants-6"> – </span>
        <span class="variants-12"> 12 </span>  Varianten
      </div>
      <div>
        <span style="background-color:rgb(250,190,0,0.20);"> 1 </span>
        <span style="background-color:rgb(250,190,0,0.55);"> – </span>
        <span style="background-color:rgb(250,190,0,1.00);"> 16 </span>  Textzeugen
      </div>
    </div>
  </xsl:template>			
  
</xsl:stylesheet>
