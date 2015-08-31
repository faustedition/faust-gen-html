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
		<elem name="dimensions">Maße</elem>
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
		<elem name="references">Bibliographische Nachweise</elem>
		<elem name="patchReferences">Bibliographische Nachweise (Zettel)</elem>
		
		
		<!-- Die folgenden Begriffe hat sich der ahnungslose Thorsten ausgedacht: -->
		<elem name="page">Seite</elem>
		<elem name="leaf">Blatt</elem>
		<elem name="disjunctLeaf">Zettel</elem>
		<elem name="sheet">Doppelblatt</elem>
	</xsl:variable>
	
	
	
	<!-- <elem name="numbering">1., 2. usw. wäre das möglich, die einfach so durchzunummerieren? </elem> 
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
	-->
	<xsl:template match="numbering"/>
	
	<xsl:template match="dimensions">
		<xsl:call-template name="element">
			<xsl:with-param name="content">
				<xsl:value-of select="width"/> mm × <xsl:value-of select="height"/> mm
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
		
	
	
	<xsl:variable name="sigils" select="document('sigil-labels.xml')"/>
	<xsl:template match="idno">
		<xsl:call-template name="element">
			<xsl:with-param name="label">
				<xsl:variable name="sigil" select="$sigils//label[@type=current()/@type]"/>
				<xsl:choose>
					<xsl:when test="$sigil/@kind = 'signature'">Signatur</xsl:when>
					<xsl:when test="$sigil">Sigle <xsl:value-of select="$sigil"/></xsl:when>
					<xsl:otherwise>
						Sigle <xsl:value-of select="@type"/>
						<xsl:message select="concat('WARNING: idno label &quot;', @type, '&quot; not found.')"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:with-param>
			<xsl:with-param name="content">
				<xsl:apply-templates/>
				<xsl:if test="following-sibling::*[1][self::note]">
					<p class="md-idno-note">
						<xsl:apply-templates/>
					</p>
				</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="idno[@type='gsa_1'][//repository != 'gsa']"/>
	<xsl:template match="*[f:isEmpty(.)]"/>
	
	<xsl:template match="note[preceding-sibling::*[1][self::idno]]"/>
	
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
			<xsl:copy-of select="f:cite(@uri, false())"/>
			<xsl:text> </xsl:text>
			<xsl:apply-templates/>
		</dd>
	</xsl:template>	
	
	
	<xsl:template match="metadata">
		<dl>
			<xsl:apply-templates/>
		</dl>
	</xsl:template>
	<xsl:template match="/*/metadata">
		<h2><xsl:value-of select="idno[@type=('faustedition', 'wa_faust')][1]"/></h2>
		<h3 class="md-headNote">
			<xsl:value-of select="headNote"/>
		</h3>
		<p class="md-note wip">
			<xsl:value-of select="headNote/following-sibling::note[1]"/>
		</p>
		<dl>
			<xsl:apply-templates select="* 
				except (idno[@type=('faustedition', 'wa_faust')][1] | headNote | headNote/following-sibling::note[1])"/>
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
	
	<!-- Alle sheets kriegen eine Überschrift -->
	<xsl:template match="sheet">
		<div class="md-{local-name()} md-level">
			<h3><xsl:value-of select="f:lookup($labels, local-name(), 'elements')"/></h3>
			<xsl:apply-templates/>
		</div>
	</xsl:template>
	
	<xsl:template match="leaf|disjunctLeaf|page" priority="1">
		<xsl:variable name="label"
			select="if (self::disjunctLeaf[not(@format=('none', 'n.s.'))])
					then 'Einzelblatt' else f:lookup($labels, local-name(), 'elements')"/>
		<xsl:variable name="number">							
			<xsl:choose>
				<xsl:when test="self::page">
					<xsl:number format="1" level="any"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:number format="1" level="any" count="leaf|disjunctLeaf"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="heading" select="concat($label, ' ', $number)"/>
		<xsl:variable name="content">
			<xsl:apply-templates/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="normalize-space(string($content)) != ''">				
				<div class="md-{local-name()} md-level" id="md-{local-name()}-{$number}">
					<h3>
						<xsl:value-of select="$heading"/>
					</h3>
					<xsl:copy-of select="$content"/>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<xsl:comment>
					<xsl:value-of select="$heading"/>
				</xsl:comment>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="leaf|disjunctLeaf|page"/>
	
	
	
	<!-- ##################################################################################################### -->
	
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