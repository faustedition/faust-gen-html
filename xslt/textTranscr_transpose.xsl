<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
	xmlns:f="http://www.faustedition.net/ns" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs f" version="2.0" xmlns:ge="http://www.tei-c.org/ns/geneticEditions">
	
	<xsl:param name="skip-posthumous" select="false()"/>
	
	<!-- delivers the tei:ptr in a not-undone ge:transpose element that points to the given @xml:id string -->
	<xsl:key 
		name="transpose" 
		match="ge:transpose[not($skip-posthumous and @ge:stage='#posthumous')]
					/ptr[not(..[@xml:id and concat('#', @xml:id) = //ge:undo/@target])]" 
		use="substring(@target, 2)"/>
		
	<!-- 
		go on with the element that has been transposed with the matching element instead
		XXX do we need a priority here?	
	-->
	<xsl:template match="*[@xml:id and key('transpose', @xml:id)]">
		<xsl:variable name="ptr" select="key('transpose', @xml:id)"/>
		<xsl:variable name="transpose" select="$ptr/.."/>				
		<xsl:variable name="currentPos" select="count(preceding::*[@xml:id and key('transpose', @xml:id)/.. is $transpose]) + 1"/>
		<xsl:variable name="replacementTarget" select="$transpose/ptr[$currentPos]/@target"/>		
		<xsl:variable name="replacement" select="id(substring($replacementTarget, 2))"/>				
<!--		<xsl:comment select="concat('Replacing #', @xml:id, ' at pos ', $currentPos, ' with #', $replacement/@xml:id, ':')"/>-->
		<xsl:for-each select="$replacement">
			<xsl:copy>				
				<xsl:apply-templates select="@*"/>
				<xsl:apply-templates select="node()"/>
			</xsl:copy>
		</xsl:for-each>
	</xsl:template>
	
	
	<!-- identity transformation -->
	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
		
</xsl:stylesheet>