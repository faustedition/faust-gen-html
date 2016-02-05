<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:f="http://www.faustedition.net/ns"
	exclude-result-prefixes="xs"
	version="2.0">
	
	<xsl:import href="faust-metadata.xsl"/>
	
	<xsl:template match="/">
		<html>
			<xsl:call-template name="html-head">
				<xsl:with-param name="title">Bibliographie</xsl:with-param>
			</xsl:call-template>
			<xsl:call-template name="header"/>
			
			<xsl:variable name="entries" as="element()*">
				<xsl:for-each-group select="//f:citation" group-by=".">
					<xsl:sequence select="f:cite(current-grouping-key(), 'dd')"/>
				</xsl:for-each-group>
			</xsl:variable>
			
			<dl>
			<xsl:for-each select="$entries">
				<xsl:sort select="@data-citation"/>
				<dt id="{replace(@data-bib-uri, '^faust://bibliography/', '')}">
					<xsl:value-of select="@data-citation"/>
				</dt>				
				<xsl:sequence select="."/>				
			</xsl:for-each>
			</dl>
			
			
			<xsl:call-template name="footer"/>			
		</html>		
	</xsl:template>
	
	
</xsl:stylesheet>