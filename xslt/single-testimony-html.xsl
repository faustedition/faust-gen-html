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

	<!-- 
	
		The following variable contains the basic configuration for the testimony metadata header. For some fields,
		more specific rules are required, these are implemented as explicit template rules further below.
		
		The <fieldspec> elements are taken from the start of testimony-table.xml and edited. Semantics:
		
		- @name: the normalized field name as found in testimony-table.xml
		- @spreadsheet: the original column name in the Excel table (for reference)
		- @ignore="yes": Don't generate a metadata entry for this field 
		- text content: The label, if present; otherwise @spreadsheet is used
	
	-->	
	<xsl:variable name="fields" xmlns="http://www.faustedition.net/ns">
		<!--These fields have been found in the excel table:-->
		<fieldspec name="status" spreadsheet="Status" ignore="yes"/><!-- raus -->
		<fieldspec name="lfd-nr-neuneu" spreadsheet="lfd. Nr. (neuneu)">Zeugnis-Nr.</fieldspec>
		<fieldspec name="lfd-nr-allerneuestens" spreadsheet="lfd. Nr. (allerneuestens)" ignore="yes"/> <!-- alle anderen weg -->
		<fieldspec name="lfd-nr-neuestens" spreadsheet="lfd. Nr. (neuestens)" ignore="yes"/>
		<fieldspec name="lfd-nr-ganz-neu" spreadsheet="lfd. Nr. (ganz neu)" ignore="yes"/>
		<fieldspec name="lfd-nr-neu" spreadsheet="lfd. Nr. (neu)" ignore="yes"/>
		<fieldspec name="lfd-nr-alt" spreadsheet="lfd. Nr. (alt)" ignore="yes"/>
		<fieldspec name="graef-nr" spreadsheet="Gräf-Nr."/>
		<fieldspec name="graef-verweisnr" spreadsheet="Gräf-Verweisnr."/>
		<fieldspec name="wa-brief-nr" spreadsheet="WA-Brief-Nr."/>
		<fieldspec name="pniower-nr" spreadsheet="Pniower-Nr."/>
		<fieldspec name="tille-nr" spreadsheet="Tille-Nr."/>
		<fieldspec name="biedermann-nr-alt" spreadsheet="Biedermann- Nr. alt">Biedermann¹</fieldspec>
		<fieldspec name="biedermann-2" spreadsheet="Biedermann-2">Biedermann²</fieldspec>
		<fieldspec name="biedermann-herwignr" spreadsheet=" Biedermann-HerwigNr.">Biedermann³</fieldspec>
		<fieldspec name="quz" spreadsheet="QuZ"/>
		<fieldspec name="h-sigle" spreadsheet="H-Sigle">Handschrift</fieldspec><!-- Links auch im Header -->
		<fieldspec name="verfasser" spreadsheet="Verfasser"/>
		<fieldspec name="verfasser-gsa-personennummer" spreadsheet="Verfasser_GSA-Personennummer" ignore="yes"/> <!-- erstmal raus, später links nach GSA setzen → Issue -->
		<fieldspec name="dokumenttyp" spreadsheet="Dokumenttyp"/><!-- siehe Issue Beschreibungsspalte -->
		<fieldspec name="div-type" spreadsheet="&lt;div type=&quot;…&quot;&gt;" ignore="yes"/> <!-- raus -->
		<fieldspec name="titel" spreadsheet="Titel"/>
		<fieldspec name="adressat" spreadsheet="Adressat"/>
		<fieldspec name="adressat-gsa-personennummer" spreadsheet="Adressat_GSA-Personennummer" ignore="yes"/> <!-- s.o. -->
		<fieldspec name="gespraechspartner-wenn-nicht-identisch-mit-verfasser" spreadsheet="Gesprächspartner (wenn nicht identisch mit Verfasser)">Gesprächspartner</fieldspec>
		<fieldspec name="gespraechspartner-gsa-personennummer" spreadsheet="Gesprächspartner_GSA-Personennummer" ignore="yes"/> <!-- s.o. -->
		<fieldspec name="datum-ereignis-genau" spreadsheet="Datum Ereignis (genau)" ignore="yes"/> <!-- raus -->
		<fieldspec name="datum-von" spreadsheet="Datum.(von)">Datum (von)</fieldspec> <!-- »Datum: « wenn datum-von und datum-bis dann »zwischen a und b«  sonst: »Datum: xxx« -->
		<fieldspec name="datum-bis" spreadsheet="Datum (bis)" ignore="yes"/> <!-- raus -->
		<fieldspec name="intervall-erschlossen" spreadsheet="Intervall erschlossen" ignore="yes"/> <!-- wenn x dann an datum oben " (erschlossen)" anhängen, feld raus -->
		<fieldspec name="datierungsvermerk" spreadsheet="Datierungsvermerk" ignore="yes"/> <!-- raus -->
		<fieldspec name="datum-zeugnis" spreadsheet="Datum (Zeugnis)" ignore="yes"/> <!-- raus -->
		<fieldspec name="vermerk" spreadsheet="Vermerk" ignore="yes"/> <!-- raus -->
		<fieldspec name="bemerkung" spreadsheet="Bemerkung" ignore="yes"/> <!-- raus -->
		<fieldspec name="zuordnung-zu-wanderjahren-trunz-aber-vgl-quz-ii-s-477f-anm-2" spreadsheet="Zuordnung zu “Wanderjahren” (Trunz; aber vgl. QuZ II, S. 477f., Anm. 2)" ignore="yes"/> <!-- raus -->
		<fieldspec name="wa-druckort" spreadsheet="WA-Druckort" ignore="yes"/> <!-- raus -->
		<fieldspec name="druckort" spreadsheet="Druckort"/> <!-- Druckort; alternativer Druckort -->
		<fieldspec name="alternativer-druckort" spreadsheet="Alternativer Druckort" ignore="yes"/> <!-- raus (s.o.) -->
		<fieldspec name="fremdzeugnis-nr" spreadsheet="Fremdzeugnis-Nr." ignore="yes"/> <!-- raus -->
		<fieldspec name="texttranscript" spreadsheet="textTranscript" ignore="yes"/> <!-- raus -->
		<fieldspec name="fehler-in-zeno" spreadsheet="Fehler in Zeno" ignore="yes"/> <!-- raus -->
		<fieldspec name="digitalisat-dateiname" spreadsheet="Digitalisat-Dateiname" ignore="yes"/> <!-- raus -->
		<fieldspec name="vorlage" spreadsheet="Vorlage" ignore="yes"/> <!-- raus -->
		<fieldspec name="vorlage-seite-von" spreadsheet="Vorlage-Seite von" ignore="yes"/> <!-- raus -->
		<fieldspec name="vorlage-absatz-von" spreadsheet="Vorlage-Absatz von" ignore="yes"/> <!-- raus -->
		<fieldspec name="vorlage-seite-bis" spreadsheet="Vorlage-Seite bis" ignore="yes"/> <!-- raus -->
		<fieldspec name="vorlage-absatz-bis" spreadsheet="Vorlage-Absatz bis" ignore="yes"/> <!-- raus -->
		<fieldspec name="unnamed-46" spreadsheet="Unnamed: 46" ignore="yes"/> <!-- raus -->
	</xsl:variable>
	
	<xsl:function name="f:fieldspec" as="element()?">
		<xsl:param name="name"/>
		<xsl:sequence select="$fields//f:fieldspec[@name=$name]"/>
	</xsl:function>
	
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
		<dt>Zeugnis-Nr.</dt>
		<dd><xsl:value-of select="."/></dd>
	</xsl:template>
	
	<xsl:template match="f:field[starts-with(@name, 'lfd-nr')]"/>
	
	<xsl:function name="f:fieldlabel">
		<xsl:param name="fieldname"/>
		<xsl:variable name="spec" select="$fields//f:fieldspec[@name = $fieldname]"/>
		<xsl:value-of select="if (normalize-space($spec)) then $spec else $spec/@spreadsheet"/>
	</xsl:function>
	
	<xsl:template match="f:field[f:fieldspec(@name)/@ignore='yes']" priority="0.1"/>
	
	<xsl:template match="f:field">
		<dt><xsl:value-of select="f:fieldlabel(@name)"/></dt>
		<dd><xsl:value-of select="."/></dd>
	</xsl:template>
	
	<xsl:template match="f:biburl">
		<dt>Quelle</dt>
		<dd><xsl:sequence select="f:cite(., false())"/></dd>
	</xsl:template>
	
</xsl:stylesheet>