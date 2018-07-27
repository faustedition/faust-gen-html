<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:j="http://www.faustedition.net/ns/json"
	exclude-result-prefixes="xs"
	version="2.0">
	
	<!-- 
	
	Utility stylesheet that converts an intermediate JSON representation to actual JSON.
	
	The following elements are recognized, all are expected to be in the namespace xmlns:j="http://www.faustedition.net/ns/json"
	
	Element        Content
	=============  ============================================================	
	<j:number/>    a valid json number as text content is directly copied
	<j:bool/>      a valid json bool as text content is directly copied
	<j:string/>    plain-text, which is quoted and included.
	<j:array/>     j:* elements that form the array's content, @dropempty -> nothing for empty element
	<j:object/>    j:* elements with a name attribute that form the array's content.
	

	Each element that appears as a child of the <j:object/> element MUST have an attribute "name" which
	contains the name of the corresponding item in the object structure. 
	
	The simple datatypes, j:number, j:bool, and j:string may also have a @value attribute. If they have 
	one, it is used as content. If there is also text content, it is dropped with a warning.
	
	All other attributes are ignored.
	
	All text content that does _not_ appear within j:number, j:bool, or j:string is dropped with a warning.
	
	" and \ inside the string values will be properly quoted. Newline sequences etc. will be sanitized, 
	but there is no real whitespace normalization unless you do that yourself.
	
	-->
	
	
	
	<xsl:template match="j:array" name="j:array" as="xs:string?" mode="#default json">
		<xsl:param name="items" as="item()*">
			<xsl:apply-templates mode="json">
				<xsl:with-param name="j:object" select="false()" tunnel="yes"/>
			</xsl:apply-templates>
		</xsl:param>
		<xsl:param name="sep">,</xsl:param>
		<xsl:if test="not(empty($items) and @dropempty)">
			<xsl:variable name="key">
				<xsl:call-template name="j:key"/>
			</xsl:variable>
			<xsl:value-of select="concat($key, '[', string-join($items, $sep), ']')"/>			
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="j:object" as="xs:string" mode="#default json">
		<xsl:param name="items" as="item()*">
			<xsl:apply-templates mode="json">
				<xsl:with-param name="j:object" select="true()" tunnel="yes"></xsl:with-param>
			</xsl:apply-templates>
		</xsl:param>
		<xsl:param name="sep">,</xsl:param>
		<xsl:variable name="key">
			<xsl:call-template name="j:key"/>			
		</xsl:variable>
		<xsl:value-of select="concat($key, '{', string-join($items, $sep), '}')"/>
	</xsl:template>
	
	<xsl:template name="j:key">
		<xsl:param name="j:object" select="false()" tunnel="yes"/>
		<xsl:if test="$j:object">
			<xsl:choose>
				<xsl:when test="@name">
					<xsl:value-of select="concat(j:quote(@name), ':')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message terminate="no" select="concat('ERROR: ', name(.), ' inside  object ', .., ' needs name attribute at item ', .)"/>
					<xsl:value-of select="concat(j:quote(concat('!!!UNNAMED!!!', generate-id())), ':')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
	</xsl:template>
	
	<xsl:template name="j:simple" match="j:number|j:bool|j:string" mode="#default json">
		<xsl:param name="content" select="if (@value) then @value else ."/>
		<xsl:variable name="j_value" select="if (local-name(.) eq 'string') then j:quote($content) else if (normalize-space($content) != '') then $content else 'null'"/>
		<xsl:variable name="key">
			<xsl:call-template name="j:key"/>
		</xsl:variable>
		<xsl:if test="$content != '' or not(@dropempty='true')">
			<xsl:value-of select="concat($key, $j_value)"/>			
		</xsl:if>
		<xsl:if test="@value and normalize-space(.)">
			<xsl:message select="concat('WARNING: ', name(), ' contains both @value=', @value, 
				' and content=', normalize-space(.), '. Dropping content.')"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:function name="j:quote">
		<xsl:param name="s"/>
		<xsl:value-of select="concat('&quot;',
			replace(replace(replace($s, '[&#x9;&#xA;&#xD;]+ ?', ' '), '\\', '\\\\'), '&quot;', '\\&quot;'),
			'&quot;')"/>		
	</xsl:function>

	<xsl:template match="text()" mode="json">
		<xsl:if test="normalize-space(.)">
			<xsl:message select="concat('WARNING: Dropping garbage: ', normalize-space(.))"/>
		</xsl:if>
	</xsl:template>
	
	
</xsl:stylesheet>