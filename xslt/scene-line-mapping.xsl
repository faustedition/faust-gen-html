<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs"
	xmlns:j="http://www.faustedition.net/ns/json"
	xmlns="http://www.faustedition.net/ns"
	xpath-default-namespace="http://www.faustedition.net/ns"
	version="2.0">
	
	<xsl:import href="jsonutils.xsl"/>
	
	<xsl:template match="/scene-info">
		<xsl:variable name="pseudojson">
			<j:array name="sceneLineMapping">
				<xsl:apply-templates/>				
			</j:array>
		</xsl:variable>
		<j:json>
			<xsl:text>var sceneLineMapping =&#10;</xsl:text>
			<xsl:apply-templates select="$pseudojson"/>			
		</j:json>		
	</xsl:template>
	
	<xsl:template match="part|act|scene">
		<xsl:apply-templates/>
		<j:object>
			<j:string name="id" value="{@n}"/>
			<j:string name="title" value="{title}"/>
			<xsl:if test="descendant-or-self::*/@first-verse">
				<j:number name="rangeStart" value="{(descendant-or-self::*/@first-verse)[1]}"/>
				<j:number name="rangeEnd" value="{(descendant-or-self::*/@last-verse)[position()=last()]}"/>
			</xsl:if>
		</j:object>
	</xsl:template>
	
	<xsl:template match="title"/>	
	
</xsl:stylesheet>