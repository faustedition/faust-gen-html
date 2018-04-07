<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.tei-c.org/ns/1.0"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	xmlns:f="http://www.faustedition.net/ns" 
	exclude-result-prefixes="xs"
	version="2.0">
	
	<xsl:import href="utils.xsl"/>

	<!-- 
	
	Erzeugt eine JSON-Repräsentation der Dokument/Datei-Mappings.	
	
	{ 
      "faust://xml/document/faust/2/gsa_391098.xml" : 
        { 
          "1" : "391098.1.html",
          "2" : "391098.1.html",
        },
	}
	
	nur halt kompakt.
	
	-->

	<xsl:template name="collection">
		<!-- Iterate over collection. -->
		<xsl:variable name="documents">
			<xsl:for-each select="collection()">
				<xsl:call-template name="document"/>
			</xsl:for-each>
		</xsl:variable>

		<xsl:variable name="items">
			<xsl:perform-sort select="$documents/*">
				<xsl:sort select="@n"/>
			</xsl:perform-sort>
		</xsl:variable>

		<!-- f:json is required for XProc processing, will be removed by p:store -->
		<f:json>
			<xsl:text>{&#10;</xsl:text>
			<xsl:value-of select="string-join($items/*, ',&#10;')"/>
			<xsl:text>}</xsl:text>
		</f:json>
	</xsl:template>


	<xsl:template match="/TEI" name="document">			
		<xsl:variable name="pages" as="item()*">
			<xsl:for-each select="//pb[@f:docTranscriptNo != '']">				
				<xsl:variable name="page" select="@f:docTranscriptNo"/>
				<xsl:if test="not(preceding::pb[@f:docTranscriptNo = $page])">					
					<xsl:value-of select="concat('&quot;', $page, '&quot;:&quot;', f:get-section-label(.), '&quot;')"/>
				</xsl:if>
			</xsl:for-each>
		</xsl:variable>
		<f:item>
			<xsl:text>"</xsl:text>
			<xsl:value-of select="//idno[@type='fausturi']"/>
			<xsl:text>":{</xsl:text>
			<xsl:value-of select="string-join($pages, ',')"/>
			<xsl:text>}</xsl:text>
		</f:item>
	</xsl:template>

</xsl:stylesheet>