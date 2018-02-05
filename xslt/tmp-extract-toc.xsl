<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:f="http://www.faustedition.net/ns"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs"
	default-collation="http://www.w3.org/2013/collation/UCA?lang=de"
	version="2.0">

	<xsl:import href="utils.xsl"/>
		
	<xsl:output method="xhtml"/>
	
	
	<xsl:template match="/">
		<xsl:variable name="preprocessed">
			<xsl:apply-templates/>
		</xsl:variable>
		<html>
			<head><title>div-Struktur</title></head>
			<body>
				<ol>
					<xsl:apply-templates select="$preprocessed" mode="toc"/>
				</ol>
			</body>
		</html>
	</xsl:template>
	
	
	
	<xsl:template match="div|front|body|back" mode="toc">
		<li>
			<em><xsl:value-of select="local-name()"/></em>
			<xsl:for-each select="@*">
				<xsl:value-of select="concat(' ', name(), '=&quot;', ., '&quot;')"/>
			</xsl:for-each>
		<xsl:if test="div|text|group|front|body|back">
			<ol>
				<xsl:apply-templates mode="#current"/>
			</ol>
		</xsl:if>
		</li>
	</xsl:template>
	
	<xsl:template match="node()" mode="toc"><xsl:apply-templates mode="#current"/></xsl:template>
	
	<xsl:template match="node()|@*">
		<xsl:copy>			
			<xsl:apply-templates mode="#current" select="@*, node()"/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>