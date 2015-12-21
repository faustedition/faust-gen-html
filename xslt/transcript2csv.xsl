<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:f="http://www.faustedition.net/ns"
	xpath-default-namespace="http://www.faustedition.net/ns"
	exclude-result-prefixes="xs"
	version="2.0">
	
<xsl:output method="text"/>

	<xsl:template match="/">"Document","Sigle","Transcript","Type"
<xsl:apply-templates select="//textTranscript"/>
</xsl:template>

	<xsl:template match="textTranscript">"<xsl:value-of select="@document"/>","<xsl:value-of select="@f:sigil"/>","<xsl:value-of select="@uri"/>","<xsl:value-of select="@type"/>"
</xsl:template>
	
	
</xsl:stylesheet>