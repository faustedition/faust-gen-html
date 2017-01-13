<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs"
	version="2.0">
	
	<xsl:output method="xml"/>
	
	<xsl:param name="namespace-uri">http://www.tei-c.org/ns/1.0</xsl:param>
	
	<xsl:template match="@*|node()">
		<xsl:copy>
			<xsl:apply-templates select="@*, node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="*[namespace-uri() = '']" priority="1">		
		<xsl:element name="{local-name()}" namespace="{$namespace-uri}">
			<xsl:apply-templates select="@*, node()"/>
		</xsl:element>
	</xsl:template>
	
</xsl:stylesheet>