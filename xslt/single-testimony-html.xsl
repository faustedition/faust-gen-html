<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns="http://www.w3.org/1999/xhtml"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs"
	version="2.0">
	
	<xsl:import href="testimony2html.xsl"/>
	
	<xsl:variable name="id" select="data(//f:testimony/@id)"/>
	
	
	<xsl:variable name="fields" xmlns="http://www.faustedition.net/ns">
			<!--These fields have been found in the excel table:-->
			<fieldspec name="status" spreadsheet="Status"/>
			<fieldspec name="lfd-nr-allerneuestens" spreadsheet="lfd. Nr. (allerneuestens)"/>
			<fieldspec name="lfd-nr-neuestens" spreadsheet="lfd. Nr. (neuestens)"/>
			<fieldspec name="lfd-nr-ganz-neu" spreadsheet="lfd. Nr. (ganz neu)"/>
			<fieldspec name="lfd-nr-neu" spreadsheet="lfd. Nr. (neu)"/>
			<fieldspec name="lfd-nr-alt" spreadsheet="lfd. Nr. (alt)"/>
			<fieldspec name="graef-nr" spreadsheet="Gräf-Nr."/>
			<fieldspec name="graef-verweisnr" spreadsheet="Gräf-Verweisnr."/>
			<fieldspec name="wa-brief-nr" spreadsheet="WA-Brief-Nr."/>
			<fieldspec name="pniower-nr" spreadsheet="Pniower-Nr."/>
			<fieldspec name="tille-nr" spreadsheet="Tille-Nr."/>
			<fieldspec name="biedermann-nr-alt" spreadsheet="Biedermann- Nr. alt"/>
			<fieldspec name="biedermann-2" spreadsheet="Biedermann-2"/>
			<fieldspec name="biedermann-herwignr" spreadsheet=" Biedermann-HerwigNr."/>
			<fieldspec name="quz" spreadsheet="QuZ"/>
			<fieldspec name="h-sigle" spreadsheet="H-Sigle"/>
			<fieldspec name="verfasser" spreadsheet="Verfasser"/>
			<fieldspec name="verfasser-gsa-personennummer" spreadsheet="Verfasser_GSA-Personennummer"/>
			<fieldspec name="dokumenttyp" spreadsheet="Dokumenttyp"/>
			<fieldspec name="div-type" spreadsheet="&lt;div type=&quot;…&quot;&gt;"/>
			<fieldspec name="titel" spreadsheet="Titel"/>
			<fieldspec name="adressat" spreadsheet="Adressat"/>
			<fieldspec name="adressat-gsa-personennummer" spreadsheet="Adressat_GSA-Personennummer"/>
			<fieldspec name="gespraechspartner-wenn-nicht-identisch-mit-verfasser" spreadsheet="Gesprächspartner (wenn nicht identisch mit Verfasser)"/>
			<fieldspec name="gespraechspartner-gsa-personennummer" spreadsheet="Gesprächspartner_GSA-Personennummer"/>
			<fieldspec name="datum-ereignis-genau" spreadsheet="Datum Ereignis (genau)"/>
			<fieldspec name="datum-von" spreadsheet="Datum.(von)"/>
			<fieldspec name="datum-bis" spreadsheet="Datum (bis)"/>
			<fieldspec name="intervall-erschlossen" spreadsheet="Intervall erschlossen"/>
			<fieldspec name="datierungsvermerk" spreadsheet="Datierungsvermerk"/>
			<fieldspec name="datum-zeugnis" spreadsheet="Datum (Zeugnis)"/>
			<fieldspec name="vermerk" spreadsheet="Vermerk"/>
			<fieldspec name="bemerkung" spreadsheet="Bemerkung"/>
			<fieldspec name="zuordnung-zu-wanderjahren-trunz-aber-vgl-quz-ii-s-477f-anm-2" spreadsheet="Zuordnung zu “Wanderjahren” (Trunz; aber vgl. QuZ II, S. 477f., Anm. 2)"/>
			<fieldspec name="wa-druckort" spreadsheet="WA-Druckort"/>
			<fieldspec name="druckort" spreadsheet="Druckort"/>
			<fieldspec name="alternativer-druckort" spreadsheet="Alternativer Druckort"/>
			<fieldspec name="fremdzeugnis-nr" spreadsheet="Fremdzeugnis-Nr."/>
			<fieldspec name="texttranscript" spreadsheet="textTranscript"/>
			<fieldspec name="fehler-in-zeno" spreadsheet="Fehler in Zeno"/>
			<fieldspec name="digitalisat-dateiname" spreadsheet="Digitalisat-Dateiname"/>
			<fieldspec name="vorlage" spreadsheet="Vorlage"/>
			<fieldspec name="vorlage-seite-von" spreadsheet="Vorlage-Seite von"/>
			<fieldspec name="vorlage-absatz-von" spreadsheet="Vorlage-Absatz von"/>
			<fieldspec name="vorlage-seite-bis" spreadsheet="Vorlage-Seite bis"/>
			<fieldspec name="vorlage-absatz-bis" spreadsheet="Vorlage-Absatz bis"/>
			<fieldspec name="unnamed-46" spreadsheet="Unnamed: 46"/>

	</xsl:variable>
	
	
	<xsl:template match="/TEI">
		<xsl:call-template name="html-frame">
			<xsl:with-param name="breadcrumbs" tunnel="yes">				
				<div class="breadcrumbs pure-right pure-nowrap pure-fade-50">
					<small id="breadcrumbs">
						<span>
							<a href="/archive">Archiv</a>
							<i class="fa fa-angle-right"/>
							<a href="/archive_testimonies#{$id}">Entstehungszeugnisse</a>
						</span>
					</small>
				</div>				
				<div id="current" class="pure-nowrap">
					<span>						
						<xsl:value-of select="f:testimony-label($id)"/>
					</span>
				</div>								
			</xsl:with-param>
			<xsl:with-param name="headerAdditions">
				<link rel="stylesheet" href="{$assets}/css/document-viewer.css"/>
			</xsl:with-param>
			<xsl:with-param name="content">
				<div class="print">
					<div class="print-side-column"></div>
					<div class="print-center-column">
						<xsl:apply-templates select="//f:testimony"/>
						<xsl:apply-templates select="//text//text[not(@copyOf)]"/>						
					</div>
					<div class="print-side-column"></div>
				</div>
			</xsl:with-param>
		</xsl:call-template>				
	</xsl:template>
	
	
	
	<xsl:template match="f:testimony">
		<dl class="metadata-container testimony-metadata">
			<xsl:apply-templates/>
		</dl>
	</xsl:template>
	
	<xsl:template match="f:field[starts-with(@name, 'lfd-nr')][1]" priority="1">
		<dt>laufende Nummer</dt>
		<dd>
			<xsl:for-each select="../f:field[starts-with(@name, 'lfd-nr')]">
				<xsl:value-of select="concat(., ' ', replace(f:fieldlabel(@name), 'lfd.\s*Nr.\s*', ''))"/>
				<xsl:if test="position() != last()">, </xsl:if>
			</xsl:for-each>
		</dd>
	</xsl:template>
	
	<xsl:template match="f:field[starts-with(@name, 'lfd-nr')]"/>
	
	<xsl:function name="f:fieldlabel">
		<xsl:param name="fieldname"/>
		<xsl:variable name="spec" select="$fields//f:fieldspec[@name = $fieldname]"/>
		<xsl:value-of select="if (normalize-space($spec)) then $spec else $spec/@spreadsheet"/>
	</xsl:function>
	
	<xsl:template match="f:field">
		<dt><xsl:value-of select="f:fieldlabel(@name)"/></dt>
		<dd><xsl:value-of select="."/></dd>
	</xsl:template>
	
	<xsl:template match="f:biburl">
		<dt>Quelle</dt>
		<dd><xsl:sequence select="f:cite(., false())"/></dd>
	</xsl:template>
	
</xsl:stylesheet>