<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs"
	xmlns="http://www.tei-c.org/ns/1.0"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	version="2.0">
	
	<!-- 
		
		Transformiert die teils vorhandene Prosastruktur in <lg>/<l>. Das ist vermutlich
		philologisch nicht korrekt, erleichtert aber das nachfolgende prozessieren		
	
	-->
		
	<xsl:template match="p[milestone[@unit='refline']]">
		<lg rend="{concat('ann-p ', @rend)}">
			<xsl:apply-templates select="@* except @rend"/>
			<xsl:for-each-group select="node()" group-starting-with="milestone[@unit='refline']">
				<l n="{current-group()[1]/@n}">
					<xsl:apply-templates select="current-group()" mode="in-artificial-lg"/>
				</l>
			</xsl:for-each-group>
		</lg>
	</xsl:template>	
	<xsl:template mode="in-artificial-lg" match="lb|milestone[@unit='refline']"/>
		
		
	<xsl:template match="node()|@*" mode="#all">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
		
</xsl:stylesheet>