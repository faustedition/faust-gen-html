<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml" xmlns:xh="http://www.w3.org/1999/xhtml"
	xmlns:f="http://www.faustedition.net/ns"	
	exclude-result-prefixes="xs"
	version="2.0">
	
	<!--<xsl:variable name="transcripts" select="collection()[2]"/>-->
	<xsl:param name="title">Lesetexte</xsl:param>
        <xsl:param name="source">https://faustedition.uni-wuerzburg.de/xml</xsl:param>
  <xsl:param name="type">text print</xsl:param>  <!-- might be text, print, archivalDocument, overview, sep. by space -->
	<xsl:output method="xhtml"/>

        <xsl:include href="utils.xsl"/>
	
	
	<xsl:template match="/">
		<html>
			<xsl:call-template name="html-head">
				<xsl:with-param name="title" select="$title"/>
			</xsl:call-template>
			<body>
				<xsl:call-template name="header"/>

        <main>
          <div class="main-content-container">
            <div id="main-content" class="main-content">
              <div id="main" class="print">
                <div class="print-side-column"/> <!-- 1. Spalte (1/5) bleibt erstmal frei -->
                <div class="print-center-column">  <!-- 2. Spalte (3/5) für den Inhalt -->
                  
                  <xsl:if test="$type = 'overview'">
                    <nav>
                      <ul>
                        <li><a href="text.html">Lesetext</a></li>
                        <li><a href="prints.html">Drucke</a></li>
                        <li><a href="archivalDocuments.html">Handschriften</a></li>
                      </ul>
                    </nav>                    
                  </xsl:if>


                  <xsl:if test="tokenize($type, ' ') = 'text'">
                    <h2>Lesetexte</h2>
                    <nav>
                      <ul>
                        <li><a href="faust1.html">Faust I</a></li>
                        <li><a href="faust2.html">Faust II</a></li>
                      </ul>
                      </nav>
                  </xsl:if>
                  
                  <xsl:if test="tokenize($type, ' ') = 'print'">              
                  <h2>Drucke</h2>
                  
                    <nav>
                    <dl>
                      
                      <xsl:variable name="mdlist" select="/"/>
                      
                      <xsl:for-each select="document(concat($source, '/print-labels.xml'))//f:item">
                        
                        <xsl:variable name="uri" select="@uri"/>
                        <xsl:variable name="md" select="$mdlist//f:textTranscript[@uri=$uri]"/>
                        <xsl:variable name="filename" select="replace($md/@href, '^.*/([^/]+)', '$1')"/>
                        <xsl:variable name="htmlname" select="replace($filename, '\.xml$', '')"/>
                        <xsl:variable name="sigil" select="$md/f:idno[1]"/>
                        <xsl:variable name="sigil-label" select="f:sigil-label($sigil/@type)"/>
                        <xsl:variable name="description" select="."/>
                        
                        
                          <dt title="{$sigil-label}">
                            <a href="{$htmlname}.html">
                              <xsl:value-of select="$sigil"/>
                            </a>
                          </dt>
                          <dd>
                            <xsl:value-of select="$description"/>
                          </dd>
                      </xsl:for-each>
                      
                    </dl>
                    </nav>
                    
                  </xsl:if>

                  <xsl:if test="$type = 'archivalDocument'">
                  <nav>
                    <h2>Handschriften</h2>                    
                    <ul>
                      <xsl:for-each select="//f:textTranscript[@type='archivalDocument']">
                        <xsl:variable name="filename" select="replace(@href, '^.*/([^/]+)', '$1')"/>
                        <xsl:variable name="htmlname" select="replace($filename, '\.xml$', '')"/>
                        <li><a href="{$htmlname}.html" title="{f:sigil-label(f:idno[1]/@type)}">
                          <xsl:value-of select="f:idno[1]"/>
                        </a></li>                        
                      </xsl:for-each>
                    </ul>
                  </nav>
                  </xsl:if>
                </div>
              </div>
            </div>
          </div>
        </main>

				<xsl:call-template name="footer"/>
			</body>
		</html>
		
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
      <link rel="stylesheet" href="lesetext.css"/>
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
