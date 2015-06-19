<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs"
	version="2.0">
	
	<xsl:import href="print2html.xsl"/>
	<xsl:param name="type">archivalDocument</xsl:param>
	
	<xsl:output method="xhtml" indent="yes"/>
	
	<xsl:template match="add[not(parent::subst)]">
		<xsl:variable name="erg"> <abbr title="ergänzt" class="app"> erg</abbr> ⟩</xsl:variable>
		<xsl:call-template name="enclose">
			<xsl:with-param name="with" select="('⟨ ',  $erg)"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="del[not(parent::subst)]">
		<xsl:variable name="tilgt"><abbr title="getilgt" class="app"> tilgt</abbr> ⟩</xsl:variable>	
		<xsl:call-template name="enclose">
			<xsl:with-param name="with" select="('⟨ ', $tilgt)"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="subst">
		<span class="app del">
			<xsl:apply-templates select="del"/>
		</span>
		<xsl:for-each select="add">
			<xsl:call-template name="enclose">
				<xsl:with-param name="with" select="('⟨: ', ' ⟩')"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>
	
</xsl:stylesheet>