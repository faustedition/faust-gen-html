<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml" xmlns:xh="http://www.w3.org/1999/xhtml"
	xmlns:f="http://www.faustedition.net/ns"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs f" 	
	version="2.0">
	
	
	<!-- 
	
	This stylesheet contains rules to render the HTML in a split mode. It is included by both print2html.xsl and apparatus.xsl
	
	-->
	
	
	<!-- Der Ausgabeordner für die HTML-Dateien. -->
	<xsl:param name="html" select="resolve-uri('target/html')"/>
	
	<!-- Pfad zu den zuvor generierten Varianten. Die HTML-Files dort müssen existieren. -->
	<xsl:param name="variants" select="resolve-uri('variants/', $html)"/>
	
	<!-- Dateiname/URI für die Ausgabedatei(en) ohne Endung. -->
	<xsl:param name="output-base"
		select="resolve-uri(//idno[@type='fausttranscript'][1], $html)"/>
	
	
	<!-- Gesamttitel für die Datei. -->
	<xsl:param name="title" select="//title[1]"/>
	
	<!-- print oder archivalDocument oder lesetext? -->
	<xsl:param name="type"/>
	
	<xsl:param name="documentURI"/>

	

	<!-- 
    Auf welcher Ebene sollen die Dateien aufgesplittet werden? $depth ist die
    max. Anzahl von divs auf der ancestor-or-self-Achse für einen Split, also 2 = Szenen.    
  -->
	<xsl:param name="depth">2</xsl:param>
	<xsl:variable name="depth_n" select="number($depth)"/>
	
	<xsl:template match="/TEI[not(@f:split)]">
		<xsl:call-template name="generate-html-frame">
			<xsl:with-param name="content">
				<xsl:apply-templates select="text"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>


	<xsl:template match="/TEI[@f:split]">
		<xsl:call-template name="generate-html-frame">
			<xsl:with-param name="single" select="false()" tunnel="yes"/>
			<xsl:with-param name="content">
				<nav class="toc">
					<ul>
						<xsl:apply-templates mode="tocpage"/>						
					</ul>
				</nav>				
			</xsl:with-param>
		</xsl:call-template>
		<xsl:for-each select=".//div[@f:section]">
			<xsl:result-document href="{$output-base}.{@f:section}.html">
				<xsl:call-template name="generate-html-frame">
					<xsl:with-param name="single" select="false()" tunnel="yes"/>
					<xsl:with-param name="content">
						<xsl:variable name="previous-section" select="preceding::div[@f:section][1]"/>
						<xsl:comment><xsl:value-of select="concat(boolean($previous-section), '; ', name($previous-section), '; ', $previous-section/@f:section)"/></xsl:comment>
						<xsl:variable name="start" select="if ($previous-section) then $previous-section else /TEI/teiHeader"/>						
						<xsl:variable name="raw-preceding-stuff" select="preceding::* intersect $start/following::*"/>
						<xsl:variable name="preceding-stuff" select="$raw-preceding-stuff except $raw-preceding-stuff/*"/>
						<xsl:if test="$preceding-stuff">
							<div class="preceding-content">
								<xsl:apply-templates select="$preceding-stuff"/>
							</div>
						</xsl:if>
												
						<div>
							<xsl:call-template name="generate-style"/>
							<xsl:attribute name="class" select="string-join(f:generic-classes(.), ' ')"/>
							<a name="{f:generate-id(.)}" id="{f:generate-id(.)}"/>
							<!-- Just using an id attribute causes the whole div to be highlighted via :marked - not good for this case -->
							<xsl:apply-templates/>
						</div>
						
						<xsl:if test="position() = last()">
							<div class="following-content">
								<xsl:apply-templates select="following::*"/>
							</div>
						</xsl:if>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:result-document>
		</xsl:for-each>
		<xsl:result-document href="{$output-base}.all.html">
			<xsl:call-template name="generate-html-frame">
				<xsl:with-param name="single" select="true()" tunnel="yes"/>
				<xsl:with-param name="content">
					<xsl:apply-templates select="text"/>
				</xsl:with-param>
			</xsl:call-template>
		</xsl:result-document>
	</xsl:template>
	
	<xsl:template match="div[@xml:id]" priority="2">
		<a name="{f:generate-id(.)}" id="{f:generate-id(.)}"/>
		<xsl:next-match/>
	</xsl:template>
	
	<xsl:template mode="tocpage" match="div[@type='stueck']"/>
	
	<xsl:template mode="tocpage" match="div">
		<li>
			<xsl:call-template name="section-link">
				<xsl:with-param name="suffix">
					<xsl:if test="@f:first-verse != ''">
						<small class="pure-fade-50 verse">
							<xsl:text> (Verse </xsl:text>
							<xsl:value-of select="@f:first-verse"/>
							<xsl:if test="@f:last-verse != @f:first-verse">
								<xsl:text> – </xsl:text>
								<xsl:value-of select="@f:last-verse"/>
							</xsl:if>
							<xsl:text>)</xsl:text>
						</small>
					</xsl:if>
				</xsl:with-param>
			</xsl:call-template>
			<xsl:if test="descendant::div[@f:label]">
				<ul>
					<xsl:apply-templates mode="#current"/>
				</ul>
			</xsl:if>
		</li>	
	</xsl:template>
	
	<xsl:template mode="tocpage" match="titlePage[not(preceding::titlePage)]">
		<li>
			<xsl:call-template name="section-link">
				<xsl:with-param name="title">Titel</xsl:with-param>
			</xsl:call-template>
		</li>
	</xsl:template>
	
	<xsl:template mode="tocpage" match="*">
		<xsl:apply-templates mode="#current"/>
	</xsl:template>
	
	<xsl:template mode="tocpage" match="node()" priority="-1"/>
	
	<xsl:template match="titlePage[ancestor::TEI[@f:split]]">
		<a name="{f:generate-id(.)}"></a>
		<xsl:next-match/>
	</xsl:template>
	
	<!-- 
		Erzeugt einen Link zur angegebenen HTML-Datei (und optional: Seite). 
		Relativierung und ggf. einsetzen in das documentViewer-Template 
		erfolgen automatisch. 
	-->
	<xsl:function name="f:html-link">
		<xsl:param name="filename"/>
		<xsl:value-of select="f:html-link($filename, ())"/>
	</xsl:function>
	<xsl:function name="f:html-link">
		<xsl:param name="filename"/>
		<xsl:param name="page"/>
		<xsl:variable name="basename" select="f:relativize($output-base, $filename)"/>
		<xsl:value-of select="
			if ($type = 'archivalDocument') 
			then concat($docbase, '/', $documentURI, '&amp;section=', $basename,
			if ($page) then concat('&amp;page=', $page) else '',
			'&amp;view=', $view)
			else $basename"/>		
	</xsl:function>
	
	<xsl:template name="filename">
		<xsl:param name="toc" select="false()"></xsl:param>
		<xsl:variable name="secno" select="if ($toc) then false() else f:get-section-number(.)"/>
		<xsl:value-of select="$output-base"/>
		<xsl:if test="$secno">
			<xsl:text>.</xsl:text>
			<xsl:value-of select="$secno"/>
		</xsl:if>
	</xsl:template>
	
	<!-- Erzeugt einen Link zum aktuellen (Fokus) div. -->
	<xsl:template name="section-link">
		<xsl:param name="class"/>
		<xsl:param name="prefix"/>
		<xsl:param name="suffix"/>
		<xsl:param name="title">
			<xsl:apply-templates mode="title" select="if (head) then head[1] else *[translate(normalize-space(.), ' ', '') ne ''][1]"/>
		</xsl:param>
		<xsl:param name="href">			
			<xsl:call-template name="current-href"/>
		</xsl:param>
		<a>
			<xsl:attribute name="href" select="$href"/>        
			
			<xsl:if test="$class">
				<xsl:attribute name="class" select="string-join($class, ' ')"/>
			</xsl:if>
			<xsl:copy-of select="$prefix"/>
			
			<xsl:choose>
				<xsl:when test="@f:label">
					<xsl:value-of select="@f:label"/>
				</xsl:when>
				<xsl:when test="head">
					<xsl:copy-of select="$title"/>
				</xsl:when>				
				<xsl:otherwise>[<xsl:copy-of select="$title"/>]</xsl:otherwise>
			</xsl:choose>			
			<xsl:copy-of select="$suffix"/>
		</a>
	</xsl:template>
	
	<xsl:template name="current-href">
		<xsl:param name="toc" select="false()"/>
		<xsl:variable name="filename">
			<xsl:call-template name="filename">
				<xsl:with-param name="toc" select="$toc"></xsl:with-param>
			</xsl:call-template>
		</xsl:variable>
		<xsl:variable name="page" select="preceding::pb[@f:docTranscriptNo][1]/@f:docTranscriptNo"/>
		<xsl:variable name="basename" select="f:relativize($output-base, $filename)"/>
		<xsl:value-of
			select="
				if (@xml:id)
				then
					concat(f:html-link($filename, $page), '#', @xml:id)
				else
					f:html-link($filename, $page)"
		/>
	</xsl:template>
	
	<xsl:template match="lb[not(@break='no')]" mode="title">
		<xsl:text> </xsl:text>    
	</xsl:template>
	
	<!-- 
    Erzeugt das Grundgerüst einer HTML-Datei und ruft dann <xsl:apply-templates/> für den Inhalt auf. 
    Ein Wrapper um das generischere html-frame, das das dreispaltige Layout mit der Seitennavigation erzeugt. 
  	-->
	<xsl:template name="generate-html-frame">
		<!-- Single = true => alles auf einer Seite -->
		<xsl:param name="single" select="false()" tunnel="yes"/>
		<xsl:param name="content"><xsl:apply-templates/></xsl:param>
		<xsl:param name="sidebar"><xsl:call-template name="local-nav"/></xsl:param>
		<xsl:call-template name="html-frame">
			<xsl:with-param name="breadcrumb-def" tunnel="yes"><xsl:call-template name="breadcrumbs"/></xsl:with-param>
			<xsl:with-param name="section-classes" select="('center', 'print')"/>			
			<xsl:with-param name="grid-content">
				<div class="pure-u-1-5"/> <!-- 1. Spalte (1/5) bleibt erstmal frei -->
				<article class="pure-u-3-5">  <!-- 2. Spalte (3/5) für den Inhalt -->
					<xsl:if test="$type = 'lesetext'">
						<!-- Placeholder navigation to push down margin notes -->
						<xsl:for-each select="$sidebar/*">
							<xsl:copy copy-namespaces="no">
								<xsl:attribute name="class" select="string-join((@class, 'type-textcrit', 'placeholder'), ' ')"/>
								<xsl:copy-of select="@* except @class"/>
								<xsl:copy-of select="node()"/>
							</xsl:copy>
						</xsl:for-each>
					</xsl:if>
					<xsl:sequence select="$content"/>
				</article>
				<div class="pure-u-1-5">  <!-- 3. Spalte (1/5) für die lokale Navigation  -->
					<xsl:sequence select="$sidebar"/>
				</div>				
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	
	
	<!-- Erzeugt eine lokale Navigation für das aktuelle (Fokus) div, d.h. Breadcrumbs, Prev/Next -->
	<xsl:template name="local-nav">
		<xsl:param name="single" tunnel="yes" select="f:is-splitable-doc(.)"/>
		<xsl:variable name="current-div" select="."/>
		<nav class="print-navigation">
			
			<ul class="fa-ul">
				<li class="toclink">
					<xsl:if test="/TEI/@f:split and not(self::TEI)">
						<a>
							<xsl:attribute name="href">
								<xsl:call-template name="current-href">
									<xsl:with-param name="toc" select="true()"/>
								</xsl:call-template>								
							</xsl:attribute>
							<span class="fa-li fa fa-menu"/>
							<xsl:text>Inhaltsverzeichnis</xsl:text>
						</a>
					</xsl:if>
					&#160;	<!-- spacing -->
				</li>
			</ul>
			
			<!-- ggf. Links zum vorherigen/nächsten div. -->
			<ul class="prevnext fa-ul">
				<li class="prev">
					<xsl:if test="preceding::div[@f:section]">
						<xsl:for-each
							select="preceding::div[@f:section][1]">
							<xsl:call-template name="section-link">
								<xsl:with-param name="prefix">
									<span class="fa-li fa fa-fast-bw"/>									
								</xsl:with-param>
							</xsl:call-template>              
						</xsl:for-each>
					</xsl:if>
					&#160;	<!-- spacing -->
				</li>
				<li class="next">
					<xsl:if test="following::div[@f:section]">
						<xsl:for-each
							select="following::div[@f:section][1]">
							<xsl:call-template name="section-link">
								<xsl:with-param name="prefix">
									<span class="fa-li fa fa-fast-fw"/>									
								</xsl:with-param>
							</xsl:call-template>
						</xsl:for-each>
					</xsl:if>
					&#160;	<!-- spacing -->
				</li>
			</ul>
			
			
			<ul class="fa-ul">
				<xsl:if test="f:is-splitable-doc(.)">
					<!-- Link zum  alles-auf-einer-Seite-Dokument. -->
					<li class="all">
						<xsl:choose>
							<xsl:when test="$single">
								<span class="fa-li fa fa-docs"/>
								<a href="{f:html-link($output-base)}">Szenenansicht</a>
							</xsl:when>
							<xsl:otherwise>
								<span class="fa-li fa fa-doc"/>
								<a href="{f:html-link(concat($output-base, '.all'))}">Gesamtansicht</a>
							</xsl:otherwise>
						</xsl:choose>
					</li>
				</xsl:if>
			</ul>
			
			<xsl:if test="/TEI/@type = 'print'">
				<ul class="fa-ul">
					<li>
						<span class="fa-li fa fa-structure"/>					
						<a href="../meta/{replace(//idno[@type='fausturi'][1], '^.*/(.*?)\.xml$', '$1')}">Metadaten</a>
					</li>
				</ul>
			</xsl:if>
		</nav>
	</xsl:template>
	
</xsl:stylesheet>
