<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:f="http://www.faustedition.net/ns"
	xmlns="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs" version="2.0">

	<xsl:param name="type"/>
	<xsl:param name="source" required="yes"/>
	<xsl:param name="documentURI" required="yes"/>
	<xsl:variable name="metadata" select="document(resolve-uri($documentURI, $source))"/>


	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="pb[@n]">
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
			<xsl:attribute name="f:docTranscriptNo" select="string-join($docTranscriptNos, ' ')"/>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>		
	</xsl:template>

</xsl:stylesheet>