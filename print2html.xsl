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
  <xsl:param name="depth" select="2"/>
  
  <!-- Soll überhaupt gesplittet werden? Wir machen das nur bei vier oder mehr dingens. -->
  <xsl:param name="split" select="count(//div) gt 4"/>
  
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
  <xsl:template match="div[$split and count(ancestor::div) lt $depth]" mode="#default">
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

  
  <xsl:template mode="toc" match="div[count(ancestor::div) lt $depth]">
    <li>
      <xsl:call-template name="section-link"/>
      <xsl:if test=".//div[count(ancestor::div) lt $depth]">
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
    <html class="yui3-loading">
      <xsl:call-template name="html-head"/>
      <body class="yui3-skin-sam">
        <xsl:call-template name="header"/>
        
        <div id="main" class="center">
          <div class="yui3-g" style="margin-top: 2em">
            <div class="yui3-u-1-5"/> <!-- 1. Spalte (1/5) bleibt erstmal frei -->
            <div class="yui3-u-3-5">  <!-- 2. Spalte (3/5) für den Inhalt -->
              <xsl:choose>
                <xsl:when test="$single">
                  <xsl:apply-templates mode="single"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates/>
                </xsl:otherwise>
              </xsl:choose>
            </div>
            <div class="yui3-u-1-5">  <!-- 3. Spalte (1/5) für die lokale Navigation  -->
              <xsl:call-template name="local-nav">
                <xsl:with-param name="single" select="$single"/>
              </xsl:call-template>
            </div>
          </div>
        </div>
      </body>
    </html>
  </xsl:template>
  
  

  <!-- Erzeugt eine lokale Navigation für das aktuelle (Fokus) div, d.h. Breadcrumbs, Prev/Next -->
  <xsl:template name="local-nav">
    <xsl:param name="single" select="false()"/>
    <xsl:variable name="current-div" select="."/>
    <nav>

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
        <xsl:if test="preceding::div[count(ancestor::div) lt $depth]">
          <li class="prev">
            <xsl:for-each
              select="preceding::div[count(ancestor::div) lt $depth][1]">
              <i class="icon-li icon-backward"/>
              <xsl:call-template name="section-link"/>              
            </xsl:for-each>
          </li>
        </xsl:if>
        <xsl:if test="following::div[count(ancestor::div) lt $depth]">
          <li class="next">
            <xsl:for-each
              select="following::div[count(ancestor::div) lt $depth][1]">
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
      <title>Digitale Faust-Edition: <xsl:value-of select="$title"/></title>



      <!-- http://purecss.io/ -->
      <link rel="stylesheet"
        href="https://faustedition.uni-wuerzburg.de/new/static/css/pure-min.css"/>
      <!-- http://fortawesome.github.io/Font-Awesome/ -->
      <link
        href="//netdna.bootstrapcdn.com/font-awesome/3.2.1/css/font-awesome.css"
        rel="stylesheet"/>
      <!-- http://www.google.com/fonts/: light, normal, medium, bold -->
      <link
        href="https://fonts.googleapis.com/css?family=Ubuntu:300,300italic,400,400italic,500,500italic,700,700italic"
        rel="stylesheet" type="text/css"/>
      <!-- http://www.google.com/fonts/: normal, bold -->
      <link
        href="https://fonts.googleapis.com/css?family=Ubuntu+Mono:400,400italic,700,700italic"
        rel="stylesheet" type="text/css"/>
      <link rel="stylesheet"
        href="https://faustedition.uni-wuerzburg.de/new/static/css/pure-custom.css"/>
      <link rel="stylesheet"
        href="https://faustedition.uni-wuerzburg.de/new/static/css/style.css"/>
      <script src="https://code.jquery.com/jquery-1.11.0.min.js"/>
      <script src="https://faustedition.uni-wuerzburg.de/new/static/js/functions.js"/>



      <link rel="stylesheet" type="text/css"
        href="https://faustedition.uni-wuerzburg.de/new/resources?yui3/build/cssreset/reset-min.css&amp;yui3/build/cssgrids/grids-min.css&amp;yui3/build/cssbase/base-min.css"/>

      <link rel="stylesheet" type="text/css"
        href="https://faustedition.uni-wuerzburg.de/new/static/css/faust.css"/>

      <!-- FIXME merge with faust.css -->
      <link rel="stylesheet" type="text/css" href="lesetext.css"/>



      <script type="text/javascript">
        var cp = '/new';
        var Faust = { contextPath: cp, FacsimileServer: "https://faustedition.uni-wuerzburg.de/images/iipsrv.fcgi" };
      </script>
      <script type="text/javascript" src="https://faustedition.uni-wuerzburg.de/new/static/yui3/build/yui/yui-debug.js"/>
      <script type="text/javascript" src="https://faustedition.uni-wuerzburg.de/new/static/js/yui-config.js"/>
      <script type="text/javascript" src="https://faustedition.uni-wuerzburg.de/new/static/js/faust.js"/>

      <link rel="schema.DC" href="http://purl.org/dc/elements/1.1/"/>
      <link rel="schema.DCTERMS" href="http://purl.org/dc/terms/"/>
      <meta name="DC.format" scheme="DCTERMS.IMT" content="text/html"/>
      <meta name="DC.type" scheme="DCTERMS.DCMIType" content="Text"/>
      <meta name="DC.publisher" content="Digitale Faust-Edition"/>
      <meta name="DC.creator" content="Digitale Faust-Edition"/>
      <meta name="DC.subject"
        content="Faust, Johann Wolfgang von Goethe, Historisch-kritische Edition, digital humanities"/>
      <!-- 
	<meta name="DCTERMS.license"  scheme="DCTERMS.URI" content="http://www.gnu.org/copyleft/fdl.html">
	<meta name="DCTERMS.rightsHolder" content="Wikimedia Foundation Inc.">
	 -->
      <script type="text/javascript">
        Faust.YUI().use('event', 'node', 'base', 'io', 'json', 'interaction', function(Y) {
        
        var lines = Y.all('.hasvars');
        
        function lineNumberForLine(line) {
        return line.getAttribute('data-n');
        }
        
        //var lineNumbers = [];
        
        lines.each(function(line) {
        // lineNumbers.push(lineNumberForLine(line));
        var n = lineNumberForLine(line),
        variants = parseInt(line.getAttribute('data-varcount')),
        group = line.getAttribute('data-vargroup'),
        varfile = '<xsl:value-of select="f:relativize($output-base, $variants)"/>' + group + '.html',
        c = 255 - (Math.min(variants - 1, 10) * 5);
        line.setStyle('backgroundColor', 'rgb(' + c + ',' + c + ',' + c + ')');
        line.on('mouseenter', function(e) {
        console.log("Entering a line with ", variants, " variants");
        Y.fire('faust:mouseover-info', { info: variants + ' variants.', mouseEvent: e });
        });
        line.on('mouseleave', function(e) { Y.fire('faust:mouseover-info-hide', {})});
        line.on('click', function(e) {
        Y.all('.variants').remove(true);
        var ioConfig = {
        on: {
        success: function(transactionId, response, arguments) {
        var html = Y.Node.create(response.responseText),
        variants = html.one('#v'+n);                    
        line.ancestor().insert(variants, line);
        }
        }
        }
        Y.io(varfile, ioConfig);
        });
        
        });
        });
      </script>

    </head>
  </xsl:template>
  <xsl:template name="header">
    <header class="">
      <div class="center">
        <a class="logo" href="/new/" title="Faustedition">
          <img
            src="https://faustedition.uni-wuerzburg.de/new/static/img/logo.svg"
            width="380" height="30" alt="Faustedition"/>
        </a>

        <div
          class="pure-menu pure-menu-open pure-menu-horizontal pure-submenu pure-right">
          <ul>
            <li>
              <a href="https://faustedition.uni-wuerzburg.de/new/xml-query/">
                <i class="icon-wrench"/> Query</a>
            </li>
            <li>
              <a
                href="https://faustedition.uni-wuerzburg.de/new/project/contact"
                >Kontakt</a>
            </li>
            <li>
              <a
                href="https://faustedition.uni-wuerzburg.de/new/project/imprint"
                >Impressum</a>
            </li>
            <li>
              <a href="https://faustedition.uni-wuerzburg.de/new/project/about"
                >Projekt</a>
            </li>
          </ul>
        </div>
        <nav class="pure-menu pure-menu-open pure-menu-horizontal pure-right">
          <ul>
            <li>
              <a href="https://faustedition.uni-wuerzburg.de/new/archive/"
                >Archiv</a>
            </li>
            <li>
              <a href="https://faustedition.uni-wuerzburg.de/new/genesis/work/"
                >Genese</a>
            </li>
            <li>
              <a href="https://faustedition.uni-wuerzburg.de/new/text/sample"
                >Text</a>
            </li>
            <li>
              <form class="pure-form">
                <input id="quick-search" type="text" placeholder="Suche"/>
              </form>
            </li>
          </ul>
        </nav>
      </div>

    </header>
  </xsl:template>

</xsl:stylesheet>
