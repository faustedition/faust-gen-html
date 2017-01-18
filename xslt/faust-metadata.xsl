<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.faustedition.net/ns"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xs f"
	version="2.0">
	
	<xsl:include href="html-frame.xsl"/>
	
	<xsl:param name="standalone" select="/print"/>
	<xsl:param name="source">file:/home/tv/Faust/</xsl:param>
	<xsl:param name="builddir">../target</xsl:param>
	<xsl:param name="builddir-resolved" select="$builddir"/>	
	<xsl:param name="transcript-list" select="resolve-uri('faust-transcripts.xml', resolve-uri($builddir-resolved))"/>
	<xsl:param name="docbase">http://beta.faustedition.net/documentViewer?faustUri=faust://xml</xsl:param>
	<xsl:param name="idmap" select="document($transcript-list)"/>
		
	
	
	<xsl:variable name="labels" xmlns="http://www.faustedition.net/ns">
		<elem name="headNote">Umfang – Inhalt</elem>
		<elem name="note">Anmerkung</elem>
		<elem name="repository">Aufbewahrungsort</elem>
		<elem name="subRepository">Abteilung</elem>
		<elem name="collection">Sammlung</elem>
		<elem name="idno">Sigle</elem>
		<elem name="subidno">Teilsigle</elem>
		<elem name="classification">Klassifikation</elem>
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
		<elem name="watermarkID">Wasserzeichen</elem>
		<elem name="countermarkID">Gegenzeichen</elem>
		<!--     "references /> / <reference": "Bibliographischer Nachweis" -->
		<elem name="patchDimensions">Maße</elem>
		<elem name="patchType">Art der Anbringung</elem>
		<!--     "patchType>glue</patchType> - geklebt" -->
		<!--     "patchType>pin</patchType> - geheftet" -->
		<!--     "patchType>lose</patchType> - lose " -->
		<elem name="patchPaperType">Papiersorte (Zettel)</elem>
		<elem name="patchPaperColour">Papierfarbe (Zettel)</elem>
		<elem name="patchChainLines">Steglinienabstand in mm (Zettel)</elem>
		<elem name="patchPaperMill">Papiermühle (Zettel)</elem>
		<elem name="patchWatermarkID">Wasserzeichen (Zettel)</elem>
		<elem name="patchCountermarkID">Gegenzeichen (Zettel)</elem>
		<elem name="references">Bibliographische Nachweise</elem>
		<elem name="patchReferences">Bibliographische Nachweise (Zettel)</elem>
		<elem name="page">Seite</elem>
		<elem name="leaf">Blatt</elem>
		<elem name="disjunctLeaf">Einzelblatt</elem>
		<elem name="sheet">Doppelblatt</elem>
		<elem name="copies">Exemplare</elem>
		<elem name="furtherCopy">Weiteres herangezogenes Exemplar</elem>
		<elem name="loose">lose</elem>
		<elem name="patch">Aufklebung</elem>
		<elem name="referenceCopy">Digitalisiertes Exemplar</elem>
		<elem name="bibl">Titelaufnahme</elem>
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
	
	<xsl:template match="dimensions|patchDimensions">
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
		<elem name="loose">lose</elem>
	</xsl:variable>
	<xsl:template match="patchType">
		<xsl:call-template name="element">
			<xsl:with-param name="content" select="f:lookup($patchType, ., 'patchType')"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="patchSurface">
		<xsl:comment>Skipping patchSurface</xsl:comment>
	</xsl:template>
	
	<xsl:variable name="repositories" select="document(resolve-uri('archives.xml', $source))"/>
	<xsl:template match="repository">
		<xsl:variable name="id" select="."/>
		<xsl:call-template name="element">
			<xsl:with-param name="content">
				<a href="{$edition}/archive_locations_detail?id={$id}">
					<xsl:value-of select="$repositories//archive[@id=$id]/displayName"/>
				</a>				
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
		
	<xsl:variable name="format">
		<elem name="2">Folio</elem>
		<elem name="4">Quart</elem>
		<elem name="8">Oktav</elem>
		<elem name="12">Duodez</elem>
		<elem name="16">Sedez</elem>
		<elem name="none">—</elem>
		<elem name="n.s.">—</elem>		
	</xsl:variable>
	<xsl:template match="format">
		<xsl:call-template name="element">
			<xsl:with-param name="content" select="f:lookup($format, ., 'format')"></xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:variable name="sigils" select="document('sigil-labels.xml')"/>
	<xsl:template match="idno">
		<xsl:call-template name="element">
			<xsl:with-param name="label">
				<xsl:variable name="sigil" select="$sigils//label[@type=current()/@type]"/>
				<xsl:choose>
					<xsl:when test="$sigil/@kind = 'signature'">Signatur</xsl:when>
					<xsl:when test="@type='hagen_nr'"><xsl:value-of select="$sigil"/></xsl:when>
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
						<xsl:apply-templates select="following-sibling::*[1][self::note]"/>
					</p>
				</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="idno[@type='gsa_2'][//repository='gsa']" priority="1">
		<xsl:call-template name="element">
			<xsl:with-param name="label">Signatur</xsl:with-param>
			<xsl:with-param name="content">
				<xsl:choose>
					<xsl:when test="following::idno[1][@type='gsa_ident']">
						<a href="http://ora-web.swkk.de/archiv_online/gsa.entry?source=gsa.vollanzeige&amp;p_id={following::idno[1][@type='gsa_ident']}">
							<xsl:value-of select="."/>
						</a>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="."/>						
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="../idno[@type='gsa_1']">
					<span class="md-sigil-gsa_1">  (alt: <xsl:value-of select="../idno[@type='gsa_1']"/>)</span>
				</xsl:if>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<xsl:template match="idno[@type='gsa_1']"/>
	<xsl:template match="idno[@type='gsa_ident']"/>
	<xsl:template match="idno[@type='kraeuter']"/>
	<xsl:template match="*[f:isEmpty(.)][not(self::format)]"/>
	
	<xsl:template match="note[preceding-sibling::*[1][self::idno]]">
		<xsl:comment>
			Not displaying note: <xsl:value-of select="."/>
		</xsl:comment>
	</xsl:template>
	
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
		<xsl:param name="full" as="item()"/>
		<xsl:variable name="bib" select="$bibliography//bib[@uri=$uri]"/>
		<xsl:variable name="id" select="replace($uri, 'faust://bibliography/', '')"/>
		<xsl:variable name="parsed-ref">
			<xsl:for-each select="$bib/reference/node()">
				<xsl:call-template name="parse-for-bib"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="$bib and $full">
				<xsl:element name="{$full}">
					<xsl:attribute name="class">bib-full</xsl:attribute>
					<xsl:attribute name="data-bib-uri" select="$uri"/>
					<xsl:attribute name="data-citation" select="$bib/citation"/>					
					<xsl:sequence select="$parsed-ref"/>
				</xsl:element>
			</xsl:when>
			<xsl:when test="$bib">
				<cite class="bib-short" title="{$parsed-ref}" data-bib-uri="{string-join(($uri, $parsed-ref//*/@data-bib-uri), ' ')}">
					<a href="{$edition}/bibliography#{$id}"><xsl:value-of select="$bib/citation"/></a>
				</cite>
			</xsl:when>
			<xsl:otherwise>
				<cite class="bib-notfound"><xsl:value-of select="$uri"/></cite>
				<xsl:message select="concat('WARNING: Citation not found: ', $uri)"/>
			</xsl:otherwise>
		</xsl:choose>		
	</xsl:function>
	
	<xsl:function name="f:resolve-faust-doc">
		<xsl:param name="uri"/>
		<xsl:param name="transcript-list"/>
		<!-- Function doesn't resolve document parameters :-(, so let's pass this in -->		
		<xsl:for-each select="document($transcript-list)//idno[@uri=$uri]/..">
			<xsl:variable name="docinfo" select="."/>
			<xsl:choose>
				<xsl:when test="$docinfo/@type='print'">
					<a class="md-document-ref" href="../meta/{replace($docinfo/@document, '.*/(.*?)\.xml', '$1')}" title="{$docinfo/headNote}">
						<xsl:value-of select="$docinfo/@f:sigil"/>
					</a>				
				</xsl:when>
				<xsl:otherwise>
					<a class="md-document-ref" href="{$docbase}/{$docinfo/@document}" title="{$docinfo/headNote}">
						<xsl:value-of select="$docinfo/@f:sigil"/>
					</a>								
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each>		
	</xsl:function>		
		
	<xsl:template match="text()" name="parse-for-bib">
		<xsl:analyze-string select="." regex="faust://[a-zA-Z0-9/_.-]*[a-zA-Z0-9/_-]+">
			<xsl:matching-substring>
				<xsl:variable name="uri" select="."/>
				<xsl:choose>
					<xsl:when test="starts-with($uri, 'faust://bibliography')">
						<xsl:copy-of select="f:cite($uri, false())"/>						
					</xsl:when>
					<xsl:when test="$idmap//idno[@uri=$uri]">
						<xsl:sequence select="f:resolve-faust-doc($uri, $transcript-list)"/>
					</xsl:when>
					<xsl:when test="$idmap//idno[@uri=replace($uri, '^faust://', 'faust://xml/')]">
						<xsl:sequence select="f:resolve-faust-doc(replace($uri, '^faust://', 'faust://xml/'), $transcript-list)"/>
					</xsl:when>
					<xsl:when test="$idmap//idno[@uri=replace($uri, '^faust://print/', 'faust://document/faustedition/')]">
						<xsl:sequence select="f:resolve-faust-doc(replace($uri, '^faust://print/', 'faust://document/faustedition/'), $transcript-list)"/>
					</xsl:when>					
					<xsl:otherwise>
						<mark class="md-unresolved-uri"><xsl:copy/></mark>
						<xsl:message select="concat('WARNING: Unresolved URI reference in text: ', .)"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:matching-substring>
			<xsl:non-matching-substring>
				<xsl:value-of select="."/>
			</xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:template>
	
	<xsl:function name="f:find-bib-refs" as="item()*">
		<xsl:param name="text"/>
		<xsl:analyze-string select="$text" regex="faust://bibliography/[a-zA-Z0-9/_.-]*[a-zA-Z0-9/_-]+">
			<xsl:matching-substring>
				<xsl:sequence select="."/>
			</xsl:matching-substring>
		</xsl:analyze-string>
	</xsl:function>
	
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
		<elem name="description">Nachweis</elem>
		<elem name="text">Text</elem>
		<elem name="facsimile">Faksimile</elem>
		<elem name="essay">Literatur</elem>
		<elem name="watermarkRubbing">Wasserzeichen-Pause</elem>
	</xsl:variable>
	<xsl:template match="reference"  priority="1">
		<dt><xsl:value-of select="f:lookup($reference-types, @type, 'reference-types')"/></dt>
		<dd>
			<xsl:copy-of select="f:cite(@uri, false())"/>
			<xsl:if test="normalize-space(.)">
				<xsl:text>, </xsl:text>
				<xsl:apply-templates/>				
			</xsl:if>
		</dd>
	</xsl:template>	
	
	<xsl:template match="copies|referenceCopy|furtherCopy">
		<xsl:call-template name="element">
			<xsl:with-param name="content">
				<dl>
					<xsl:apply-templates/>
				</dl>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="metadata">
		<dl>
			<xsl:apply-templates/>
		</dl>
	</xsl:template>
	<xsl:template match="/*/metadata">
		<h2><xsl:value-of select="idno[@type='faustedition'][1]"/></h2>
		<h3 class="md-headNote">
			<xsl:value-of select="headNote"/>
		</h3>
		<p class="md-note wip">
			<xsl:apply-templates select="headNote/following-sibling::note[1]/*"/>
		</p>
		<dl>
			<xsl:apply-templates select="* 
				except (idno[@type=('faustedition', 'wa_faust')][1] | headNote | headNote/following-sibling::*[1][self::note])"/>
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
	
	<xsl:template match="watermarkID|patchWatermarkID|countermarkID|patchCountermarkID">
		<xsl:variable name="id" select="normalize-space(.)"/>
		<xsl:variable name="label" select="document('watermark-labels.xml')//watermark[@id=normalize-space($id)]"/>		
		<xsl:call-template name="element">
			<xsl:with-param name="content">
				<xsl:choose>
					<xsl:when test="$label"><xsl:value-of select="$label"/></xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$id"/>
						<xsl:message select="concat('WARNING: Watermark label not found for ', name(), ' ', $id)"/>
					</xsl:otherwise>					
				</xsl:choose>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- 
	
	Wir erzeugen Abschnitte für strukturelle Elemente, aber nur wenn irgendwo darunter ein nicht-leeres Metadatenfeld ist.	
	-->
	
	<xsl:template name="pagenos">
		<xsl:for-each select="self::page|page|leaf/page">
			<a class="md-pageref"><xsl:number format="1" level="any"/></a>
			<xsl:if test="position() != last()">, </xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	<!-- Alle sheets kriegen eine Überschrift 
	<xsl:template match="sheet">
		<div class="md-{local-name()} md-level">
			<h3><xsl:value-of select="f:lookup($labels, local-name(), 'elements')"/></h3>
			<xsl:apply-templates/>
		</div>
	</xsl:template> -->
	
	<xsl:template match="sheet|leaf|disjunctLeaf|page" priority="1">
		<xsl:variable name="label"
			select="if (self::disjunctLeaf[(metadata/format | /archivalDocument/metadata/format) = ('none', 'n.s.')])
					then 'Zettel' else f:lookup($labels, local-name(), 'elements')"/>
		<xsl:variable name="heading" select="$label"/>
		<xsl:variable name="content">
			<xsl:apply-templates/>
		</xsl:variable>
		<xsl:choose>
			<xsl:when test="normalize-space(string($content)) != ''">				
				<div class="md-{local-name()} md-level">
					<h3>
						<xsl:choose>
							<xsl:when test="self::page">
								<xsl:value-of select="$heading"/>
								<xsl:text> </xsl:text>
								<xsl:call-template name="pagenos"/>		
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$heading"/> (Seiten <xsl:call-template name="pagenos"/>)								
							</xsl:otherwise>
						</xsl:choose>
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
								<div class="pure-u-1-5"></div>
								<div class="pure-u-3-5">
									<div id="metadataContainer" class="metadata-container pure-u-4-5">
										<xsl:apply-templates/>
									</div>									
								</div>
								<div class="pure-u-1-5">
									<p>											
										<a href="../print/{replace(//textTranscript[1]/@uri, '.xml', '')}"><i class="fa fa-variants"></i> Text</a>
									</p>
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
