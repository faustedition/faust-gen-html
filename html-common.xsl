<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml" xmlns:xh="http://www.w3.org/1999/xhtml"
	xmlns:f="http://www.faustedition.net/ns"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs f" 	
	version="2.0">
	
	<!-- common code for print2html and variant generation. not to be used standalone -->
	<xsl:import href="utils.xsl"/>
	
	
	<xsl:template match="figure" mode="#default single">
		<br class="figure {@type}"/>
	</xsl:template>
	
	<xsl:template match="lb" mode="#default single">
		<br class="lb"/>
	</xsl:template>
	
	<xsl:template match="gap[@unit='chars']" mode="#default single">
		<span class="{string-join(f:generic-classes(.), ' ')} gap-unit-chars generated-text" data-gap-length="{@quantity}">
			<xsl:value-of select="string-join(for $n in 1 to @quantity return '×', '')"/>
		</span>
	</xsl:template>
	
	<xsl:template match="gap[@unit='words']" mode="#default single">
		<span class="{string-join(f:generic-classes(.), ' ')} gap-unit-words generated-text" data-gap-length="{@quantity}">
			<xsl:value-of select="string-join(for $n in 1 to @quantity return '×···×', ' ')"/>
		</span>
	</xsl:template>  
	
	<xsl:template match="space" mode="#default single">
		<span class="{string-join(f:generic-classes(.), ' ')} generated-text">***</span>
	</xsl:template>
	
	<!-- Render sth as enclosed with generated text. -->
	<xsl:template name="enclose">
		<xsl:param name="with" required="yes"/>
		<span class="{string-join(f:generic-classes(.), ' ')}">
			<span class="generated-text">
				<xsl:value-of select="$with[1]"/>
			</span>
			<xsl:apply-templates select="node()" mode="#current"/>
			<span class="generated-text">
				<xsl:value-of select="if ($with[2]) then $with[2] else $with"/>
			</span>
		</span>
	</xsl:template>
	
	<xsl:template match="supplied" mode="#default single">
		<xsl:call-template name="enclose">
			<xsl:with-param name="with" select="'[',']'"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="unclear[@cert='high']" mode="#default single">
		<xsl:call-template name="enclose">
			<xsl:with-param name="with" select="'{','}'"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="unclear[@cert='low']" mode="#default single">
		<xsl:call-template name="enclose">
			<xsl:with-param name="with" select="'{{','}}'"/>
		</xsl:call-template>
	</xsl:template>
	
	
	
	
</xsl:stylesheet>