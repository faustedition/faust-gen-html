<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs"
	xmlns="http://www.w3.org/2000/svg"
	xpath-default-namespace="http://www.w3.org/2000/svg"
	xmlns:xlink="http://www.w3.org/1999/xlink"
	version="2.0">
	
	<xsl:template match="svg">
		<xsl:copy>
			<xsl:copy-of select="@*, node()"/>
			<xsl:for-each select="//defs/*/@id">
				<use xlink:href="#{.}"/>
			</xsl:for-each>
		</xsl:copy>
	</xsl:template>
	
	
</xsl:stylesheet>