<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.faustedition.net/ns"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs"
	version="2.0">	
	
	<xsl:param name="document"/>
	<xsl:param name="source"/>
	<xsl:variable name="baseprefix">faust://xml/</xsl:variable>
	<xsl:variable name="linkprefix">faust://xml/image-text-links/</xsl:variable>
	<xsl:variable name="imgprefix">faust://facsimile/</xsl:variable>
	<xsl:variable name="metadataprefix">document/</xsl:variable>
	
	<xsl:function name="f:json-string">
		<xsl:param name="s"/>
		<xsl:value-of select="concat('&quot;', replace(replace(normalize-space($s), '\\', '\\'), '&quot;', '\\&quot;'), '&quot;')"/>
	</xsl:function>
	
	<!-- Creates a string as key-value-pair. Generates the empty string if no value. -->
	<xsl:function name="f:s" as="xs:string">
		<xsl:param name="key"/>
		<xsl:param name="value"/>
		<xsl:param name="comma" as="xs:boolean"/>
		<xsl:variable name="result">
			<xsl:if test="$value">
				<xsl:text>"</xsl:text>
				<xsl:value-of select="$key"/>
				<xsl:text>":</xsl:text>
				<xsl:value-of select="f:json-string($value)"/>
				<xsl:if test="$comma">,</xsl:if>			
			</xsl:if>
			</xsl:variable>
		<xsl:value-of select="$result"/>
	</xsl:function>
	
	<xsl:function name="f:a" as="xs:string">
		<xsl:param name="key"/>
		<xsl:param name="values"/>
		<xsl:param name="comma" as="xs:boolean"/>
		<xsl:variable name="result">				
			<xsl:if test="count($values) > 0">
				<xsl:if test="$key">
					<xsl:text>"</xsl:text>
					<xsl:value-of select="$key"/>
					<xsl:text>":</xsl:text>
				</xsl:if>
				<xsl:text>[</xsl:text>
				<xsl:for-each select="$values">
					<xsl:value-of select="f:json-string(.)"/>
					<xsl:if test="position() != last()">,</xsl:if>
				</xsl:for-each>
				<xsl:text>]</xsl:text>
			</xsl:if>
		</xsl:variable>
		<xsl:value-of select="$result"/>
	</xsl:function>
	
	<xsl:template match="/*">
		<f:document>
			<xsl:text>{</xsl:text>
			<xsl:value-of select="f:s('document', replace($document, $metadataprefix, ''), true())"/>
			<xsl:if test="self::print"><xsl:value-of select="f:s('type', 'print', true())"/></xsl:if>
			<xsl:value-of select="f:s('base', replace(@xml:base, $baseprefix, ''), true())"/>
			<xsl:value-of select="f:s('text', (//textTranscript/@uri, 'null')[1], true())"/>
	
			<!-- ### sigils ### -->
			<xsl:text>"sigils":{</xsl:text>
				<xsl:value-of select="f:s('headNote', metadata/headNote, true())"/>
				<xsl:if test="metadata/subrepository">
					<xsl:value-of select="f:s('subRepository', metadata/subRepository, true())"/>			
				</xsl:if>
				<xsl:for-each select="metadata/idno[. != ('none', 'n.s.', 'n.a.')]">
					<xsl:value-of select="f:s(concat('idno_', @type), ., true())"/>
				</xsl:for-each>		
				<xsl:for-each select="metadata/subidno[. != ('none', 'n.s.', 'n.a.')]">
					<xsl:value-of select="f:s(concat('subidno_', @type), ., true())"/>
				</xsl:for-each>
				<xsl:value-of select="f:s('note_gsa_1', metadata/idno[@type='gsa_1']/following-sibling::*[1][self::note], true())"/>
				<xsl:value-of select="f:s('collection', metadata/collection[1], true())"/>
				<xsl:value-of select="f:s('repository', (metadata/repository, 'print')[1], false())"/>
			<xsl:text>},"page":[</xsl:text>
			<xsl:apply-templates select="//page"/>
			<xsl:text>]}</xsl:text>
		</f:document>
	</xsl:template>
	
	
	<xsl:template match="page">
		<xsl:text>{"doc":[</xsl:text>
		<xsl:apply-templates select="descendant::docTranscript"/>
		<xsl:text>]}</xsl:text>
		<xsl:if test="position() != last()">,</xsl:if>
	</xsl:template>
	
	<xsl:template match="docTranscript">
		<xsl:text>{</xsl:text>
		<xsl:if test="@uri">
			<xsl:value-of select="f:s('uri', @uri, true())"/>
			<xsl:variable name="transcript" select="doc(resolve-uri(@uri, replace(base-uri(.), $baseprefix, $source)))"/>
			<xsl:value-of select="f:s('imgLink', replace($transcript//tei:graphic[@mimeType = 'image/svg+xml']/@url, $linkprefix, ''), true())"/>
			<xsl:value-of select="f:a('img', for $t in $transcript//tei:graphic[not(@mimeType = 'image/svg+xml')]/@url return replace($t, $imgprefix, ''), false())"/>
		</xsl:if>
		<xsl:text>}</xsl:text>
	</xsl:template>
	
</xsl:stylesheet>