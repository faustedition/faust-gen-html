<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml" xmlns:xh="http://www.w3.org/1999/xhtml"
	xmlns:f="http://www.faustedition.net/ns"	
	exclude-result-prefixes="xs"
	version="2.0">
  
  <xsl:import href="html-frame.xsl"/>
	
	<!--<xsl:variable name="transcripts" select="collection()[2]"/>-->
	<xsl:param name="title">Lesetext</xsl:param>
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

          <section class="center pure-g-r">

            <div class="pure-u-1-5"></div>

            <article class="pure-u-3-5 pure-center">
                  
                  <xsl:if test="$type = 'overview'">
                    <h1>Text</h1>
                    <p class="pure-tiles">
                     <a href="text.html" title="Lesetext" class="pure-button pure-button-tile">Lese&#xAD;text</a>
                     <a href="prints.html" title="Drucke" class="pure-button pure-button-tile">Drucke</a>
                     <a href="archivalDocuments.html" title="Handschriften" class="pure-button pure-button-tile">Hand&#xAD;schriften</a>
                    </p>
                  </xsl:if>


                  <xsl:if test="tokenize($type, ' ') = 'text'">
                    <h1>Lesetext</h1>
                    <p class="pure-tiles">
                     <a href="faust1.html" title="Faust I" class="pure-button pure-button-tile">Faust I</a>
                     <a href="faust2.html" title="Faust II" class="pure-button pure-button-tile">Faust II</a>
                    </p>
                  </xsl:if>
                  

                  <xsl:if test="tokenize($type, ' ') = 'print'">              
                    <h1>Drucke</h1>
                    <dl>
                      <xsl:variable name="mdlist" select="/"/>
                      
                      <xsl:for-each select="document(concat($source, '/print-labels.xml'))//f:item">
                        <xsl:variable name="uri" select="@uri"/>
                        <xsl:variable name="md" select="$mdlist//f:textTranscript[@uri=$uri][1]"/>
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
                  </xsl:if>

                  <xsl:if test="$type = 'archivalDocument'">
                    <h1>Handschriften</h1>                    
                    <ul>
                      <xsl:for-each select="//f:textTranscript[@type='archivalDocument']">
                        <xsl:sort select="f:idno[1]"/>
                        <xsl:variable name="filename" select="replace(@href, '^.*/([^/]+)', '$1')"/>
                        <xsl:variable name="htmlname" select="replace($filename, '\.xml$', '')"/>                        
                        <li><a href="{$htmlname}.html" title="{f:sigil-label(f:idno[1]/@type)}">
                          <xsl:value-of select="if (f:idno[1]) then f:idno[1] else concat('!! keine Sigle – faust://xml/', @document)"/>
                        </a></li>                        
                      </xsl:for-each>
                    </ul>
                  </xsl:if>


            </article>

            <div class="pure-u-1-5"></div>

          </section>

				<xsl:call-template name="footer"/>
			</body>
		</html>
		
	</xsl:template>
	
	
</xsl:stylesheet>
