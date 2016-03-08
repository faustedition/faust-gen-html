<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.faustedition.net/ns"
	exclude-result-prefixes="xs"
	version="2.0">
	
	<!-- 
		This stylesheet generates the archives.js that is read from the
		web application from archives.xml.	
	-->
	
	<xsl:output method="text" media-type="application/javascript"/>
	<xsl:strip-space elements="*"/>
	
	<xsl:template match="/archives">
		<wrapper>
			<xsl:text>var archives={</xsl:text>
			<xsl:apply-templates select="*"/>
			<xsl:text>}</xsl:text>
		</wrapper>
	</xsl:template>
	
	<xsl:template match="archive" priority="1">
		<xsl:text>"</xsl:text>
		<xsl:value-of select="@id"/>
		<xsl:text>":{</xsl:text>
		<xsl:apply-templates select="*"/> 
		<xsl:text>}</xsl:text>
		<xsl:if test="position() != last()">,</xsl:if>
	</xsl:template>
	
	<xsl:template match="*">
		<xsl:value-of select="concat('&quot;', local-name(.), '&quot;:&quot;', ., '&quot;')"/>
		<xsl:if test="position() != last()">,</xsl:if>		
	</xsl:template>
	
	<xsl:template match="*[@*][not(self::country)]">
		<xsl:value-of select="concat('&quot;', local-name(.), '&quot;:{')"/>
		<xsl:value-of select="string-join(for $attr in @* return concat('&quot;', local-name($attr), '&quot;:&quot;', $attr, '&quot;'), ',')"/>		
		<xsl:text>}</xsl:text>
		<xsl:if test="position() != last()">,</xsl:if>		
	</xsl:template>		
	
</xsl:stylesheet>
