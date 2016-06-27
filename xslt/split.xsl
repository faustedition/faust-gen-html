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
					<xsl:with-param name="content">
						<xsl:variable name="previous-section" select="preceding::div[@f:section][1]"/>
						<xsl:comment><xsl:value-of select="concat(boolean($previous-section), '; ', name($previous-section), '; ', $previous-section/@f:section)"/></xsl:comment>
						<xsl:variable name="start" select="if ($previous-section) then $previous-section else /TEI/teiHeader"/>						
						<xsl:variable name="preceding-stuff" select="preceding::* intersect $start/following::*"/>
						<xsl:if test="$preceding-stuff">
							<div class="preceding-content">
								<xsl:comment>
									<xsl:apply-templates mode="debugxml" select="$preceding-stuff"/>
								</xsl:comment>
								<xsl:apply-templates select="$preceding-stuff"/>
							</div>
						</xsl:if>
												
						<div>
							<xsl:call-template name="generate-style"/>
							<xsl:attribute name="id" select="f:generate-id(.)"/>
							<xsl:attribute name="class" select="string-join(f:generic-classes(.), ' ')"/>
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
	</xsl:template>
	
	
	<xsl:template mode="tocpage" match="div">
		<li>
<!--			<a href="{f:html-link(concat($output-base, '.', f:get-section-number(.)))}">
				<xsl:value-of select="f:normalize-space(head)"/>
				<xsl:comment>
					<xsl:for-each select="@*"><xsl:value-of select="concat(name(), '=', ., ' ')"/></xsl:for-each>
				</xsl:comment>
			</a>
-->			<xsl:call-template name="section-link"/>
			<xsl:if test="descendant::div[@f:section]">
				<ul>
					<xsl:apply-templates mode="#current"/>
				</ul>
			</xsl:if>
		</li>	
	</xsl:template>
	<xsl:template mode="tocpage" match="*">
		<xsl:apply-templates mode="#current"/>
	</xsl:template>
	<xsl:template mode="tocpage" match="node()" priority="-1"/>

	
	
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
		<xsl:variable name="secno" select="f:get-section-number(.)"/>
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
		<xsl:variable name="filename">
			<xsl:call-template name="filename"/>
		</xsl:variable>
		<xsl:variable name="page" select="preceding::pb[@f:docTranscriptNo][1]/@f:docTranscriptNo"/>
		<xsl:variable name="basename" select="f:relativize($output-base, $filename)"/>
		<xsl:variable name="href" select="if (@xml:id) 
												then concat(f:html-link($filename, $page), '#', @xml:id)
												else f:html-link($filename, $page)"/>
		<a>
			<xsl:attribute name="href" select="$href"/>        
			
			<xsl:if test="$class">
				<xsl:attribute name="class" select="string-join($class, ' ')"/>
			</xsl:if>
			<xsl:copy-of select="$prefix"/>
			
			<xsl:variable name="title">
				<xsl:apply-templates mode="title" select="if (head) then head[1] else *[translate(normalize-space(.), ' ', '') ne ''][1]"/>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="@f:scene-label or @f:act-label">
					<xsl:value-of select="(@f:scene-label, @f:act-label)"/>
				</xsl:when>
				<xsl:when test="head">
					<xsl:copy-of select="$title"/>
				</xsl:when>				
				<xsl:otherwise>[<xsl:copy-of select="$title"/>]</xsl:otherwise>
			</xsl:choose>			
			<xsl:copy-of select="$suffix"/>
		</a>
	</xsl:template>
	
	<xsl:template match="lb[not(@break='no')]" mode="title">
		<xsl:text> </xsl:text>    
	</xsl:template>
	
	
	
	<!-- 
    Erzeugt das Grundgerüst einer HTML-Datei und ruft dann 
    <xsl:apply-templates/> für den Inhalt auf. 
  -->
	<xsl:template name="generate-html-frame">
		<!-- Single = true => alles auf einer Seite -->
		<xsl:param name="single" select="false()" tunnel="yes"/>
		<xsl:param name="content"><xsl:apply-templates/></xsl:param>
		<xsl:param name="sidebar"><xsl:call-template name="local-nav"/></xsl:param>
		<html>
			<xsl:call-template name="html-head"/>
			<body>
				<xsl:call-template name="header"/>
				
				<main class="nofooter">
					<div  class="print">
						<div class="print-side-column"/> <!-- 1. Spalte (1/5) bleibt erstmal frei -->
						<div class="print-center-column">  <!-- 2. Spalte (3/5) für den Inhalt -->
							<xsl:sequence select="$content"/>
						</div>
						<div class="print-side-column">  <!-- 3. Spalte (1/5) für die lokale Navigation  -->
							<xsl:sequence select="$sidebar"/>
						</div>
					</div>
				</main>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>
	
	
	
	<!-- Erzeugt eine lokale Navigation für das aktuelle (Fokus) div, d.h. Breadcrumbs, Prev/Next -->
	<xsl:template name="local-nav">
		<xsl:param name="single" tunnel="yes" select="f:is-splitable-doc(.)"/>
		<xsl:variable name="current-div" select="."/>
		<nav class="print-navigation">
			
			<!-- Breadcrumbs als Liste: Zuoberst Titel, dann die übergeordneten Heads, schließlich der aktuelle Head -->
			<ul class="breadcrumbs fa-ul">
				<!-- Der Titel kann hereingegeben werden oder aus dem TEI-titleStmt kommen -->
				<li>
					<span class="fa-li fa fa-up-dir"/>
					<a href="{f:html-link($output-base)}">
						<xsl:value-of select="$title"/>
					</a>
				</li>
				
				<xsl:for-each select="ancestor-or-self::div">
					<li>
						<xsl:choose>              
							<xsl:when test=". is $current-div">
								<xsl:attribute name="class">current-section</xsl:attribute>
								<span class="fa-li fa fa-left-dir"/>
							</xsl:when>
							<xsl:otherwise>
								<span class="fa-li fa fa-up-dir"/>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:call-template name="section-link"/>
					</li>
				</xsl:for-each>
			</ul>
			
			<!-- ggf. Links zum vorherigen/nächsten div. -->
			<ul class="prevnext fa-ul">
				<xsl:if test="preceding::div[count(ancestor::div) lt $depth_n]">
					<li class="prev">
						<xsl:for-each
							select="preceding::div[count(ancestor::div) lt $depth_n][1]">
							<span class="fa-li fa fa-fast-bw"/>
							<xsl:call-template name="section-link"/>              
						</xsl:for-each>
					</li>
				</xsl:if>
				<xsl:if test="following::div[count(ancestor::div) lt $depth_n]">
					<li class="next">
						<xsl:for-each
							select="following::div[count(ancestor::div) lt $depth_n][1]">
							<span class="fa-li fa fa-fast-fw"/>
							<xsl:call-template name="section-link"/>
						</xsl:for-each>
					</li>
				</xsl:if>
			</ul>
			
			
			<ul class="fa-ul">
				<xsl:if test="f:is-splitable-doc(.)">
					<!-- Link zum  alles-auf-einer-Seite-Dokument. -->
					<li class="all">
						<xsl:choose>
							<xsl:when test="$single">
								<span class="fa-li fa fa-docs"/>
								<a href="{f:html-link($output-base)}">nach Szenen zerlegt</a>
							</xsl:when>
							<xsl:otherwise>
								<span class="fa-li fa fa-doc"/>
								<a href="{f:html-link(concat($output-base, '.all'))}">auf einer Seite</a>
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
	
	<xsl:template name="breadcrumbs-old">		
		<xsl:choose>
			
			<!-- Lesetext -->
			<xsl:when test="$type = 'lesetext'">
				<a href="text">Text</a>
				>
				<xsl:choose>
					<xsl:when test="starts-with($output-base, 'faust1')">
						<a href="faust1">Faust I</a>
					</xsl:when>
					<xsl:otherwise>
						<a href="faust2">Faust II</a>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:call-template name="div-breadcrumbs"/>				
			</xsl:when>
			
			
			<!-- Druck -->
			<xsl:when test="$type = 'print'">
				<xsl:variable name="lineno" select="f:numerical-lineno((.//*[f:hasvars(.)])[1]/@n)"/>
				<xsl:variable name="scene" select="reverse(document('scenes.xml')//f:scene[number(f:rangeStart) le number($lineno)])[1]"/>
				<a href="genesis">Genese</a>
				>
				<xsl:choose>
					<xsl:when test="starts-with($scene/f:id, '1')">
						<a href="{$edition}/chessboard_faust_i">Faust I</a>
					</xsl:when>
					<xsl:otherwise>
						<a href="{$edition}/chessboard_faust_ii">Faust II</a>
					</xsl:otherwise>
				</xsl:choose>
				>
				<a href="{$edition}/geneticBarGraph?rangeStart={$scene/f:rangeStart}&amp;rangeEnd={$scene/f:rangeEnd}">
					<xsl:value-of select="$scene/f:title"/>
				</a>
				<br/>
				<a href="{$edition}/archive">Archiv</a>
				>
				<a href="{$edition}/archive_prints">Drucke</a>
				>
				<a href="{f:html-link($output-base)}"><xsl:value-of select="$title"/></a>
				<xsl:call-template name="div-breadcrumbs"/>
			</xsl:when>
			
			<xsl:otherwise>
				<xsl:comment>
					Keine Brotkrumen weil type = <xsl:value-of select="$type"/>
				</xsl:comment>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="div-breadcrumbs">
		<xsl:for-each select="ancestor-or-self::div">
			> 
			<xsl:call-template name="section-link"/>
		</xsl:for-each>
	</xsl:template>
	
	
	
</xsl:stylesheet>
