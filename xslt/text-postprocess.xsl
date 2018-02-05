<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns="http://www.tei-c.org/ns/1.0"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs f"
	version="2.0">

	<!--

		This stylesheet is applied to the almost finished reading text, after
		the apparatus has been applied. Thus, it contains cleanup steps that
		need to work on the apparatus.

	-->

	<xsl:strip-space elements="TEI teiHeader fileDesc titleStmt publicationStmt sourceDesc choice app"/>


	<!-- mark up apparatus abbreviations -->
	<xsl:template match="note[@type='textcrit']//note/text()">
		<xsl:analyze-string select="." regex="\b(ci|em|mon|bill|erg|vorschl)\b\.?" flags="!">
			<xsl:matching-substring>
				<abbr><xsl:value-of select="concat(regex-group(1), '.')"/></abbr>
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:copy/>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>

	<!-- Keep everything else as is -->
	<xsl:template match="node()|@*" mode="#all">
		<xsl:copy copy-namespaces="no">
			<xsl:apply-templates select="@*, node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>