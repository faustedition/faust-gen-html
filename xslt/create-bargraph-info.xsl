<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	xmlns:f="http://www.faustedition.net/ns"
	exclude-result-prefixes="xs f"
	version="2.0">
	
	<xsl:import href="utils.xsl"/>
	
	<xsl:param name="source-uri" select="document-uri(/)"/>

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
		<xsl:variable name="sortedLines">
			<xsl:perform-sort>
				<xsl:sort select="number(@n)"/>
				<xsl:for-each-group select="$lines" group-by="string-join((@n, @type, @page, @section), '|')">
					<xsl:sequence select="current-group()[1]"/>			
				</xsl:for-each-group>
			</xsl:perform-sort>
		</xsl:variable>
		
		<xsl:variable name="labeledLines" as="element()*">
			<xsl:for-each select="$sortedLines/*">
				<xsl:copy>
					<xsl:copy-of select="@*"/>
					<xsl:attribute name="prec" select="preceding::f:line[1]/@n"/>
					<xsl:attribute name="label" select="string-join((
						if (number(@n) - 1 eq number(preceding::f:line[1]/@n)) then 't' else 'f', 
						@type, 
						@page,
						@section), '|')"/>
				</xsl:copy>
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:result-document href="/tmp/lines">
			<doc>
				<xsl:sequence select="$labeledLines"/>
			</doc>
		</xsl:result-document>
		
		<f:document sigil="{.//idno[@type='faustedition']}">
		<!-- First a little document metadata -->
		<xsl:text>{"sigil":"</xsl:text><xsl:value-of select=".//idno[@type='faustedition']"/><xsl:text>",</xsl:text>
		<xsl:variable name="sigil_t" select="f:sigil-for-uri(.//idno[@type='faustedition'])"/>
		<xsl:text>"sigil_t":"</xsl:text><xsl:value-of select="$sigil_t"/><xsl:text>",</xsl:text>
		<xsl:text>"yearlabel":"</xsl:text><xsl:value-of select="f:get-order-info($sigil_t)/@yearlabel"/><xsl:text>",</xsl:text>
		<xsl:text>"source":"</xsl:text><xsl:value-of select=".//idno[@type='fausturi']"/><xsl:text>",</xsl:text>			
		<xsl:text>"print":</xsl:text><xsl:value-of select="if (TEI/@type = 'print') then 'true' else 'false'"/><xsl:text>,</xsl:text>
		<xsl:text>"intervals":[</xsl:text>
				<!-- now group adjacent verse numbers. We create a new interval if either the number verses is not 
					consecutive or a different page or type starts.  -->
				<xsl:for-each-group select="$sortedLines/*"
					group-starting-with="f:line[
						@type != preceding-sibling::*[1]/@type
					 or @page != preceding-sibling::*[1]/@page
					 or @section != preceding-sibling::*[1]/@section
					 or @inscriptions != preceding-sibling::*[1]/@inscriptions
					 or number(@n)-1 ne number(preceding-sibling::*[1]/@n)]"
					>
					<xsl:sort select="index-of(('paralipomenaUncertain', 'paralipomena', 'verseLineVariant', 'verseLineUncertain', 'verseLine'), current-group()[1]/@type)"/>					
<!--					<xsl:message>
						Gruppe:
						<xsl:for-each select="current-group()">
							<xsl:copy-of select="."/><xsl:text>&#10;</xsl:text>
						</xsl:for-each>
					</xsl:message>
-->					<xsl:variable name="page" select="current-group()[1]/@page"/>
						<xsl:text>{"type":"</xsl:text><xsl:value-of select="current-group()[1]/@type"/><xsl:text>",</xsl:text>
						<xsl:text>"page":</xsl:text><xsl:value-of select="if ($page != '') then $page else 1"/><xsl:text>,</xsl:text>
						<xsl:text>"section":"</xsl:text><xsl:value-of select="current-group()[1]/@section"/><xsl:text>",</xsl:text>
					  <xsl:text>"inscriptions":"</xsl:text><xsl:value-of select="current-group()[1]/@inscriptions"/><xsl:text>",</xsl:text>
						<xsl:text>"start":</xsl:text><xsl:value-of select="current-group()[1]/@n"/><xsl:text>,</xsl:text>
						<xsl:text>"end":</xsl:text><xsl:value-of select="current-group()[last()]/@n"/><xsl:text>}</xsl:text>
					<xsl:if test="position() != last()">,</xsl:if>					
				</xsl:for-each-group>
		<xsl:text>]}&#10;</xsl:text>
		</f:document>
	</xsl:template>
	
	
	<xsl:template match="l[matches(@n, '^(\d+[A-Za-z]*\??\s*)+$')]">
		<xsl:variable name="page" select="preceding::pb[1]/@f:docTranscriptNo"/>
		<xsl:variable name="section" select="f:get-section-label(.)"/>
		<xsl:variable name="inscriptions" select="preceding::milestone[@unit='stage'][1]/@change, descendant-or-self::*/@change[starts-with(., '#i_')]"/>
		<xsl:sequence select="for $n in tokenize(@n, '\s+') return f:verseLine($n, $page, $section, $inscriptions)"/>
	</xsl:template>
	
	
	<xsl:function name="f:verseLine" as="element()?">
		<xsl:param name="n" as="xs:string"/>
		<xsl:param name="page" as="xs:string?"/>
		<xsl:param name="section" as="xs:string?"/>
		<xsl:param name="inscriptions"/>
		<xsl:sequence select="f:line(xs:integer(replace($n, '^(\d+).*$', '$1')), $page, 		
					if (matches($n, '\d+\?$'))
					then 'verseLineUncertain' 
					else if (matches($n, '^\d+[A-Za-z]+$')) 
						 then 'verseLineVariant'
						 else 'verseLine', $section, $inscriptions)"/>	
	</xsl:function>

	<xsl:template match="milestone[@unit='paralipomenon' and @f:relatedLines != '']">
		<xsl:variable name="page" select="preceding::pb[1]/@f:docTranscriptNo"/>
		<xsl:variable name="type" select="if (@f:relatedLinesUncertain = 'true') then 'paralipomenaUncertain' else 'paralipomena'"/>
		
		<xsl:for-each select="tokenize(@f:relatedLines, ',\s*')">
			<xsl:analyze-string select="." regex="(\d+)-(\d+)">
				<!-- Ranges -> one <line> element for each line in the range -->
				<xsl:matching-substring>
					<!-- FIXME Inscriptions + Paralipomena? -->
					<xsl:sequence select="for $n in (xs:integer(regex-group(1)) to xs:integer(regex-group(2))) return f:line($n, $page, $type, (), ())"/>
				</xsl:matching-substring>
				<xsl:non-matching-substring>
					<xsl:choose>
						<xsl:when test="matches(., '^\d+$')">
							<xsl:sequence select="f:line(xs:integer(.), $page, $type, (), ())"/> <!-- FIXME Inscriptions -->
						</xsl:when>
						<xsl:otherwise>
							<xsl:message>WARNING: Cannot parse relatedLines: <xsl:copy-of select="."/> (in <xsl:value-of select="$source-uri"/>)</xsl:message>
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
		<xsl:param name="section" as="xs:string?"/>
		<xsl:param name="inscriptions"/>
		<xsl:variable name="result" as="element()">
			<f:line type="{$type}" page="{$page}" n="{$n}" section="{$section}" inscriptions="{$inscriptions}"/>
		</xsl:variable>
		<xsl:sequence select="if ($result/@n != '') then $result else ()"/>
	</xsl:function>
	
	<xsl:template match="*"/>
	
	
</xsl:stylesheet>