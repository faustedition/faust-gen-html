<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"	
	xmlns="http://www.tei-c.org/ns/1.0"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"	
	version="2.0">
	

	<xsl:template match="restore[del and (normalize-space(string-join(text(), '')) eq '') and (count(*) eq 1)]">
		<del>
			<xsl:apply-templates select="del/@*"/>
			<xsl:copy>
				<xsl:apply-templates select="@*"/>
				<xsl:apply-templates select="del/node()"/>
			</xsl:copy>
		</del>
	</xsl:template>
	
	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"></xsl:apply-templates>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>