<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:j="http://www.faustedition.net/ns/json"	
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs"
	version="2.0">
	
	<!-- Creates a summarized structure of a TEI file as a JSON document. Used for development purposes only. -->
	
	<xsl:import href="jsonutils.xsl"/>
	<xsl:output method="text" media-type="application/json" encoding="UTF-8"/>
	
	<xsl:template match="node()"><xsl:apply-templates/></xsl:template>
	
	<xsl:template match="div|*[descendant::div]|div[descendant::div]/*[not(self::pb|self::figure|self::fw)]">
		<j:object>
			<!--<j:string name="element" value="{local-name()}"/>-->
			<xsl:choose>
				<xsl:when test="@n"><j:string name="{local-name()}" value="{@n}"/></xsl:when>
				<xsl:otherwise>
					<j:string name="{local-name()}">
						<xsl:variable name="content" select="normalize-space(string-join(node(), ' '))"/>							
						<xsl:value-of select="if ($content = '') then '' else 
							concat('[', substring($content, 1, 40), 
							if (string-length($content) gt 20) then ' …]' else ']')"/>
					</j:string>
				</xsl:otherwise>
			</xsl:choose>
			<j:array name="content" dropempty="true">
				<xsl:apply-templates/>
			</j:array>
		</j:object>
	</xsl:template>
	
	<xsl:template match="/">
		<xsl:variable name="intermediate">
			<xsl:apply-templates/>
		</xsl:variable>
		<xsl:apply-templates mode="json" select="$intermediate"/>
	</xsl:template>
	
</xsl:stylesheet>