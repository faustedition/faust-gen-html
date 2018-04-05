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
			<j:string name="sigil" value="{replace(normalize-space(//f:idno[@type='faustedition']), '\s+', '_')}"/>
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
				<xsl:apply-templates select="//page"/>
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
			<j:bool name="empty" value="{
				if (descendant::docTranscript[not(@uri)] and 
				       (descendant::comment()[contains(., 'leer')] 
					 or descendant::note[contains(., 'leer')])) 
				then 'true' else 'false'}"/>
		</j:object>
	</xsl:template>
	
	<xsl:template match="docTranscript">
		<j:object>
			<xsl:if test="@uri">
				<j:string name="uri" value="{@uri}"/>
				<xsl:variable name="transcript" select="doc(resolve-uri(@uri, replace(base-uri(.), $baseprefix, $source)))"/>
				<j:string name='imgLink' value="{replace($transcript//tei:graphic[@mimeType = 'image/svg+xml']/@url, $linkprefix, '')}"/>
				<j:array name="img">
					<xsl:for-each select="$transcript//tei:graphic[not(@mimeType = 'image/svg+xml')]/@url">
						<j:string value="{replace(., $imgprefix, '')}"/>
					</xsl:for-each>
				</j:array>				
			</xsl:if>
		</j:object>
	</xsl:template>
	
</xsl:stylesheet>