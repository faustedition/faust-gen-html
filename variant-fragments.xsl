<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	xmlns:f="http://www.faustedition.net/ns"
	exclude-result-prefixes="xs f"
	version="2.0">
		
	<xsl:include href="html-common.xsl"/>
	
	<xsl:param name="variants">variants/</xsl:param>
	<xsl:param name="docbase">https://faustedition.uni-wuerzburg.de/new</xsl:param>
  	<xsl:param name="type"/>
	<xsl:param name="depth">2</xsl:param>
		
	
	<xsl:output method="xhtml"/>
	
	<xsl:function name="f:varcount">
		<xsl:param name="group"/>
		<xsl:variable name="part" select="$group[1]/@part"/>
		<xsl:variable name="name" select="name($group[1])"/>
		<xsl:value-of select="if ($part) then count($group[@part=$part and name()=$name]) else count($group[name()=$name])"/>
	</xsl:function>
	
	<xsl:template match="/*">		
		<xsl:for-each-group select="*" group-by="f:output-group(@n)">
			<xsl:variable name="output-file" select="concat($variants, current-grouping-key(), '.html')"/>			
			<xsl:result-document href="{$output-file}">
				<div class="groups" data-group="{current-grouping-key()}">
					<xsl:for-each-group select="current-group()" group-by="@n">
						<div class="variants" data-n="{current-grouping-key()}" 
							data-size="{f:varcount(current-group())}" xml:id="v{current-grouping-key()}" id="v{current-grouping-key()}">
							<xsl:for-each-group select="current-group()" group-by="normalize-space(.)">
								
									<xsl:apply-templates select="current-group()[1]">
										<xsl:sort select="@f:sigil"/>
										<xsl:with-param name="group" select="current-group()"/>
									</xsl:apply-templates>
								
							</xsl:for-each-group>
						</div>
					</xsl:for-each-group>
				</div>
			</xsl:result-document>
		</xsl:for-each-group>
	</xsl:template>
	
	<!-- 
		Will format the lines inside the variant group. The context node is the first
		entry of a group of lines with identical text, the $group parameter contains 
		the whole group. 
	-->
	<xsl:template match="*[@n]">
		<xsl:param name="group" as="node()*"/>
		<div class="{string-join(f:generic-classes(.), ' ')}" 
			data-n="{@n}" data-source="{@f:doc}">
			<xsl:call-template name="generate-style"/>
			
			<!-- first format the line's content ... -->
			<xsl:apply-templates/>
			
			<!-- now there's the list of sigils where this line is featured. -->
			<xsl:text> </xsl:text>
			<span class="sigils"> <!-- will float right -->
				<xsl:for-each select="$group">
					<xsl:variable name="target">						
						<xsl:choose>
							<xsl:when test="@f:type='archivalDocument'">
								<xsl:value-of select="concat($docbase, '/', @f:doc)"/>
								<xsl:if test="@f:page">
									<xsl:value-of select="concat('&amp;page=', @f:page)"/>
								</xsl:if>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="f:printlink(@f:href, @n)"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<a class="sigil" href="{$target}" title="{f:sigil-label(@f:sigil-type)}">
						<xsl:value-of select="@f:sigil"/>
					</a>
					<xsl:if test="position() lt count($group)">
						<xsl:text>, </xsl:text>
					</xsl:if>
				</xsl:for-each>
			</span>
		</div>
	</xsl:template>

	<xsl:function name="f:printlink">
		<xsl:param name="transcript"/>
		<xsl:param name="n"/>
		
		<xsl:variable name="split" select="f:is-splitable-doc(document($transcript))"/>
		<xsl:variable name="targetpart">
			<xsl:choose>
				<xsl:when test="$split">
					<xsl:variable name="div" select='document($transcript)//*[@n = $n 
						and not(self::pb or self::div or self::milestone[@unit="paralipomenon"] or self::milestone[@unit="cols"] or @n[contains(.,"todo")] or @n[contains(.,"p")])]/ancestor::div'/>
					<xsl:if test="$div">
						<xsl:text>.</xsl:text>
						<xsl:number 
							select="$div[1]"
							level="any"
							from="TEI"						
						/>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>.</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:value-of select="concat(
			replace($transcript, '^.*/(.*)\.xml$', '$1'), $targetpart, '.html#l', $n)"/>
	</xsl:function>
	
	<xsl:template match="*">
		<xsl:element name="{f:html-tag-name(.)}">
			<xsl:attribute name="class" select="string-join(f:generic-classes(.), ' ')"/>			
			<xsl:apply-templates/>
		</xsl:element>		
	</xsl:template>
	
</xsl:stylesheet>
