<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	xmlns:f="http://www.faustedition.net/ns"
	exclude-result-prefixes="xs f"
	version="2.0">

	<xsl:output method="xml"/>
	
	<xsl:key name="next" match="*/@next" use="document(.)"/>
	<xsl:param name="incipit_words" as="xs:integer">5</xsl:param>
	
	<xsl:template name="collection">
		<xsl:variable name="documents">
			<xsl:for-each select="collection()">
				<xsl:call-template name="document"/>
			</xsl:for-each>
		</xsl:variable>
		
		<f:json>
			<xsl:value-of select="string-join($documents/*, ',&#10;')"/>
		</f:json>
	</xsl:template>
	
	<xsl:template match="/">
		<f:document>
			<xsl:apply-templates/>
		</f:document>
	</xsl:template>
	
	<xsl:template match="TEI" name="document">
		<xsl:variable name="uri" select="//idno[@type='fausturi']"/>
		<xsl:variable name="sigil" select="//idno[@type='faustedition']"/>
			<xsl:for-each select="//milestone[@unit='paralipomenon' and not(key('next', .))]">				
				<xsl:variable name="no" select="replace(@n, 'p(\d+)', '$1')"/>
				<xsl:variable name="spanTo" select="document(current()/@spanTo)"/>
				<xsl:variable name="rawContent">
					<xsl:choose>
						<xsl:when test="count($spanTo) eq 1">
							<xsl:sequence select="following::node()[$spanTo >> .]"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:message select="concat('WARNING: Paralipomenon ', $no, ' in ', $sigil, ': spanTo points to ', count($spanTo), ' nodes!')"/>
							<xsl:sequence select="following::node()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="rawText">
					<xsl:apply-templates select="$rawContent" mode="text"></xsl:apply-templates>
				</xsl:variable>
				<xsl:variable name="text" select="tokenize(normalize-space(string-join($rawText, '')), ' ')[position() le $incipit_words]"/>
				<f:item>
					<xsl:text>{</xsl:text>
					<xsl:text>"n":</xsl:text>		<xsl:value-of select="$no"/><xsl:text>,</xsl:text>
					<xsl:text>"sigil":</xsl:text>	
					<xsl:value-of select="$sigil"/><xsl:text>",</xsl:text>
					<xsl:text>"uri":</xsl:text>     
					<xsl:value-of select="$uri"/><xsl:text>",</xsl:text>
					<xsl:text>"text":"</xsl:text>	<xsl:value-of select="$text"/><xsl:text>"</xsl:text>
					<xsl:text>}</xsl:text>
				</f:item>	
			</xsl:for-each>
		
	</xsl:template>
	
	<xsl:template mode="text" match="l|p|head|stage">
		<xsl:apply-templates mode="#current"/>
		<xsl:if test="position() != last()">
			<xsl:text> / </xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template mode="text" match="speaker|label">
		<xsl:apply-templates mode="#current"/>
		<xsl:text>. </xsl:text>
	</xsl:template>
	
</xsl:stylesheet>