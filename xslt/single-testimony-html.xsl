<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns="http://www.w3.org/1999/xhtml"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs"
	version="2.0">
	
	<xsl:import href="testimony2html.xsl"/>
	
	<xsl:variable name="id" select="data(//f:testimony/@id)"/>

	
	
	
	
	<xsl:template match="/TEI">
		<xsl:call-template name="html-frame">
			<xsl:with-param name="breadcrumb-def" tunnel="yes">
				<a href="/archive">Archiv</a>
				<a href="/archive_testimonies#{$id}">Entstehungszeugnisse</a>
				<a><xsl:value-of select="f:testimony-label($id)"/></a>
			</xsl:with-param>			
			<xsl:with-param name="headerAdditions">				
				<link rel="stylesheet" href="{$assets}/css/document-viewer.css"/>
			</xsl:with-param>
			<xsl:with-param name="scriptAdditions">
				require(['faust_app']);
			</xsl:with-param>
			<xsl:with-param name="content">
				<div class="testimony pure-g-r">
					<div class="pure-u-1-2">
						<xsl:apply-templates select="//f:testimony"/>						
					</div>
					<div class="pure-u-1-2">
						<xsl:apply-templates select="//text//text[not(@copyOf)]"/>						
					</div>					
				</div>
			</xsl:with-param>
		</xsl:call-template>				
	</xsl:template>

	
	<xsl:template match="f:testimony">
		<dl class="metadata-container testimony-metadata">
			<xsl:apply-templates/>
			<dd><a href="#{$id}">zum Entstehungszeugnis im Text <i class="fa fa-right-dir"></i></a></dd>			
		</dl>
		<xsl:if test="descendant::f:field[@name='zuordnung-zu-wanderjahren-trunz-aber-vgl-quz-ii-s-477f-anm-2'][normalize-space(lower-case(.)) = 'x']">
			<p>
				Dieses Zeugnis ist in der älteren Forschung auf <em>Faust</em> bezogen worden; wahrscheinlich gehört es in einen anderen Zusammenhang.
			</p>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="f:field[starts-with(@name, 'lfd-nr')][1]" priority="1">
		<dt>Zeugnis-Nr.</dt>
		<dd><xsl:value-of select="."/></dd>
	</xsl:template>
	
	<xsl:template match="f:field[starts-with(@name, 'lfd-nr')]"/>
		
	<xsl:template match="f:field[@name='datum-von']">
		<dt>Datum</dt>
		<dd>
			<xsl:choose>
				<xsl:when test="../f:field[@name='datum-bis']">zwischen <xsl:value-of select="."/> und <xsl:value-of select="../f:field[@name='datum-bis']"/></xsl:when>
				<xsl:otherwise><xsl:value-of select="."/></xsl:otherwise>				
			</xsl:choose>
			<xsl:if test="../f:field[@name='intervall-erschlossen']"> (erschlossen)</xsl:if>
		</dd>
	</xsl:template>
	
	<xsl:template match="f:field[@name='dokumenttyp']">
		<dt><xsl:value-of select="f:fieldlabel(@name)"/></dt>
		<dd><xsl:call-template name="render-dokumenttyp"/></dd>
	</xsl:template>
	
	<xsl:template match="f:field[@name='druckort']">
		<dt><xsl:value-of select="f:fieldlabel(@name)"/></dt>
		<dd>
			<xsl:value-of select="."/>
			<xsl:if test="../f:field[@name='alternativer-druckort']">; <xsl:value-of select="../f:field[@name='alternativer-druckort']"/></xsl:if>
		</dd>
	</xsl:template>
	
	<xsl:template match="f:field[@name='h-sigle']">
		<dt><xsl:value-of select="f:fieldlabel(@name)"/></dt>
		<dd><xsl:sequence select="f:sigil-links(.)"/></dd>
	</xsl:template>
	
	<xsl:function name="f:fieldlabel">
		<xsl:param name="fieldname"/>
		<xsl:variable name="spec" select="$fields//f:fieldspec[@name = $fieldname]"/>
		<xsl:value-of select="if (normalize-space($spec)) then $spec else $spec/@spreadsheet"/>
	</xsl:function>	
	
	<xsl:template match="f:field[f:fieldspec(@name)/@ignore='yes']" priority="0.1"/>
	
	<xsl:template match="f:field">
		<dt><xsl:value-of select="f:fieldlabel(@name)"/></dt>
		<dd><xsl:value-of select="."/></dd>
	</xsl:template>
	
	<xsl:template match="f:biburl">
		<xsl:variable name="citation" select="f:cite(., false())"/>
		<xsl:if test="starts-with($citation, 'faust://')"><xsl:message select="concat('WARNING: Citation ', ., ' missing in testimony ', $id)"/></xsl:if>
		<dt>Quelle</dt>
		<dd><xsl:sequence select="$citation"/></dd>
	</xsl:template>
	
</xsl:stylesheet>