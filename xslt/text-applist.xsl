<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:f="http://www.faustedition.net/ns"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs f"
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
						text-indent: 0;
						width: auto;						
					}
					.type-textcrit .rdg:before { content: " " }
					.type-textcrit .reading-type, .type-textcrit .applinks { display: none; }
					.appnote { cursor: inherit; }
				</style>
			</xsl:with-param>
			<xsl:with-param name="section-classes" select="('print', 'center')"/>
			<xsl:with-param name="breadcrumb-def" tunnel="yes">
				<a href="/print/text">Text</a>
				<a href="/text-app">Apparat</a>
			</xsl:with-param>
			<xsl:with-param name="content">
				<nav class="pure-center">
					<a href="app" class="pure-button {if ($output-type='app') then 'pure-button-selected' else ''}">Apparat nach Typ</a>
					<xsl:text> </xsl:text>
					<a href="app-by-scene" class="pure-button {if ($output-type='byscene') then 'pure-button-selected' else ''}">Apparat nach Textstelle</a>
					<xsl:text> </xsl:text>
					<a href="faust" class="pure-button">Text</a>
				</nav>
				<xsl:choose>
					<xsl:when test="$output-type='byscene'">
						<xsl:apply-templates mode="byscene"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="app-by-type"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	
	<xsl:template name="app-by-type">				
		<xsl:for-each-group select="//note[@type = 'textcrit']"
			group-by="
				for $attr in descendant::rdg/@type
				return
					tokenize($attr, '\s+')">
			<xsl:sort select="current-grouping-key()"/>
			<div>
				<h2 id="{current-grouping-key()}">
					<xsl:value-of
						select="concat(f:format-rdg-type(current-grouping-key()), ': ', f:rdg-type-descr(current-grouping-key()))"
					/>
				</h2>
				<xsl:choose>
					<xsl:when test="$output-type = 'reflist'">
						<ul>
							<xsl:for-each select="current-group()">
								<li>
									<xsl:value-of select="ref"/>
								</li>
							</xsl:for-each>
						</ul>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="current-group()"/>
					</xsl:otherwise>
				</xsl:choose>
			</div>
		</xsl:for-each-group>
	</xsl:template>
	
	<xsl:template match="*" mode="byscene">
		<xsl:apply-templates mode="#current"/>
	</xsl:template>
	<xsl:template match="text()" mode="byscene"/>
	
	<xsl:template mode="byscene" match="div[descendant::note[@type='textcrit']][count(ancestor::div) lt 4]">
		<xsl:text>&#10;&#10;&#10;&#10;&#10;&#10;</xsl:text>
		<div>
			<xsl:element name="h{count(ancestor::div)+2}">
				<xsl:value-of select="@f:label"/>				
			</xsl:element>
			<xsl:apply-templates mode="#current"/>
		</div>
	</xsl:template>
	
	<xsl:template mode="byscene" match="note[@type='textcrit']">
		<xsl:apply-templates select="." mode="#default"/>
	</xsl:template>

	<xsl:template match="note[@type='textcrit']">
		<xsl:text>&#10;&#10;&#10;</xsl:text>
		<xsl:comment><xsl:value-of select="ref, @xml:id, app/lem" separator="   "/></xsl:comment>
		<xsl:text>&#10;</xsl:text>
		<xsl:next-match/>
	</xsl:template>
		
	<xsl:template match="note[@type='textcrit']/ref">
		<a href="faust.{f:get-section-number(.)}#{../@xml:id}">
			<xsl:next-match/>
		</a>
	</xsl:template>
	
</xsl:stylesheet>