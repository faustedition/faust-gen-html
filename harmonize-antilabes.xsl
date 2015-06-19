<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"    
	xmlns:f="http://www.faustedition.net/ns" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs f" version="2.0" xmlns:ge="http://www.tei-c.org/ns/geneticEditions">

	<!-- 
    Antilaben sind in den Handschriften nicht durch @part='I', 'M', 'F' gekennzeichnet, sondern es existiert ein 
    <join type="@antilabe" target=…>, das die jeweiligen Zeilen in der richtigen Reihenfolge referenziert.
    Die @ns stimmen allerdings schon. Wir setzen part='I', 'M', 'F' um die Antilabenerkennung später zu triggern.
  -->  
	<xsl:key name="antilabe" match="join[@type='antilabe']" use="for $ref in tokenize(@target, '\s+') return substring($ref, 2)"/>  
	<xsl:template match="*[@xml:id and key('antilabe', @xml:id)]">
		<xsl:variable name="join" select="key('antilabe', @xml:id)"/>
		<xsl:variable name="ids" select="for $ref in tokenize(string-join($join/@target, ' '), '\s+') return substring($ref, 2)"/>
		<xsl:variable name="pos" select="index-of($ids, string(@xml:id))"/>
		<xsl:variable name="part">
			<xsl:choose>
				<xsl:when test="$pos = 1">I</xsl:when>
				<xsl:when test="$pos = count($ids)">F</xsl:when>
				<xsl:otherwise>M</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:copy>
			<xsl:apply-templates select="@* except @part"/> <!-- just in case -->
			<xsl:attribute name="part" select="$part"/>
			<xsl:if test="@part">
				<xsl:variable name="warning" select="concat('WARNING: Replaced @part attribte ', @part, ' with ', $part, ' on element ', @xml:id, ' (', normalize-space(.), ')')"/>
				<xsl:message select="$warning"/>
				<xsl:comment select="$warning"/>
			</xsl:if>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	

</xsl:stylesheet>