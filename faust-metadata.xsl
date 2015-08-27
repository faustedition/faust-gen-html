<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.faustedition.net/ns"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xs"
	version="2.0">
	
	
	<xsl:variable name="labels" xmlns="http://www.faustedition.net/ns">
		<elem name="headNote">Umfang – Inhalt</elem>
		<elem name="note">Anmerkung</elem>
		<elem name="repository">Aufbewahrungsort</elem>
		<elem name="subRepository">Abteilung</elem>
		<elem name="collection">Sammlung</elem>
		<elem name="idno">Sigle</elem>
		<elem name="subidno">Teilsigle</elem>
		<!-- "textTranscript"": "entfällt als Angabe, wird direkt in Konvolutstruktur übersetzt und als Bild angezeigt -->
		<elem name="classification">Handschriftentyp</elem>
		<elem name="history">Überlieferung</elem>
		<elem name="container">Aufbewahrungsform</elem>
		<elem name="binding">Einband</elem>
		<elem name="numberingList">Foliierung/Paginierung</elem>
		<elem name="condition">Erhaltungszustand</elem>
		<elem name="dimensions">Blattmaße</elem>
		<elem name="width">Breite in mm</elem>
		<elem name="height">Höhe in mm </elem>
		<elem name="format">Format</elem>
		<elem name="bindingMaterial">Bindematerial</elem>
		<elem name="stabMarks">Stichlöcher</elem>
		<elem name="stabMark">Stichloch in mm </elem>
		<elem name="leafCondition">Erhaltungszustand des Blatts</elem>
		<elem name="edges">Ränder</elem>
		<elem name="paperType">Papiersorte</elem>
		<elem name="paperColour">Papierfarbe</elem>
		<elem name="chainLines">Steglinienabstand in mm</elem>
		<elem name="paperMill">Papiermühle</elem>
		<elem name="watermarkID">Wasserzeichen-Kürzel</elem>
		<elem name="countermarkID">Gegenzeichen-Kürzel</elem>
		<!--     "references /> / <reference": "Bibliographischer Nachweis" -->
		<elem name="patchDimensions">Zettelmaße</elem>
		<elem name="patchType">Art der Anbringung</elem>
		<!--     "patchType>glue</patchType> - geklebt" -->
		<!--     "patchType>pin</patchType> - geheftet" -->
		<!--     "patchType>lose</patchType> - lose " -->
		<elem name="patchPaperType">Papiersorte (Zettel)</elem>
		<elem name="patchPaperColour">Papierfarbe (Zettel)</elem>
		<elem name="patchChainLines">Steglinienabstand in mm (Zettel)</elem>
		<elem name="patchPaperMill">Papiermühle (Zettel)</elem>
		<elem name="patchWatermarkID">Wasserzeichen-Kürzel (Zettel)</elem>
		<elem name="patchCountermarkID">Gegenzeichen-Kürzel (Zettel)</elem>
		<elem name="references">Bibliographischer Nachweis</elem>
		<elem name="patchReferences">Bibliographischer Nachweis (Zettel)</elem>
	</xsl:variable>
	
	<xsl:variable name="edges">
		<elem name="cut">beschnitten</elem>
		<elem name="uncut">unbeschnitten</elem>
	</xsl:variable>
	
	<xsl:function name="f:lookup" as="node()*">
		<xsl:param name="labels"/>
		<xsl:param name="key"/>
		<xsl:param name="type"/>
		<xsl:variable name="label" select="$labels//*[@name=$key]"/>
		<xsl:choose>
			<xsl:when test="$label">
				<xsl:sequence select="$label/node()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$key"/>
				<xsl:message select="concat('WARNING: Did not find ', $key, ' in ', $type, ' labels')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	
	<!-- Grundstruktur "normales" Element. Also Name: Inhalt -->
	<xsl:template name="element">
		<xsl:param name="content">
			<xsl:apply-templates/>
		</xsl:param>
		<xsl:param name="extralabel"/>
		<xsl:param name="label" select="f:lookup($labels, local-name(), 'elements')"/>
		<dt class="md-{local-name()}">
			<xsl:copy-of select="$label"/>
			<xsl:value-of select="$extralabel"/>
		</dt>
		<dd class="md-{local-name()}">
			<xsl:sequence select="$content"/>
		</dd>
	</xsl:template>
	
	<!-- Sofern kein besonderes Feld: -->
	<xsl:template match="*">
		<xsl:call-template name="element"/>
	</xsl:template>
	
	<!-- <elem name="numbering">1., 2. usw. wäre das möglich, die einfach so durchzunummerieren? </elem> -->
	<xsl:template match="numberingList">
		<xsl:call-template name="element">
			<xsl:with-param name="content">
				<ol>
					<xsl:apply-templates/>
				</ol>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="numbering">
		<li><xsl:apply-templates/></li>
	</xsl:template>
	
	<!--     "edges>cut</edges> - beschnitten" -->
	<!--     "edges>uncut</edges> - unbeschnitten " -->
	<xsl:template match="edges">
		<xsl:call-template name="element">
			<xsl:with-param name="content" select="f:lookup($edges, ., 'edges')"/>
		</xsl:call-template>
	</xsl:template>
	
	
	
	<xsl:variable name="patchType">
		<elem name="glue">geklebt</elem>
		<elem name="pin">geheftet</elem>
		<elem name="lose">lose</elem>
	</xsl:variable>
	<xsl:template match="patchType">
		<xsl:call-template name="element">
			<xsl:with-param name="content" select="f:lookup($patchType, ., 'patchType')"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:variable name="idnos">
		<xsl:for-each select="document('sigil-labels.xml')//label">
			<elem name="{@type}"><xsl:value-of select="."/></elem>
		</xsl:for-each>
	</xsl:variable>
	<xsl:template match="idno">
		<xsl:call-template name="element">
			<xsl:with-param name="extralabel" select="concat(' (', f:lookup($idnos, @type, 'idnos'), ')')"/>		
		</xsl:call-template>
	</xsl:template>
	
	
	
	<!-- Grundstruktur der Seite. Fliegt raus für produktiv -->
	<xsl:template match="/*">
		<html>
			<head>
				<title>Metadaten</title>
			</head>
		</html>
		<body>
			<dl>
				<xsl:apply-templates select="metadata"></xsl:apply-templates>
			</dl>
		</body>
	</xsl:template>
	
</xsl:stylesheet>