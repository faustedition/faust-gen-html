<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.tei-c.org/ns/1.0"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs"
	xmlns:f="http://www.faustedition.net/ns" 
	version="2.0">
	
	<xsl:import href="utils.xsl"/>
	
	<!-- Transforms text nodes in the way that is usable for the reading versions: ſ to s, ā to aa etc. -->
	
	<xsl:param name="normalization">NFC</xsl:param>
	
	<xsl:template match="text()">
		<xsl:copy-of select="f:normalize-print-chars(.)"/>
	</xsl:template>
	<xsl:strip-space elements="app choice subst"/>	
	<xsl:template match="orig/text()[. = 'sſ']">ß</xsl:template>
		
	
	<!-- Replacement characters for various types of <g> -->	
	<xsl:variable name="gmap">
		<g ref="#g_break">[</g>
		<g ref="#g_transp_1">⊢</g>
		<g ref="#g_transp_2">⊨</g>
		<g ref="#g_transp_2a">⫢</g>
		<g ref="#g_transp_3">⫢</g>
		<g ref="#g_transp_3S">⎱</g>
		<g ref="#g_transp_4">+</g>
		<g ref="#g_transp_5">✓</g>
		<g ref="#g_transp_6">#</g>
		<g ref="#g_transp_7">◶</g>
		<g ref="#g_transp_8">⊣</g>
		<g ref="#parenthesis_left">(</g>
		<g ref="#parenthesis_right">)</g>
		<g ref="#truncation">.</g>		
	</xsl:variable>
	<xsl:template match="g">
		<xsl:variable name="g" select="$gmap/g[@ref=current()/@ref]"/>
		<xsl:choose>
			<xsl:when test="$g">
				<xsl:value-of select="$g"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="."/>
			</xsl:otherwise>
		</xsl:choose>	
	</xsl:template>
	
	
	<xsl:template match="node()|@*" priority="-1">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	

</xsl:stylesheet>