<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns:ge="http://www.tei-c.org/ns/geneticEditions"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	version="2.0">
	
	<!-- Additional cleanup steps for preparing the reading text. -->

	
	<!-- Identitätstransformation -->
	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="@*, node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template
		match="group | l/hi[@rend='big'] | seg[@f:questionedBy or @f:markedBy] | c | damage[not(descendant::supplied)] 
		| s| seg[@xml:id] | profileDesc | creation | ge:transposeGrp">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template
		match="sourceDesc/* | encodingDesc | revisionDesc 
		| titlePage[not(./titlePart[@n])] | pb[not(@break='no')] | fw | hi/@status | anchor |  
		join[@type='antilabe'] | join[@result='sp'] | join[@type='former_unit'] | */@xml:space
		| div[@type='stueck' and not(.//l[@n])] | lg/@type | figure | text[not(.//l[@n])] | speaker/@rend | stage[not(matches(@rend,'inline'))]/@rend
		| l/@rend | l/@xml:id | space[@type='typographical'] | hi[not(matches(@rend,'antiqua')) and not(matches(@rend,'latin'))]/@rend
		| sp/@who | note[@type='editorial'] | ge:transpose[not(@ge:stage='#posthumous')] | ge:stageNotes | 
		handNotes | unclear/@cert | lg/@xml:id | addSpan[not(@ge:stage='#posthumous')] | milestone[@unit='group' or @unit='stage'] | ge:rewrite"/>
	<xsl:template match="comment()" priority="1"/>
	<!-- lb -> Leerzeichen -->
	<xsl:template match="lb">
		<xsl:if test="not(@break='no')">
			<xsl:text> </xsl:text>
		</xsl:if>
	</xsl:template>
	<xsl:strip-space
		elements="TEI teiHeader fileDesc titleStmt publicationStmt sourceDesc ge:transpose"/>
	<xsl:template match="ge:transpose/add/text()"/>
	<xsl:template match="choice[sic]">
		<xsl:apply-templates select="sic"/>
	</xsl:template>
	<!--<!-\- sample data for MC; to be moved at the end of procedures when reading text is finished -\->
						<xsl:template match="div/@n"/>
						<xsl:template match="orig | unclear">
							<xsl:apply-templates/>
						</xsl:template>
						<xsl:template match="l[@n='4625']">
							<l n="4625">
								<xsl:text>Sein Innres reinigt von verlebtem</xsl:text>
								<note type="textcrit">
									<it>
										<xsl:text>4625</xsl:text>
									</it>
									<xsl:text> Lemma] Variante </xsl:text>
									<it><xsl:text>Sigle</xsl:text></it>
								</note>
								<xsl:text>Graus.</xsl:text>
							</l>
						</xsl:template>-->


	
</xsl:stylesheet>
