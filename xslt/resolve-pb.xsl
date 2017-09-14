<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:f="http://www.faustedition.net/ns"
	xmlns="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs" version="2.0">

	<xsl:param name="type"/>
	<xsl:param name="source" required="yes"/>
	<xsl:param name="documentURI" select="//idno[@type='fausturi'][1]"/>
	<xsl:variable name="metafile" select="resolve-uri($documentURI, $source)"/>
	<xsl:variable name="metadata" select="document($metafile)"/>


	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="not($documentURI)">
				<xsl:message select="concat('WARNING: No documentURI given for ', document-uri(/), '. Canonical page numbers will not work.')"/>
				<xsl:copy-of select="/"/>
			</xsl:when>
			<xsl:when test="not(doc-available($metafile))">
				<xsl:message select="concat('WARNING: Metadata file ', $metafile, ' is not available. Canonical page numbers will not work.')"/>
				<xsl:copy-of select="/"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:next-match/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="pb[@n and $documentURI]">
		<xsl:variable name="pbNo" as="xs:string">
			<xsl:number format="1" level="any"/>
		</xsl:variable>
		<xsl:variable name="docTranscriptNos">
			<xsl:for-each select="tokenize(@n, '\s+')">
				<xsl:variable name="n" select="replace(., '^0+', '')"/>
				<xsl:variable name="pattern" select="concat('0*(', $n, ')(\.xml)?')"/>
				<xsl:variable name="pageElem"
					select="$metadata//f:docTranscript[matches(@uri, $pattern)]/ancestor::f:page[1]"/>
				<xsl:for-each select="$pageElem[1]">
					<xsl:number format="1" level="any" from="f:archivalDocument|f:print"/>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:variable>
		<xsl:copy>
			<xsl:apply-templates select="@* except f:docTranscriptNo"/>
			<xsl:choose>
				<xsl:when test="string-join($docTranscriptNos, '') != ''">
					<xsl:attribute name="f:docTranscriptNo" select="string-join($docTranscriptNos, ' ')"/>					
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="$type = 'archivalDocument'">
						<xsl:message>WARNING: No doc transcript; using fallback pageno <xsl:value-of select="$pbNo"/> in <xsl:value-of select="id('sigil')"/></xsl:message>
					</xsl:if>
					<xsl:attribute name="f:docTranscriptNo" select="$pbNo"/>
					<xsl:attribute name="f:hasDocTranscript">no</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>		
	</xsl:template>

</xsl:stylesheet>
