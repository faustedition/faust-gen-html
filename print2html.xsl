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

  <xsl:include href="html-common.xsl"/>
  
  <!-- Der Ausgabeordner für die HTML-Dateien. -->
  <xsl:param name="html" select="resolve-uri('target/html')"/>

  <!-- Pfad zu den zuvor generierten Varianten. Die HTML-Files dort müssen existieren. -->
  <xsl:param name="variants" select="resolve-uri('variants/', $html)"/>
      
  <!-- Dateiname/URI für die Ausgabedatei(en) ohne Endung. -->
  <xsl:param name="output-base"
    select="resolve-uri(replace(base-uri(), '^.*/(.*)\.xml$', '$1'), $html)"/>
  
  <!-- 
    Bis zu welcher Ebene sollen die Dateien aufgesplittet werden? $depth ist die
    max. Anzahl von divs auf der ancestor-or-self-Achse für einen Split, also 2 = Szenen.    
  -->
  <xsl:param name="depth">2</xsl:param>
  <xsl:variable name="depth_n" select="number($depth)"/>
  
  <xsl:param name="splitcond" select="4"/>
  
  <!-- Soll überhaupt gesplittet werden? Wir machen das nur bei vier oder mehr dingens. -->
  <xsl:param name="split" select="count(//div) gt number($splitcond)"/>
  
  <!-- Gesamttitel für die Datei. -->
  <xsl:param name="title" select="//title[1]"/>
  
  <!-- print oder archivalDocument? -->
  <xsl:param name="type"/>
  
  
  <!-- 
  
  Globales Steuergerüst
  =====================
  
  HTML-Framework etc.
  
  -->

  <xsl:output method="xhtml" include-content-type="yes"/>

  <xsl:template match="/">
    <xsl:for-each select="/TEI/text">
      <!-- Focus -->
      <xsl:call-template name="generate-html-frame"/>
      <xsl:if test="$split">
        <xsl:result-document href="{$output-base}.all.html">
          <xsl:call-template name="generate-html-frame">
            <xsl:with-param name="single" select="true()"/>
          </xsl:call-template>        
        </xsl:result-document>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>
  
  
  <!--
    
    Behandlung für "inhaltliche" TEI-Elemente
    ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    TODO was hiervon gemeinsam mit der Variantenerzeugung?
    
   -->

  <xsl:key name="alt" match="alt" use="for $ref in tokenize(@target, '\s+') return substring($ref, 2)"/>
<!-- Die Behandlung von den meisten Elementen ist relativ gleich: -->
  <xsl:template match="*" mode="#default single">
    <!-- # Varianten aus dem variants-Folder auslesen: -->
    <xsl:variable name="varcount">
      <xsl:choose>
        <xsl:when test="@n">
          <xsl:variable name="n" select="@n"/>
          <xsl:value-of
            select="document(concat($variants, f:output-group($n), '.html'))/xh:div/xh:div[@data-n = $n]/@data-size"
          />
        </xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!-- Dann ein Element erzeugen: div oder span oder p, siehe utils.xsl -->
    <xsl:element
      name="{f:html-tag-name(.)}">
      <xsl:if test="@n">
        
        <!-- Ein paar (für's JS interessante) Daten speichern wir in data-Attributen: -->
        <xsl:attribute name="data-n" select="@n"/>
        <xsl:attribute name="data-varcount" select="$varcount"/>
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
        if (@n) then ('hasvars', concat('varcount-', $varcount)) else (),
        if (@xml:id and key('alt', @xml:id)) then 'alt' else (),
        if (@n and @part) then ('antilabe', concat('part-', @part)) else ()), ' ')"/>

      <!-- Zeilennummer als link, wird dann in lesetext.css weggestylt -->
      <xsl:call-template name="generate-lineno"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:element>
  </xsl:template>
  
  <!-- Erzeugt die Zeilennummer vor der Zeile -->
  <xsl:template name="generate-lineno">
    <xsl:variable name="display-line" select="f:lineno-for-display(@n)"/>
    <xsl:if test="number($display-line) gt 0">
      <!-- Klick auf Zeilennummer führt zu einem Link, der wiederum auf die Zeilennummer verweist -->
      <xsl:attribute name="id" select="concat('l', @n)"/>
      <a href="#l{@n}">
        <xsl:attribute name="class">
          <xsl:text>lineno</xsl:text>
          <!-- Jede 5. ist immer sichtbar, alle anderen nur wenn über die Zeile gehovert wird -->
          <xsl:if test="$display-line mod 5 != 0">
            <xsl:text> invisible</xsl:text>
          </xsl:if>
        </xsl:attribute>
        <xsl:value-of select="$display-line"/>
      </a>
    </xsl:if>
  </xsl:template>

  <!-- divs, die bis zu $depth tief verschachtelt sind, werden im Standardmodus zerlegt: -->
  <xsl:template match="div[$split and count(ancestor::div) lt number($depth_n)]" mode="#default">
    <xsl:variable name="filename">
      <xsl:call-template name="filename"/>
    </xsl:variable>
    <xsl:variable name="divhead" select="normalize-space(head[1])"/>

    <!-- Dazu fügen wir an der entsprechenden Stelle ein Inhaltsverzeichnis aller untergeordneter Dateien ein: -->
    <ul class="toc">
      <xsl:apply-templates select="." mode="toc"/>
    </ul>

    <!-- … während für den eigentlichen Inhalt ein neues Dokument erzeugt wird. -->
    <xsl:result-document href="{$filename}">
      <xsl:call-template name="generate-html-frame"/>
    </xsl:result-document>
  </xsl:template>

  <!-- Berechnet den Dateinamen für das aktuelle div. -->
  <xsl:template name="filename">
    <xsl:variable name="divno">
      <xsl:number count="div" level="any" format="1"/>
    </xsl:variable>
    <xsl:value-of select="concat($output-base, '.', $divno, '.html')"/>
  </xsl:template>

  
  <xsl:template mode="toc" match="div[count(ancestor::div) lt $depth_n]">
    <li>
      <xsl:call-template name="section-link"/>
      <xsl:if test=".//div[count(ancestor::div) lt $depth_n]">
        <ul class="toc">
          <xsl:apply-templates mode="#current"/>
        </ul>
      </xsl:if>
    </li>
  </xsl:template>
  <xsl:template mode="toc" match="node()"/>

  <!-- Erzeugt einen Link zum aktuellen (Fokus) div. -->
  <xsl:template name="section-link">
    <xsl:param name="class"/>
    <xsl:param name="prefix"/>
    <xsl:param name="suffix"/>
    <xsl:variable name="filename">
      <xsl:call-template name="filename"/>
    </xsl:variable>
    <a>
      <xsl:attribute name="href" select="f:relativize($output-base, $filename)"/>        
      
      <xsl:if test="$class">
        <xsl:attribute name="class" select="string-join($class, ' ')"/>
      </xsl:if>
      <xsl:copy-of select="$prefix"/>
      <xsl:choose>
        <xsl:when test="head">
          <xsl:value-of select="normalize-space(head[1])"/>
        </xsl:when>
        <xsl:otherwise> [<xsl:value-of select="normalize-space(*[text()][1])"/>]
        </xsl:otherwise>
      </xsl:choose>
      <xsl:copy-of select="$suffix"/>
    </a>
  </xsl:template>
  
  
  
  <!-- 
    Erzeugt das Grundgerüst einer HTML-Datei und ruft dann 
    <xsl:apply-templates/> für den Inhalt auf. 
  -->
  <xsl:template name="generate-html-frame">
    <!-- Single = true => alles auf einer Seite -->
    <xsl:param name="single" select="false()"/>
    <html>
      <xsl:call-template name="html-head"/>
      <body>
        <xsl:call-template name="header"/>
        
        <main>
          <div class="main-content-container">
            <div id="main-content" class="main-content">
              <div id="main" class="print">
                <div class="print-side-column"/> <!-- 1. Spalte (1/5) bleibt erstmal frei -->
                <div class="print-center-column">  <!-- 2. Spalte (3/5) für den Inhalt -->
                  <xsl:choose>
                    <xsl:when test="$single">
                      <xsl:apply-templates mode="single"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:apply-templates/>
                    </xsl:otherwise>
                  </xsl:choose>
                </div>
                <div class="print-side-column">  <!-- 3. Spalte (1/5) für die lokale Navigation  -->
                  <xsl:call-template name="local-nav">
                    <xsl:with-param name="single" select="$single"/>
                  </xsl:call-template>
                </div>
              </div>
            </div>
          </div>
        </main>
        <xsl:call-template name="footer"/>
      </body>
    </html>
  </xsl:template>
  
  

  <!-- Erzeugt eine lokale Navigation für das aktuelle (Fokus) div, d.h. Breadcrumbs, Prev/Next -->
  <xsl:template name="local-nav">
    <xsl:param name="single" select="false()"/>
    <xsl:variable name="current-div" select="."/>
    <nav class="print-navigation">

      <!-- Breadcrumbs als Liste: Zuoberst Titel, dann die übergeordneten Heads, schließlich der aktuelle Head -->
      <ul class="breadcrumbs icons-ul">
        <!-- Der Titel kann hereingegeben werden oder aus dem TEI-titleStmt kommen -->
        <li>
          <i class="icon-li icon-caret-up"/>
          <a href="{f:relativize($output-base, concat($output-base, '.html'))}">
            <xsl:value-of select="$title"/>
          </a>
        </li>

        <xsl:for-each select="ancestor-or-self::div">
          <li>
            <xsl:choose>              
              <xsl:when test=". is $current-div">
                <xsl:attribute name="class">current</xsl:attribute>
                <i class="icon-li icon-caret-left"/>
              </xsl:when>
              <xsl:otherwise>
                <i class="icon-li icon-caret-up"/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="section-link"/>
          </li>
        </xsl:for-each>
      </ul>

      <!-- ggf. Links zum vorherigen/nächsten div. -->
      <ul class="prevnext icons-ul">
        <xsl:if test="preceding::div[count(ancestor::div) lt $depth_n]">
          <li class="prev">
            <xsl:for-each
              select="preceding::div[count(ancestor::div) lt $depth_n][1]">
              <i class="icon-li icon-backward"/>
              <xsl:call-template name="section-link"/>              
            </xsl:for-each>
          </li>
        </xsl:if>
        <xsl:if test="following::div[count(ancestor::div) lt $depth_n]">
          <li class="next">
            <xsl:for-each
              select="following::div[count(ancestor::div) lt $depth_n][1]">
              <i class="icon-li icon-forward"/>
              <xsl:call-template name="section-link"/>
            </xsl:for-each>
          </li>
        </xsl:if>
      </ul>
      

      <xsl:if test="$split">
        <ul class="icons-ul">
          <!-- Link zum  alles-auf-einer-Seite-Dokument. -->
          <li class="all">
            <xsl:choose>
              <xsl:when test="$single">
                <i class="icon-li icon-copy"/>
                <a href="{f:relativize($output-base, concat($output-base, '.html'))}">nach Szenen zerlegt</a>
              </xsl:when>
              <xsl:otherwise>
                <i class="icon-li icon-file-alt"/>
                <a href="{f:relativize($output-base, concat($output-base, '.all.html'))}">auf einer Seite</a>
              </xsl:otherwise>
            </xsl:choose>
          </li>
        </ul>
      </xsl:if>
    </nav>
  </xsl:template>

  <xsl:template name="html-head">
    <xsl:param name="title" select="$title"/>
    <head>
      <meta charset='utf-8'/>

      <script type="text/javascript" src="../js/faust_common.js"/>
      <script src="../js/faust_print_view.js"/>
      <link href="//netdna.bootstrapcdn.com/font-awesome/3.2.1/css/font-awesome.css" rel="stylesheet"/>
      <link rel="stylesheet" href="../css/document-text.css"/>
      <link rel="stylesheet" href="../css/document-transcript.css"/>
      <link rel="stylesheet" href="../css/document-transcript-highlight-hands.css"/>
      <link rel="stylesheet" href="../css/document-transcript-interaction.css"/>
      <link rel="stylesheet" href="../css/pure-custom.css"/>
      <link rel="stylesheet" href="../css/basic_layout.css"/>
    </head>

  </xsl:template>

  <xsl:template name="header">
    <header>
      <div class="header-content">
        <a class="faustedition-logo" title="Faustedition" href="../index.php">
          <img class="faustedition-logo-svg" src="../img/faustlogo.svg" alt="Faustedition logo"/>
        </a>
        <nav class="header-navigation pure-menu">
          <a href="../archives.php">Archiv</a>
          <xsl:text> </xsl:text>
          <a href="../chessboard_overview.php">Genese</a>
          <xsl:text> </xsl:text>
          <a href="../lesetext_demo/index.html">Text</a>
          <xsl:text> </xsl:text>
          <input autocomplete="off" id="quick-search" placeholder="Search" type="text"/>
        </nav>
      </div>
    </header>
  </xsl:template>

  <xsl:template name="footer">
    <footer>
      <div id='footer-content' class='footer-content'>
        <b>Digitale Faust-Edition</b> • Copyright (c) 2009-2015 • Freies Deutsches Hochstift Frankfurt • Klassik Stiftung Weimar • Universität Würzburg
      </div>
      <div id="footer-navigation" class="footer-navigation">
        <a href="../K_Hilfe.php">Hilfe</a>
        <xsl:text> </xsl:text>
        <a href="../K_Kontakt.php">Kontakt</a>
        <xsl:text> </xsl:text>
        <a href="../K_Impressum.php">Impressum</a>
        <xsl:text> </xsl:text>
        <a href="../Startseite.php">Projekt</a>
      </div>
    </footer>
  </xsl:template>

</xsl:stylesheet>
