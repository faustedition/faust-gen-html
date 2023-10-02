<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml" xmlns:xh="http://www.w3.org/1999/xhtml"
	xmlns:f="http://www.faustedition.net/ns"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs f xh"
	version="2.0">
	
	<xsl:import href="print2html.xsl"/>
	<xsl:param name="output-type">app</xsl:param>
	
	
	<xsl:template match="/">
		<xsl:call-template name="html-frame">
			<xsl:with-param name="headerAdditions">
				<style>
					.note.type-textcrit {
						float: none;
						margin: 0;
						width: auto;	
						text-indent: 0;
					}
					.type-textcrit .rdg:before { content: " " }
					.type-textcrit .reading-type { display: none; }
				</style>
			</xsl:with-param>
			<xsl:with-param name="section-classes" select="('print', 'center')"/>
			<xsl:with-param name="breadcrumb-def" tunnel="yes">
				<a href="/print/faust">Text</a>
				<a href="/text-app">Apparat</a>
			</xsl:with-param>
			<xsl:with-param name="content">				
				<xsl:for-each-group select="//note[@type='textcrit']" 
									group-by="for $attr in descendant::rdg/@type return tokenize($attr, '\s+')">
					<xsl:sort select="current-grouping-key()"/>
					<div>
						<h2 id="{current-grouping-key()}">
							<xsl:value-of select="concat(f:format-rdg-type(current-grouping-key()), ': ', f:rdg-type-descr(current-grouping-key()))"/>
						</h2>
						<xsl:choose>
							<xsl:when test="$output-type = 'reflist'">
								<ul>
									<xsl:for-each select="current-group()">
										<li><xsl:value-of select="ref"/></li>
									</xsl:for-each>
								</ul>								
							</xsl:when>
							<xsl:otherwise>
								<xsl:apply-templates select="current-group()"/>								
							</xsl:otherwise>
						</xsl:choose>
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
