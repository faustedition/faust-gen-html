<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.w3.org/1999/xhtml"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" version="2.0">

  <xsl:output method="html" doctype-public="html"/>

  <xsl:template match="/">

    <html class="yui3-loading">
      <head>
        <title>Digitale Faust-Edition: Lesetext (Beispiel)</title>



        <!-- http://purecss.io/ -->
        <link rel="stylesheet" href="/new/static/css/pure-min.css"/>
        <!-- http://fortawesome.github.io/Font-Awesome/ -->
        <link href="//netdna.bootstrapcdn.com/font-awesome/3.2.1/css/font-awesome.css"
          rel="stylesheet"/>
        <!-- http://www.google.com/fonts/: light, normal, medium, bold -->
        <link
          href="https://fonts.googleapis.com/css?family=Ubuntu:300,300italic,400,400italic,500,500italic,700,700italic"
          rel="stylesheet" type="text/css"/>
        <!-- http://www.google.com/fonts/: normal, bold -->
        <link href="https://fonts.googleapis.com/css?family=Ubuntu+Mono:400,400italic,700,700italic"
          rel="stylesheet" type="text/css"/>
        <link rel="stylesheet" href="/new/static/css/pure-custom.css"/>
        <link rel="stylesheet" href="/new/static/css/style.css"/>
        <script src="https://code.jquery.com/jquery-1.11.0.min.js"/>
        <script src="/new/static/js/functions.js"/>



        <link rel="stylesheet" type="text/css"
          href="/new/resources?yui3/build/cssreset/reset-min.css&amp;yui3/build/cssgrids/grids-min.css&amp;yui3/build/cssbase/base-min.css"/>

        <link rel="stylesheet" type="text/css" href="/new/static/css/faust.css"/>



        <script type="text/javascript">
                      var cp = '/new';
                      var Faust = { contextPath: cp, FacsimileServer: "https://faustedition.uni-wuerzburg.de/images/iipsrv.fcgi" };
                    </script>
        <script type="text/javascript" src="/new/static/yui3/build/yui/yui-debug.js"/>
        <script type="text/javascript" src="/new/static/js/yui-config.js"/>
        <script type="text/javascript" src="/new/static/js/faust.js"/>

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


      </head>
      <body class="yui3-skin-sam">



        <header class="">
          <div class="center">
            <a class="logo" href="/new/" title="Faustedition">
              <img src="/new/static/img/logo.svg" width="380" height="30" alt="Faustedition"/>
            </a>

            <div class="pure-menu pure-menu-open pure-menu-horizontal pure-submenu pure-right">
              <ul>
                <li>
                  <a href="/new/xml-query/">
                    <i class="icon-wrench"/> Query</a>
                </li>
                <li>
                  <a href="/new/project/contact">Kontakt</a>
                </li>
                <li>
                  <a href="/new/project/imprint">Impressum</a>
                </li>
                <li>
                  <a href="/new/project/about">Projekt</a>
                </li>
              </ul>
            </div>
            <nav class="pure-menu pure-menu-open pure-menu-horizontal pure-right">
              <ul>
                <li>
                  <a href="/new/archive/">Archiv</a>
                </li>
                <li>
                  <a href="/new/genesis/work/">Genese</a>
                </li>
                <li>
                  <a href="/new/text/sample">Text</a>
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


        <div id="main" class="center">

          <script type="text/javascript">
            Faust.YUI().use('event', 'node', 'base', 'io', 'json', 'interaction', function(Y) {
            var lines = Y.all('.ann-l');
            
            function lineNumberForLine(line) {
            return parseInt(
            line.getAttribute('class')
            .split(' ')[1]
            .slice('linenum-'.length)
            )
            }
            
            var lineNumbers = [];
            lines.each(function(line){
            lineNumbers.push(lineNumberForLine(line));
            });
            
            function augmentText(id, o, args) {
            var variants = Y.JSON.parse(o.responseText);
            lines.each(function(line) {
            var variantsForLine = variants[lineNumberForLine(line)];
            var numOfVariantsForLine = variantsForLine.length;
            var c = 255 - (Math.min(numOfVariantsForLine - 1, 10) * 5);
            line.setStyle('backgroundColor', 'rgb(' + c + ',' + c + ',' + c + ')');
            
            
            line.on('mouseenter', function(e) {
            Y.fire('faust:mouseover-info', { info: numOfVariantsForLine + ' variants.', mouseEvent: e });
            });
            
            line.on('mouseleave', function(e) { Y.fire('faust:mouseover-info-hide', {})});
            
            line.on('click', function(e) {
            Y.all('.variant').remove(true);
            
            line.ancestor().insert('<div class="variant"><br/></div>', line);
            Y.each(variantsForLine, function(variant) {
            line.ancestor().insert(
            '<div class="variant">' +
              variant.variantText +
              ' <a href="' + cp + variant.source.slice('faust://xml'.length) + '">'
                + variant.name + '</a></div>', line);
            })
            });
            
            });
            }
            
            
            var ioConfig = {
            method: 'POST',
            data: Y.JSON.stringify(lineNumbers),
            headers: {
            'Content-Type': 'application/json'
            },
            on: {
            success: augmentText
            }
            };
            
            Y.io(cp + '/genesis/variants', ioConfig);
            
            });
          </script>
          
          <div class="yui3-g" style="margin-top: 2em">
            <div class="yui3-u-1-5"></div>            
            <div class="yui3-u-3-5">
              <xsl:apply-templates select="text"/>
            </div>
          </div>
        </div>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="*">
    <div>      
      <xsl:if test="@n">
        <xsl:attribute name="data-n" select="@n"/>
      </xsl:if>
      <xsl:attribute name="class">
        <xsl:value-of select="concat('ann-', local-name(.), ' ')"/>
        <xsl:value-of select="concat(@rend, ' ')"/>
        <xsl:if test="@n">
          <xsl:value-of select="concat('linenum-', @n)"/>
        </xsl:if>
      </xsl:attribute>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

</xsl:stylesheet>
