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
	
	<xsl:param name="headerAdditions">
		<style type="text/css">
			.hit .headNote { font-weight: lighter; margin-left: 1em;}
			.hit h3 { margin-bottom: 3pt; }			
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
		<!-- Klick auf Zeilennummer führt zu einem Link, der wiederum auf die Zeilennummer verweist -->
		<xsl:attribute name="id" select="concat('l', @n)"/>
		<a href="{concat($edition, ancestor::f:hit/@href, '#l', @n)}" class="lineno">
			<xsl:value-of select="f:display-line(@n)"/>
		</a>		
	</xsl:template>
	
	<!-- Matches are marked up & made to links. Maybe include match term in URI some time -->
	<xsl:template match="exist:match">
		<mark class="match">
			<a class="match" href="{ancestor::f:hit/@href}#l{ancestor::*[@n][1]/@n}">
				<xsl:apply-templates/>
			</a>
		</mark>
	</xsl:template>
	
	<!-- Each hit is represented by a heading and the actual content -->
	<xsl:template match="f:hit">
		<section class="hit">
			<!-- this will become a proper breadcrumb some time -->
			<h3>
				<a href="{@href}">
					<span class="sigil">
						<xsl:value-of select="@sigil"/>						
					</span>
					<xsl:text> </xsl:text>
					<span class="headnote">
						<xsl:value-of select="@headnote"/>
					</span>				
				</a>
			</h3>
			<xsl:apply-templates/>
		</section>
	</xsl:template>
	
	
	<xsl:template match="/f:results">
		<html>
			<xsl:call-template name="html-head"/>
			<body>
				<xsl:call-template name="header">
					<xsl:with-param name="breadcrumbs" tunnel="yes">						
						<div id="current">
							Suchergebnisse
						</div>						
					</xsl:with-param>
				</xsl:call-template>
				
				<main>
					<div class="main-content-container">
						<div id="main-content" class="main-content">
							<div id="main" class="print">
								<div class="print-side-column"/> <!-- 1. Spalte (1/5) bleibt erstmal frei -->
								<div class="print-center-column">  <!-- 2. Spalte (3/5) für den Inhalt -->
									<xsl:apply-templates/>
								</div>
							</div>
						</div>
					</div>
				</main>				
			</body>
		</html>
	</xsl:template>
	
	
	
</xsl:stylesheet>