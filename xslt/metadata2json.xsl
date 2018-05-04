<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.faustedition.net/ns"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns:j="http://www.faustedition.net/ns/json"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs"
	version="2.0">

	<xsl:import href="jsonutils.xsl"/>
	<xsl:import href="utils.xsl"/>
	
	<xsl:param name="document"/>
	<xsl:param name="source"/>
	<xsl:param name="builddir">../../../../target/</xsl:param>
	<xsl:param name="builddir-resolved" select="resolve-uri($builddir)"/>
	<xsl:variable name="baseprefix">faust://xml/</xsl:variable>
	<xsl:variable name="linkprefix">faust://xml/image-text-links/</xsl:variable>
	<xsl:variable name="imgprefix">faust://facsimile/</xsl:variable>
	<xsl:variable name="metadataprefix">faust://xml/document/</xsl:variable>
	
	<!-- Iterate over collection. -->	
	<xsl:template name="collection">
		<xsl:variable name="documents">
			<xsl:for-each select="collection()/*">
				<xsl:call-template name="document"/>
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:variable name="json">
			<j:object>
				<j:array name="metadata">
					<xsl:perform-sort select="$documents/*">
						<xsl:sort select="f:splitSigil(@sigil)[1]"/>
						<xsl:sort select="f:splitSigil(@sigil)[2]"/>
						<xsl:sort select="f:splitSigil(@sigil)[3]"/>
					</xsl:perform-sort>
				</j:array>
				<j:string name="metadataPrefix" value="{$metadataprefix}"/>
				<j:string name="linkPrefix" value="{$linkprefix}"/>
				<j:string name="imgPrefix" value="{$imgprefix}"/>
				<j:string name="printPrefix" value="faust://xml/print/"/>
				<j:string name="basePrefix" value="faust://xml/"/>
			</j:object>
		</xsl:variable>
		
		<!-- f:json is required for XProc processing, will be removed by p:store -->
		<f:json>
			<xsl:text>var documentMetadata = &#10;</xsl:text>
			<xsl:apply-templates select="$json/*">
				<xsl:with-param name="sep">,&#10;</xsl:with-param>
			</xsl:apply-templates>			
		</f:json>
	</xsl:template>
	
	
	<!-- Only used when run directly against a document -->
	<xsl:template match="/f:*">		
		<xsl:variable name="json">
			<xsl:call-template name="document"/>			
		</xsl:variable>
		<f:document>
			<xsl:apply-templates select="$json/*"/>			
		</f:document>
	</xsl:template>


	<xsl:template name="document">
		<j:object sigil="{//f:idno[@type='faustedition']}">
			<xsl:variable name="sigil_t" select="f:sigil-for-uri(//f:idno[@type='faustedition'])"/>
			<j:string name="sigil" value="{$sigil_t}"/>
			<j:string name="document"><xsl:value-of select="replace(document-uri(/), concat($source, 'document/'), '')"/></j:string>
			<xsl:if test="self::print">
				<j:string name="type">print</j:string>
			</xsl:if>
			<j:string name="base" value="{replace(@xml:base, $baseprefix, '')}"/>
			<j:string name="text" value="{(//textTranscript/@uri, 'null')[1]}"/>
			
			<j:object name="sigils">
				<!-- Yes, these aren't all real sigils ... -->
				<j:string name="headNote" value="{metadata/headNote}"/>
				<j:string name="classification" value="{if (metadata/classification = ('n.s.', 'none', '')) then '' else metadata/classification}"/>
				<xsl:if test="metadata/subrepository">
					<j:string name="subRepository" value="{metadata/subRepository}"/>
				</xsl:if>
				<xsl:for-each select="metadata/idno[. != ('none', 'n.s.', 'n.a.')]">
					<j:string name="idno_{@type}" value="{.}"/>
				</xsl:for-each>
				<xsl:for-each select="metadata/subidno[. != ('none', 'n.s.', 'n.a.')]">
					<j:string name="subidno_{@type}" value="."/>
				</xsl:for-each>
				<j:string name='note_gsa_1' value="{metadata/idno[@type='gsa_1']/following-sibling::*[1][self::note]}"/>
				<j:string name='collection' value="{metadata/collection[1]}"/>
				<j:string name='repository' value="{(metadata/repository, 'print')[1]}"/>
			</j:object>
			<j:array name="page">
				<xsl:choose>
					<xsl:when test="self::print">
						<xsl:call-template name="print-pages"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="//page"/>						
					</xsl:otherwise>
				</xsl:choose>
			</j:array>
		</j:object>
	</xsl:template>

	<xsl:template match="page">
		<j:object>
			<j:array name="doc">
				<xsl:apply-templates select="descendant::docTranscript"/>
				<xsl:if test="count(descendant::docTranscript) > 1">
					<xsl:message select="concat('ATTN: ', document-uri(/), ' has multiple doc transcripts for a page: ', 
						string-join(descendant::docTranscript/@uri, ', '))"/>
				</xsl:if>
			</j:array>
			<xsl:if test="//textTranscript">
				<xsl:variable name="docTranscriptNo" as="xs:double"><xsl:number from="/*" level="any"/></xsl:variable>
				<xsl:variable name="sigil_t" select="f:sigil-for-uri(//idno[@type='faustedition'][1])"/>
				<xsl:variable name="textTranscript" select="doc(resolve-uri(concat('prepared/textTranscript/', $sigil_t, '.xml'), $builddir-resolved))"/>
				<xsl:variable name="pb" select="($textTranscript//tei:pb[@f:docTranscriptNo and number(@f:docTranscriptNo) ge $docTranscriptNo])[1]" as="node()?"/>
				<xsl:variable name="section" select="f:get-section-number($pb[1])"/> <!-- select="($pb/ancestor::*[@f:section])[1]/@f:section"/> -->
				<xsl:variable name="div" select="($pb/ancestor::*[self::tei:div or self::tei:text][@n])[1]/@n"/>
				<xsl:if test="$section"><j:number name="section" value="{$section}"/></xsl:if>
				<xsl:if test="$div"><j:string name="div" value="{$div}"/></xsl:if>
			</xsl:if>		
			<j:bool name="empty" value="{
				if (descendant::docTranscript[not(@uri)] and 
				       (descendant::comment()[contains(., 'leer')] 
					 or descendant::note[contains(., 'leer')])) 
				then 'true' else 'false'}"/>
		</j:object>
	</xsl:template>
	
	<xsl:template name="print-pages">
		<xsl:variable name="sigil_t" select="f:sigil-for-uri(//idno[@type='faustedition'][1])"/>
		<xsl:variable name="preparedTranscript" select="resolve-uri(concat('prepared/textTranscript/', $sigil_t, '.xml'), $builddir-resolved)"/>
		<xsl:choose>
			<xsl:when test="doc-available($preparedTranscript)">				
				<xsl:variable name="textTranscript" select="doc($preparedTranscript)"/>
				<xsl:variable name="prefix" select="concat('print/', replace(//textTranscript/@uri, '\.xml$', ''), '/')"/>
				<xsl:for-each select="$textTranscript//tei:pb">
					<xsl:variable name="section" select="(ancestor::*[@f:section])[1]/@f:section"/>
					<xsl:variable name="div" select="(ancestor::*[self::tei:div or self::tei:text][@n])[1]/@n"/>			
					<j:object>
						<j:array name="doc">
							<j:object>
								<j:array name="img">							
									<xsl:for-each select="tokenize(@facs, '\s+')">
										<xsl:sort select="."/>
										<j:string value="{concat($prefix, replace(., '\.tiff?$', ''))}"/>
									</xsl:for-each>							
								</j:array>
							</j:object>
						</j:array>
						<xsl:if test="$section"><j:number name="section" value="{$section}"/></xsl:if>
						<xsl:if test="$div"><j:string name="div" value="{$div}"/></xsl:if>				
					</j:object>
				</xsl:for-each>		
			</xsl:when>
			<xsl:otherwise>
				<xsl:message select="concat('WARNING: ', $sigil_t, ': ', $preparedTranscript, ' not found')"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="docTranscript">
		<j:object>
			<xsl:if test="@uri">
				<j:string name="uri" value="{@uri}"/>
				<xsl:variable name="transcript" select="doc(resolve-uri(@uri, replace(base-uri(.), $baseprefix, $source)))"/>
				<j:string name='imgLink' value="{replace($transcript//tei:graphic[@mimeType = 'image/svg+xml']/@url, $linkprefix, '')}"/>
				<j:array name="img">
					<xsl:for-each select="$transcript//tei:graphic[not(@mimeType = 'image/svg+xml')]/@url">
						<xsl:sort select="."/>
						<j:string value="{replace(., $imgprefix, '')}"/>
					</xsl:for-each>
				</j:array>
			</xsl:if>
		</j:object>
	</xsl:template>
	
</xsl:stylesheet>