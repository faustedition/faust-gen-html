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
		
		
		This adds the following information:
		
		/TEI/@f:repository        The repository ID that holds the archival document
		/TEI/@f:repository-label  its label
		/TEI/@f:split             true if this doc is to be split into multiple components
		/TEI/@f:number            numbering passed in (i.e. order of sigils)
		/TEI/@f:index             numbering by macrogenesis
		
		//idno                    for every idno from the metadata
		//idno/@type='headNote'   for the headNote
		//idno/@type='fausturi'   for the full faust:// uri to the document
		//idno/@type='fausttranscript' for the transcript's basename
		//idno/@type='sigil_n'    for the 'shortened minimal' sigil      FIXME
		
		Attributes for divs:
		f:act                     act number if it's an act div¹             
		f:act-label               act label if it's an act div¹               split:211f
		f:scene                   scene number if it's a scene¹               html-common:22
		                                                                      split:133
		f:scene-label             scene label if it's a scene¹                html-common:21-75
		                                                                      search-results:102
		                                                                      split:211f
		                                                                      fts4.xql:90
		                                                                      
		   ¹ these might be merged to n and f:label, respectively		
		f:first-verse             first Schröer verse number in the div
		f:last-verse              last Schröer verse number in the div
		f:min-verse               smallest Schröer verse number in the div
		f:max-verse               largest Schröer verse number in the div

		
		f:verse-range			  nominal verse range from the scene info
		
		f:section                 if /TEI/@f:split is true, this is the section
		                          number that this div indicates.
		
		//l/@f:schroer            Schröer verse number if available 
		
		
		
		
		From resolve-pbs.xsl:
		//pb/@f:docTranscriptNo   number of the document transcript corresponding to that page
		
	-->
	
	
	<xsl:import href="emend-core.xsl"/>
	
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
	
	<xsl:param name="number"/>
	
	<xsl:param name="sigil_t" select="f:sigil-for-uri($metadata//f:idno[@type='faustedition'])"/>

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
			<xsl:comment>fileDesc, existierend</xsl:comment>
			<xsl:apply-templates select="node()"/>
			<xsl:comment>/fileDesc, existierend</xsl:comment>
			
			<xsl:variable name="sigil">
				<xsl:choose>
					<xsl:when test="$type = 'lesetext'">Lesetext</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$metadata//f:idno[@type='faustedition']"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
						
			
			<idno type="faustedition" xml:id="sigil"><xsl:value-of select="$sigil"/></idno>
			<xsl:if test="$type != 'lesetext'">
				<idno type="headNote"><xsl:value-of select="$metadata//f:headNote"/></idno>				
			</xsl:if>
			
			<xsl:for-each select="$metadata//f:idno[. != 'none'][. != 'n.s.'][@type != 'faustedition']">
				<idno type="{@type}">
					<xsl:value-of select="."/>
				</idno>
			</xsl:for-each>

			<idno type="sigil_t" xml:id="sigil_t"><xsl:value-of select="$sigil_t"/></idno>
			<idno type="sigil_n" xml:id="sigil_n"><xsl:value-of select="replace(lower-case($sigil), '[ .*]', '')"/></idno>						
			<idno type="fausturi" xml:id="fausturi"><xsl:value-of select="$faustURI"/></idno>
			<idno type="fausttranscript" xml:id="fausttranscript"><xsl:value-of select="if ($type='lesetext') then 'faust' else $transcriptBase"/></idno>
			
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
			<xsl:if test="$number"><xsl:attribute name="f:number" select="if ($sigil_t = 'faust') then 0 else $number"/></xsl:if>
			<xsl:attribute name="f:index" select="f:get-order-info($sigil_t)/@index"/>
			<xsl:apply-templates select="@* except (@type, @n)"/>
			<xsl:comment><xsl:value-of select="$sigil_t"/></xsl:comment>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
	</xsl:template>
	
	<!-- 
		
		Revamped <div> handling.
		
		<div>s that are to be written to a separate file get a f:section attribute.
		<div>s that are recognized get f:scene and f:scene-label attributes
		
	-->
		
	
	<!-- f:section-div == this div will govern an own output file (section) -->
	<xsl:function name="f:section-div" as="xs:boolean">
		<xsl:param name="div"/>
		<xsl:value-of select="$splittable and 
			(if ($div/@type) 
				then $div/@type=('scene') and not($div/descendant::div[f:section-div(.)]) 
				else  (count($div/ancestor-or-self::div) = $depth_n
					or count($div/ancestor-or-self::div) lt $depth_n and not($div/descendant::div[f:section-div(.)])))"/>
	</xsl:function>
	
	<xsl:template match="text">
		<xsl:variable name="content">
			<xsl:apply-templates select="node()"/>
		</xsl:variable>
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:attribute name="f:first-verse" select="($content//*/@f:schroer)[1]"/>			
			<xsl:attribute name="f:last-verse" select="($content//*/@f:schroer)[last()]"/>
			<xsl:variable name="linenos" select="for $attr in $content//*/@f:schroer return for $n in tokenize($attr, '\s+') return xs:integer($n)"/>
			<xsl:attribute name="f:min-verse" select="min($linenos)"/>
			<xsl:attribute name="f:max-verse" select="max($linenos)"/>
			<xsl:sequence select="$content"/>
		</xsl:copy>
	</xsl:template>
	
	
	<!-- one template to rule them all -->
	<xsl:template match="div" priority="5" mode="pass2">
		<xsl:variable name="content" select="node()"/>		
		<xsl:variable name="first-verse" select="($content//*/@f:schroer)[1]"/>
		<xsl:variable name="last-verse" select="($content//*/@f:schroer)[last()]"/>
		<xsl:variable name="linenos" select="for $attr in $content//*/@f:schroer return for $n in tokenize($attr, '\s+') return number($n)"/>
		<xsl:variable name="scene" select="f:get-scene-info(.)"/>
		
		<!-- Attributes: f:section, f:first-verse f:last-verse, f:act?, f:scene?, f:label, n, xml:id, f:verse-range -->
		
		<xsl:copy>
			<xsl:if test="f:section-div(.)">
				<xsl:attribute name="f:section" select="count(preceding::div[f:section-div(.)]) + 1"/>
				<xsl:if test="$scene/descendant-or-self::*/@f:min-verse">
					<xsl:attribute name="f:verse-range" separator=" "
												 select="($scene/descendant-or-self::*/@f:min-verse)[1], 
												 				 ($scene/descendant-or-self::*/@f:max-verse)[position()=last()]"/>
				</xsl:if>
			</xsl:if>
			
			<xsl:choose>
				<xsl:when test="$scene">
					<xsl:attribute name="n" select="$scene/@n"/>
					<xsl:call-template name="add-xmlid">
						<xsl:with-param name="id" select="concat(local-name($scene), '_', $scene/@n)"/>
					</xsl:call-template>					
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="add-xmlid"/>
				</xsl:otherwise>
			</xsl:choose>
			
			<xsl:attribute name="f:label">
				<xsl:choose>
					<xsl:when test="$type = 'lesetext' and $scene/f:title">
						<xsl:value-of select="$scene/f:title"/>
					</xsl:when>
					<xsl:when test="$type = 'lesetext' and local-name($scene) = 'act'">
						<xsl:variable name="act" select="tokenize($scene/@n, '\.')[2]"/>
						<xsl:number format="I." ordinal="true" value="$act"/><xsl:text> Akt</xsl:text>
					</xsl:when>
					<xsl:otherwise><xsl:call-template name="extract-scene-label"/></xsl:otherwise>
				</xsl:choose>				
			</xsl:attribute>
			
			<xsl:if test="$first-verse">
				<xsl:attribute name="f:first-verse" select="$first-verse"/>
				<xsl:attribute name="f:last-verse" select="$last-verse"/>
				<xsl:attribute name="f:min-verse" select="min($linenos)"/>
				<xsl:attribute name="f:max-verse" select="max($linenos)"/>
			</xsl:if>
						
			<xsl:apply-templates select="@* except @n" mode="#current"/>
			<xsl:apply-templates select="node()" mode="#current"/>
			
		</xsl:copy>
	</xsl:template>
	
	<!-- extracts the scene label from the heading -->
	<xsl:template name="extract-scene-label">
		<xsl:variable name="raw-label" select="(head, stage, sp, *)[1]"/>
		<xsl:variable name="emended-label">
			<xsl:apply-templates mode="emend" select="$raw-label"/>
		</xsl:variable>
		<xsl:variable name="text-label" select="
			if ($raw-label/head or string-length($emended-label) le 60)
			then $emended-label
			else replace($emended-label, '\..*$', '. …')"/>
		<xsl:value-of
			select="f:normalize-space(f:normalize-print-chars($text-label))"
		/>		
	</xsl:template>
	
	<xsl:template match="lb[not(@break='no')]" mode="emend"><xsl:text> </xsl:text></xsl:template>

	<!-- Adds an XML id, but only if none is present at the context element. -->
	<xsl:template name="add-xmlid">
		<xsl:param name="id" select="generate-id()"/>
		<xsl:if test="not(@xml:id)">
			<xsl:attribute name="xml:id" select="$id"/>
		</xsl:if>
	</xsl:template>
	
	
	<!-- Any other div is just augmented with a generated id -->
	<xsl:template match="titlePage">
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
	
	<xsl:template match="*[f:is-schroer(.)]">
		<xsl:copy>
			<xsl:variable name="display-linenos" select="for $token in tokenize(@n, '\s+') return f:lineno-for-display($token)"/>				
			<xsl:attribute name="f:schroer" select="string-join(for $n in $display-linenos return if ($n = 0) then () else $n, ' ')"/>
			<xsl:apply-templates select="@*, node()"/>
		</xsl:copy>
	</xsl:template>
	
	
	<!-- Remove editorial notes. Cf. #88. Probably needs better solution some time, -->
	<xsl:template match="note[@type='editorial']">
		<xsl:comment>note type='editorial'
			<xsl:copy-of select="."/>
		</xsl:comment>
	</xsl:template>
	
	
	<xsl:template match="/">
		<xsl:comment>
			
			Generated Document
			==================
			
			This XML document has been generated from the original transcript, losing details.
			Do not edit or re-use it, rather use the original transcript.
			
		</xsl:comment>
		<xsl:variable name="pass1">
			<xsl:apply-templates/>			
		</xsl:variable>
		<xsl:apply-templates mode="pass2" select="$pass1"/>
	</xsl:template>
	
	<xsl:template match="node()|@*" mode="#default pass2">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="#current"/>
		</xsl:copy>
	</xsl:template>
	
	
</xsl:stylesheet>
