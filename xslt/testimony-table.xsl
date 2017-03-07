<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns="http://www.w3.org/1999/xhtml"
	xpath-default-namespace="http://www.faustedition.net/ns"
	exclude-result-prefixes="xs"
	version="2.0">
		
	<xsl:include href="html-frame.xsl"/>
	
	<xsl:param name="resolved-builddir" select="resolve-uri('../../../../target/')"/>
	
	<!-- Mapping id -> file: -->
	<xsl:variable name="usage" select="doc(resolve-uri('testimony-index.xml', $resolved-builddir))"/>
	<!-- Machine-readable bibliography: -->
	<xsl:variable name="bibliography" select="doc('bibliography.xml')"/>
	

	<xsl:param name="extrastyle">
		<style type="text/css">
			.message { border: 1px solid transparent; border-radius: 1px; padding: 1px; margin: 1px;}
			.message.error { color: rgb(190,0,0); border-color: rgb(190,0,0); background-color: rgba(190,0,0,0.1); }
			.message.warning { color: black; background-color: rgba(220,160,0,0.2); border-color: rgb(220,160,0); }
			.message.info  { color: rgb(0,0,190); border-color: rgb(0,0,190); background-color: rgba(0,0,190,0.1); }
		</style>
	</xsl:param>
	
	
	<xsl:template match="/testimonies">
		<xsl:call-template name="html-frame">
			<xsl:with-param name="headerAdditions"><xsl:copy-of select="$extrastyle"/></xsl:with-param>
			<xsl:with-param name="content">
				
				<div id="testimony-table-container">
					<table data-sortable='true' class='pure-table'>
						<thead>
							<tr>
								<xsl:for-each select=".//testimony[1]/field/@label">
									<th data-sorted="false"
										data-sortable-type="{
											if (. = ('Gräf', 'Pniower'))
											then 'numericplus'
											else if (. = 'Datum')
											then 'date-de'
											else if (. = 'Druckort')
											then 'bibliography'
											else 'alpha'
										}"> 
										<xsl:value-of select="."/>
									</th>
								</xsl:for-each>							
								<th data-sortable-type="alpha">Auszug</th>
							</tr>
						</thead>
						<tbody>
							<xsl:apply-templates/>
						</tbody>
					</table>
				</div>
				
				<script type="text/javascript">
					// set breadcrumbs
					document.getElementById("breadcrumbs").appendChild(Faust.createBreadcrumbs([{caption: "Archiv", link: "archive"}, {caption: "Dokumente zur Entstehungsgeschichte"}]));
				</script>
				
				
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="testimony">
		<xsl:variable name="lbl" select="string-join(
			for $field in field return if ($field/text()) then concat($field/@label, ': ', $field) else (),
			', ')"/>
		<xsl:variable name="used" select="$usage//testimony[@id=current()/@id]"/>
		
		<!-- We're building an XML fragment that will finally serve as  info container for the current entry -->
		<xsl:variable name="rowinfo_raw">
			
			<!-- now a bunch of assertions -->
			<xsl:choose>
				<xsl:when test="not($used)">
					<f:excerpt/>
					<f:message status="info">kein XML für »<xsl:value-of select="@id"/>«</f:message>
				</xsl:when>
				<xsl:when test="count($used) > 1">
					<f:excerpt/>
					<f:message status="error"><xsl:value-of select="concat(count($used), ' XML-Quellen')"/></f:message>
				</xsl:when>				
				<xsl:otherwise>
					<f:base><xsl:value-of select="$used/@base"/></f:base>
					<f:href><xsl:value-of select="concat('testimony/', $used/@base, '#', $used/@id)"/></f:href>
					<xsl:variable name="bibref" select="concat('faust://bibliography/', $used/@base)"/>
					<xsl:variable name="bib" select="$bibliography//bib[@uri=$bibref]"/>
					<xsl:copy-of select="$bib"/>
					<xsl:variable name="excerpt" select="$used/text()"/>
					
					<xsl:if test="not($excerpt)">
						<f:message status="info">kein Auszug</f:message>
					</xsl:if>
					<f:excerpt><xsl:value-of select="$excerpt"/></f:excerpt>
					<xsl:if test="not($bib)">
						<f:message status="warning">kein Literaturverzeichniseintrag für faust://bibliography/<xsl:value-of select="$used/@base"/></f:message>
					</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="rowinfo">
			<f:row id="{@id}" lbl="{$lbl}">
				<xsl:copy-of select="@*, field, $rowinfo_raw/*[local-name() != 'message']"/>
				<f:messages>
					<xsl:copy-of select="$rowinfo_raw/message"/>
				</f:messages>
			</f:row>
		</xsl:variable>
				
		<xsl:apply-templates select="$rowinfo"/>
		
	</xsl:template>
	
	<xsl:template match="row">
		<tr id="{@id}">
			<xsl:apply-templates/>			
		</tr>
	</xsl:template>
	
	<xsl:template match="field">
		<td title="{@label}: {.}">
			<xsl:apply-templates/>
		</td>
	</xsl:template>
	
	<xsl:template match="field[@label='Druckort']">
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
	
	<xsl:template match="excerpt">
		<td>
			<a href="{../href}">
				<xsl:apply-templates/>
			</a>
			<xsl:for-each select="../messages/message">
				<div class="message {@status}"><xsl:value-of select="."/></div>
			</xsl:for-each>
		</td>
	</xsl:template>
	
	<xsl:template match="messages">
		<xsl:for-each select="message">
			<xsl:message select="concat(upper-case(@status), ':', ../../base, ':', ., ' (', ../../@lbl, ')')"/>			
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="row/*" priority="-1"/>
	
</xsl:stylesheet>