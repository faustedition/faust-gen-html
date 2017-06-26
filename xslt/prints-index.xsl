<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:f="http://www.faustedition.net/ns"
	exclude-result-prefixes="xs"
	xmlns="http://www.w3.org/1999/xhtml"
	xpath-default-namespace="http://www.faustedition.net/ns"
	version="2.0">
	
	<!-- 
	
		Creates the index page at /archive_prints
	
	-->
	
	<xsl:import href="html-frame.xsl"/>	
	<xsl:param name="source"/>
	
	<xsl:template match="/">
		<xsl:variable name="transcripts" select="."/>
		
		<xsl:call-template name="html-frame">
			<xsl:with-param name="content">
				<table id="prints" data-sortable="true" class="pure-table">
					<thead>
						<tr>
							<th data-sortable-type="sigil" data-sorted="false">Sigle</th>
							<th data-sortable-type="numericplus" data-sorted="true" data-sorted-direction="ascending">Kurzbeschreibung</th>
						</tr>
					</thead>
					<tbody>
						<xsl:for-each select="document(resolve-uri('print-labels.xml', $source))//item">
							<xsl:variable name="uri" select="@uri"/>
							<xsl:variable name="transcript" select="$transcripts//textTranscript[@uri=$uri]"/>							
							<tr>
								<td>
									<a href="print/{replace($transcript/@uri, 'faust://xml.*/(.+?)\.xml', '$1')}">
										<xsl:value-of select="$transcript/@f:sigil"/>
									</a>
								</td>
								<td data-value="{position()}">
									<xsl:value-of select="."/>
								</td>
							</tr>
						</xsl:for-each>							
					</tbody>
				</table>
				
				<script type="text/javascript" src="js/jquery.min.js"></script> 
				<script type="text/javascript" src="js/jquery.table.js"></script> 
				<script type="text/javascript">
					$("table[data-sortable]").fixedtableheader();	

					// Setup breadcrumbs
					document.getElementById("breadcrumbs").appendChild(Faust.createBreadcrumbs([{caption: "Archiv", link: "archive"}, {caption: "Drucke"}]));

					window.addEventListener("DOMContentLoaded", function(){
						Sortable.initTable(document.getElementById('prints'));
					});
				</script>
				
			</xsl:with-param>
		</xsl:call-template>
		
	</xsl:template>
	
</xsl:stylesheet>
