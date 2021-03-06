<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xh="http://www.w3.org/1999/xhtml"
	
	xmlns:f="http://www.faustedition.net/ns"
	xmlns:ge="http://www.tei-c.org/ns/geneticEditions"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	
	xmlns:exist="http://exist.sourceforge.net/NS/exist"
	
	exclude-result-prefixes="xs f ge xh exist"
	
	version="2.0">
	
	<!-- 
	
		Mark up search results as coming from our eXist query.
		
		EXPERIMENTAL.
		
		
		The input document to this stylesheet is a search result as created by 
		the accompagnying eXist XQuery on the documents prepared by the prepare-search
		statement. 
		
		A full-text result item is formatted as follows:
		
	    <f:hit sigil="A 8" headnote="Erste Gesamtausgabe bei Cotta, 1808" type="print" n="2088" href="print/A8_IIIB18.4.html">
        	<l n="2088">A! <exist:match>tara</exist:match> lara da!</l>
    	</f:hit>

	-->
	
	<xsl:import href="apparatus.xsl"/>
	
	<xsl:output method="xhtml" indent="yes"/>
	
	
	<xsl:param name="headerAdditions">
		<title>Faustedition | Suche: <xsl:value-of select="$query"/></title>									
		<style type="text/css">
			.hit .headnote { font-weight: lighter; margin-left: 1em;}
			.hit h3 { margin-bottom: 3pt; vertical-align: middle; }
			.hit h3 a { font-weight: normal; }
			.hit .sigil { padding-right: 5px; border-right: 1px solid gray; }
			.hit .breadcrumbs { color: gray; vertical-align: middle; }
			.hit .breadcrumbs span { margin: 0 5px; }
			.score {margin-left: 5px; padding-left: 5px; color: #ddd; visibility: hidden; }
			h3:hover .score { visibility: visible; }
			.subhit { width: 100%; display: flex;  }
			.subhit-content { width: 75%; }
			.subhit ul.breadcrumbs { width: 25%; padding: 0; margin: 0;  font-size: 80%; }
			.subhit ul.breadcrumbs li { display: inline; list-style-type: none; color: gray; }
			.subhit ul.breadcrumbs li ~ li:before { padding-right: 0.5ex; content: "›" }
			.hit ul.breadcrumbs { display: none; }
			.print-center-column { width: 80%; }
			ul.sort { list-style-type: none; }
			.idno mark { padding: 0; }
		</style>
	</xsl:param>
	

	<!-- Page numbers are not useful here -->
	<xsl:template name="generate-pageno"/>
	
	<!-- Line numbers that aren't exactly Ströer numbers are marked up like ~ 1234 -->
	<xsl:function name="f:display-line" as="xs:string">
		<xsl:param name="n"/>
		<xsl:value-of select="
		if (matches($n, '^\d+$')) 
			then $n 
			else replace($n, '^\D*(\d+).*$', '~ $1')"/>
	</xsl:function>
	
	<!-- Line numbers need href from f:hit and should be shown for every line -->
	<xsl:template name="generate-lineno">	
		<a href="{ancestor::f:*[1]/@href}#l{@n}" class="lineno">
			<xsl:value-of select="f:display-line(@n)"/>
		</a>		
	</xsl:template>
	
	<xsl:template match="f:subhit">
		<div class="subhit">
			<div class="subhit-content">
				<xsl:apply-templates select="* except f:breadcrumbs"/>				
			</div>
			<xsl:apply-templates select="f:breadcrumbs"/>
		</div>
	</xsl:template>
	
	<xsl:template match="f:breadcrumbs">
		<xsl:if test="*">
			<ul class="breadcrumbs">
				<xsl:apply-templates/>
			</ul>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="f:breadcrumb">
		<li><xsl:value-of select="
			if (@n and @n = $scenes//*/@n)
			then $scenes//*[@n=current()/@n]/f:title
			else @f:label"/></li>
	</xsl:template>
	
	<xsl:variable name="navbar">
		<xsl:if test="/f:results/@start">
		<xsl:variable name="start" as="xs:integer" select="/f:results/@start"/>
		<xsl:variable name="items" as="xs:integer" select="/f:results/@items"/>
		<xsl:variable name="hits" as="xs:integer" select="/f:results/@hits"/>
		<xsl:variable name="prev" as="xs:integer" select="max((1, $start - $items))"/>
		<xsl:variable name="next" as="xs:integer" select="$start + $items"/>
		<xsl:variable name="end" as="xs:integer" select="min(($next - 1, $hits))"/>
		<nav class="searchnav">
			<h3 class="pure-center">
				<xsl:if test="$start gt 1">
					<a rel="prev" class="pure-pull-left" href="search?q={encode-for-uri($query)}&amp;start={$prev}&amp;items={$items}">‹ Vorige</a>
				</xsl:if>
				Treffer <xsl:value-of select="$start"/> bis <xsl:value-of select="$end"/> von <xsl:value-of select="$hits"/>
				<xsl:if test="$next lt $hits">
					<a rel="next" class="pure-pull-right" href="search?q={encode-for-uri($query)}&amp;start={$next}&amp;items={$items}">Nächste ›</a>
				</xsl:if>		
			</h3>			
		</nav>
		</xsl:if>
	</xsl:variable>
	
	<!-- Matches are marked up & made to links. Maybe include match term in URI some time -->
	<xsl:template match="exist:match">
		<mark class="match">
			<xsl:choose>
				<xsl:when test="ancestor::f:sigils">
					<!-- We're already inside an <a> -->
					<xsl:apply-templates/>
				</xsl:when>
				<xsl:otherwise>
					<a class="match" href="{ancestor::f:*[1]/@href}#l{ancestor::*[@n][1]/@n}">
						<xsl:apply-templates/>
					</a>					
				</xsl:otherwise>
			</xsl:choose>
		</mark>
	</xsl:template>
	
	<!-- Each hit is represented by a heading and the actual content -->
	<xsl:template match="f:hit">
		<xsl:variable name="scene-data" select="f:get-scene-info(.)"/>
		<xsl:variable name="separator">
			<i class="fa fa-angle-right"/>			
		</xsl:variable>
		
		<section class="hit">			
			<h3>
				<a href="{@href}">
					<span class="sigil" title="{@headnote}">
						<xsl:value-of select="@sigil"/>						
					</span>
					<xsl:if test="$scene-data">
						<small class="breadcrumbs">
							<xsl:choose>
								<xsl:when test="(starts-with($scene-data/f:id, '2')) ">
									<span>Faust II</span>
									<xsl:copy-of select="$separator"/>
									<span><xsl:number value="substring($scene-data/f:id, 3, 1)" format="I." ordinal="true"/>. Akt</span>
								</xsl:when>
								<xsl:otherwise>
									<span>Faust I</span>
								</xsl:otherwise>
							</xsl:choose>
							<xsl:copy-of select="$separator"/>									
							<span><xsl:value-of select="$scene-data/f:title"/></span>							
						</small>						
					</xsl:if>
				</a>
			</h3>
			<xsl:apply-templates/>
		</section>
	</xsl:template>
	
	<xsl:template match="f:doc">
		<section class="doc">
			<h3><a href="{@href}">
				<span class="sigil" title="{@headnote}">
					<xsl:value-of select="@sigil"/>
				</span>
				</a>
				<span class="score">
					<xsl:value-of select="@score"/>
				</span>
			</h3>
			<xsl:apply-templates/>
		</section>
	</xsl:template>
	
	<xsl:template name="order-item">
		<xsl:param name="type" required="yes"/>
		<xsl:param name="label" required="yes"/>
		<xsl:param name="active" select="$type = /f:results/@order"/>
		<li class="order-{$type}">
			<xsl:choose>
				<xsl:when test="$active">
					<strong><xsl:value-of select="$label"/></strong>
				</xsl:when>
				<xsl:otherwise>
					<a href="{$edition}/search?q={escape-html-uri($query)}&amp;order={$type}"><xsl:value-of select="$label"/></a>
				</xsl:otherwise>
			</xsl:choose>	
		</li>
	</xsl:template>
	
	<xsl:template match="/f:results">
		<xsl:call-template name="html-frame">
			<xsl:with-param name="breadcrumb-def" tunnel="yes">						
					<a>Suchergebnisse</a>
					<a><xsl:value-of select="@query"/></a>				
			</xsl:with-param>
			<xsl:with-param name="section-classes" select="('center', 'print')"/>
			<xsl:with-param name="title" tunnel="yes">Faustedition: Suche nach <xsl:value-of select="$query"/></xsl:with-param>
			<xsl:with-param name="grid-content">
					<div class="pure-u-1-5">
						<h4>Sortierung</h4>
						<ul class="sort">
							<xsl:call-template name="order-item">
								<xsl:with-param name="type">score</xsl:with-param>
								<xsl:with-param name="label">Relevanz</xsl:with-param>
							</xsl:call-template>
							<xsl:call-template name="order-item">
								<xsl:with-param name="type">sigil</xsl:with-param>
								<xsl:with-param name="label">Sigle</xsl:with-param>
							</xsl:call-template>
							<xsl:call-template name="order-item">
								<xsl:with-param name="type">verse</xsl:with-param>
								<xsl:with-param name="label">Vers</xsl:with-param>
							</xsl:call-template>
						</ul>
					</div> 
					<article class="pure-u-4-5">  <!-- 2. Spalte (3/5) für den Inhalt -->						
						<xsl:choose>
							<xsl:when test="*">
								<xsl:copy-of select="$navbar"/>
								<xsl:apply-templates/>
								<xsl:copy-of select="$navbar"/>												
							</xsl:when>
							<xsl:otherwise>
								<div class="pure-alert pure-alert-warning">Keine Treffer für <em><xsl:value-of select="@query"/></em>.</div>												
							</xsl:otherwise>
						</xsl:choose>
					</article>			
			</xsl:with-param>
		</xsl:call-template>						
	</xsl:template>
	
	<xsl:template match="exist:exception">
		<xsl:variable name="severe" select="not(/*/*[not(self::exist:exception)])"/>
		<div class="pure-alert {if ($severe) then 'pure-alert-danger' else 'pure-alert-info pure-alert-dismissable'}">
			<h3>Fehler <xsl:value-of select="if (@where = 'sigil') then 'bei der Siglensuche' else if (@where = 'fulltext') then 'bei der Volltextsuche' else ()"/></h3>
			<p><xsl:value-of select="@code"/> | <xsl:value-of select="@location"/></p>
			<pre>
				<xsl:apply-templates/>
			</pre>
		</div>
	</xsl:template>
	
	<xsl:template match="f:fulltext-results">
		<h2><xsl:value-of select="@hits"/> Volltext-Treffer in <xsl:value-of select="@docs"/> Dokumenten</h2>
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="f:sigils">
		<h2><xsl:value-of select="@hits"/> Treffer in Siglen und Signaturen</h2>
		<ul>
			<xsl:apply-templates/>
		</ul>		
	</xsl:template>
	<xsl:template match="f:idno-match">
		<li><a href="{@href}">
			<xsl:choose>
				<xsl:when test="idno/@type = 'faustedition'">
					<strong><xsl:apply-templates/></strong>
				</xsl:when>
				<xsl:otherwise>
					<strong><xsl:value-of select="@sigil"/></strong>
					(<xsl:value-of select="@idno-label"/>: <xsl:apply-templates/>)					
				</xsl:otherwise>
			</xsl:choose>
		</a></li>
	</xsl:template>
	
</xsl:stylesheet>
