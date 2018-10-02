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
	<xsl:param name="docbase">/document?sigil=</xsl:param>
	
	
	<!-- 
		
		This stylesheet creates a table that links all watermark / countermark combinations to the list of witnesses that
		contain paper with the watermark, the countermark, or both. 
		
		Input is a single XML document that wraps all the metadata xml files. We expect each files' root element to be
		augmented by a faust-uri attribute. This is prepared by metadata-html.xpl
	-->
	
	
	<xsl:template match="/">
		<xsl:call-template name="html-frame">
			<xsl:with-param name="content">
				<table class="pure-table" data-sortable="true">
					<thead>
						<tr>
							<th data-sorted="true" data-sorted-direction="ascending"  data-sortable-type='alpha'>Hauptzeichen</th>
							<th data-sorted="false" data-sortable-type='alpha'>Gegenzeichen</th>
							<th data-sorted="false" data-sortable-type='sigil'>Zeugen (Haupt- und Gegenzeichen)</th>
							<th data-sorted="false" data-sortable-type='sigil'>Zeugen (nur Hauptzeichen)</th>
							<th data-sorted="false" data-sortable-type='sigil'>Zeugen (nur Gegenzeichen)</th>
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
	
	<!-- The actual watermark IDs in the data are to be normalized. watermark-labels.xml contaisn the mapping for that. -->
	<xsl:function name="f:wm-label">
		<xsl:param name="wm-id"/>
		<xsl:variable name="id" select="normalize-space($wm-id)"/>		
		<xsl:variable name="normalized" select="document('watermark-labels.xml')//watermark[@id=$id]"/>
		<xsl:choose>
			<xsl:when test="$normalized = ('k.A.', '', '-', '–', '—')">
				<xsl:text/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$normalized"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<!-- watermark label -> something we could use as an id -->
	<xsl:function name="f:toid">
		<xsl:param name="wm-id"/>
		<xsl:value-of select="replace(normalize-space($wm-id), '\W', '_')"/>
	</xsl:function>
	
	
	<xsl:template name="watermark-table-body">
		<!-- first, extract the relevant info from the input data. Creates a sequence of elements of this form:
		     
		     <watermark watermark= countermark= faust-uri= sigil= />
		     
		     One element for each watermarkID/countermarkID pair		     
		-->
		<xsl:variable name="watermarks"  as="element()*">
			<xsl:for-each select="//*[ends-with(local-name(), 'atermarkID')]">
				<f:watermark>
					<xsl:attribute name="watermark" select="normalize-space(f:wm-label(.)[1])"/>
					<xsl:attribute name="countermark" select="normalize-space(f:wm-label((following-sibling::countermarkID|following-sibling::patchCountermarkID)[1]))"/>
					<xsl:attribute name="faust-uri" select="ancestor::*/@faust-uri"/>					
					<xsl:attribute name="sigil" select="ancestor-or-self::*[@faust-uri]/metadata/idno[@type='faustedition'][1]"/>									
				</f:watermark>							
			</xsl:for-each>
			<!-- now the countermarks w/o watermarks: -->
			<xsl:for-each select="//*[ends-with(local-name(), 'ountermarkID')][not(f:wm-label((preceding-sibling::watermarkID|preceding-sibling::patchWatermarkID)[1]) = '')]">
				<f:watermark>
					<xsl:attribute name="watermark"/>
					<xsl:attribute name="countermark" select="normalize-space(f:wm-label(.)[1])"/>
					<xsl:attribute name="faust-uri" select="ancestor::*/@faust-uri"/>					
					<xsl:attribute name="sigil" select="ancestor-or-self::*[@faust-uri]/metadata/idno[@type='faustedition'][1]"/>									
				</f:watermark>				
			</xsl:for-each>			
		</xsl:variable>
		
		<!-- for all distinct watermark values ... -->
		<xsl:for-each-group select="$watermarks[@watermark != '']" group-by="@watermark">
			<xsl:sort select="current-grouping-key()"/>
			<xsl:variable name="wm" select="current-grouping-key()"/>
			
			<!-- which non-empty countermark values occur with this watermark? -->
			<xsl:variable name="countermarks" select="distinct-values(current-group()/@countermark[. != ''])"/>
			<!-- build a table row for each combination ... -->
			<xsl:for-each select="$countermarks">
				<xsl:sort select="."/>
				<xsl:sequence select="f:watermark-row($wm, ., $watermarks)"/>
			</xsl:for-each>
			<xsl:if test="count($countermarks) = 0"> <!-- wm never appears with a countermark -->
				<xsl:sequence select="f:watermark-row($wm, '', $watermarks)"/>
			</xsl:if>
		</xsl:for-each-group>
		
		<!-- countermarks that never appear with a watermark in our corpus have not been dealt with yet: -->
		<xsl:for-each-group select="$watermarks" group-by="@countermark">
			<xsl:sort select="current-grouping-key()"/>
			<xsl:variable name="cm" select="current-grouping-key()"/>
			<xsl:if test="empty(current-group()[@watermark != ''])">
				<!-- $cm is a countermark which never appears together with a watermark -->
				<xsl:sequence select="f:watermark-row('', $cm, $watermarks)"/>
			</xsl:if>
		</xsl:for-each-group>
	</xsl:template>
	
	<!-- a single row in the table. -->
	<xsl:function name="f:watermark-row">
		<xsl:param name="wm" as="xs:string"/> <!-- watermark, may be '' -->
		<xsl:param name="cm" as="xs:string"/> <!-- countermark, may be '' -->
		<xsl:param name="watermarks" as="element()*"/> <!-- The whole watermark list, we select from that -->
		<tr id="{f:toid($wm)}">		
			<td><xsl:value-of select="$wm"/></td>
			<td>
				<xsl:if test="$cm != ''">
					<xsl:attribute name="id" select="f:toid($cm)"/>
				</xsl:if>
				<xsl:value-of select="$cm"/>
			</td>				
			<td><!-- Watermark and Countermark -->
				<xsl:if test="$cm != '' and $wm != ''">
					<xsl:sequence select="f:sigils($watermarks[@watermark=$wm][@countermark=$cm])"/>											
				</xsl:if>
			</td>
			<td><!-- Watermark only -->
				<xsl:if test="$wm != ''">
					<xsl:sequence select="f:sigils($watermarks[@watermark=$wm][@countermark=''])"/>					
				</xsl:if>
			</td>				
			<td><!-- Countermark only -->					
				<xsl:if test="$cm != ''">
					<xsl:sequence select="f:sigils($watermarks[@countermark = $cm and @watermark = ''])"/>						
				</xsl:if>
			</td>			
		</tr>
	</xsl:function>	
	
	<!-- a list of links to the witnesses -->
	<xsl:function name="f:sigils">
		<xsl:param name="watermarks" as="element()*"/> <!-- <watermark> elements as in $watermarks above -->
		<xsl:variable name="watermarks-uniq" as="element()*">
			<xsl:for-each-group select="$watermarks" group-by="@sigil">
				<xsl:copy-of select="current-group()[1]"/>
			</xsl:for-each-group>
		</xsl:variable>
		<xsl:for-each select="$watermarks-uniq">
			<xsl:sort select="f:splitSigil(@sigil)[1]"/>
			<xsl:sort select="f:splitSigil(@sigil)[2]"/>
			<xsl:sort select="f:splitSigil(@sigil)[3]"/>
			<a class="sigil" href="/document?sigil={f:sigil-for-uri(@sigil)}&amp;view=structure"><xsl:value-of select="@sigil"/></a>
			<xsl:if test="position() != last()">, </xsl:if>
		</xsl:for-each>							
	</xsl:function>
		
	
	
</xsl:stylesheet>
