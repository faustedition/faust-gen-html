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
		
	<xsl:include href="apparatus.xsl"/>
	
	<xsl:param name="canonical">faust</xsl:param>
	<xsl:variable name="canonicalDocs" select="tokenize($canonical, ' ')"/>
	<xsl:param name="order-url">http://dev.digital-humanities.de/ci/view/Faust/job/faust-macrogen/lastSuccessfulBuild/artifact/target/macrogenesis/order.xml</xsl:param>
	<xsl:variable name="order" select="doc($order-url)"/>
	
	<xsl:function name="f:get-wit-index">
		<xsl:param name="sigil_t"/>
		<xsl:param name="extra"/>
		<xsl:variable name="el" select="$order//f:item[@sigil_t = $sigil_t]"/>
		<xsl:variable name="idx" select="if ($el) then number($el/@index) else 99999"/>
		<xsl:value-of select="$idx + $extra"/>
	</xsl:function>
	<xsl:function name="f:get-wit-index">
		<xsl:param name="sigil_t"/>
		<xsl:value-of select="f:get-wit-index($sigil_t, 0)"/>
	</xsl:function>
	
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
				<xsl:for-each-group select="//*[f:hasvars(.) and contains(@n, ' ')]" group-by="@n">
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
	
	###
	
	The new mechanism should work as follows:
	
	1. We only consider the emended versions, and we sort them by macrogenesis order.
	2. We group adjacent items in this list by the XML grouping key.
	3. for each group, 
			i.  we render the first emended version and the list of sigils
			ii. we iterate through the list of non-emended versions and render those that 
			    differ from the emended version wrt their grouping key	
	-->
	<xsl:template name="create-single-variants">
		<xsl:param name="current-lines" as="node()*" select="current-group()"/>
		<xsl:param name="current-n" select="current-grouping-key()"/>
		<xsl:variable name="all-lines" as="element()*">
			<xsl:perform-sort select="$current-lines">
				<xsl:sort select="f:get-wit-index(@f:sigil_t)" stable="yes"/>
			</xsl:perform-sort>
		</xsl:variable>
		<xsl:variable name="emended-lines" select="$all-lines[@f:emended]"/>
		<xsl:variable name="variant-lines" select="$all-lines except $emended-lines"/>
		<xsl:variable name="evidence">
			<xsl:sequence select="$standoff"/>
			<xsl:for-each-group select="$emended-lines" group-by="@f:sigil_t">
				<f:evidence>
					<xsl:copy-of select="current-group()[1]/@*"/>
					<xsl:copy-of select="current-group()"/>
				</f:evidence>				
			</xsl:for-each-group>
		</xsl:variable>
		<div class="variants" data-n="{current-grouping-key()}"
			data-witnesses="{count($evidence/* except $evidence/*[@f:type='lesetext'] except $evidence/f:standoff)}"
			data-variants="{count(distinct-values(for $ev in $evidence/* except $evidence/f:standoff return f:normalize-space($ev)))-1}"
			id="v{$current-n}">
			<xsl:attribute name="xml:id" select="concat('v', $current-n)"/>
			<xsl:for-each-group select="$evidence/f:evidence" group-adjacent="f:variant-grouping-key(.)">
				<xsl:variable name="current_sigils" select="current-group()/@f:sigil_t"/>
				<xsl:apply-templates select="current-group()[1]/*">
					<xsl:with-param name="group" select="current-group()"/>
				</xsl:apply-templates>
				<xsl:comment>Now potential inner variance:</xsl:comment>				
				<xsl:for-each select="$variant-lines[@f:sigil_t = $current_sigils][f:variant-grouping-key(.) != current-grouping-key()]">
					<xsl:variable name="variant-evidence">
						<xsl:sequence select="$standoff"/>
						<f:evidence>
							<xsl:copy-of select="."/>
						</f:evidence>
					</xsl:variable>
					<xsl:for-each select="$variant-evidence/f:evidence">
						<xsl:apply-templates>
							<xsl:with-param name="variant-lines" select="true()"/>
						</xsl:apply-templates>						
					</xsl:for-each>
				</xsl:for-each>

			</xsl:for-each-group>
		</div>
	</xsl:template>
	
	<xsl:template match="f:evidence">
		<xsl:param name="group"/>
		<xsl:result-document href="/tmp/evidence/ev-{generate-id(.)}.xml" method="xml" indent="yes">
			<TEI>
				<xsl:copy-of select="."/>
				<group>
					<xsl:copy-of select="$group"/>
				</group>
			</TEI>
		</xsl:result-document>
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
		<xsl:param name="group" as="node()*" select="."/>
		<xsl:param name="variant-lines" select="false()"/>
		<div class="{string-join((f:generic-classes(.), if ($variant-lines) then 'variant-lines' else ()), ' ')}" 
			data-n="{@n}" data-source="{string-join($group/@f:sigil_t, ' ')}">
			<xsl:call-template name="generate-style"/>
			
			<!-- first format the line's content ... -->
			<xsl:apply-templates/>
			
			<!-- now there's the list of sigils where this line is featured. -->
			<xsl:text> </xsl:text>
			<span class="sigils"> <!-- will float right -->
				<xsl:for-each select="$group">
					<xsl:variable 
						name="target" 
						select="if (@f:type!='lesetext') 
									then f:doclink(@f:sigil_t, @f:page, @n) 
									else concat($printbase, @f:sigil_t, if (@f:section != '') then '.' else '', @f:section, '#l', @n)"/>						
					<a class="sigil" href="{$target}" title="{@f:headNote}">
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
		<xsl:for-each-group select="//*[@n = $ns]" group-by="@f:sigil_t">			
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
	
	<xsl:template match="pb" priority="2"/>
	
	
	<!-- 
		The following templates and functions generate a grouping key by normalizing text and rendering elements and attributes
		as text. This should produce a string representation that catches exactly the significant inner variance.
	-->
	
	<xsl:function name="f:variant-grouping-key">
		<xsl:param name="line"/>
		<xsl:variable name="contents">
			<xsl:apply-templates mode="grouping-key" select="$line"/>
		</xsl:variable>
		<xsl:value-of select="data($contents)"/>
	</xsl:function>
	
	<xsl:template mode="grouping-key" match="f:evidence">
		<xsl:apply-templates mode="#current" select="*"/>
	</xsl:template>

	<xsl:template mode="grouping-key" match="*">
		<xsl:value-of select="concat('&lt;', name())"/>
		<xsl:for-each select="@* except @f:*">
			<xsl:sort select="name()"/>
			<xsl:value-of select="concat(' ', name(), '=', f:quoted-attribute-value(.))"/>
		</xsl:for-each>
		<xsl:choose>
			<xsl:when test="child::node()">
				<xsl:text>></xsl:text>
				<xsl:apply-templates mode="#current"/>
				<xsl:value-of select="concat('&lt;/', name(), '&gt;')"/>
			</xsl:when>
			<xsl:otherwise>/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template mode="grouping-key" match="text()">
		<xsl:value-of select="f:normalize-space(f:normalize-print-chars(.))"/>
	</xsl:template>
	
	<xsl:function name="f:quoted-attribute-value">
		<xsl:param name="value"/>
		<xsl:variable name="quot">"</xsl:variable>
		<xsl:variable name="apos">'</xsl:variable>
		<xsl:value-of select="concat($quot, replace(replace(replace(replace(replace(normalize-space(normalize-unicode($value)), 
			$quot, '&amp;quot;'),
			$apos, '&amp;apos;'),
			'&lt;', '&amp;lt;'),
			'&gt;', '&amp;gt;'),
			'&amp;', '&amp;amp;'), $quot)"/>
	</xsl:function>
		
</xsl:stylesheet>
