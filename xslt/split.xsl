<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml" xmlns:xh="http://www.w3.org/1999/xhtml"
	xmlns:f="http://www.faustedition.net/ns"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs f" 	
	version="2.0">
	
	<xsl:import href="config.xsl"/>
	
	<!-- 
	
	This stylesheet contains rules to render the HTML in a split mode. It is included by both print2html.xsl and apparatus.xsl
	
	-->
	
	
	<!-- Der Ausgabeordner für die HTML-Dateien. -->
	<xsl:param name="html" select="f:safely-resolve('target/html')"/>
	
	<!-- Pfad zu den zuvor generierten Varianten. Die HTML-Files dort müssen existieren. -->
	<xsl:param name="variants" select="f:safely-resolve('variants/', $html)"/>
	
	<!-- Dateiname/URI für die Ausgabedatei(en) ohne Endung. -->
	<xsl:param name="output-base"
		select="f:safely-resolve(//idno[@type='sigil_t'][1], $html)"/>
	
	
	<!-- Gesamttitel für die Datei. -->
	<xsl:param name="title" select="//title[1]"/>
	
	<!-- print oder archivalDocument oder lesetext? -->
	<xsl:param name="type" select="//TEI/@type"/>
	
	<xsl:param name="documentURI"/>	

	

	<!-- 
    Auf welcher Ebene sollen die Dateien aufgesplittet werden? $depth ist die
    max. Anzahl von divs auf der ancestor-or-self-Achse für einen Split, also 2 = Szenen.    
  -->
	<xsl:param name="depth">2</xsl:param>
	<xsl:variable name="depth_n" select="number($depth)"/>
	
	<xsl:template match="/TEI">
		<xsl:call-template name="generate-html-frame">
			<xsl:with-param name="content">
				<xsl:apply-templates select="text"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>


	<xsl:template match="/TEI[@f:split][descendant::div[@f:section]]" priority="1">
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
						
						<xsl:if test="not(following::div[@f:section])">
							<div class="following-content">
								<xsl:apply-templates select="following::* except following::*//node()"/>
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
		
		<xsl:if test="$type = 'lesetext'">
			
			<xsl:result-document href="{$output-base}.all1.html">
				<xsl:variable name="faust1"><xsl:apply-templates select="text" mode="extract-faust1"/></xsl:variable>
				<xsl:call-template name="generate-html-frame">
					<xsl:with-param name="single" select="true()" tunnel="yes"/>
					<xsl:with-param name="content">
						<xsl:apply-templates select="$faust1"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:result-document>
			
			<xsl:result-document href="{$output-base}.all2.html">
				<xsl:call-template name="generate-html-frame">
					<xsl:with-param name="single" select="true()" tunnel="yes"/>
					<xsl:with-param name="content">
						<xsl:apply-templates select="text//div[@n='2']"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:result-document>
			
		</xsl:if>
	</xsl:template>
	
	<xsl:template mode="extract-faust1" match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="@*, node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	<xsl:template mode="extract-faust1" match="div[@n='2']"/>
	
	<xsl:template match="div[@xml:id]" priority="2">
		<a name="{f:generate-id(.)}" id="{f:generate-id(.)}"/>
		<xsl:next-match/>
	</xsl:template>
	
	<xsl:template mode="tocpage" match="div[@type='stueck']"/>
	
	<xsl:template mode="tocpage" match="div">
		<li>
			<xsl:if test="@xml:id">
				<xsl:attribute name="id" select="@xml:id"/>
			</xsl:if>
			<xsl:variable name="link" select="f:link-to(.)"/>
			<a href="{$link/@href}">
				<xsl:value-of select="$link"/>
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
			</a>
				
				
				
			
			<xsl:if test="descendant::div[@f:label]">
				<ul>
					<xsl:apply-templates mode="#current"/>
				</ul>
			</xsl:if>
		</li>	
	</xsl:template>
	
	<xsl:template mode="tocpage" match="titlePage[not(preceding::titlePage)]">
		<li>
			<a href="{f:link-to(.)/@href}">Titel</a>
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
	
	<!-- Creates an HTML link to the current element, labeled with the current section label -->
	<xsl:function name="f:link-to" as="element()">
		<xsl:param name="el" as="node()"/>
		<xsl:param name="section" as="item()"/> <!-- true(): Detect section, false(): No section part, everything else: use that as section part -->
		<xsl:variable name="section-number" select="f:get-section-number($el)"/>
		<xsl:variable name="section-prefix" select="if ($type='lesetext') then 
				if ($section eq 'no' or $section eq '' or $section-number eq '') then '' else '.' 
			else '&amp;section='"/>
		<xsl:variable name="section-part" select="						
			if ($section eq 'yes') then if ($section-number) then concat($section-prefix, $section-number) else $section-prefix 
			else if ($section eq 'no') then ''
			else concat($section-prefix, $section)"/>
		<xsl:variable name="title" select="($el/ancestor-or-self::*[@f:label][1]/@f:label, f:get-section-div($el)/@f:label)[1]"/>
		<xsl:variable name="sigil_t" select="id('sigil_t', $el)"/>
		<xsl:variable name="page" select="$el/preceding::pb[1]/@f:docTranscriptNo"/>
		<xsl:variable name="n" select="$el/ancestor-or-self::*[f:hasvars(.)][1]/@n"/>
		<xsl:variable name="id" select="f:generate-id($el)"/>
		<xsl:variable name="href" select="concat(
			if ($type = 'lesetext' or $sigil_t='faust')
			then '/print/faust'
			else concat('/document?sigil=', $sigil_t, 
						if ($page) then concat('&amp;page=', $page) else ''),
			$section-part,						
			if ($n) then concat('#l', $n) else if($id) then concat('#', $id) else '')"/>
		<a href="{$href}"><xsl:value-of select="$title"/></a>
	</xsl:function>
	
	<xsl:function name="f:link-to" as="element()">
		<xsl:param name="el" as="node()"/>
		<xsl:sequence select="f:link-to($el, 'yes')"/>
	</xsl:function>
			
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
			<xsl:with-param name="breadcrumb-def" tunnel="yes">
				<xsl:choose>
					<xsl:when test="$type = 'lesetext' and not(ancestor-or-self::div[@f:section])">
						<xsl:message>Lesetext Root</xsl:message>
						<a href="/text">Text</a>
						<a>Konstituierter Text</a>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="breadcrumbs"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="jsRequirements" select="'faust_app:faust_app'"/>
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
	
	<xsl:template name="section-link">
		<xsl:param name="prefix"/>
		<xsl:variable name="link" select="f:link-to(.)"/>
		<a href="{$link/@href}">
			<xsl:sequence select="$prefix"/>
			<xsl:value-of select="$link"/>
		</a>
	</xsl:template>
	
	<!-- Erzeugt eine lokale Navigation für das aktuelle (Fokus) div, d.h. Breadcrumbs, Prev/Next -->
	<xsl:template name="local-nav">
		<xsl:param name="single" tunnel="yes" select="f:is-splitable-doc(.)"/>
		<xsl:variable name="current-div" select="."/>
		<nav class="print-navigation">
			
			<ul class="fa-ul">
				<li class="toclink">
					<xsl:if test="/TEI/@f:split and not(self::TEI)">
						<a href="{f:link-to(/, '')/@href}">
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
								<a href="{f:link-to(.)/@href}">Szenenansicht</a>
							</xsl:when>
							<xsl:when test="$type = 'lesetext' and not(self::text)">
								<xsl:variable name="part" select="substring(ancestor-or-self::div[@n][1]/@n, 1, 1)"/>
								<xsl:variable name="label" select="if ($part = '1') then 'Faust I' else if ($part = '2') then 'Faust II' else ''"/>
								<span class="fa-li fa fa-doc"/>
								<xsl:choose>
									<xsl:when test="$part">
										<a href="{f:link-to(., concat('all', $part))/@href}">Gesamtansicht <xsl:value-of select="$label"/></a>										
									</xsl:when>
									<xsl:otherwise>
										<a href="{f:link-to(., 'all')/@href}">Gesamtansicht</a>										
									</xsl:otherwise>
								</xsl:choose>
							</xsl:when>
							<xsl:otherwise>
								<span class="fa-li fa fa-doc"/>
								<a href="{f:link-to(., 'all')/@href}">Gesamtansicht</a>
							</xsl:otherwise>
						</xsl:choose>
					</li>
				</xsl:if>
			</ul>
			<xsl:variable name="evil-hack"><f:extra-nav/></xsl:variable>
			<xsl:apply-templates select="$evil-hack"/>
		</nav>
	</xsl:template>
	

	
</xsl:stylesheet>
