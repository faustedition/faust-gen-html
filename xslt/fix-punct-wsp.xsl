<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs"
	version="2.0">
	
	<xsl:template match="text()" priority="1">
		<xsl:variable select="replace(.,       '(\p{Ps}|[„»])\s+',       '$1')" name="step1"/>
		<xsl:value-of select="replace($step1, '\s+(\p{Pe}|[,.!?:«“])',   '$1')"/>
	</xsl:template>
	
	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>	
	
</xsl:stylesheet>