<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="f">
	
	<xsl:import href="utils.xsl"/>
	
	<xsl:variable name="known-expansions" select="doc('../expan-map.xml')"/>
	
	<xsl:template match="/">
		<xsl:comment>Edit expansions in this file and commit as expan-map.xml</xsl:comment>
		<f:expan-map xmlns="http://www.tei-c.org/ns/1.0">
			<xsl:for-each-group
				select="//abbr[not(preceding-sibling::expan | following-sibling::expan)]"
				group-by="f:normalize-space(.)">
				<xsl:variable name="abbr" select="current-grouping-key()"/>
				<choice>
					<xsl:comment select="string-join(current-group()/ancestor::*[f:hasvars(.)]/@n, ', ')"/>
					<abbr>
						<xsl:value-of select="$abbr"/>
					</abbr>
					
					<!-- do we have an existing expansion? -->
					<xsl:variable name="existing-expansion" select="$known-expansions//abbr[. = $abbr]/../expan[. != $abbr]"/>
					
					<!-- find all expansions for the current abbr elsewhere in the text -->
					<xsl:variable name="expansions">
						<xsl:for-each-group
							select="//expan[
							preceding-sibling::abbr[f:normalize-space(.) = $abbr] |
							following-sibling::abbr[f:normalize-space(.) = $abbr]
							]"
							group-by="f:normalize-space(.)">
							<expan>
								<xsl:value-of select="current-grouping-key()"/>
							</expan>
						</xsl:for-each-group>
					</xsl:variable>
					
					<xsl:choose>
						<xsl:when test="$existing-expansion">
							<xsl:copy-of select="$existing-expansion" copy-namespaces="no"/>
						</xsl:when>
						<xsl:when test="$expansions//expan">
							<xsl:comment>Expansions from the text, should be exactly one:</xsl:comment>							
							<xsl:copy-of select="$expansions" copy-namespaces="no"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:comment>TODO</xsl:comment>
							<expan>
								<xsl:value-of select="$abbr"/>
							</expan>
						</xsl:otherwise>
					</xsl:choose>
				</choice>
			</xsl:for-each-group>
			
			<xsl:comment>additional expansions from the old expan-map.xml:</xsl:comment>
			
			<xsl:copy-of select="$known-expansions//abbr[not(data(.) = current()//abbr)]/.." copy-namespaces="no"/>
		</f:expan-map>
	</xsl:template>
</xsl:stylesheet>