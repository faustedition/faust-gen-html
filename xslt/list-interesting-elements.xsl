<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.tei-c.org/ns/1.0"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns:ge="http://www.tei-c.org/ns/geneticEditions" 
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs"
	version="2.0">

	<xsl:import href="utils.xsl"/>
	
	<xsl:template match="/">
		<TEI xmlns="http://www.tei-c.org/ns/1.0">
			<teiHeader>
				<fileDesc>
					<titleStmt>
						<title>Elemente im Kontext aus #178</title>
					</titleStmt>
					<publicationStmt>
						<p>internal use</p>
					</publicationStmt>
					<sourceDesc>
						<p><xsl:copy-of select="//idno"/></p>
					</sourceDesc>
				</fileDesc>
			</teiHeader>
			<text>
				<body>
					<xsl:for-each-group select="
						  //sic
						| //damage
						| //surplus
						| //unclear
						| //supplied
						| //orig[matches(., '^[aou]$')]
						| //*[matches(@ge:stage,'#posthumous')]
						"
						group-by="local-name()">
						<div>
							<head><xsl:copy-of select="current-grouping-key()"></xsl:copy-of></head>
							<xsl:for-each select="current-group()">
								<xsl:copy-of select="ancestor-or-self::*[f:hasvars(.)]"></xsl:copy-of>
							</xsl:for-each>
						</div>
					</xsl:for-each-group>
				</body>
			</text>
		</TEI>
		
	</xsl:template>
	
	
	
</xsl:stylesheet>