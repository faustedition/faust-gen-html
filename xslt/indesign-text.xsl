<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns="http://www.tei-c.org/ns/1.0"
	xmlns:aid="http://ns.adobe.com/AdobeInDesign/4.0/"
	xmlns:f="http://www.faustedition.net/ns"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs"
	version="2.0">
	
	<!--
		
	This stylesheet prepares an (emended) TEI file for import into Indesign. It performs the following steps:
	
	1.  Whitespace normalization. 
	
		Whitespace from the original files w/o semantics is stripped or normalized to a single space character.
		Then, linebreaks are introduced after elements that should become paragraphs in Indesign's data model.
		
	2.  Introduction of paragraph templates via aid:pformat attributes.
	
		For elements that should become paragraphs in InDesign's model, we add a aid:pformat attribute. This is 
		a hyphen-delimited string of a main template name and optionally one or more template suffixes for special 
		cases. The main template name is either mentioned in the $format-names variable below or it is simply the
		element name. The suffixes are generated in the pformat-extras template below for special cases. E.g., an 
		<l> element inside a <lg rend="indented"> might get the template name Verse-Indented, and if there is 
		a line number to print, it might be Verse-VerseNo-Indented.
		
	3.  Introduction of character templates via aid:cformat attributes.
	
		Simply for all inline elements.
		
	4.  Generation of verse numbers.
	
		All verses with a Schroer number divisible by 5 is prefixed with <seg aid:cformat="VerseNo">number[Tab]</seg>.
		
	5.  Everything else is just passed through.
	
		
	
	
		
	Material:
	
	* http://www.xporc.net/2015/05/14/xml-und-indesign-i-tuecken-des-xml-imports/
	* https://github.com/faustedition/faust-gen-html/issues/109
	
	-->
	<xsl:import href="utils.xsl"/>

	<!-- Brutal white-space solution. See the strip-space of tei's to-text for alternatives. -->
	<xsl:strip-space elements="*"/>
	
	
	<!-- Alternative template names for elements, element name is used instead -->
	<xsl:variable name="format-names">
		<format element="l">Verse</format>
		<format element="stage">Stage</format>
		<format element="speaker">Speaker</format>
	</xsl:variable>	

	<!-- Explicitely insert the verse no + Tab if applicable -->
	<xsl:template match="l[f:is-schroer(.) and number(@n) mod 5 = 0]" mode="prefix">
		<seg aid:cformat="versnr">
			<xsl:value-of select="@n"/>
			<xsl:text>&#9;</xsl:text>
		</seg>
	</xsl:template>
	
	<!-- List all elements that should become paragraphs here -->
	<xsl:template match="l|stage|speaker|head">
		<xsl:copy>
			<xsl:variable name="pformat-extras" as="item()*">
				<xsl:call-template name="pformat-extras"/>
			</xsl:variable>
			<xsl:attribute name="aid:pformat" select="f:format-name(., $pformat-extras)"/>
			<xsl:apply-templates select="@*"/>
			<xsl:apply-templates select="." mode="prefix"/>
			<xsl:apply-templates select="node()"/>
		</xsl:copy>
		<xsl:text>&#10;</xsl:text>
	</xsl:template>
	
	<!-- Additons for the paragraph templates -->
	<xsl:template name="pformat-extras" as="item()*">
		<xsl:if test="self::l[f:is-schroer(.) and number(@n) mod 5 = 0]">VerseNo</xsl:if>
		<xsl:if test="ancestor::lg[@rend='indented']/*">Indented</xsl:if>	
		<xsl:if test="parent::lg and position()=1">FirstInLG</xsl:if>
		<xsl:if test="parent::lg and position()=last()">LastInLG</xsl:if>		
	</xsl:template>
	
	<!-- We add character formats for just any inline element -->
	<xsl:template match="*[f:isInline(.)]">
		<xsl:copy>
			<xsl:attribute name="aid:cformat" select="f:format-name(., ())"/>
			<xsl:apply-templates select="@*, node()"/>
		</xsl:copy>
	</xsl:template>
	
	
	<!-- Boring stuff follows -->
		
	<xsl:template match="/TEI">
		<xsl:copy>
			<xsl:namespace name="aid">http://ns.adobe.com/AdobeInDesign/4.0/</xsl:namespace> <!-- don't want this on _every_ element w/an aid:* attribute -->
			<xsl:apply-templates select="@*, node()"/>
		</xsl:copy>
	</xsl:template>
	
	<!-- no processing for the header -->
	<xsl:template match="teiHeader">
		<xsl:copy-of select="."/>
	</xsl:template>
	
	
	<!-- whitespace normalization. https://wiki.tei-c.org/index.php/XML_Whitespace#Structured_Elements_and_xsl:strip-space -->
	<xsl:template match="text()" mode="#default">
		<xsl:choose>
			<xsl:when
				test="ancestor::*[@xml:space][1]/@xml:space='preserve'">
				<xsl:value-of select="."/>
			</xsl:when>
			<xsl:otherwise>
				<!-- Retain one leading space if node isn't first, has
	     non-space content, and has leading space.-->
				<xsl:if test="position()!=1 and          matches(.,'^\s') and          normalize-space()!=''">
					<xsl:text> </xsl:text>
				</xsl:if>
				<xsl:value-of select="normalize-space(.)"/>
				<xsl:choose>
					<!-- node is an only child, and has content but it's all space -->
					<xsl:when test="last()=1 and string-length()!=0 and      normalize-space()=''">
						<xsl:text> </xsl:text>
					</xsl:when>
					<!-- node isn't last, isn't first, and has trailing space -->
					<xsl:when test="position()!=1 and position()!=last() and matches(.,'\s$')">
						<xsl:text> </xsl:text>
					</xsl:when>
					<!-- node isn't last, is first, has trailing space, and has non-space content   -->
					<xsl:when test="position()=1 and matches(.,'\s$') and normalize-space()!=''">
						<xsl:text> </xsl:text>
					</xsl:when>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<!-- This actually generates the name, just mechanically -->
	<xsl:function name="f:format-name">
		<xsl:param name="element"/>
		<xsl:param name="addition"/>
		<xsl:choose>
			<xsl:when test="$format-names//*[@element = local-name($element)]">
				<xsl:value-of select="$format-names//*[@element = local-name($element)]"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="local-name($element)"/>
			</xsl:otherwise>
		</xsl:choose>
		<xsl:if test="$addition">
			<xsl:text>-</xsl:text>
			<xsl:value-of select="string-join($addition, '-')"/>
		</xsl:if>
	</xsl:function>
	
	
	
	<!-- ################################################################################################# -->
	
	<!-- leave everything else as-is -->
	<xsl:template match="node() | @*" priority="-1" mode="#default">
		<xsl:copy>
			<xsl:apply-templates select="@*, node()"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="text()" mode="#all" priority="-10"/>
	
</xsl:stylesheet>