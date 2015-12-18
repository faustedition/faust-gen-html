<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.tei-c.org/ns/1.0"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs"
	xmlns:f="http://www.faustedition.net/ns" 
	version="2.0">
	
	<!-- 
		This stylesheet prepares textual transcripts for being searched.
		
		It currently makes two kinds of transformations:
		
		1. It enriches the document with available metadata information. This most notably includes the TEI header.
		2. It normalizes text nodes.
	-->
	
	<xsl:import href="utils.xsl"/>
	
	<xsl:param name="documentURI"/>
	<xsl:param name="transcriptURI"/>
	<xsl:param name="transcriptBase" select="replace(replace($transcriptURI, '^.*/', ''), '\.(html|xml)$', '')"/>
	<xsl:param name="source"/>
	<xsl:variable name="faustURI" select="concat('faust://xml/', $documentURI)"/>	
	<xsl:param name="type"/>
	<xsl:variable name="metadata">
		<xsl:variable name="path" select="resolve-uri($documentURI, $source)"/>
		<xsl:choose>
			<xsl:when test="doc-available($path)">
				<xsl:sequence select="doc($path)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message select="concat('WARNING: No metadata for ', $type, ' ', $faustURI, ' at ', $path)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<xsl:variable name="splittable" select="f:is-splitable-doc(/)"/>
	
	<xsl:output method="xml" indent="yes"/>

	
	<!-- The first title in the titleStmt will be taken from the headNote, with #headNote -->
	<xsl:template match="titleStmt">
			<xsl:copy>
				<xsl:apply-templates select="@*"/>
				<title type="headNote" xml:id="headNote">
					<xsl:value-of select="$metadata//f:headNote"/>
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

	<xsl:template match="text()" priority="1">
		<xsl:variable name="tmp1" select=" replace(.,'ā','aa')"/>
		<xsl:variable name="tmp2" select=" replace($tmp1,'ē','ee')"/>
		<xsl:variable name="tmp3" select=" replace($tmp2,'m̄','mm')"/>
		<xsl:variable name="tmp4" select=" replace($tmp3,'n̄','nn')"/>
		<xsl:variable name="tmp5" select=" replace($tmp4,'r̄','rr')"/>
		<xsl:variable name="tmp5a" select=" replace($tmp5,'ſs','ß')"/>
		<xsl:variable name="tmp6" select=" replace($tmp5a,'ſ','s')"/>
		<xsl:variable name="tmp7" select=" replace($tmp6,'—','–')"/>
		<xsl:variable name="tmp8" select=" replace($tmp7,'&#x00AD;','')"/>  <!-- Soft Hyphen -->
		<xsl:value-of select="normalize-unicode($tmp8)"/>
	</xsl:template>
	<xsl:strip-space elements="app choice subst"/>	
	<xsl:template match="orig/text()[. = 'sſ']">ß</xsl:template>
	
	<!-- //TEI/@type will be print, archivalDocument, or lesetext -->
	<xsl:template match="TEI">
		<xsl:copy>
			<xsl:namespace name="f">http://www.faustedition.net/ns</xsl:namespace>
			<xsl:attribute name="type" select="$type"/>
			<xsl:apply-templates select="@* except @type"/>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="div">
		<xsl:copy>
			<xsl:attribute name="n">
				<xsl:if test="$splittable">
					<xsl:number count="div" level="any" format="1"/>
				</xsl:if>
			</xsl:attribute>
			<xsl:apply-templates select="@* except @n"/>
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