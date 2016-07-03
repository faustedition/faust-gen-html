<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:f="http://www.faustedition.net/ns"
	exclude-result-prefixes="xs"
	version="2.0">
	
	<!-- 	
		This is a helper stylesheet that whitespace-normalizes all text and attribute nodes of a
		given XML document and then writes the indented version of the document.
	-->
	
	<xsl:import href="utils.xsl"/>
	
	<xsl:output method="xml" indent="yes" />
	
	<xsl:template match="@*">
		<xsl:attribute name="{name()}" select="normalize-space(.)"/>
	</xsl:template>
	
	<xsl:template match="text()">
		<xsl:value-of select="f:normalize-space(.)"/>
	</xsl:template>

	<xsl:template match="node()">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>