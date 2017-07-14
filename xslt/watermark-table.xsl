<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.faustedition.net/ns"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xs f"	
	version="2.0">
	
	<xsl:import href="utils.xsl"/>
	<xsl:include href="html-frame.xsl"/>
	
	<xsl:param name="standalone" select="/print"/>
	<xsl:param name="source">file:/home/tv/Faust/</xsl:param>
	<xsl:param name="builddir">../target</xsl:param>
	<xsl:param name="builddir-resolved" select="$builddir"/>	
	<xsl:param name="transcript-list" select="resolve-uri('faust-transcripts.xml', resolve-uri($builddir-resolved))"/>
	<xsl:param name="docbase">http://beta.faustedition.net/documentViewer?faustUri=faust://xml</xsl:param>
	
	<xsl:template match="/">
		<xsl:call-template name="html-frame">
			<xsl:with-param name="content">
				<table class="pure-table" data-sortable="true">
					<thead>
						<tr>
							<th data-sorted="true" data-sorted-direction="ascending"  data-sortable-type='alpha'>Hauptzeichen</th>
							<th data-sorted="false" data-sortable-type='alpha'>Gegenzeichen</th>
							<th data-sorted="false" data-sortable-type='sigil'>Zeugen</th>
							<th data-sorted="false" data-sortable-type='sigil'>Zeugen (nur Hauptzeichen)</th>
						</tr>
					</thead>
					<tbody>
						<xsl:call-template name="watermark-table-body"/>
					</tbody>
				</table>
				<script type="text/javascript" src="js/jquery.min.js"></script> 
				<script type="text/javascript" src="js/jquery.table.js"></script> 
				
				<script type="text/javascript">
					$("table[data-sortable]").fixedtableheader();
					// set breadcrumbs
					document.getElementById("breadcrumbs").appendChild(Faust.createBreadcrumbs([{caption: "Ausgabe", link: "intro"}, {caption: "Wasserzeichen", link: "watermarks"}, {caption: "Wasserzeichen-Übersicht"}]));
				</script>			
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:function name="f:wm-label">
		<xsl:param name="wm-id"/>
		<xsl:variable name="id" select="normalize-space($wm-id)"/>		
		<xsl:value-of select="document('watermark-labels.xml')//watermark[@id=$id]"/>				
	</xsl:function>
	
	<xsl:function name="f:toid">
		<xsl:param name="wm-id"/>
		<xsl:value-of select="replace(normalize-space($wm-id), '\W', '_')"/>
	</xsl:function>
	
	<xsl:template name="watermark-table-body">
		<!-- <watermark watermark= countermark= faust-uri= sigil= /> -->
		<xsl:variable name="watermarks"  as="element()*">
			<xsl:for-each select="//*[ends-with(local-name(), 'atermarkID')][not(normalize-space(.) = ('', 'none', 'n.a.'))]">
				<f:watermark>
					<xsl:attribute name="watermark" select="normalize-space(f:wm-label(.)[1])"/>
					<xsl:attribute name="countermark" select="normalize-space(f:wm-label((following-sibling::countermarkID|following-sibling::patchCountermarkID)[1]))"/>
					<xsl:attribute name="faust-uri" select="ancestor::*/@faust-uri"/>					
					<xsl:attribute name="sigil" select="ancestor-or-self::*[@faust-uri]/metadata/idno[@type='faustedition'][1]"/>									
				</f:watermark>							
			</xsl:for-each>			
		</xsl:variable>
		
		<xsl:for-each-group select="$watermarks" group-by="@watermark">
			<xsl:sort select="lower-case(replace(current-grouping-key(), '\W+', ''))"/>
			<tr id="{f:toid(current-grouping-key())}">
				<td><xsl:value-of select="@watermark[1]"/></td>
				<xsl:if test="count(distinct-values(@countermark)) > 1">
					<xsl:message select="concat('WARNING: For watermark ', @watermark[1], ', there are multiple countermarks: ', string-join(distinct-values(@countermark), ', '))"/>					
				</xsl:if>
				<td><xsl:value-of select="@countermark[1]"/></td>
				<td>
					<xsl:sequence select="f:sigils(current-group()[normalize-space(@countermark) != ''])"/>					
				</td>
				<td>
					<xsl:sequence select="f:sigils(current-group()[normalize-space(@countermark) = ''])"/>
				</td>
			</tr>
		</xsl:for-each-group>
	</xsl:template>
	
	<xsl:function name="f:sigils">
		<xsl:param name="watermarks" as="element()*"/>
		<xsl:variable name="watermarks-uniq" as="element()*">
			<xsl:for-each-group select="$watermarks" group-by="@sigil">
				<xsl:copy-of select="current-group()[1]"/>
			</xsl:for-each-group>
		</xsl:variable>
		<xsl:for-each select="$watermarks-uniq">
			<xsl:sort select="f:splitSigil(@sigil)[1]"/>
			<xsl:sort select="f:splitSigil(@sigil)[2]"/>
			<xsl:sort select="f:splitSigil(@sigil)[3]"/>
			<a href="/documentViewer?faustUri={@faust-uri}&amp;view=structure"><xsl:value-of select="@sigil"/></a>
			<xsl:if test="position() != last()">, </xsl:if>
		</xsl:for-each>							
	</xsl:function>
		
	
	
</xsl:stylesheet>