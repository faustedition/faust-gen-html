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
	
	
	
	
	<xsl:template match="/testimonies">
		<xsl:call-template name="html-frame">
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
								<th data-sortable-type="bibliography">Bibliographie</th>
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
		
		<!-- now a bunch of assertions -->
		<xsl:choose>
			<xsl:when test="not($used)">
				<xsl:message select="concat('INFO: No XML for ', $lbl)"/>
			</xsl:when>
			<xsl:when test="count($used) > 1">
				<xsl:message select="concat('ERROR: ', count($used), 'XML sources ', string-join($used/@base, ', '), ' for ', $lbl)"/>
			</xsl:when>				
			<xsl:otherwise>
				<xsl:variable name="bibref" select="concat('faust://bibliography/', $used/@base)"/>
				<xsl:variable name="bib" select="$bibliography//bib[@uri=$bibref]"/>		
				<xsl:variable name="href" select="concat('testimony/', $used/@base, '#', $used/@id)"/>
				<xsl:variable name="excerpt" select="$used/text()"/>
				
				<xsl:if test="not($excerpt)">
					<xsl:message select="concat('INFO: No rs for ', $href)"/>
				</xsl:if>
				<xsl:if test="not($bib)">
					<xsl:message select="concat('WARNING: No bibliography entry for ', $bibref)"/>
				</xsl:if>
				
				<!-- Stupid first try version, no differentiation between fields at all -->
				<tr id="{@id}">
					<xsl:for-each select="field">
						<td>
							<a href="{$href}"><xsl:value-of select="."/></a>
						</td>
					</xsl:for-each>
					
					<td>
						<cite class="bib-short" 
							title="{$bib/reference}" 
							data-bib-uri="{$bibref}">
							<a href="/bibliography#{$used/@base}">
								<xsl:value-of select="$bib/citation"/>
							</a>
						</cite>
					</td>
					
					<td>
						<a href="{$href}"><xsl:value-of select="$excerpt"/></a>
					</td>
				</tr>
				
				
			</xsl:otherwise>
		</xsl:choose>
		
		
		
	</xsl:template>

	
</xsl:stylesheet>