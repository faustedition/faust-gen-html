<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.tei-c.org/ns/1.0"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs"
	xmlns:f="http://www.faustedition.net/ns" 
	version="2.0">
	
	<!--
		This stylesheet adds additional metadata provided by parameters and extracted from
		document/**/*.xml to the transcript document. Metadata is copied mainly to the TEI 
		header. Rest of the document is passed through as is.
	-->
	
	<xsl:import href="utils.xsl"/>
	
	<!-- The root directory of the Faust XML data, corresponds to faust://xml/, needs to resolve -->
	<xsl:param name="source"/>
	
	<!-- The path to the metadata document, relative to $source -->
	<xsl:param name="documentURI"/>
	
	<!-- archivalDocument, print, or lesetext -->
	<xsl:param name="type" select="local-name($metadata/*[1])"/>
		
	<!-- Resolved faust:// URI of the textual transcript -->
	<xsl:param name="transcriptURI" select="resolve-uri($metadata//f:textTranscript/@uri, base-uri($metadata//f:textTranscript))"/>
		
	<!-- Base name of the textual transcript, used for naming generated files -->	
	<xsl:param name="transcriptBase" select="replace(replace($transcriptURI, '^.*/', ''), '\.(html|xml)$', '')"/>
	
	<!-- Canonical URI for the document. Defaults to faust://xml/$documentURI -->
	<xsl:param name="faustURI" select="concat('faust://xml/', $documentURI)"/>

	<xsl:param name="depth">2</xsl:param>
	<xsl:variable name="depth_n" select="number($depth)"/>
	

	<xsl:variable name="metadata">
		<xsl:variable name="path" select="resolve-uri($documentURI, $source)"/>
		<xsl:choose>
			<xsl:when test="doc-available($path)">
				<xsl:sequence select="doc($path)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:message select="concat('WARNING: No metadata for ', (: $type, ' ',:) $faustURI, ' at ', $path)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="archives" select="doc(resolve-uri('archives.xml', $source))"/>
	
	<xsl:variable name="splittable" select="f:is-splitable-doc(/)"/>
	
	<xsl:output method="xml" indent="yes"/>

	
	<!-- The first title in the titleStmt will be taken from the headNote, with #headNote -->
	<xsl:template match="titleStmt">
			<xsl:copy>
				<xsl:apply-templates select="@*"/>
				<title type="headNote" xml:id="headNote">
					<xsl:choose>
						<xsl:when test="$type = 'lesetext' and contains($faustURI, 'faust1')">Faust I</xsl:when>
						<xsl:when test="$type = 'lesetext' and contains($faustURI, 'faust2')">Faust II</xsl:when>
						<xsl:otherwise><xsl:value-of select="$metadata//f:headNote"/></xsl:otherwise>
					</xsl:choose>
				</title>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	
	<!-- 
		We add some idnos:
		
		#sigil – the faustedition sigil
		#fausturi – the faust:// uri to the document
		#fausttranscript – the base name of the textual transcript file
		
		also all idnos from the metadata with appropriate @type.
	
	-->
	<xsl:template match="fileDesc">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="node()"/>
			
			<xsl:variable name="sigil">
				<xsl:choose>
					<xsl:when test="$type = 'lesetext'">Lesetext</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$metadata//f:idno[@type='faustedition']"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			
			<idno type="faustedition" xml:id="sigil"><xsl:value-of select="$sigil"/></idno>
			<idno type="sigil_n" xml:id="sigil_n"><xsl:value-of select="replace(lower-case($sigil), '[ .*]', '')"/></idno>						
			<idno type="fausturi" xml:id="fausturi"><xsl:value-of select="$faustURI"/></idno>
			<idno type="fausttranscript" xml:id="fausttranscript"><xsl:value-of select="$transcriptBase"/></idno>
			
			<xsl:for-each select="$metadata//f:idno[. != 'none'][. != 'n.s.'][@type != 'faustedition']">
				<idno type="{@type}">
					<xsl:value-of select="."/>
				</idno>
			</xsl:for-each>
			
		</xsl:copy>
	</xsl:template>

	
	<!-- //TEI/@type will be print, archivalDocument, or lesetext -->
	<xsl:template match="TEI">
		<xsl:copy>
			<xsl:namespace name="f">http://www.faustedition.net/ns</xsl:namespace>
			<xsl:attribute name="type" select="$type"/>
			<xsl:variable name="repository" select="normalize-space(($metadata//f:repository)[1])"/>
			<xsl:attribute name="f:repository" select="$repository"/> <!-- FIXME -->
			<xsl:attribute name="f:repository-label" select="$archives//f:archive[@id=$repository]/f:name"/> <!-- FIXME -->
			<xsl:if test="$splittable">
				<xsl:attribute name="f:split">true</xsl:attribute>
			</xsl:if>
			<xsl:apply-templates select="@* except @type"/>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	
	<!-- f:section-div == this div will govern an own output file (section) -->
	<xsl:function name="f:section-div" as="xs:boolean">
		<xsl:param name="div"/>
		<xsl:value-of select="$splittable 
			and count($div/ancestor-or-self::div) = $depth_n
			or count($div/ancestor-or-self::div) lt $depth_n and not($div/descendant::div[f:section-div(.)])"/>
	</xsl:function>
	
	<!-- Scenes that are recognized get a f:scene and f:scene-label attribute -->
	<xsl:template match="div[f:section-div(.)]" priority="2">
		<xsl:variable name="scenedata">
			<xsl:call-template name="scene-data"/>
		</xsl:variable>		
		<xsl:copy>
			<xsl:attribute name="f:section" select="count(preceding::div[f:section-div(.)]) + 1"/>			
			<xsl:choose>
				<xsl:when test="$scenedata/*">
					<xsl:attribute name="f:scene" select="$scenedata//f:id"/>
					<xsl:call-template name="add-xmlid"><xsl:with-param name="id" select="concat('scene_', $scenedata//f:id)"/></xsl:call-template>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="add-xmlid"/>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:attribute name="f:scene-label">
				<xsl:variable name="stage" select="stage[1]"/>
				<xsl:variable name="raw-label">
					<xsl:choose>
						<xsl:when test="$type = 'lesetext' and $scenedata/*">
							<xsl:value-of select="$scenedata//f:title"/>
						</xsl:when>
						<xsl:when test="head">
							<xsl:value-of select="head[1]"/>
						</xsl:when>
						<xsl:when test="string-length($stage) le 60">
							<xsl:value-of select="$stage"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="replace($stage, '\..*$', '. …')"/>
						</xsl:otherwise>
					</xsl:choose>					
				</xsl:variable>
				<xsl:value-of select="f:normalize-space(f:normalize-print-chars($raw-label))"/>
			</xsl:attribute>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	

	<!-- Adds an XML id, but only if none is present at the context element. -->
	<xsl:template name="add-xmlid">
		<xsl:param name="id" select="generate-id()"/>
		<xsl:if test="not(@xml:id)">
			<xsl:attribute name="xml:id" select="$id"/>
		</xsl:if>
	</xsl:template>
	
	<!-- This deals with Acts: It finds the first labeled scene and calculates the act number. -->
	<xsl:template match="div" priority="1">
		<xsl:variable name="scenes" as="element()*">
			<xsl:for-each select=".//div[f:section-div(.)]">
				<xsl:call-template name="scene-data"/>
			</xsl:for-each>
		</xsl:variable>
		<xsl:variable name="first-scene" select="$scenes[1]"/>
		
		<xsl:choose>
			<xsl:when test="$first-scene and starts-with($first-scene/f:id, '2')">
				<xsl:copy>
					<xsl:variable name="act" select="tokenize($first-scene/f:id, '\.')[2]"/>
					<xsl:attribute name="f:act" select="$act"/>
					<xsl:attribute name="f:act-label" select="concat($act, '. Akt')"/>
					<xsl:call-template name="add-xmlid"><xsl:with-param name="id" select="concat('act_', $act)"/></xsl:call-template>					
					<xsl:apply-templates select="@*"/>
					<xsl:apply-templates/>
				</xsl:copy>
			</xsl:when>
			<xsl:otherwise>
				<xsl:next-match/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Any other div is just augmented with a generated id -->
	<xsl:template match="div|titlePage">
		<xsl:copy>
			<xsl:call-template name="add-xmlid"/>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
	</xsl:template>
	
	<!-- Remove suffixes like a/b/c from @n, cf. #50 -->
	<xsl:template match="*[f:hasvars(.)]/@n">
		<xsl:attribute name="n" select="string-join(
			for $n in tokenize(., '\s+')
			return replace($n, '(\d+)[a-z]$', '$1'),
			' ')"/>
	</xsl:template>
	
	
	<xsl:template match="/">
		<xsl:comment>
			
			Generated Document
			==================
			
			This XML document has been generated from the original transcript, losing details.
			Do not edit or re-use it, rather use the original transcript.
			
		</xsl:comment>
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="node()|@*">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
	
	
</xsl:stylesheet>
