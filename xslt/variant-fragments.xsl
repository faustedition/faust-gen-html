<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xh="http://www.w3.org/1999/xhtml"
	xmlns:ge="http://www.tei-c.org/ns/geneticEditions"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:f="http://www.faustedition.net/ns"
	exclude-result-prefixes="xs f tei xh ge"
	version="2.0">
		
	<xsl:include href="html-common.xsl"/>
	
	<xsl:param name="variants">variants/</xsl:param>
	<xsl:param name="docbase">https://faustedition.uni-wuerzburg.de/new</xsl:param>  	
	<xsl:param name="depth">2</xsl:param>
	<xsl:param name="canonical">document/print/A8.xml document/faust/2/gsa_391098.xml</xsl:param>
	<xsl:variable name="canonicalDocs" select="tokenize($canonical, ' ')"/>
	
	<xsl:variable name="standoff" as="element()*">
		<f:standoff>
			<xsl:sequence select="//f:standoff/*"/>
		</f:standoff>
	</xsl:variable>
		
	
	<xsl:output method="xhtml"/>
		
	<xsl:template match="/f:variants">
		<xsl:for-each-group select="*" group-by="f:raw-output-group(@n)">
			<!-- eine Ausgabedatei für ca. 10 kanonische Zeilen -->		
			<xsl:variable name="output-file" select="concat($variants, current-grouping-key(), '.html')"/>			
			<xsl:result-document href="{$output-file}">
				<div class="groups" data-group="{current-grouping-key()}">
					<xsl:for-each-group select="current-group()" group-by="tokenize(@n, '[ ,;\t\n]+')">
						<xsl:call-template name="create-single-variants">
							<xsl:with-param name="current-lines" select="current-group()"/>
							<xsl:with-param name="current-n" select="current-grouping-key()"/>
						</xsl:call-template>
					</xsl:for-each-group>
				</div>
			</xsl:result-document>
		</xsl:for-each-group>
	
		<!-- additional apparatus for @n with multiple values (cf. #51) -->
		<xsl:variable name="output-file" select="concat($variants, '_.html')"/>
		<xsl:result-document href="{$output-file}">
			<div class="groups" data-group="_">
				<xsl:for-each-group select="//*[f:hasvars(.) and contains(@n, ' ') and not(contains(@n, 'before'))]" group-by="@n">
					<xsl:variable name="ns" select="tokenize(current-grouping-key(), '\s+')"/>
					<xsl:variable name="current-lines" as="element()*">
						<xsl:sequence select="current-group()"/>
						<xsl:call-template name="join-lines">
							<xsl:with-param name="ns" select="$ns"/>								
						</xsl:call-template>
					</xsl:variable>
					<xsl:call-template name="create-single-variants">
						<xsl:with-param name="current-n" select="string-join($ns, '_')"/>
						<xsl:with-param name="current-lines" select="$current-lines"/>
					</xsl:call-template>										
				</xsl:for-each-group>
			</div>
		</xsl:result-document>		
	</xsl:template>

	<!-- 
		
		Creates the HTML fragment for a group of lines corresponding to a specific @n.
		
		Parameters:
			current-lines: Sequence of nodes with that @n
			current-n: @n
	
	-->
	<xsl:template name="create-single-variants">
		<xsl:param name="current-lines" as="node()*" select="current-group()"/>
		<xsl:param name="current-n" select="current-grouping-key()"/>
		<xsl:variable name="evidence">
			<xsl:sequence select="$standoff"/>
			<xsl:for-each-group select="$current-lines" group-by="@f:doc">
				<f:evidence>
					<xsl:copy-of select="current-group()[1]/@*"/>
					<xsl:copy-of select="current-group()"/>
				</f:evidence>
			</xsl:for-each-group>
		</xsl:variable>
		<xsl:variable name="cline" select="$current-lines[@f:doc = $canonicalDocs]"/>
		<xsl:variable name="ctext"
			select="
			if ($cline) then
			f:normalize-space($cline[1])
			else
			''"/>
		<div class="variants" data-n="{current-grouping-key()}"
			data-witnesses="{count($evidence/* except $evidence/*[@f:type='lesetext'] except $evidence/f:standoff)}"
			data-variants="{count(distinct-values(for $ev in $evidence/* except $evidence/f:standoff return f:normalize-space($ev)))-1}"
			data-ctext="{$ctext}" id="v{$current-n}">
			<xsl:attribute name="xml:id" select="concat('v', $current-n)"/>
			<xsl:for-each-group select="$evidence/*" group-by="f:normalize-space(.)">
				<xsl:apply-templates select="current-group()[1]/*">
					<!--<xsl:sort select="@f:sigil"/>-->
					<!-- Sorting is done in collect-metadata.xpl, we just keep the document order from there -->
					<xsl:with-param name="group" select="current-group()"/>
				</xsl:apply-templates>

			</xsl:for-each-group>
		</div>
	</xsl:template>
	
	<xsl:template match="f:evidence">
		<xsl:param name="group"/>
		<xsl:apply-templates>
			<xsl:with-param name="group" select="$group"/>
		</xsl:apply-templates>
	</xsl:template>
	
	<!-- 
		Will format the lines inside the variant group. The context node is the first
		entry of a group of lines with identical text, the $group parameter contains 
		the whole group. 
	-->
	<xsl:template match="*[f:hasvars(.)]" priority="1">
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
					<xsl:variable 
						name="target" 
						select="if (@f:type='archivalDocument') 
									then f:doclink(@f:doc, @f:page, @n) 
									else concat($printbase, @f:section, '#l', @n)"/>						
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

	<!-- 
		when called with $ns=('3356', '3357'), this template creates an artificial 
		<l n='3356 3357'>Content of 3356 | Content of 3357</l>
		for each document that contains <l n="3356"> and <l n="3357">
	-->
	<xsl:template name="join-lines">
		<xsl:param name="ns" as="xs:string*"/>
		<xsl:for-each-group select="//*[@n = $ns]" group-by="@f:doc">			
			<xsl:variable name="template" select="current-group()[1]" as="node()"/>
			<xsl:variable name="rest" select="subsequence(current-group(), 2)" as="node()*"/>
			<xsl:element name="{name($template)}">
				<xsl:attribute name="n" select="string-join($ns, ' ')"/>
				<xsl:copy-of select="$template/@* except $template/@n"/>
				<xsl:copy-of select="$template/node()"/>
				<xsl:for-each select="$rest">
					<span xmlns="http://www.w3.org/1999/xhtml" class="generated-text"> | </span>
					<xsl:copy-of select="./node()"/>
				</xsl:for-each>
			</xsl:element>
		</xsl:for-each-group>
	</xsl:template>
		
</xsl:stylesheet>
