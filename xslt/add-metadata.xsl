<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.tei-c.org/ns/1.0"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs"
	xmlns:f="http://www.faustedition.net/ns" 
	version="2.0">
	
	<!--
		This stylesheet adds additional metadata provided by parameters and extracted from
		document/**/*.xml to the transcript document. Metadata is copied mainly to the TEI 
		header. Rest of the document is passed through as is.
	-->
	
	<xsl:import href="utils.xsl"/>
	
	<!-- The root directory of the Faust XML data, corresponds to faust://xml/, needs to resolve -->
	<xsl:param name="source"/>
	
	<!-- The path to the metadata document, relative to $source -->
	<xsl:param name="documentURI"/>
	
	<!-- archivalDocument, print, or lesetext -->
	<xsl:param name="type" select="local-name($metadata/*[1])"/>
		
	<!-- Resolved faust:// URI of the textual transcript -->
	<xsl:param name="transcriptURI" select="resolve-uri($metadata//f:textTranscript/@uri, base-uri($metadata//f:textTranscript))"/>
		
	<!-- Base name of the textual transcript, used for naming generated files -->	
	<xsl:param name="transcriptBase" select="replace(replace($transcriptURI, '^.*/', ''), '\.(html|xml)$', '')"/>
	
	<!-- Canonical URI for the document. Defaults to faust://xml/$documentURI -->
	<xsl:param name="faustURI" select="concat('faust://xml/', $documentURI)"/>


	<xsl:variable name="metadata">
		<xsl:variable name="path" select="resolve-uri($documentURI, $source)"/>
		<xsl:choose>
			<xsl:when test="doc-available($path)">
				<xsl:sequence select="doc($path)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message select="concat('WARNING: No metadata for ', (: $type, ' ',:) $faustURI, ' at ', $path)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="archives" select="doc(resolve-uri('archives.xml', $source))"/>
	
	<xsl:variable name="splittable" select="f:is-splitable-doc(/)"/>
	
	<xsl:output method="xml" indent="yes"/>

	
	<!-- The first title in the titleStmt will be taken from the headNote, with #headNote -->
	<xsl:template match="titleStmt">
			<xsl:copy>
				<xsl:apply-templates select="@*"/>
				<title type="headNote" xml:id="headNote">
					<xsl:choose>
						<xsl:when test="$type = 'lesetext' and contains($faustURI, 'faust1')">Faust I</xsl:when>
						<xsl:when test="$type = 'lesetext' and contains($faustURI, 'faust2')">Faust II</xsl:when>
						<xsl:otherwise><xsl:value-of select="$metadata//f:headNote"/></xsl:otherwise>
					</xsl:choose>
				</title>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	
	<!-- 
		We add some idnos:
		
		#sigil – the faustedition sigil
		#fausturi – the faust:// uri to the document
		#fausttranscript – the base name of the textual transcript file
		
		also all idnos from the metadata with appropriate @type.
	
	-->
	<xsl:template match="fileDesc">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="node()"/>
			
			<idno type="faustedition" xml:id="sigil">
				<xsl:choose>
					<xsl:when test="$type = 'lesetext'">Lesetext</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$metadata//f:idno[@type='faustedition']"/>
					</xsl:otherwise>
				</xsl:choose>
			</idno>
			
			<idno type="fausturi" xml:id="fausturi"><xsl:value-of select="$faustURI"/></idno>
			<idno type="fausttranscript" xml:id="fausttranscript"><xsl:value-of select="$transcriptBase"/></idno>
			
			<xsl:for-each select="$metadata//f:idno[. != 'none'][. != 'n.s.'][@type != 'faustedition']">
				<idno type="{@type}">
↓					<xsl:value-of select="."/>
				</idno>
			</xsl:for-each>
			
		</xsl:copy>
	</xsl:template>

	
	<!-- //TEI/@type will be print, archivalDocument, or lesetext -->
	<xsl:template match="TEI">
		<xsl:copy>
			<xsl:namespace name="f">http://www.faustedition.net/ns</xsl:namespace>
			<xsl:attribute name="type" select="$type"/>
			<xsl:variable name="repository" select="normalize-space(($metadata//f:repository)[1])"/>
			<xsl:attribute name="f:repository" select="$repository"/> <!-- FIXME -->
			<xsl:attribute name="f:repository-label" select="$archives//f:archive[@id=$repository]/f:name"/> <!-- FIXME -->
			<xsl:apply-templates select="@* except @type"/>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="div">
		<xsl:copy>
			<xsl:attribute name="f:n">
				<xsl:if test="$splittable">
					<xsl:number count="div" level="any" format="1"/>
				</xsl:if>
			</xsl:attribute>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	
	
	<xsl:template match="/">
		<xsl:comment>
			
			Generated Document
			==================
			
			This XML document has been generated from the original transcript, losing details.
			Do not edit or re-use it, rather use the original transcript.
			
		</xsl:comment>
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	
</xsl:stylesheet>