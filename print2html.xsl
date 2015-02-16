<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xh="http://www.w3.org/1999/xhtml"
  xmlns:f="http://www.faustedition.net/ns"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" version="2.0">
  
  <xsl:import href="utils.xsl"/>
  
  <xsl:param name="variants">variants/</xsl:param>

  <xsl:output method="html" doctype-public="html"/>

  <xsl:template match="/">

    <html class="yui3-loading">
      <head>
        <title>Digitale Faust-Edition: Lesetext (Beispiel)</title>



        <!-- http://purecss.io/ -->
        <link rel="stylesheet" href="https://faustedition.uni-wuerzburg.de/new/static/css/pure-min.css"/>
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
        <link rel="stylesheet" href="https://faustedition.uni-wuerzburg.de/new/static/css/pure-custom.css"/>
        <link rel="stylesheet" href="https://faustedition.uni-wuerzburg.de/new/static/css/style.css"/>
        <script src="https://code.jquery.com/jquery-1.11.0.min.js"/>
        <script src="https://faustedition.uni-wuerzburg.de/new/static/js/functions.js"/>



        <link rel="stylesheet" type="text/css"
          href="https://faustedition.uni-wuerzburg.de/new/resources?yui3/build/cssreset/reset-min.css&amp;yui3/build/cssgrids/grids-min.css&amp;yui3/build/cssbase/base-min.css"/>

        <link rel="stylesheet" type="text/css" href="https://faustedition.uni-wuerzburg.de/new/static/css/faust.css"/>
        
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
                varfile = 'variants/' + group + '.html',
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
      <body class="yui3-skin-sam">



        <header class="">
          <div class="center">
            <a class="logo" href="/new/" title="Faustedition">
              <img src="https://faustedition.uni-wuerzburg.de/new/static/img/logo.svg" width="380" height="30" alt="Faustedition"/>
            </a>

            <div class="pure-menu pure-menu-open pure-menu-horizontal pure-submenu pure-right">
              <ul>
                <li>
                  <a href="https://faustedition.uni-wuerzburg.de/new/xml-query/">
                    <i class="icon-wrench"/> Query</a>
                </li>
                <li>
                  <a href="https://faustedition.uni-wuerzburg.de/new/project/contact">Kontakt</a>
                </li>
                <li>
                  <a href="https://faustedition.uni-wuerzburg.de/new/project/imprint">Impressum</a>
                </li>
                <li>
                  <a href="https://faustedition.uni-wuerzburg.de/new/project/about">Projekt</a>
                </li>
              </ul>
            </div>
            <nav class="pure-menu pure-menu-open pure-menu-horizontal pure-right">
              <ul>
                <li>
                  <a href="https://faustedition.uni-wuerzburg.de/new/archive/">Archiv</a>
                </li>
                <li>
                  <a href="https://faustedition.uni-wuerzburg.de/new/genesis/work/">Genese</a>
                </li>
                <li>
                  <a href="https://faustedition.uni-wuerzburg.de/new/text/sample">Text</a>
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

          
          <div class="yui3-g" style="margin-top: 2em">
            <div class="yui3-u-1-5"></div>            
            <div class="yui3-u-3-5">
              <xsl:apply-templates select="//text"/>
            </div>
          </div>
        </div>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="*">
    <xsl:variable name="varcount">
      <xsl:choose>
        <xsl:when test="@n">
          <xsl:variable name="n" select="@n"/>
          <xsl:value-of select="document(concat($variants, f:output-group($n), '.html'))/xh:div/xh:div[@data-n = $n]/@data-size"/>
        </xsl:when>
        <xsl:otherwise>0</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- FIXME improve span/div detection -->
    <xsl:element name="{if (@n or self::div or self::l or self::lg or self::p or self::sp) then 'div' else 'span'}">      
      <xsl:if test="@n">
        <xsl:attribute name="data-n" select="@n"/>
        <xsl:attribute name="data-varcount" select="$varcount"/>        
        <xsl:attribute name="data-vargroup" select="f:output-group(@n)"/>
        <xsl:attribute name="title" select="concat($varcount, ' variants.')"></xsl:attribute>
      </xsl:if>
      <xsl:attribute name="class">
        <xsl:value-of select="concat(local-name(.), ' ')"/>
        <xsl:value-of select="concat(@rend, ' ')"/>
        <xsl:if test="@n">
          <xsl:value-of select="concat('linenum-', @n, ' hasvars ', 'varcount-', $varcount)"/>
        </xsl:if>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="figure">
    <br class="figure {@type}"/>
  </xsl:template>
  
  <xsl:template match="lb">
    <br class="lb"/>
  </xsl:template>

</xsl:stylesheet>
