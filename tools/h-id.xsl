<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xpath-default-namespace="http://www.w3.org/1999/xhtml" version="2.0">
	<xsl:output method="text"/>
	<xsl:template match="/">
		<xsl:text>id&#9;Textinhalt&#10;</xsl:text>
		<xsl:for-each
			select="//*[self::h2 or self::h3 or self::h4]">
			<xsl:value-of select="@id"/>
			<xsl:text>&#9;</xsl:text>
			<!-- Tab -->
			<xsl:value-of select="normalize-space(.)"/>
			<xsl:text>&#10;</xsl:text>
			<!-- Zeilenumbruch -->
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
