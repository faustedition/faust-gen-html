<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.faustedition.net/ns"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xs f tei"
	version="3.0">
	
	<xsl:import href="utils.xsl"/>
	<xsl:import href="bibliography.xsl"/>
	<xsl:import href="collect-hands.xsl"/>
	<xsl:include href="html-frame.xsl"/>
		
	<xsl:param name="source">file:/home/tv/Faust/</xsl:param>
	<xsl:param name="builddir">../target</xsl:param>
	<xsl:param name="builddir-resolved" select="$builddir"/>	
	<xsl:param name="transcript-list" select="f:safely-resolve('faust-transcripts.xml', f:safely-resolve($builddir-resolved))"/>
	<xsl:param name="docbase">/document?sigil=</xsl:param>
	<xsl:param name="source-uri" select="document-uri(/)"/>
	<xsl:param name="sigil_t" select="f:sigil-for-uri(//idno[@type='faustedition'])"/>
	
	
	
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
	
	<xsl:variable name="repositories" select="document(f:safely-resolve('archives.xml', $source))"/>
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
						<xsl:message select="concat('WARNING: idno label &quot;', @type, '&quot; not found.', ' (in ', $source-uri, ')')"/>
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
						<a href="https://ores.klassik-stiftung.de/ords/f?p=401:2:::::P2_ID:{following::idno[1][@type='gsa_ident']}">
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
	<xsl:template match="idno[@type='hecker']"/>
	<xsl:template match="*[f:isEmpty(.)][not(self::format)]"/>
	
	<xsl:template match="note[preceding-sibling::*[1][self::idno]]">
		<xsl:comment>
			Not displaying note: <xsl:value-of select="."/>
		</xsl:comment>
	</xsl:template>
	
	<xsl:function name="f:isEmpty" as="xs:boolean">
		<xsl:param name="element"/>		
		<xsl:sequence select="$element = 'none' or $element = '' or $element = 'n.s.'"/>
	</xsl:function>

	<xsl:template match="textTranscript"/>	
	<xsl:template match="docTranscript"/>	
	
	<!-- Bibliographische Verweise. Stehen z.T. einfach als URIs im Text in den anderen Feldern. -->	
	<xsl:template match="text()">
		<xsl:call-template name="parse-for-bib"/>
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
		<xsl:if test="classification and not(classification = ('n.s.', 'none', ''))">
			<h3 class="md-classification">
				<xsl:value-of select="classification"/>
			</h3>			
		</xsl:if>
		<h3 class="md-headNote">
			<xsl:apply-templates select="headNote/node()"/>
		</h3>
		<p class="md-note">
			<xsl:apply-templates select="headNote/following-sibling::note[1]/node()"/>
		</p>	
		<dl>
			<xsl:call-template name="verse-range"/>
			<dt><a href="{$edition}/macrogenesis/{$sigil_t}">Makrogenese-Lab</a></dt>
			<dd><a href="{$edition}/macrogenesis/{$sigil_t}">Datierungsinformationen</a></dd>
			<xsl:call-template name="hands-info"/>
			<xsl:apply-templates select="* 
				except (idno[@type=('faustedition', 'wa_faust')][1] | headNote | headNote/following-sibling::*[1][self::note] | classification)"/>
		</dl>		
	</xsl:template>
	
	<xsl:template name="verse-range">
		<xsl:variable name="transcriptUri" select="f:safely-resolve(concat('prepared/textTranscript/', f:sigil-for-uri(//idno[@type='faustedition']), '.xml'), $builddir-resolved)"/>
		<xsl:variable name="transcript" select="if (doc-available($transcriptUri)) then document($transcriptUri) else ()"/>
		<xsl:variable name="textEl" select="$transcript/tei:TEI/tei:text"/>
		<dt>Verse</dt>
		<dd>
			<a href="{$edition}/genesis_bargraph?rangeStart={$textEl/@f:min-verse}&amp;rangeEnd={$textEl/@f:max-verse}#{$sigil_t}">
				<xsl:value-of select="string-join(($textEl/@f:min-verse, $textEl/@f:max-verse), ' – ')"/>
			</a>
		</dd>		
	</xsl:template>
	
	<xsl:variable name="scribes">
		<elem name="g">Goethe</elem>
		<elem name="ovg">Ottilie von Goethe</elem>
		<elem name="wvg">Wolfgang von Goethe</elem>
		<elem name="ec">Eckermann</elem>
		<elem name="f">Färber</elem>
		<elem name="gt">Geist</elem>
		<elem name="gh">Göchhausen</elem>
		<elem name="go">Göttling</elem>
		<elem name="hd">Herder</elem>
		<elem name="aj">Anna Jameson</elem>
		<elem name="jo">John</elem>
		<elem name="kr">Kräuter</elem>
		<elem name="m">Müller (Friedrich von)</elem>
		<elem name="re">Reichel</elem>
		<elem name="ri">Riemer</elem>
		<elem name="st">Schuchardt</elem>
		<elem name="sd">Seidler (Luise)</elem>
		<elem name="so">Soret</elem>
		<elem name="sp">Spiegel (Frhr. von und zu Pickelsheim, Carl Emil)</elem>
		<elem name="sta">Stadelmann</elem>
		<elem name="sti">Stieler (Pauline)</elem>
		<elem name="v">Helene Vulpius</elem>
		<elem name="we">Weller</elem>
		<elem name="wejo">Weller und John</elem>
		<elem name="wo">Pius Alexander Wolff</elem>
		<elem name="sc">Schreiberhand</elem>
		<elem name="zs">Zeitgenössische Schrift</elem>
		<elem name="xx">Fremde Hand</elem>
		<elem name="xy">Fremde Hand</elem>
		<elem name="xz">Fremde Hand</elem>
		<elem name="">?</elem>
	</xsl:variable>
	
	<xsl:variable name="materials">
		<elem name="blau">Blaustift</elem>
		<elem name="bl">Bleistift</elem>
		<elem name="ko">Kohlestift</elem>
		<elem name="ro">Rötel</elem>
		<elem name="t">Tinte</elem>
		<elem name="tr">rote Tinte</elem>
		<elem name="">?</elem>
	</xsl:variable>
	
	<xsl:variable name="hands"><xsl:call-template name="collect-hands"/></xsl:variable>
	
	<xsl:template name="hands-info">
		<dt xml:id="hands-info">Schreiberhände</dt>
		<xsl:comment>
			<xsl:value-of select="serialize($hands)"/>
		</xsl:comment>				
		<dd>
			<xsl:variable name="total-chars" select="sum($hands//*/@extent)"/>
			<xsl:for-each-group select="$hands//*/f:hand" group-by="@scribe">
				<xsl:sort select="sum(current-group()/@extent)" order="descending"/>
				<xsl:variable name="current-extent" select="sum(current-group()/@extent)"/>
				<a href="#hand-{current-grouping-key()}"><xsl:sequence select="f:lookup($scribes, current-grouping-key(), 'scribes')"/> 
					(<xsl:value-of select="format-number(sum(current-group()/@extent) div $total-chars, '###%')"/>)</a>
				<xsl:if test="position() != last()"> · </xsl:if>
			</xsl:for-each-group>
		</dd>
	</xsl:template>
	
	<xsl:template name="hands-details">
		<h2>Schreiber</h2>
		<xsl:for-each-group select="$hands//f:hands/f:hand" group-by="@scribe">
			<xsl:sort select="@scribe"/>
			<h3 id="hand-{current-grouping-key()}"><xsl:sequence select="f:lookup($scribes, current-grouping-key(), 'scribes')"/></h3>
			<dl>
				<xsl:for-each-group select="current-group()" group-by="@material">
					<dt><xsl:sequence select="f:lookup($materials, current-grouping-key(), 'materials')"/></dt>
					<dd>						
						<xsl:for-each-group select="current-group()" group-by="../@page">
							<xsl:variable name="ratio" select="if (../@total-extent = 0) then 0 else sum(@extent) div ../@total-extent"/>
														
							<a href="/document?sigil={$sigil_t}&amp;page={current-grouping-key()}&amp;view=facsimile_document"
								 title="{format-number($ratio, '###.##% der Seite')}"
								 style="opacity:{0.3 + 0.7 * $ratio}">
								<xsl:value-of select="current-grouping-key()"/>
							</a>							
							<xsl:if test="position() != last()">, </xsl:if>
					</xsl:for-each-group>
					</dd>
			</xsl:for-each-group>				
			</dl>
		</xsl:for-each-group>
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
		<xsl:variable name="xmlid" select="replace(normalize-space($label[1]), '\W', '_')"/>		
		<xsl:call-template name="element">
			<xsl:with-param name="content">
				<xsl:choose>
					<xsl:when test="$label">
						<a>
							<xsl:if test="self::watermarkID|self::patchWatermarkID">
								<xsl:attribute name="href" select="concat('/watermark-table#', $xmlid)"/>		
							</xsl:if>
							<xsl:value-of select="$label"/>
						</a>
						<xsl:if test="$label/@imgref">
							<xsl:text> </xsl:text>
							<a href="/archive_watermarks#{$label/@imgref}" title="Abbildung"><i class="fa fa-file-image"></i></a>
						</xsl:if>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$id"/>
						<xsl:message select="concat('WARNING: Watermark label not found for ', name(), ' ', $id, ' (in ', $source-uri, ')')"/>
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
				<xsl:message select="concat('WARNING: Did not find &quot;', $key, '&quot; in ', $type, ' (in ', $sigil_t, ': ', $source-uri, ')')"/>
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
			<div id="metadataContainer" class="metadata-container">
				<xsl:apply-templates/>
				
				<xsl:call-template name="hands-details"/>
			</div>
	</xsl:template>
	
</xsl:stylesheet>
