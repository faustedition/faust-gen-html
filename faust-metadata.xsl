<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.faustedition.net/ns"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xs f"
	version="2.0">
	
	<xsl:include href="html-frame.xsl"/>
	
	<xsl:param name="standalone"/>
	<xsl:param name="source">file:/home/tv/Faust/</xsl:param>	
	
	
	<xsl:variable name="labels" xmlns="http://www.faustedition.net/ns">
		<elem name="headNote">Umfang – Inhalt</elem>
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
		
		
		<!-- Die folgenden Begriffe hat sich der ahnungslose Thorsten ausgedacht: -->
		<elem name="page">Seite(?)</elem>
		<elem name="leaf">Blatt(?)</elem>
		<elem name="disjunctLeaf">separates Blatt(?)</elem>
		<elem name="sheet">Bogen(?)</elem>
	</xsl:variable>
	
	
	
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
	
	<xsl:template match="dimensions">
		<xsl:call-template name="element">
			<xsl:with-param name="content">
				Breite: <xsl:value-of select="width"/> mm × Höhe: <xsl:value-of select="height"/> mm
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:variable name="edges">
		<elem name="cut">beschnitten</elem>
		<elem name="uncut">unbeschnitten</elem>
	</xsl:variable>
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
	
	<xsl:variable name="repositories" select="document(resolve-uri('archives.xml', $source))"/>
	<xsl:template match="repository">
		<xsl:variable name="id" select="."/>
		<xsl:call-template name="element">
			<xsl:with-param name="content">
				<a href="{$edition}/archiveDetail.php?archiveId={$id}">
					<xsl:value-of select="$repositories//archive[@id=$id]/displayName"/>
				</a>				
			</xsl:with-param>
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
	<xsl:template match="*[f:isEmpty(.)]"/>
	
	<xsl:function name="f:isEmpty" as="xs:boolean">
		<xsl:param name="element"/>		
		<xsl:value-of select="$element = 'none' or $element = '' or $element = 'n.s.'"/>
	</xsl:function>

	<xsl:template match="textTranscript"/>	
	<xsl:template match="docTranscript"/>	
	
	<!-- Bibliographische Verweise. Stehen z.T. einfach als URIs im Text in den anderen Feldern. -->	
	<xsl:variable name="bibliography" select="document('bibliography.xml')"/>

	<!-- 
		Liefert <cite>-Element mit Zitation.
		
		- uri: faust://bibliography-URI
		- full: wenn true() dann volle Referenz, sonst nur Autor/Jahr
	-->
	<xsl:function name="f:cite" as="element()">
		<xsl:param name="uri" as="xs:string"/>
		<xsl:param name="full" as="xs:boolean"/>
		<xsl:variable name="bib" select="$bibliography//bib[@uri=$uri]"/>
		<xsl:choose>
			<xsl:when test="$bib and $full">
				<cite class="bib-full" data-uri="{$uri}" data-citation="$bib/citation">
					<xsl:copy-of select="$bib/reference/node()"/>
				</cite>
			</xsl:when>
			<xsl:when test="$bib">
				<cite class="bib-short" title="{$bib/reference}" data-uri="{$uri}"><xsl:value-of select="$bib/citation"/></cite>
			</xsl:when>
			<xsl:otherwise>
				<cite class="bib-notfound"><xsl:value-of select="$uri"/></cite>
				<xsl:message select="concat('WARNING: Citation not found: ', $uri)"/>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:function>
		
	<xsl:template match="text()">
		<xsl:analyze-string select="." regex="faust://bibliography/[a-zA-Z0-9/_-]+">
			<xsl:matching-substring>
				<xsl:copy-of select="f:cite(., false())"/>
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:value-of select="."/>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	
	<xsl:template match="references">
		<xsl:call-template name="element">
			<xsl:with-param name="content">
				<dl class="bib-list">
					<xsl:apply-templates/>
				</dl>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:variable name="reference-types">
		<elem name="description">Beschreibung</elem>
		<elem name="text">Text</elem>
		<elem name="facsimile">Faksimile</elem>
		<elem name="essay">Aufsatz</elem>
	</xsl:variable>
	<xsl:template match="reference">
		<dt><xsl:value-of select="f:lookup($reference-types, @type, 'reference-types')"/></dt>
		<dd>
			<xsl:copy-of select="f:cite(@uri, true())"/>
			<xsl:text> </xsl:text>
			<xsl:apply-templates/>
		</dd>
	</xsl:template>	
	
	
	<xsl:template match="metadata">
		<dl>
			<xsl:apply-templates/>
		</dl>
	</xsl:template>
	
	<xsl:template match="revisionDesc"/>
	
	<xsl:template match="page[metadata[* except docTranscript]]">
		<xsl:variable name="pageno">
			<xsl:number count="page"/>
		</xsl:variable>
		<div class="md-page">
			<h3>Seite <xsl:value-of select="$pageno"/></h3>
			<xsl:apply-templates/>
		</div>
	</xsl:template>
	
	<!-- 
	
	Wir erzeugen Abschnitte für strukturelle Elemente, aber nur wenn irgendwo darunter ein nicht-leeres Metadatenfeld ist.
	
	-->
	<xsl:template match="sheet|leaf|disjunctLeaf|page[descendant::metadata[* except (docTranscript | *[f:isEmpty(.)])]]" priority="1">
		<div class="md-{local-name()} md-level">
			<h3>
				<xsl:number format="1."/>
				<xsl:text> </xsl:text>
				<xsl:value-of select="f:lookup($labels, local-name(), 'elements')"/>
			</h3>
			<xsl:apply-templates/>
		</div>
	</xsl:template>
	<xsl:template match="sheet|leaf|disjunctLeaf|page">
		<xsl:comment>
			<xsl:number format="1."/>
			<xsl:text> </xsl:text>
			<xsl:value-of select="f:lookup($labels, local-name(), 'elements')"/>			
		</xsl:comment>
	</xsl:template>
	
	
	
	<!-- 
		Nachschlagen eines Labels für die Endnutzer. Parameter:
		
		- labels: Variable, in der nachgeschlagen wird, siehe z.B. $elements oben
		- key: Schlüssel, nach dem gesucht wird (= @name), z.B. Elementname
		- type: Beschreibung für die Fehlermeldung, falls nix gefunden
		
		Gibt entweder den Wert von $labels//*[@name=$key] zurück oder $key selbst + Warn-Message
	-->
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
				<xsl:message select="concat('WARNING: Did not find &quot;', $key, '&quot; in ', $type)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	
	<!-- 
		Grundstruktur "normales" Element. Also Name: Inhalt. Parameter, alle optional:
		
		- content 	 Inhalt des Felds in der Darstellung
		- label      Bezeichnung des Felds
		- extralabel zusätzliche Bezeichnung, ergänzung zu $label		
	-->
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
	
	<xsl:template match="metadataImport"/>
	
	<!-- Sofern kein besonderes Feld: -->
	<xsl:template match="*">
		<xsl:call-template name="element"/>
	</xsl:template>
	
		
	<xsl:template match="/*">
		<xsl:choose>
			<xsl:when test="$standalone">
				<html>
					<xsl:call-template name="html-head"/>
					<body>					
						<xsl:call-template name="header"/>
						<main>
							<div class="pure-g-r center">				
								<div class="metadata pure-u-1">
									<xsl:apply-templates/>
								</div>
							</div>
						</main>
						<xsl:call-template name="footer"/>
					</body>				
				</html>
			</xsl:when>
			<xsl:otherwise>
				<div id="metadataContainer" class="metadata-container">
					<xsl:apply-templates/>
				</div>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>