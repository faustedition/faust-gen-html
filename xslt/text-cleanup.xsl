<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns="http://www.tei-c.org/ns/1.0"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns:ge="http://www.tei-c.org/ns/geneticEditions"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	version="2.0">
	
	<!-- 
		Additional cleanup steps for preparing the reading text. 
	
		These steps are performed _after_ assembling the reading text from its main
		parts (assemble-reading-text.xsl), but _before_ the apparatus entries are
		applied (text-insert-app.xsl).
	-->

	<xsl:strip-space elements="TEI teiHeader fileDesc titleStmt publicationStmt sourceDesc ge:transpose choice"/>

	
	<!-- These elements are replaced with their respective content: -->
	<xsl:template match="
		  group 
		| l/hi[@rend='big'] 
		| seg[@f:questionedBy or @f:markedBy] 
		| c
		| damage
		| s
		| seg[@xml:id]
		| orig
		| sic
		| corr
		| profileDesc
		| creation
		| ge:transposeGrp
		| surplus
		| unclear
		| supplied
		| div//text
		| div//front
		| div//body
		| div//titlePage[titlePart[@n]]">
		<xsl:apply-templates/>
	</xsl:template>	
	
	<!-- These nodes are dropped, together with their content: -->
	<xsl:template match="
		  sourceDesc/* 
		| encodingDesc 
		| revisionDesc 
		| titlePage[not(descendant::titlePart[@n])] 
		| pb[not(@break='no')] 
		| fw 
		| hi/@status 
		| anchor 
		| join[@type='antilabe'] 
		| join[@result='sp'] 
		| join[@type='former_unit'] 
		| */@xml:space
		| div[@type='stueck' and not(.//l[@n])] 
		| lg/@type 
		| figure 
		| text[not(.//l[@n])] 
		| speaker/@rend 
		| stage[not(matches(@rend,'inline'))]/@rend
		| l/@rend 
		| l/@xml:id 
		| space[@type='typographical'] 
		| hi[not(matches(@rend,'antiqua')) and not(matches(@rend,'latin'))]/@rend
		| sp/@who 
		| note[@type='editorial'] 
		| ge:transpose[not(@ge:stage='#posthumous')] 
		| ge:stageNotes 
		| handNotes 
		| unclear/@cert 
		| lg/@xml:id 
		| addSpan[not(@ge:stage='#posthumous')]
		| milestone[@unit='group' or @unit='stage']
		| ge:rewrite
		| ge:transpose/add/text()
		| space[not(ancestor::div[@n='2'])]
		| div[@type='stueck']"/>

	<!-- Drop comments as well; this needs to override node() from above -->
	<xsl:template match="comment()" priority="1"/>
	
	<!-- lb -> space -->
	<xsl:template match="lb[not(ancestor::head)]">
		<xsl:if test="not(@break='no')">
			<xsl:text> </xsl:text>
		</xsl:if>
	</xsl:template>

	<xsl:template match="choice[sic]">
		<xsl:apply-templates select="sic/text()"/>
	</xsl:template>
	
	<xsl:template match="text/@type">
		<xsl:attribute name="type">lesetext</xsl:attribute>
	</xsl:template>
	
	<xsl:template match="div//titlePart">
		<head>
			<xsl:apply-templates select="@*, node()"/>
		</head>
	</xsl:template>
	
	<!-- The following post-processing steps need to be applied afterwards: -->
	<xsl:template match="/">
		<xsl:variable name="pass1"><xsl:apply-templates/></xsl:variable>		
		<xsl:variable name="pass2"><xsl:apply-templates mode="pass2" select="$pass1"/></xsl:variable>
		<xsl:apply-templates mode="pass3" select="$pass2"/>
	</xsl:template>
	
	<!-- Drop now-empty container elements -->
	<xsl:template mode="pass2"	match="
		  text[not(normalize-space(.))] 
		| front[not(normalize-space(.))]"/>
	
	<!-- Drop outer text containers -->
	<xsl:template mode="pass2" match="text[text]">
		<xsl:apply-templates mode="#current"/>
	</xsl:template>
	
	<!-- Further text fixes (that shouldn't collide with Ae transformation) -->
	
	<!-- Remove parentheses from stage directions -->
	<xsl:template mode="pass2" match="stage//text()">		
		<xsl:value-of select="replace(., '[()]', '')"/>
	</xsl:template>
	
	<!-- Add trailing . if stage direction does not end with a period -->
	<xsl:template mode="pass3" match="stage/node()[position()=last()]">		
		<xsl:choose>
			<xsl:when test="matches(string-join(parent::stage, ''), '\p{P}\s*$')">
				<!-- Ends with punctuation: just keep it as is -->
				<xsl:next-match/>
			</xsl:when>
			<xsl:when test="not(self::text())">
				<!-- Ends with an element etc.: Add period at end -->
				<xsl:next-match/>
				<xsl:text>.</xsl:text>
			</xsl:when>
			<xsl:when test="normalize-space(.) = ''">
				<!-- Ends with whitespace: Prefix with period -->
				<xsl:text>.</xsl:text>
				<xsl:next-match/>
			</xsl:when>
			<xsl:otherwise>
				<!-- Otherwise add period at end -->
				<xsl:next-match/>
				<xsl:text>.</xsl:text>
			</xsl:otherwise>
		</xsl:choose>	
	</xsl:template>
	
	<!-- Remove a trailing . from speaker and head and at end of / immediately after hi -->
	<xsl:template mode="pass2" match="speaker/text()[position()=last()]">
		<xsl:value-of select="replace(., '\.\s*$', '')"/>
	</xsl:template>
	
	<xsl:template mode="pass2" match="head/text()[position()=last()]">
		<xsl:value-of select="replace(., '\.\s*$', '')"/>
	</xsl:template>
	
	<xsl:template mode="pass2" match="stage//hi/text()[position()=last()]">
		<xsl:value-of select="replace(., '\.$', '')"/>
	</xsl:template>
	
	<xsl:template mode="pass2" match="stage//text()[preceding-sibling::node()[1][self::hi]]" priority="1">
		<xsl:variable name="prep"><xsl:next-match/></xsl:variable>
		<xsl:value-of select="replace($prep, '^\.', '')"/>
	</xsl:template>
	
	<!-- The following fixes are eventually to be implemented in all source files: -->
	<xsl:template match="stage/emph">
		<xsl:element name="hi">
			<xsl:apply-templates select="@*, node()"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="name">
		<xsl:element name="hi">
			<xsl:apply-templates select="@*, node()"/>
		</xsl:element>
	</xsl:template>
	
	<xsl:template match="sp[stage[not(following-sibling::*)]]">
		<xsl:next-match/>
		<xsl:for-each select="stage[not(following-sibling::*)]">
			<xsl:copy>
				<xsl:apply-templates select="@*, node()"/>
			</xsl:copy>
		</xsl:for-each>
	</xsl:template>
	<xsl:template match="sp/stage[not(following-sibling::*)]"/>

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

	<xsl:template match="text()" priority="0.5">
		<xsl:value-of select="replace(replace(replace(., 'Ae', 'Ä'), 'Oe', 'Ö'), 'Ue', 'Ü')"/>
	</xsl:template>

	<xsl:template match="processing-instruction('oxygen')|processing-instruction('xml-model')">
		<xsl:processing-instruction name="xml-model">href="http://dev.digital-humanities.de/ci/job/faust-schema/lastSuccessfulBuild/artifact/target/schema/faust-tei.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction>
		<xsl:processing-instruction name="xml-model">href="http://dev.digital-humanities.de/ci/job/faust-schema/lastSuccessfulBuild/artifact/target/schema/faust-tei.sch" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:processing-instruction>		
	</xsl:template>

	<!-- Keep everything else as is -->
	<xsl:template match="node()|@*" mode="#all">
		<xsl:copy copy-namespaces="no">
			<xsl:apply-templates select="@*, node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	
</xsl:stylesheet>