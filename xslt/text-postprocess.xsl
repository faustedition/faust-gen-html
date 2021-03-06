<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns="http://www.tei-c.org/ns/1.0"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs f"
	version="2.0">

	<!--

		This stylesheet is applied to the almost finished reading text, after
		the apparatus has been applied. Thus, it contains cleanup steps that
		need to work on the apparatus.

	-->
	
	<xsl:import href="utils.xsl"/>

	<xsl:strip-space elements="TEI teiHeader fileDesc titleStmt publicationStmt sourceDesc choice app"/>


	<!-- 
		
		Annotate divs with scene labels
		
		TODO this needs to be factored-in with the code that does the f:scene-label
		and f:act-label stuff in add-metadata.xsl
	
	-->
	<xsl:variable name="ordinals" as="xs:string*" select="('Erster', 'Zweiter', 'Dritter', 'Vierter', 'Fünfter')"/>	
	<xsl:template match="div">
		<xsl:variable name="scene" select="f:get-scene-info(.)"/>
		<xsl:copy>
			<xsl:choose>
				<xsl:when test="local-name($scene) = 'act'">
					<xsl:variable name="act" select="number(tokenize($scene/@n, '\.')[2])"/>					
					<xsl:attribute name="f:label">
						<!--<xsl:number lang="de" value="$act" format="Ww" ordinal="-er"/> doesn't work??? -->
						<xsl:value-of select="concat(subsequence($ordinals, $act, 1), ' Akt')"/>
					</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:if test="not(@n)">
						<xsl:attribute name="n" select="$scene/@n"/>						
					</xsl:if>
					<xsl:attribute name="f:label">	
						<xsl:value-of select="$scene/f:title"/>
					</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:apply-templates select="@*, node()"/>			
		</xsl:copy>
	</xsl:template>
	
	<xsl:function name="f:split-string" as="xs:string*">
		<xsl:param name="string"></xsl:param>
		<xsl:sequence select="for $cp in string-to-codepoints($string) return codepoints-to-string($cp)"/>
	</xsl:function>

	<xsl:template match="g[matches(., '^\.{2,4}$')]">
		<xsl:if test="not(matches(preceding-sibling::node()[1], '\s$'))">
			<xsl:text> </xsl:text>
		</xsl:if>
		<xsl:copy>
			<xsl:apply-templates select="@*" mode="#current"/>
			<xsl:value-of select="string-join(f:split-string(.), '&#x2009;')"/>
		</xsl:copy>
	</xsl:template>
	
	
	<xsl:template match="/TEI">
		<xsl:copy>
			<xsl:namespace name="f">http://www.faustedition.net/ns</xsl:namespace>
			<xsl:apply-templates select="@*, node()"/>
		</xsl:copy>
	</xsl:template>

	<!-- Keep everything else as is -->
	<xsl:template match="node()|@*" mode="#all">
		<xsl:copy copy-namespaces="no">
			<xsl:apply-templates select="@*, node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>
