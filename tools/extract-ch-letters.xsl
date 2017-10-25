<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://collections.chadwyck.co.uk/ns"
	xpath-default-namespace="http://collections.chadwyck.co.uk/ns"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs tei"
	version="2.0">
	
	<!-- Errät die URL des Zeno-Files zum aktuellen CH-File -->
	<xsl:function name="tei:guess-url">
		<xsl:param name="ch-url"/>
		<xsl:variable name="resolved" select="resolve-uri($ch-url)"/>
		<xsl:variable name="number" select="replace($resolved, '^.*/0*([0-9]*)\.xml$', '$1')"/>
		<xsl:variable name="relative" select="concat('../../../testimony/wa_IV/wa_IV_', $number, '.xml')"/>
		<xsl:value-of select="resolve-uri($relative, $resolved)"/>
	</xsl:function>
	
	<!-- Dateipfad zur xml/testimony/letters/*.xml. Wenn nicht angegeben: Raten ... -->
	<xsl:param name="teiurl" select="tei:guess-url(document-uri(/))"/>
	
	<!-- hier geht's los: -->
	<xsl:template match="/">
		<xsl:if test="not(doc-available($teiurl))">
			<xsl:message select="concat('TEI file ', $teiurl, ' for ', document-uri(/), ' is missing. Use teiurl=...')" terminate="yes"/>
		</xsl:if>
		
		<!-- die beiden Dokumente merken ... -->
		<xsl:variable name="tei" select="document($teiurl)"/>
		<xsl:variable name="ch" select="."/>
		
		<ROOT> <!-- wie in den ch-dateien -->
			<xsl:for-each select="$tei//tei:num[@type='wa-letter']"> <!-- für jede Briefnummer aus Zeno in der Reihenfolge von dort: -->
				<xsl:variable name="letterno" select="number(.)"/>   <!-- Zahl draus, falls führende 0 etc. -->
				<xsl:for-each select="$ch//LETTER[number(@N) = $letterno]">  <!-- Passenden CH-Brief suchen und ... -->
					<xsl:message select="concat('Brief ', $letterno)"/>					
					<xsl:apply-templates select="."/>	<!-- ... behandeln wie im Rest des  Stylesheets angegeben -->
					<xsl:text>&#10;</xsl:text> <!-- Zeilenumbruch -->
				</xsl:for-each>
			</xsl:for-each>			
		</ROOT>
	</xsl:template>
		
	<!-- Identitätstransformation: Alles aus CH beibehalten, was nicht extra behandelt wird -->
	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="@*, node()"/>
		</xsl:copy>
	</xsl:template>
	
	
</xsl:stylesheet>