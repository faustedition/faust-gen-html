<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs"
	version="2.0">
	
	<!-- 
	
	Dieses Stylesheet wandelt von pagemap.xsl erzeugte Datei, oder eine Konkatenation daraus (p:wrap-sequence) in
	eine JSON-Repräsentation. Beispiel, analog zum Beispiel in pagemap.xsl:
	
	
	{ 
      "faust://xml/document/faust/2/gsa_391098.xml" : 
        { 
          "1" : "391098.1.html",
          "2" : "391098.1.html",
        },
	}
	
	nur halt kompakt.
	
	-->
	
	
	<xsl:output method="text" media-type="application/json"/>
	<xsl:strip-space elements="*"/>
	
	<xsl:template match="/">
		<json>
			<xsl:text>{</xsl:text>
			<xsl:apply-templates/>
			<xsl:text>}</xsl:text>
		</json>
	</xsl:template>
	
	<xsl:template match="document">
		<xsl:text>"</xsl:text>
		<xsl:value-of select="@uri"/>
		<xsl:text>":{</xsl:text>
		<xsl:value-of select="string-join((
			for $page in .//page[normalize-space(.)]
			return concat('&quot;', $page/text(), '&quot;:&quot;', $page/parent::file/@name, '&quot;')), 
			',')"/>
		<xsl:text>}</xsl:text>		
		<xsl:if test="following-sibling::document">,</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>