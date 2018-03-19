<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns="http://www.w3.org/1999/xhtml"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs tei f"
	default-collation="http://www.w3.org/2013/collation/UCA?lang=de"
	version="3.0">
	
	<xsl:import href="html-frame.xsl"/>
	<xsl:param name="limit" select="1"/>
	<xsl:param name="title"/>
	<xsl:variable name="forbidden-sigils" select="if (count(//TEI) > 1) then ('Testhandschrift', 'Lesetext') else ()"/>
	
	<!-- tokenize -->
	<xsl:template match="text()" priority="1">
		<xsl:variable name="sigil" select="ancestor::TEI//idno[@type='faustedition']"/>
		<xsl:variable name="n" select="ancestor::*[@n][1]/@n"/>
		<xsl:variable name="transcript" select="ancestor::TEI//idno[@type='fausttranscript']"/>
		<xsl:variable name="section" select="if (ancestor::TEI/@split='true') then concat($transcript, '.', ancestor::*/@f:section[1]) else $transcript"/>
		<xsl:analyze-string select="." regex="\w+">
			<xsl:matching-substring>
				<xsl:choose>
					<xsl:when test="not(matches(., '^[0-9]+$') or $sigil=$forbidden-sigils)">
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
		<xsl:message select="concat('Generating word index for up to ', $limit, ' occurances ...')"/>		
		<xsl:variable name="tokenized">
			<xsl:apply-templates select="//text"/>
		</xsl:variable>
		<xsl:call-template name="html-frame">
			<xsl:with-param name="headerAdditions">
				<style>
					.token { font-weight: bold; }
					.camelcase { color: red; }
					td.count { justify: right; }
					.documents { color: gray; }
				</style>
			</xsl:with-param>
			<xsl:with-param name="breadcrumb-def" tunnel="yes"><a>
				<xsl:choose>
					<xsl:when test="$title"><xsl:value-of select="$title"/></xsl:when>
					<xsl:otherwise>Seltene Tokens (≤ <xsl:value-of select="$limit"/> Vorkommen)</xsl:otherwise>
				</xsl:choose></a>
			</xsl:with-param>
			<xsl:with-param name="jsRequirements">sortable:Sortable</xsl:with-param>
			<xsl:with-param name="scriptAdditions">Sortable.initTable(document.getElementById('wordlist'));</xsl:with-param>
			<xsl:with-param name="content">			
						
				
				<table data-sortable="true" class="pure-table" xml:id="wordlist">
				<thead><tr>
					<th data-sortable-type="alpha">Token</th>
					<th data-sortable-type="numericplus">Häufigkeit</th>
					<th data-sortable-type="numericplus">Verse (Zeugen)</th>
				</tr></thead>
				<tbody>
					<xsl:comment select="$limit"/>
					<xsl:comment select="$limit = 0"/>
				<xsl:for-each-group select="$tokenized//w" group-by=".">
					<xsl:sort select="count(current-group())"/>
					<xsl:sort select="current-grouping-key()"/>					
					<xsl:variable name="total" select="count(current-group())"/>
					
					<xsl:if test="($limit = 0) or ($total &lt;= $limit)">
						<tr>
							<td>
								<xsl:attribute name="class" separator=" ">
									<xsl:text>token</xsl:text>
									<xsl:if test="matches(current-grouping-key(), '[a-z][A-Z]')">
										<xsl:text>camelcase</xsl:text>
									</xsl:if>									
								</xsl:attribute>
								<xsl:value-of select="current-grouping-key()"/>
							</td>
							<td class="count">
								<xsl:value-of select="$total"/>
							</td>
							<td class="where">
								<xsl:for-each-group select="current-group()" group-by="@n">
									<xsl:sort select="replace(current-grouping-key(), '\D*(\d+).*', '$1')"/>
									<xsl:variable name="n" select="current-grouping-key()"/>
									<xsl:value-of select="if ($n != '') then $n else 'ohne Versnr.'"/>
									<small class="documents">
										<xsl:text> (</xsl:text>					
										<xsl:for-each-group select="current-group()" group-by="@s">
											<xsl:variable name="w" select="current-group()[1]"/>
											<a href="/print/{$w/@t}#l{$n}"><xsl:value-of select="$w/@s"/></a>											
											<xsl:if test="position() != last()">, </xsl:if>
										</xsl:for-each-group>
										<xsl:text>)</xsl:text>										
									</small>
									<xsl:if test="position() != last()">, </xsl:if>
								</xsl:for-each-group>								
							</td>
						</tr>						
					</xsl:if>					
				</xsl:for-each-group>
				</tbody>
				</table>
			</xsl:with-param>			
		</xsl:call-template>
	</xsl:template>	
	
	
	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="@*, node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
</xsl:stylesheet>
