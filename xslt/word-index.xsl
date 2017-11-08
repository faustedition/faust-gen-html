<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns="http://www.w3.org/1999/xhtml"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs"
	default-collation="http://www.w3.org/2013/collation/UCA?lang=de"
	version="3.0">
	
	<xsl:import href="html-frame.xsl"/>
	<xsl:param name="limit" select="1"></xsl:param>
	
	<!-- tokenize -->
	<xsl:template match="text()" priority="1">
		<xsl:variable name="sigil" select="ancestor::TEI//idno[@type='faustedition']"/>
		<xsl:variable name="n" select="ancestor::*[@n][1]/@n"/>
		<xsl:variable name="transcript" select="ancestor::TEI//idno[@type='fausttranscript']"/>
		<xsl:variable name="section" select="if (ancestor::TEI/@split='true') then concat($transcript, '.', ancestor::*/@f:section[1]) else $transcript"/>
		<xsl:analyze-string select="." regex="\w+">
			<xsl:matching-substring>
				<xsl:choose>
					<xsl:when test="not(matches(., '^[0-9]+$') or $sigil=('Lesetext', 'Testhandschrift'))">
						<tei:w s="{$sigil}" n="{$n}" t="{$section}"><xsl:value-of select="."/></tei:w>						
					</xsl:when>
					<xsl:otherwise><xsl:copy/></xsl:otherwise>
				</xsl:choose>
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:copy/>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	
	<xsl:template match="/">
		<xsl:call-template name="html-frame">
			<xsl:with-param name="content">			
						
				<xsl:variable name="tokenized">
					<xsl:apply-templates select="//text"/>
				</xsl:variable>
				
				<h1>Index seltener Tokens (weniger als <xsl:value-of select="$limit"/> Vorkommen)</h1>
				
				<xsl:for-each-group select="$tokenized//w" group-by=".">
					<xsl:sort select="current-grouping-key()"/>					
					<xsl:variable name="total" select="count(current-group())"/>
					
					<xsl:if test="$total lt $limit">
						<div class="l">
							<strong>
								<xsl:if test="matches(current-grouping-key(), '[a-z][A-Z]')">
									<xsl:attribute name="style">color:red;</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="current-grouping-key()"/>
							</strong> (<xsl:value-of select="$total"/>):<xsl:text> </xsl:text>
							<xsl:for-each-group select="current-group()" group-by="@s">
								<xsl:value-of select="current-grouping-key()"/> 
								<xsl:text> (</xsl:text>					
								<xsl:for-each select="current-group()">
									<xsl:choose>
										<xsl:when test="@n != ''">
											<a href="/print/{@t}#l{@n}"><xsl:value-of select="@n"/></a>											
										</xsl:when>
										<xsl:otherwise>
											<a href="/print/{@t}">ohne Versnr.</a>
										</xsl:otherwise>
									</xsl:choose>									
									<xsl:if test="position() != last()">, </xsl:if>
								</xsl:for-each>
								<xsl:text>)</xsl:text>
								<xsl:if test="position() != last()">, </xsl:if>
							</xsl:for-each-group>
						</div>						
					</xsl:if>
					
				</xsl:for-each-group>		
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>	
	
	
	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="@*, node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>