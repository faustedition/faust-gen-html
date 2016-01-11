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
	<xsl:param name="depth">2</xsl:param>
	<xsl:param name="canonical">document/print/A8.xml document/faust/2/gsa_391098.xml</xsl:param>
	<xsl:variable name="canonicalDocs" select="tokenize($canonical, ' ')"/>
		
	
	<xsl:output method="xhtml"/>
		
	<xsl:template match="/f:variants">
		<xsl:for-each-group select="*" group-by="f:output-group(@n)">
			<!-- eine Ausgabedatei für ca. 10 kanonische Zeilen -->		
			<xsl:variable name="output-file" select="concat($variants, current-grouping-key(), '.html')"/>			
			<xsl:result-document href="{$output-file}">
				<div class="groups" data-group="{current-grouping-key()}">
					<xsl:for-each-group select="current-group()" group-by="tokenize(@n, '[ ,;\t\n]+')">
						<xsl:variable name="cline" select="current-group()[@f:doc = $canonicalDocs]"/>
						<xsl:variable name="ctext" select="if ($cline) then normalize-space($cline[1]) else ''"/>
						<xsl:variable name="evidence">
							<xsl:for-each-group select="current-group()" group-by="@f:doc">
								<f:evidence>
									<xsl:copy-of select="current-group()[1]/@*"/>
									<xsl:copy-of select="current-group()"/>
								</f:evidence>
							</xsl:for-each-group>
						</xsl:variable>
						<div class="variants" 
							data-n="{current-grouping-key()}" 
							data-witnesses="{count($evidence/* except $evidence/*[@type='lesetext'])}"
							data-variants="{count(distinct-values(for $ev in $evidence/* return normalize-space($ev)))-1}"
							data-ctext="{$ctext}"
							id="v{current-grouping-key()}">
							<xsl:attribute name="xml:id" select="concat('v', current-grouping-key())"/>
							<xsl:for-each-group select="$evidence/*" group-by="normalize-space(.)">
								
									<xsl:apply-templates select="current-group()[1]/*">
										<!--<xsl:sort select="@f:sigil"/>-->
										<!-- Sorting is done in collect-metadata.xpl, we just keep the document order from there -->
										<xsl:with-param name="group" select="current-group()"/>
									</xsl:apply-templates>
								
							</xsl:for-each-group>
						</div>
					</xsl:for-each-group>
				</div>
			</xsl:result-document>
		</xsl:for-each-group>
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
					<xsl:variable 
						name="target" 
						select="if (@f:type='archivalDocument') 
									then f:doclink(@f:doc, @f:page, @n) 
									else f:printlink(@f:href, @n)"/>						
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
	
	
	<xsl:template match="*">
		<xsl:element name="{f:html-tag-name(.)}">
			<xsl:attribute name="class" select="string-join(f:generic-classes(.), ' ')"/>			
			<xsl:apply-templates/>
		</xsl:element>		
	</xsl:template>
	
</xsl:stylesheet>
