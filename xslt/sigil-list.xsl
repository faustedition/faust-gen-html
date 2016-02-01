<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:f="http://www.faustedition.net/ns"
	xpath-default-namespace="http://www.faustedition.net/ns"
	exclude-result-prefixes="xs"
	version="2.0">
	
	<xsl:output method="html"/>
	
	<xsl:template match="/">
		<html>
			<head>
				<title>Siglen</title>
				<style>
					th { border-bottom: 1pt solid black; }
					tr:nth-child(even) { background: #eee; }
					tr:hover { background: #ffc; }
					tr { vertical-align: top; }
					tr ul { list-style-type: none; }
					.duplicate { background: #f88; }
				</style>
			</head>
			<body>
				
				<h2>Präferierter Siglentyp</h2>
				<table>
					<thead>
						<tr>
							<th>Siglentyp</th>
							<th>Anzahl Vorkommen</th>
						</tr>
					</thead>
					<tbody>
						<xsl:for-each-group select="//textTranscript" group-by="idno[1]/@type">
							<xsl:sort select="count(current-group())" order="descending"/>
							<tr>						
								<td><xsl:value-of select="current-grouping-key()"/></td>
								<td><xsl:value-of select="count(current-group())"/></td>
							</tr>					
						</xsl:for-each-group>						
					</tbody>
				</table>
				
				
				<h2>Liste der Handschriften/Drucke mit Siglen</h2>
				
				<table>
					<thead>
						<tr>
							<th>Präferierte Sigle</th>
							<th>Präf. Siglentyp</th>
							<th>weitere Siglen</th>
						</tr>
					</thead>
					<tbody>
						<xsl:apply-templates select="//textTranscript">
							<xsl:sort select="@f:sigil"/>
						</xsl:apply-templates>
					</tbody>
				</table>
				
				
			</body>			
		</html>
	</xsl:template>
	
	<xsl:template match="textTranscript">
		<xsl:variable name="pref_dup" select="f:duplicates(idno[1])"/>
		<tr>
			<td class="{if ($pref_dup) then 'duplicate' else ''}"><a href="{
				if (@type = 'archivalDocument')
				then concat('http://beta.faustedition.net/documentViewer?view=structure&amp;faustUri=faust://xml/', @document)
				else replace(@uri, '^.*/(.*)\.xml$', 'http://beta.faustedition.net/print/$1.html')
				}"><xsl:value-of select="idno[1]"/></a></td>
			<td><xsl:value-of select="idno[1]/@type"/></td>
			<td>
				<ul class="sigils">
					<xsl:apply-templates select="idno except idno[1]"/>
				</ul>
			</td>
		</tr>
	</xsl:template>
	
	<xsl:function name="f:duplicates" as="item()*">
		<xsl:param name="idno"/>
		<xsl:sequence select="root($idno)//idno[@type = $idno/@type][normalize-space(.) = normalize-space($idno)] except $idno"/>
	</xsl:function>
	
	<xsl:template match="idno">
		<xsl:variable name="duplicate" select="f:duplicates(.)"/>
		<li class="{if ($duplicate) then 'duplicate' else ''}">
			<xsl:value-of select="."/> (<xsl:value-of select="@type"/>)
		</li>
	</xsl:template>
	
</xsl:stylesheet>