<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns="http://www.w3.org/1999/xhtml"
	xpath-default-namespace="http://www.faustedition.net/ns"
	exclude-result-prefixes="xs"
	version="2.0">
		
	<xsl:import href="utils.xsl"/>
	<xsl:include href="html-frame.xsl"/>
	
	<xsl:strip-space elements="*"/>	
	
	<xsl:param name="builddir-resolved" select="resolve-uri('../../../../target/')"/>
	
	<!-- XML version of the testimony table, generated by get-testimonies.py from the excel table -->
	<xsl:param name="table" select="doc('testimony-table.xml')"/>	
	
	<!-- input is the Mapping id -> file, generated by workflow from testimony xmls -->
	<xsl:param name="usage" select="/"/>
	
	<xsl:param name="transcript-list" select="resolve-uri('faust-transcripts.xml', resolve-uri($builddir-resolved))"/>
	
	<!-- Machine-readable bibliography, generated by python script from wiki page : -->
	<xsl:variable name="bibliography" select="doc('bibliography.xml')"/>

	<!-- 
		
		The following variable defines the available columns. To define a new column, you
		should copy the corresponding <fieldspec> element from testimony-table.xml to the
		right place in the variable below and adjust it accordingly.
		
		Attributes:
		
			- label: label as used in the <field> attributes
			- spreadsheet: original label from spreadsheet, for reference only
			- sortable-type: sort order for sortable
			
		Content:
		
			The element content is copied 1:1 to the corresponding <th> element
	
	-->
	<xsl:variable name="columns" xmlns="http://www.faustedition.net/ns">
		<fieldspec name="graef-nr" spreadsheet="Gräf-Nr." sortable-type="numericplus">Gräf</fieldspec>
		<fieldspec name="pniower-nr" spreadsheet="Pniower-Nr." sortable-type="numericplus">Pniower</fieldspec>
		<fieldspec name="quz" spreadsheet="QuZ">QuZ</fieldspec>
		<fieldspec name="biedermann-herwignr" spreadsheet=" Biedermann-HerwigNr.">Biedermann³</fieldspec>
		<fieldspec name="datum-von" spreadsheet="Datum.(von)" sortable-type="date-de">Datum</fieldspec>
		<fieldspec name="dokumenttyp" spreadsheet="Dokumenttyp">Beschreibung</fieldspec>		
		<fieldspec name="druckort" spreadsheet="Druckort" sortable-type="bibliography">Druckort</fieldspec>
		<fieldspec name="excerpt" generated="true">Auszug</fieldspec>
	</xsl:variable>
	
	<xsl:variable name="beschreibung" xmlns="http://www.faustedition.net/ns">
		<template name="Brief">Brief von $verfasser an $adressat</template>
		<template name="Tagebuch">Tagebucheintrag von $verfasser</template>
		<template name="Gespräch">Gesprächsbericht von $verfasser</template>
		<template name="Text">$titel</template>
	</xsl:variable>
	
	<xsl:function name="f:field-label">
		<xsl:param name="name"/>
		<xsl:value-of select="$columns/fieldspec[@name = $name]/node()"/>
	</xsl:function>
	
	<xsl:function name="f:expand-fields">
		<xsl:param name="template" as="xs:string"/>
		<xsl:param name="context"/>
		<xsl:analyze-string select="$template" regex="\$[a-z0-9_-]+">
			<xsl:matching-substring>
				<xsl:variable name="field" select="substring(., 2)"/>
				<xsl:variable name="substitution" select="$context//*[@name = $field]"/>
				<xsl:choose>
					<xsl:when test="$substitution">
						<span title="{$field}"><xsl:value-of select="$substitution"/></span>
					</xsl:when>
					<xsl:otherwise>
						<span class="message warning">$<xsl:value-of select="$field"/></span>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:matching-substring>
			<xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
		</xsl:analyze-string>
	</xsl:function>
	
	<!-- Used for the message column. Can be removed once there are no more warnings etc. -->
	<xsl:param name="extrastyle">
		<style type="text/css">
			.message { border: 1px solid transparent; border-radius: 1px; padding: 1px; margin: 1px;}
			.message.error { color: rgb(190,0,0); border-color: rgb(190,0,0); background-color: rgba(190,0,0,0.1); }
			.message.warning { color: black; background-color: rgba(220,160,0,0.2); border-color: rgb(220,160,0); }
			.message.info  { color: rgb(0,0,190); border-color: rgb(0,0,190); background-color: rgba(0,0,190,0.1); }
		</style>
	</xsl:param>
	
	<xsl:template match="/testimony-index">
		<xsl:for-each select="$table">
			<xsl:call-template name="start"/>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="start">
		<xsl:call-template name="html-frame">
			<xsl:with-param name="headerAdditions"><xsl:copy-of select="$extrastyle"/></xsl:with-param>
			<xsl:with-param name="content">
				
				<div id="testimony-table-container">
					<table data-sortable='true' class='pure-table'>
						<thead>
							<tr>
								<xsl:for-each select="$columns/fieldspec">
									<th data-sorted="false"
										data-sortable-type="{if (@sortable-type) then @sortable-type else 'alpha'}"
										id="th-{@name}"> 
										<xsl:copy-of select="node()"/>
									</th>
								</xsl:for-each>	
							</tr>
						</thead>
						<tbody>
							<xsl:apply-templates/>
						</tbody>
					</table>
				</div>
				<script type="text/javascript" src="js/jquery.min.js"></script> 
				<script type="text/javascript" src="js/jquery.table.js"></script> 
	
				<script type="text/javascript">
					$("table[data-sortable]").fixedtableheader();
					// set breadcrumbs
					document.getElementById("breadcrumbs").appendChild(Faust.createBreadcrumbs([{caption: "Archiv", link: "archive"}, {caption: "Dokumente zur Entstehungsgeschichte"}]));
				</script>
								
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	
	<!-- 
	
		Rendering a single testimony to a row works as follows:
		
		1. first, all additional data like usage and bibliography information are collected. There are also some consistency checks
		   that result in <message> elements.
		   
		2. then, we're adding additional empty <field name="…"/> elements for all fields in $columns but not in the current 
		   entry.

        3. finally, for each fieldspec in $column, we call <xsl:apply-templates/> on the corresponding <field/> from step 1/2.
           This should generate the actual <td> for the column. There are default implementations below.
	
	-->
	<xsl:template match="citation|testimony">
		<xsl:variable name="entry" select="."/>
		<xsl:variable name="lbl" select="string-join(
			for $field in field return if ($field/text()) then concat(string-join($columns/fieldspec[@label=$field/@label], ''), ': ', $field) else (),
			', ')"/>
		<xsl:variable name="used" select="$usage//*[@testimony-id=current()/@id]"/>
		
		<!-- We're building an XML fragment that will finally be moved into the current <testimony> entry -->
		<xsl:variable name="rowinfo_raw">
			
			<!-- now a bunch of assertions -->
			<xsl:choose>
				<xsl:when test="not($used) and $entry//field[@name='h-sigle']"/>
				<xsl:when test="not($used) and (not(@id) or @id = '' or contains(@id, ' '))">					
					<f:message status="error">keine/komische ID: »<xsl:value-of select="@id"/>«</f:message>
				</xsl:when>
				<xsl:when test="not($used)">
					<f:message status="info">kein XML für »<xsl:value-of select="@id"/>«</f:message>
				</xsl:when>
				<xsl:otherwise>
					<f:base><xsl:value-of select="$used/@base"/></f:base>
					<f:href><xsl:value-of select="concat('testimony/', @id)(: $used/@base, '#', $used/@testimony-id):)"/></f:href>
					<xsl:variable name="bibref" select="normalize-space($used[1]/text())"/>
					<xsl:variable name="bib" select="$bibliography//bib[@uri=$bibref]"/> <!-- TODO refactor to bibliography.xsl -->
					<xsl:copy-of select="$bib"/>
					<xsl:variable name="excerpt" select="$used/@rs"/>
					
					<xsl:if test="not($excerpt)">
						<f:message status="info">kein Auszug</f:message>
					</xsl:if>
					<f:field name="excerpt"><xsl:value-of select="$excerpt"/></f:field>
					<xsl:if test="not($bib)">
						<f:message status="warning">kein Literaturverzeichniseintrag für <xsl:value-of select="$bibref"/></f:message>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="rowinfo" as="element()">
			<xsl:copy> 
				<xsl:attribute name="id" select="@testimony-id"/>
				<xsl:copy-of select="@*"/>
				<xsl:sequence select="*"/>
				<xsl:sequence select="$rowinfo_raw"/>
				<xsl:for-each select="$columns/fieldspec">
					<xsl:if test="not(@name = ($entry//field/@name, $rowinfo_raw/field/@name))">
						<f:field name="{@name}"/>
					</xsl:if>
				</xsl:for-each>
			</xsl:copy>
		</xsl:variable>
				
		<tr id="{$rowinfo/@id}">
			<xsl:for-each select="$columns//fieldspec">
				<xsl:variable name="fieldname" select="@name"/>
				<xsl:apply-templates select="$rowinfo//field[@name=$fieldname]"/>
			</xsl:for-each>
		</tr>
	</xsl:template>
		
	<xsl:template match="field">
		<td title="{if (normalize-space(.)) then concat(f:field-label(@name), ': ', .) else f:field-label(@name)}">
			<xsl:apply-templates/>
		</td>
	</xsl:template>
	
	<xsl:template match="field[@name='druckort']">
		<xsl:choose>
			<xsl:when test="../bib">
				<td>	
					<cite class="bib-short bib-testimony" title="{../bib/reference}" data-bib-uri="faust://bibliography/{../base}">
						<a href="{../href}"><xsl:value-of select="."/></a>
					</cite>								
				</td>
			</xsl:when>
			<xsl:when test="../base">
				<td>
					<a href="{../href}"><xsl:value-of select="."/></a>
				</td>
			</xsl:when>
			<xsl:otherwise>
				<xsl:next-match/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="field[@name='dokumenttyp']">
		<td title="Beschreibung">
			<xsl:variable name="type" select="normalize-space(.)"/>
			<xsl:variable name="template" select="$beschreibung//template[@name=$type]"/>			
			<xsl:choose>
				<xsl:when test="$template">
					<xsl:sequence select="f:expand-fields($template, ..)"/>
				</xsl:when>
				<xsl:otherwise>
					<div class="message warning"><xsl:value-of select="."/></div>
				</xsl:otherwise>
			</xsl:choose>
		</td>
	</xsl:template>
	
	<xsl:template match="field[@name='excerpt']">
		<td>
			<xsl:if test="../field[@name='h-sigle']">				
				<xsl:variable name="sigils" select="normalize-space(../field[@name='h-sigle']/text())"/>
				<xsl:text>→ </xsl:text>
				<xsl:for-each select="tokenize($sigils, ';\s*')">
					<xsl:variable name="sigil" select="."/>
					<xsl:variable name="document" select="doc($transcript-list)//*[@f:sigil=$sigil]"/>
					<xsl:variable name="uri" select="$document/idno[@type='faust-doc-uri']/text()"/>
					<xsl:choose>
						<xsl:when test="not($document)">
							<a class="message error">H-Sigle nicht gefunden: <a title="zur Handschriftenliste" href="/archive_manuscripts">»<xsl:value-of select="$sigil"/>«</a></a>
						</xsl:when>
						<xsl:otherwise>
							<a href="{if ($document/@type='print')
									  then concat('/print/', replace(replace($document/@uri, '^.*/', ''), '\.xml$', ''))
								      else concat('/documentViewer?faustUri=', $uri)}"
							   title="{$document/headNote}">
								<xsl:value-of select="$sigil"/>
							</a>											
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="not(position() = last())">; </xsl:if>
				</xsl:for-each>
				<xsl:if test="normalize-space(.)"> / </xsl:if>
			</xsl:if>
			<xsl:if test="normalize-space(.)">
				<a href="{../href}"><xsl:apply-templates/></a>				
			</xsl:if>
			
			<xsl:for-each select="../message">
				<div class="message {@status}"><xsl:value-of select="."/></div>
			</xsl:for-each>
		</td>
	</xsl:template>
	
	<xsl:template match="messages">
		<xsl:for-each select="message">
			<xsl:message select="concat(upper-case(@status), ':', ../../base, ':', ., ' (', ../../@lbl, ')')"/>			
		</xsl:for-each>
	</xsl:template>
	
</xsl:stylesheet>
