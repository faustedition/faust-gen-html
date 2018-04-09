<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml" xmlns:xh="http://www.w3.org/1999/xhtml"
	xmlns:f="http://www.faustedition.net/ns"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs f xh"
	version="2.0">
	
	<xsl:import href="print2html.xsl"/>
	
	<xsl:template match="/">
		<xsl:call-template name="html-frame">
			<xsl:with-param name="headerAdditions">
				<style>
					.note.type-textcrit {
						float: none;
						margin: 0;
						width: auto;						
					}
					.type-textcrit .rdg:before { content: " " }
					.type-textcrit .reading-type { display: none; }
				</style>
			</xsl:with-param>
			<xsl:with-param name="section-classes" select="('print', 'center')"/>
			<xsl:with-param name="breadcrumb-def" tunnel="yes">
				<a href="/print/text">Text</a>
				<a href="/text-app">Apparat</a>
			</xsl:with-param>
			<xsl:with-param name="content">				
				<xsl:for-each-group select="//note[@type='textcrit']" group-by="tokenize(descendant::rdg/@type, '\s+')">
					<xsl:sort select="current-grouping-key()"/>
					<div>
						<h2 id="{current-grouping-key()}"><xsl:value-of select="current-grouping-key()"/></h2>
						<xsl:apply-templates select="current-group()"/>					
					</div>
				</xsl:for-each-group>				
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="note[@type='textcrit']/ref">
		<a href="faust.{f:get-section-number(.)}#{../@xml:id}">
			<xsl:next-match/>
		</a>
	</xsl:template>
	
</xsl:stylesheet>