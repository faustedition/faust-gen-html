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
	
	<xsl:variable name="ordinals" as="xs:string*" select="('Erster', 'Zweiter', 'Dritter', 'Vierter', 'Fünfter')"/>
		
	
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
	
	<!-- taken and shortened from add-metadata.xsl -->
	<xsl:template match="div">
		<xsl:variable name="explicit-scene" select="$scenes//f:scene[@n = current()/@n]"/>
		<xsl:variable name="guessed-scene" as="element()*">
			<xsl:call-template name="scene-data"/>
		</xsl:variable>
		<xsl:variable name="scene" select="($explicit-scene, $guessed-scene)[1]"/>
		<xsl:variable name="act"> <!-- act no, if this is an act  -->
			<xsl:choose>
				<xsl:when test="matches(@n, '^2\.[1-5]$')">
					<xsl:value-of select="replace(@n, '^2\.([1-5])', '$1')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:sequence select="()"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:copy>
			<xsl:choose>
				<xsl:when test="data($act) != ''">					
					<xsl:attribute name="f:label">
						<!--<xsl:number lang="de" value="$act" format="Ww" ordinal="-er"/> doesn't work??? -->
						<xsl:value-of select="concat(subsequence($ordinals, $act, 1), ' Akt')"/>
					</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="not(@n)">
						<xsl:attribute name="f:n" select="$scene/@n"/>						
					</xsl:if>
					<xsl:attribute name="f:label">	
						<xsl:value-of select="$scene//f:title"/>
					</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="@*, node()"/>			
		</xsl:copy>
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