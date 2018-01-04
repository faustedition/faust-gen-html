<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.tei-c.org/ns/1.0"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs"
	version="2.0">
	
	<xsl:import href="utils.xsl"/>

	<!-- URL for the source XML files -->
	<xsl:param name="source">file:/home/tv/git/faust-gen/data/xml/</xsl:param>
	
	<!-- If you pass URLs in, the respective witnesses will be read from these files, otherwise from unprocessed source tree -->
	<xsl:param name="A-uri" select="resolve-uri('print/A8_IIIB18.xml', $source)"/>
	<xsl:param name="H-uri" select="resolve-uri('transcript/gsa/391098/391098.xml', $source)"/>
	<xsl:param name="H0a-uri" select="resolve-uri('transcript/dla_marbach/Cotta-Archiv_Goethe_23/Marbach_Deutsches_Literaturarchiv.xml', $source)"/>
	<xsl:param name="C1_4-uri" select="resolve-uri('print/C(1)4_IIIB24.xml', $source)"/>
	
	<!-- pass in to provide witness content directly, otherwise URIs are used -->
	<xsl:param name="A" select="doc($A-uri)"/>
	<xsl:param name="H" select="doc($H-uri)"/>
	<xsl:param name="H0a" select="doc($H0a-uri)"/>
	<xsl:param name="C1_4" select="doc($C1_4-uri)"/>
	
	
	<!-- 
	
		If you start this stylesheet using start template 'faust', it takes A for Faust I and
		adds Faust II to the end of it:
		
	-->
	<xsl:template name="faust">
		<xsl:comment>### Aus A: ###</xsl:comment>
		<xsl:apply-templates select="$A"/>
	</xsl:template>
		
	<xsl:template match="div[descendant::l[@n='4612']]"> 
		<!-- div that encloses all of Faust 1, doesn't have an @n unfortunately  -->
		<xsl:next-match/>
		
		<div n="2">
			<head>TODO: Der Tragödie zweiter Teil oder so</head>
			<xsl:comment>### Aus 2 H: ###</xsl:comment>
			<xsl:apply-templates select="$H//body/*"/>
		</div>
	</xsl:template>
	

	<!-- Alternatively, use -it faust2 to start this /only/ for Faust II  -->
	<xsl:template name="faust2">
		<xsl:comment>### Aus 2 H: ###</xsl:comment>
		<xsl:apply-templates select="$H"/>
	</xsl:template>
	
		
	<!--
			
	This stylesheet assembles the reading text from its main parts, 2 H with the following replacements:
			
			
	  **H**           **H**           **H.0a / C.1\_4**   **H.0a / C.1\_4**
	  **von**         **bis**         **von**             **bis**
	  div n="2.1.1"   l n="6036"      div n="2.1.1"       l n="6036"
	  div n="2.3.1"   div n="2.3.3"   div n="2.3.1"       div n="2.3.3"
	  
	Since these boundaries are (a) in different parts of the hierarchy and (b) quite few, we write
	them directly as XSLT. The idea is that sections that don't contain the entire content from the
	same source have a special assembly template (*), and content that is to be attached after a 
	boundary, but inside the same innermost container as the boundary marker is attached after
	the boundary marker (#).
	
	*	2.1 / head from   2 H
		2.1.1      from   2 H.0a
		2.1.2 with
		    - head        2 H.0a
		    - 2.1.2.1     2 H.0a
		    - 2.1.2.2     2 H.0a 
	#*		- 2.1.2.3
			    - up & including sp[l[@n='6036']]  2 H.0a
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
		<xsl:copy>
			<xsl:apply-templates select="@*"/>	
			<xsl:apply-templates select="node() except (div[@n='2.1.1'], div[@n='2.1.1']/following::node())"/>
			<xsl:comment>### Aus 2 H.0a: ###</xsl:comment>
			<xsl:apply-templates select="$H0a//div[@n='2.1.1']"/>
			<xsl:apply-templates select="$H0a//div[@n='2.1.1']/following-sibling::node() except $H0a//sp[l[@n='6036']]/following::node()"/>			
			<xsl:comment>### Weiter aus 2 H: ###</xsl:comment>
			<xsl:apply-templates select="$H//div[@n='2.1.2']/following-sibling::node()"/>			
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="sp[l[@n='6036']]">
		<!-- this will match inside $H0a//div[@n=2.1.2.3] -->
		<xsl:next-match/>	<!-- default handling for the actual sp and its content -->
		<xsl:comment>### Aus 2 H: ###</xsl:comment>
		<xsl:apply-templates select="$H//sp[l[@n='6036']]/following-sibling::node()"/>
	</xsl:template>
	
	<xsl:template match="div[@n='2.1.2.3']">
		<xsl:next-match/>
		<xsl:comment>### Aus 2 H: ###</xsl:comment>
		<xsl:apply-templates select="$H//div[@n='2.1.2.3']/following-sibling::node()"/>
	</xsl:template>
	
	<xsl:template match="div[@n='2.3']">
		<xsl:copy>
			<xsl:apply-templates select="@*, node() except (div[1], div[1]/following::node())"/>
			<xsl:comment>### Aus C.1_4: ###</xsl:comment>
			<xsl:apply-templates select="$C1_4//div[starts-with(@n, '2.3.')]"/>
		</xsl:copy>
	</xsl:template>

	<!-- identity transformation; just copy everything else from the current source: -->
	
	<xsl:template match="node() | @*">
		<xsl:copy>
			<xsl:apply-templates mode="#current" select="@*, node()"/>
		</xsl:copy>
	</xsl:template>
	

	
		
		
</xsl:stylesheet>