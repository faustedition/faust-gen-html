<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	xmlns:f="http://www.faustedition.net/ns"
	exclude-result-prefixes="xs f"
	version="2.0">
		
	<xsl:import href="html-common.xsl"/>
	
	<xsl:param name="variants">variants/</xsl:param>
	<xsl:param name="docbase">https://faustedition.uni-wuerzburg.de/new</xsl:param>
		
	
	<xsl:output method="xhtml"/>
	
	<xsl:template match="/*">		
		<xsl:for-each-group select="*" group-by="f:output-group(@n)">
			<xsl:variable name="output-file" select="concat($variants, current-grouping-key(), '.html')"/>			
			<xsl:result-document href="{$output-file}">
				<div class="groups" data-group="{current-grouping-key()}">
					<xsl:for-each-group select="current-group()" group-by="@n">
						<div class="variants" data-n="{current-grouping-key()}" 
							data-size="{count(current-group())}" xml:id="v{current-grouping-key()}" id="v{current-grouping-key()}">
							<xsl:apply-templates select="current-group()">
								<xsl:sort select="@f:sigil"/>
							</xsl:apply-templates>
						</div>
					</xsl:for-each-group>
				</div>
			</xsl:result-document>
		</xsl:for-each-group>
	</xsl:template>
	
	<xsl:template match="*[@n]">
		<div class="{string-join(f:generic-classes(.), ' ')}" 
			data-n="{@n}" data-source="{@f:doc}">
			<xsl:call-template name="generate-style"/>
			<xsl:apply-templates/>
			<xsl:text> </xsl:text>
			<a class="sigil" href="{$docbase}/{@f:doc}" title="{@f:sigil-type}">
				<xsl:value-of select="@f:sigil"/>
			</a>
		</div>
	</xsl:template>	
	
	<xsl:template match="*">
		<xsl:element name="{f:html-tag-name(.)}">
			<xsl:attribute name="class" select="string-join(f:generic-classes(.), ' ')"/>			
			<xsl:apply-templates/>
		</xsl:element>		
	</xsl:template>
	
	<xsl:template match="lb">
		<br/>
	</xsl:template>
</xsl:stylesheet>
