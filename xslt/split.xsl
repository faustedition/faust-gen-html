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
		select="resolve-uri(replace(base-uri(), '^.*/(.*)\.xml$', '$1'), $html)"/>
	
	
	<!-- Gesamttitel für die Datei. -->
	<xsl:param name="title" select="//title[1]"/>
	
	<!-- print oder archivalDocument oder lesetext? -->
	<xsl:param name="type"/>
	
	<xsl:param name="documentURI"/>

	

	<!-- 
    Bis zu welcher Ebene sollen die Dateien aufgesplittet werden? $depth ist die
    max. Anzahl von divs auf der ancestor-or-self-Achse für einen Split, also 2 = Szenen.    
  -->
	<xsl:param name="depth">2</xsl:param>
	<xsl:variable name="depth_n" select="number($depth)"/>


	<xsl:template match="/TEI">
		<xsl:for-each select="/TEI/text">
			<!-- Focus -->
			<xsl:call-template name="generate-html-frame">
				<xsl:with-param name="single" tunnel="yes" select="false()"/>
				<xsl:with-param name="breadcrumbs" tunnel="yes">
					<xsl:call-template name="breadcrumbs"/>
				</xsl:with-param>				
			</xsl:call-template>
			<xsl:if test="f:is-splitable-doc(.)">      
				<xsl:result-document href="{$output-base}.all.html">
					<xsl:call-template name="generate-html-frame">
						<xsl:with-param name="single" tunnel="yes" select="true()"/>
						<xsl:with-param name="breadcrumbs" tunnel="yes">
							<xsl:call-template name="breadcrumbs"/>
						</xsl:with-param>
					</xsl:call-template>        
				</xsl:result-document>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	

	
	<!-- divs, die bis zu $depth tief verschachtelt sind, werden im Standardmodus zerlegt: -->
	<xsl:template match="div[f:is-splitable-doc(.) and count(ancestor::div) lt number($depth_n)]">
		<xsl:param name="single" tunnel="yes" select="true()"/>
		<xsl:choose>
			<xsl:when test="$single">
				<xsl:next-match/>
			</xsl:when>
			
			<xsl:otherwise>            
				<xsl:variable name="filename">
					<xsl:call-template name="filename"/>
				</xsl:variable>
				<xsl:variable name="divhead" select="normalize-space(head[1])"/>
				
				<!-- Dazu fügen wir an der entsprechenden Stelle ein Inhaltsverzeichnis aller untergeordneter Dateien ein: -->
				<ul class="toc">
					<xsl:apply-templates select="." mode="toc"/>
				</ul>
				
				<!-- … während für den eigentlichen Inhalt ein neues Dokument erzeugt wird. -->
				<xsl:result-document href="{$filename}.html">
					<xsl:call-template name="generate-html-frame">
						<xsl:with-param name="breadcrumbs" tunnel="yes">
							<xsl:call-template name="breadcrumbs"/>
						</xsl:with-param>						
					</xsl:call-template>
				</xsl:result-document>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Berechnet den Dateinamen für das aktuelle div. -->
	<xsl:template name="filename">
		<xsl:variable name="divno">
			<xsl:number count="div" level="any" format="1"/>
		</xsl:variable>
		<xsl:value-of select="concat($output-base, '.', $divno)"/>
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
		<xsl:variable name="href" select="f:html-link($filename, $page)"/>
		<a>
			<xsl:attribute name="href" select="$href"/>        
			
			<xsl:if test="$class">
				<xsl:attribute name="class" select="string-join($class, ' ')"/>
			</xsl:if>
			<xsl:copy-of select="$prefix"/>
			
			<xsl:variable name="title">
				<xsl:apply-templates mode="title" select="if (head) then head[1] else *[translate(normalize-space(.), ' ', '') ne ''][1]"/>
			</xsl:variable>
			<xsl:value-of select="if (head) then $title else concat('[', $title, ']')"/>
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
		<html>
			<xsl:call-template name="html-head"/>
			<body>
				<xsl:call-template name="header"/>
				
				<main class="nofooter">
					<div  class="print">
						<div class="print-side-column"/> <!-- 1. Spalte (1/5) bleibt erstmal frei -->
						<div class="print-center-column">  <!-- 2. Spalte (3/5) für den Inhalt -->
							<xsl:choose>
								<xsl:when test="$single">
									<xsl:apply-templates/>
								</xsl:when>
								<xsl:otherwise>
									<xsl:apply-templates/>
								</xsl:otherwise>
							</xsl:choose>
						</div>
						<div class="print-side-column">  <!-- 3. Spalte (1/5) für die lokale Navigation  -->
							<xsl:call-template name="local-nav"/>
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
