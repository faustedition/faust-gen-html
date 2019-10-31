<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.tei-c.org/ns/1.0"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	xmlns:f="http://www.faustedition.net/ns"
	exclude-result-prefixes="xs f"
	version="2.0">
	
	<xsl:import href="utils.xsl"/>

	<!-- URL for the source XML files -->
	<xsl:param name="source">file:/home/tv/git/faust-gen/data/xml/</xsl:param>

	<xsl:param name="use-collection" select="false()"/>
	
	<!-- If you pass URLs in, the respective witnesses will be read from these files, otherwise from unprocessed source tree -->
	<xsl:param name="A-uri" select="f:safely-resolve('print/A8_IIIB18.xml', $source)"/>
	<xsl:param name="H-uri" select="f:safely-resolve('transcript/gsa/391098/391098.xml', $source)"/>
	<xsl:param name="IH0a-uri" select="f:safely-resolve('transcript/dla_marbach/Cotta-Archiv_Goethe_23/Marbach_Deutsches_Literaturarchiv.xml', $source)"/>
	<xsl:param name="C1_4-uri" select="f:safely-resolve('print/C(1)4_IIIB24.xml', $source)"/>
	
	<!-- pass in to provide witness content directly, otherwise URIs are used -->
	<xsl:param name="A" select="if ($use-collection) then collection()[1] else doc($A-uri)"/>
	<xsl:param name="H" select="if ($use-collection) then collection()[2] else doc($H-uri)"/>
	<xsl:param name="IH0a" select="if ($use-collection) then collection()[3] else doc($IH0a-uri)"/>
	<xsl:param name="C1_4" select="if ($use-collection) then collection()[4] else doc($C1_4-uri)"/>
		
	<!-- 
	
		If you start this stylesheet using start template 'faust', it takes A for Faust I and
		adds Faust II to the end of it:
		
	-->
	<xsl:template name="faust">
		<xsl:message select="concat('Assembling from: ', 
			'A: ', document-uri($A), '; 2 H: ', document-uri($H), 
			'; 2 I H.0a: ', document-uri($IH0a), '; C.1_4: ', document-uri($C1_4))"/>
		<xsl:comment>### Aus A: ###</xsl:comment>
		<xsl:apply-templates select="$A"/>
	</xsl:template>
	
	<xsl:function name="f:source" as="node()*">
		<xsl:param name="sigil"/>
		<xsl:comment select="concat('### Aus ', $sigil, ': ###')"></xsl:comment>
		<app><rdg><witStart wit="faust://document/faustedition/{$sigil}"/></rdg></app>
	</xsl:function>
		
	<xsl:template match="div[descendant::l[@n='354'] and descendant::l[@n='4612']]"> 
		<!-- div that encloses all of Faust 1, doesn't have an @n unfortunately  -->
		<xsl:copy>
			<xsl:if test="not(@xml:id)"><xsl:attribute name="xml:id">part_1.1</xsl:attribute></xsl:if>
			<xsl:if test="not(@n)"><xsl:attribute name="n">1.1</xsl:attribute></xsl:if>
			<xsl:apply-templates select="@*, node()"/>
		</xsl:copy>
		
		<div n="2" xml:id="part_2">			
			<xsl:sequence select="f:source('2_H')"/>
			<xsl:apply-templates select="$H//*[@n='before_4613_c']"/>
			<xsl:apply-templates select="$H/TEI/text/group/text[1]/body"/>
		</div>
	</xsl:template>
	

	<!-- Alternatively, use -it faust2 to start this /only/ for Faust II  -->
	<xsl:template name="faust2">
		<xsl:comment>### Aus 2 H: ###</xsl:comment>
		<xsl:apply-templates select="$H"/>
	</xsl:template>
	
		
	<!--
			
	This stylesheet assembles the reading text from its main parts, 2 H with the following replacements:
			
			
	  **H**           **H**           **I H.0a / C.1\_4** **I H.0a / C.1\_4**
	  **von**         **bis**         **von**             **bis**
	  div n="2.1.1"   l n="6036"      div n="2.1.1"       l n="6036"
	  div n="2.3.1"   div n="2.3.3"   div n="2.3.1"       div n="2.3.3"
	  
	Since these boundaries are (a) in different parts of the hierarchy and (b) quite few, we write
	them directly as XSLT. The idea is that sections that don't contain the entire content from the
	same source have a special assembly template (*), and content that is to be attached after a 
	boundary, but inside the same innermost container as the boundary marker is attached after
	the boundary marker (#).
	
	*	2.1 / head from   2 H
		2.1.1      from   2 I H.0a
		2.1.2 with
		    - head        2 I H.0a
		    - 2.1.2.1     2 I H.0a
		    - 2.1.2.2     2 I H.0a 
	#*		- 2.1.2.3
			    - up & including sp[l[@n='6036']]  2 I H.0a
	#		    - sp[l[@n='6036']]/following:*     2 H
			- 2.1.2.4-6   2 H
		2.2 from          2 H
	*	2.3
		    - head        2 H
		    - divs        C.1_4
		2.4               2 H
		2.5               2 H
	
	-->
	
	<xsl:template match="div[@n='2.1']">
		<xsl:copy copy-namespaces="no">
			<xsl:apply-templates select="@*"/>	
			<xsl:apply-templates select="node() except (child::div[@n='2.1.1'], child::div[@n='2.1.1']/following::node())"/>			
			<xsl:sequence select="f:source('2_I_H.0a')"/>
			<xsl:apply-templates select="$IH0a//div[@n='2.1.1']"/>
			<xsl:apply-templates select="$IH0a//div[@n='2.1.1']/following-sibling::node() except $IH0a//sp[l[@n='6036']]/following::node()"/>			
			<xsl:comment>### Weiter aus 2 H: ###</xsl:comment>
			<xsl:apply-templates select="$H//div[@n='2.1.2']/following-sibling::node()"/>			
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="sp[l[@n='6036']]">
		<!-- this will match inside $H0a//div[@n=2.1.2.3] -->
		<xsl:next-match/>	<!-- default handling for the actual sp and its content -->
		<xsl:sequence select="f:source('2_H')"/>
		<xsl:apply-templates select="$H//sp[l[@n='6036']]/following-sibling::node()"/>
	</xsl:template>
	
	<xsl:template match="div[@n='2.1.2.3']">
		<xsl:next-match/>		
		<xsl:sequence select="f:source('2_H')"/>
		<xsl:apply-templates select="$H//div[@n='2.1.2.3']/following-sibling::node()"/>
	</xsl:template>
	
	<xsl:template match="div[@n='2.3']">
		<xsl:copy copy-namespaces="no">
			<xsl:apply-templates select="@*, node() except (child::div[1], child::div[1]/following::node())"/>
			<xsl:sequence select="f:source('C.1_4')"/>
			<xsl:apply-templates select="$C1_4//div[starts-with(@n, '2.3.')]"/>
		</xsl:copy>
		<xsl:sequence select="f:source('2_H')"/>
	</xsl:template>
	
	<!-- https://github.com/faustedition/faust-gen-html/issues/182 -->
	<xsl:template match="teiHeader">
		<teiHeader>
			<fileDesc>
				<titleStmt>
					<title type="main">Faust</title>
					<title type="sub">Eine Tragödie</title>
					<title type="sub">Konstituierter Text</title>
					<author>Johann Wolfgang Goethe</author>
					<respStmt>
						<resp>Bearbeitet von <name>Gerrit Brüning</name> und <name>Dietmar
							Pravida</name></resp>
						<resp><name>Thorsten Vitt</name> stellte die digitale Vorstufe des Textes
							bereit.</resp>
					</respStmt>
				</titleStmt>
				<editionStmt>
					<edition><xsl:value-of select="document('../version.xml#version')"/></edition>
				</editionStmt>
				<publicationStmt>
					<publisher><!-- bleibt leer --></publisher>
					<date when="{current-dateTime()}">generiert: <xsl:value-of select="current-dateTime()"/></date>
					<availability>
						<licence target="https://creativecommons.org/licenses/by-nc-sa/4.0/"
							>Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)</licence>
					</availability>
				</publicationStmt>
			</fileDesc>			
		</teiHeader>
	</xsl:template>

	<!-- identity transformation; just copy everything else from the current source: -->
	
	<xsl:template match="node() | @*">
		<xsl:copy copy-namespaces="no">
			<xsl:apply-templates mode="#current" select="@*, node()"/>
		</xsl:copy>
	</xsl:template>
	
		
</xsl:stylesheet>