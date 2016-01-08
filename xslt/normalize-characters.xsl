<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.tei-c.org/ns/1.0"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs"
	xmlns:f="http://www.faustedition.net/ns" 
	version="2.0">
	
	
	<!-- Transforms text nodes in the way that is usable for the reading versions: ſ to s, ā to aa etc. -->
	
	<xsl:param name="normalization">NFC</xsl:param>
		
	
	<xsl:template match="text()">
		<xsl:variable name="tmp1" select=" replace(.,'ā','aa')"/>
		<xsl:variable name="tmp2" select=" replace($tmp1,'ē','ee')"/>
		<xsl:variable name="tmp3" select=" replace($tmp2,'m̄','mm')"/>
		<xsl:variable name="tmp4" select=" replace($tmp3,'n̄','nn')"/>
		<xsl:variable name="tmp5" select=" replace($tmp4,'r̄','rr')"/>
		<xsl:variable name="tmp5a" select=" replace($tmp5,'ſs','ß')"/>
		<xsl:variable name="tmp6" select=" replace($tmp5a,'ſ','s')"/>
		<xsl:variable name="tmp7" select=" replace($tmp6,'—','–')"/>
		<xsl:variable name="tmp8" select=" replace($tmp7,'&#x00AD;','')"/>  <!-- Soft Hyphen -->
		<xsl:value-of select="normalize-unicode($tmp8, $normalization)"/>
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