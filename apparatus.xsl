<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:f="http://www.faustedition.net/ns"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs f"
	version="2.0">
	
	<xsl:import href="html-frame.xsl"/>
	<xsl:include href="html-common.xsl"/>
	<xsl:param name="type">archivalDocument</xsl:param>
	
	<xsl:output method="xhtml" indent="yes"/>



	<xsl:template match="add[not(parent::subst)]">
		<xsl:variable name="erg"> <abbr title="ergänzt" class="app"> erg</abbr> ⟩</xsl:variable>
		<xsl:call-template name="enclose">
			<xsl:with-param name="with" select="('⟨ ',  $erg)"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="del[not(parent::subst)]">
		<span class="deleted"><xsl:apply-templates/></span>
		<xsl:variable name="tilgt"><abbr title="getilgt" class="app"> tilgt</abbr> ⟩</xsl:variable>	
		<xsl:call-template name="enclose">
			<xsl:with-param name="with" select="('⟨ ', $tilgt)"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="del[@f:revType='instant']" priority="1">
		<xsl:call-template name="enclose">
			<xsl:with-param name="with" select="('⟨ ', ' &gt;⟩')"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="subst">
		<span class="deleted replaced">
			<xsl:apply-templates select="del"/>
		</span>
		<xsl:for-each select="add">
			<xsl:call-template name="enclose">
				<xsl:with-param name="with" select="('⟨: ', ' ⟩')"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>
	





	<xsl:template match="/">
		<xsl:for-each select="/TEI/text">
			<xsl:call-template name="generate-html-frame"/>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:key name="alt" match="alt" use="for $ref in tokenize(@target, '\s+') return substring($ref, 2)"/>
	<!-- Einfacher als in print2html da kein Variantenapparat -->
	<xsl:template match="*">
		<xsl:element name="{f:html-tag-name(.)}">
			<xsl:call-template name="generate-style"/>
			<xsl:attribute name="class" select="string-join((f:generic-classes(.),
				if (@xml:id and key('alt', @xml:id)) then 'alt' else (),
				if (@n and @part) then ('antilabe', concat('part-', @part)) else ()), ' ')"/>
			<xsl:call-template name="generate-lineno"/>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<!-- TODO Vereinigen mit print2html -> html-frame.xsl -->
	<xsl:template name="generate-html-frame">
		<html>
			<xsl:call-template name="html-head"/>
			<body>
				<xsl:call-template name="header"/>
				
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
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>
	
	
</xsl:stylesheet>