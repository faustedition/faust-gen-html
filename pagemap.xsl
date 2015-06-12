<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:f="http://www.faustedition.net/ns"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs f"
	version="2.0">

	<!-- 
	
	Dieses Stylesheet erzeugt aus einem einzelnen Faust-Transcript ein XML-Dokument, dass die Datei- und Seitenstruktur wiedergibt.
	
	Beispiel (gekürzt):

	<document uri="faust://xml/document/faust/2/gsa_391098.xml" split="true">
		<page>1</page>
		<page>3</page>
		<page>5</page>
		<file name="391098.1.html">
			<file name="391098.2.html">
				<page>7</page>
				<page>8</page>
				<page>9</page>
				<page>10</page>
			</file>
			<page>11</page>
		</file>
	</document>

	Also ein document-Element pro Document, ein <page>-Element pro Seite, und ein (ggf. geschachteltes)
	file-Element pro Seite. 
	
	Die Eingabedatei muss vorher mit resolve-pb.xsl behandelt worden sein, außerdem werden die üblichen Parameter
	erwartet (siehe config.xml).

	-->

	<xsl:import href="print2html.xsl"/>
	<xsl:strip-space elements="*"/>
	<xsl:template match="comment()|text()|processing-instruction()"/>
	<xsl:template match="/">
		<xsl:variable name="splittable" select="f:is-splitable-doc(.)"/>
		<document uri="faust://xml/{$documentURI}" split="{$splittable}">
			<file name="{replace($output-base, '^.*/', '')}.html">
				<xsl:choose>
					<xsl:when test="$splittable">
						<xsl:apply-templates mode="divs"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select=".//pb" mode="divs"/>
					</xsl:otherwise>
				</xsl:choose>
			</file>
		</document>
	</xsl:template>

	<xsl:template match="pb[@f:docTranscriptNo][not(preceding::pb[@f:docTranscriptNo=current()/@f:docTranscriptNo])]" mode="divs">
		<page>
			<xsl:value-of select="@f:docTranscriptNo"/>
		</page>
	</xsl:template>

	<xsl:template match="text()|comment()|processing-instruction()" mode="divs"/>

	<xsl:template match="div[count(ancestor::div) lt number($depth_n)]" mode="divs">
		<xsl:variable name="filename">
			<xsl:call-template name="filename"/>
		</xsl:variable>
		<file name="{replace($filename, '^.*/', '')}">
			<xsl:apply-templates mode="#current"/>
		</file>
	</xsl:template>

</xsl:stylesheet>