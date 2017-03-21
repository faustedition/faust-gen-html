<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs"
	xmlns:j="http://www.faustedition.net/ns/json"
	xmlns="http://www.faustedition.net/ns"
	xpath-default-namespace="http://www.faustedition.net/ns"
	version="2.0">
	
	<xsl:import href="jsonutils.xsl"/>
	
	<xsl:template match="/sceneLineMapping">
		<xsl:variable name="acts">
			<xsl:call-template name="generate-acts"/>
		</xsl:variable>		
		<xsl:variable name="pseudojson">
			<j:array name="sceneLineMapping">
				<xsl:apply-templates select="*, $acts"/>				
			</j:array>
		</xsl:variable>
		<j:json>
			<xsl:text>var sceneLineMapping =&#10;</xsl:text>
			<xsl:apply-templates select="$pseudojson"/>			
		</j:json>
	</xsl:template>
	
	
	<xsl:template match="scene|act">
		<j:object>
			<xsl:apply-templates/>
		</j:object>
	</xsl:template>
	
	<xsl:template match="rangeStart|rangeEnd">
		<j:number name="{local-name()}">
			<xsl:apply-templates/>
		</j:number>
	</xsl:template>
	
	<xsl:template match="title|id">
		<j:string name="{local-name()}">
			<xsl:apply-templates/>
		</j:string>
	</xsl:template>
	
		
	<xsl:template name="generate-acts">
		<xsl:for-each-group select=".//scene[starts-with(id, '2')]" group-by="tokenize(id, '\.')[2]">
			<act>
				<id>2.<xsl:value-of select="current-grouping-key()"/></id>
				<title><xsl:number format="I." value="current-grouping-key()"/> Akt</title>
				<xsl:copy-of select="current-group()[1]/rangeStart"/>
				<xsl:copy-of select="current-group()[last()]/rangeEnd"/>
			</act>
		</xsl:for-each-group>
	</xsl:template>
	
</xsl:stylesheet>