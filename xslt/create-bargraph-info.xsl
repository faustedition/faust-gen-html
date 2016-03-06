<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns:j="http://www.ibm.com/xmlns/prod/2009/jsonx"
	exclude-result-prefixes="xs f"
	version="2.0">

	<xsl:output method="xml"/>
	
	<!-- 
		This document converts a textual transcript to a JSONx representation suited for generating the bargraph JSON.
		It should be run on the preprocessed stuff from add-metadata.xsl. 
		It extracts _verse intervals_ from the lines and milestone elements in the transcript.
	-->
	
	<xsl:template match="/">
		<!-- Collect the data: One <f:line> element for each referred line. See below. -->
		<xsl:variable name="lines" as="element()*">
			<xsl:apply-templates select=".//l[@n]|.//milestone[@f:relatedLines]"/>
		</xsl:variable>
		
		<!-- Sort by verse number -->
		<xsl:variable name="sortedLines" as="element()*">
			<xsl:perform-sort select="$lines">
				<xsl:sort select="number(@n)"/>
			</xsl:perform-sort>
		</xsl:variable>
		
		<f:json>
		<!-- First a little document metadata -->
		<xsl:text>{"sigil":"</xsl:text><xsl:value-of select=".//idno[@type='faustedition']"/><xsl:text>",</xsl:text>
		<xsl:text>"source":"</xsl:text><xsl:value-of select=".//idno[@type='fausturi']"/><xsl:text>",</xsl:text>			
		<xsl:text>"print":"</xsl:text><xsl:value-of select="if (TEI/@type = 'print') then 'true' else 'false'"/><xsl:text>",</xsl:text>
		<xsl:text>"intervals":[</xsl:text>
				<!-- now group adjacent verse numbers. We create a new interval if either the number verses is not 
					consecutive or a different page or type starts.  -->
				<xsl:for-each-group select="$sortedLines" group-adjacent="string-join((
					if (number(@n) - 1 eq number(preceding::f:line[1]/@n)) then 't' else 'f', 
					@type, 
					@page), '|')">
					
						<xsl:text>"type":"</xsl:text><xsl:value-of select="current-group()[1]/@type"/><xsl:text>",</xsl:text>
						<xsl:text>"page":</xsl:text><xsl:value-of select="current-group()[1]/@page"/><xsl:text>,</xsl:text>
						<xsl:text>"start":</xsl:text><xsl:value-of select="current-group()[1]/@n"/><xsl:text>,</xsl:text>
						<xsl:text>"end":</xsl:text><xsl:value-of select="current-group()[last()]/@n"/><xsl:text>}</xsl:text>
					<xsl:if test="position() != last()">,</xsl:if>					
				</xsl:for-each-group>
		<xsl:text>]}</xsl:text>
		</f:json>
	</xsl:template>
	
	
	<xsl:template match="l[matches(@n, '^\d+[A-Za-z]*\??$')]">
		<xsl:variable name="page" select="preceding::pb[1]/@f:docTranscriptNo"/>
		<xsl:sequence select="for $n in tokenize(@n, '\s+') return f:verseLine($n, $page)"/>
	</xsl:template>
	
	
	<xsl:function name="f:verseLine" as="element()?">
		<xsl:param name="n" as="xs:string"/>
		<xsl:param name="page" as="xs:string?"/>
		<xsl:sequence select="f:line(xs:integer(replace($n, '^(\d+).*$', '$1')), $page, 		
					if (matches($n, '\d+\?$'))
					then 'verseLineUncertain' 
					else if (matches($n, '^\d+[A-Za-z]+$')) 
						 then 'verseLineVariant'
						 else 'verseLine')"/>	
	</xsl:function>

	<xsl:template match="milestone[@unit='paraliponemon' and @f:relatedLines != '']">
		<xsl:variable name="page" select="preceding::pb[1]/@f:docTranscriptNo"/>
		<xsl:variable name="type" select="if (@f:relatedLinesUncertain = 'true') then 'paraliponemaUncertain' else 'paraliponema'"/>
		<xsl:for-each select="tokenize(f:relatedLines, ',\s*')">
			<xsl:analyze-string select="." regex="(\d+)-(\d+)">
				<!-- Ranges -> one <line> element for each line in the range -->
				<xsl:matching-substring>
					<xsl:sequence select="for $n in (xs:integer(regex-group(1)) to xs:integer(regex-group(2))) return f:line($n, $page, $type)"/>
				</xsl:matching-substring>
				<xsl:non-matching-substring>
					<xsl:choose>
						<xsl:when test="matches(., '^\d+$')">
							<xsl:sequence select="f:line(xs:integer(.), $page, $type)"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:message>WARNING: Cannot parse relatedLines: <xsl:copy-of select="."/></xsl:message>
						</xsl:otherwise>						
					</xsl:choose>
				</xsl:non-matching-substring>
			</xsl:analyze-string>			
		</xsl:for-each>
	</xsl:template>
	
	<xsl:function name="f:line" as="element()?">
		<xsl:param name="n" as="xs:integer"/>
		<xsl:param name="page" as="xs:string?"/>
		<xsl:param name="type" as="xs:string"/>		
		<xsl:variable name="result" as="element()">
			<f:line type="{$type}" page="{$page}" n="{$n}"/>
		</xsl:variable>
		<xsl:sequence select="if ($result/@n != '') then $result else ()"/>
	</xsl:function>
	
	<xsl:template match="*"/>
	
	
</xsl:stylesheet>