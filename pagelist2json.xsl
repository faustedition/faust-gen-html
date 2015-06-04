<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs"
	version="2.0">
	
	<!-- 
	
	Dieses Stylesheet wandelt von pagemap.xsl erzeugte Datei, oder eine Konkatenation daraus (p:wrap-sequence) in
	eine JSON-Repräsentation. Beispiel, analog zum Beispiel in pagemap.xsl:
	
	
	[ { 
    "document" : "faust://xml/document/faust/2/gsa_391098.xml",
    "files" : [ 
        { 
          "name" : "391098.1.html",
          "pages" : [ 11 ]
        },
        { 
          "name" : "391098.2.html",
          "pages" : [ 7, 8, 9, 10 ]
        }
      ]
	} ]
	
	nur halt kompakt.
	
	-->
	
	
	<xsl:output method="text" media-type="application/json"/>
	<xsl:strip-space elements="*"/>
	
	<xsl:template match="/">
		<xsl:text>[</xsl:text>
		<xsl:apply-templates/>
		<xsl:text>]</xsl:text>
	</xsl:template>
	
	<xsl:template match="document">
		<xsl:text>{"document":"</xsl:text>
		<xsl:value-of select="@uri"/>
		<xsl:text>","files":[</xsl:text>
		<xsl:apply-templates select="descendant::file"/>
		<xsl:text>]}</xsl:text>		
		<xsl:if test="following-sibling::document">,</xsl:if>
	</xsl:template>
	
	<xsl:template match="file">
		<xsl:text>{"name":"</xsl:text>
		<xsl:value-of select="@name"/>
		<xsl:text>","pages": [</xsl:text>
	  	<xsl:value-of select="string-join(child::page/text(), ',')"/>
		<xsl:text>]}</xsl:text>
		<xsl:if test="some $file in ancestor::document//file satisfies $file >> .">,</xsl:if>		
	</xsl:template>		
</xsl:stylesheet>