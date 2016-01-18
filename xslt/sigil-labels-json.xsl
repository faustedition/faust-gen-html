<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.faustedition.net/ns"
	exclude-result-prefixes="xs"
	version="2.0">
	
	<!-- 
	
		This stylesheet converts sigil-labels.xml to a JSON structure
		that is currently found in faustedition/faust-web/js/faust-tables.js
	
	-->
	
	<xsl:output method="text"/>
	
	<xsl:template match="sigil-labels">
		<xsl:variable name="labels" as="xs:string*">
			<xsl:apply-templates select="label"/>
		</xsl:variable>
		<xsl:value-of select="concat('{&#10;&#9;', string-join($labels, ',&#10;&#9;'), '&#10;}')"/>
	</xsl:template>
	
	<xsl:template match="label">
		<xsl:value-of select="concat('&quot;idno_', @type, '&quot;: &quot;', ., '&quot;')"/>
	</xsl:template>
	
</xsl:stylesheet>