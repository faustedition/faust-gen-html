<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns:t="http://www.faustedition.net/ns/testimony"
	exclude-result-prefixes="xs"
	version="2.0">
	
	
	<xsl:import href="html-common.xsl"/>
	<xsl:import href="html-frame.xsl"/>
	<xsl:import href="bibliography.xsl"/>
	<xsl:import href="testimony-common.xsl"/>	
	
	<xsl:variable name="basename" select="replace(document-uri(/), '^.*/([^/]+)\.xml', '$1')"/>
	<xsl:variable name="biburl" select="if (//t:biburl) then //t:biburl[1] else concat('faust://bibliography/', $basename)"/>
	
	
	
	<xsl:template match="/TEI">
		<xsl:call-template name="html-frame">
			<xsl:with-param name="headerAdditions">
				<script type="text/javascript" src="{$assets}/js/faust_app.js"/>
			</xsl:with-param>			
			<xsl:with-param name="content">				
					<xsl:apply-templates select="text"/>					
			</xsl:with-param>
			<xsl:with-param name="breadcrumb-def" tunnel="yes">
				<a href="/archive">Archiv</a>
				<a href="/archive_testimonies">Entstehungszeugnisse</a>
				<a title="{f:cite($biburl, true())}">
					<xsl:value-of select="f:cite($biburl, false())"/>
				</a>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>	
	
	<xsl:template match="rs">
		<mark class="{string-join(f:generic-classes(.), ' ')}">
			<xsl:apply-templates/>
		</mark>
	</xsl:template>
				
	<xsl:template match="desc/milestone" priority="1"/>
	
	<xsl:template name="testimony-marker" match="milestone[@unit='testimony']|anchor[preceding::milestone[substring(@spanTo, 2) = current()/@xml:id]]">
		<xsl:variable name="root" select="f:root-milestone(.)"/>
		<xsl:variable name="chain" select="f:milestone-chain($root)"/>
		<xsl:variable name="root_id" select="f:real_id($root/@xml:id)"/>
		<xsl:variable name="position" select="count($chain[current() >> .])"/>
		<xsl:variable name="marker_id" select="if ($position = 0) then $root_id else concat($root_id, '_', $position)"/>
		<xsl:variable name="all_marker_ids" select="($root_id, for $n in 1 to count($chain)-1 return concat($root_id, '_', $n))"/>
		<xsl:variable name="other_ids" select="$all_marker_ids"/>

		<a 	class="appnote generated-text testimony-ref"
			id="{$marker_id}"			
			data-also-highlight="{string-join($other_ids, ' ')}">
			<xsl:choose>
				<xsl:when test="$position = 0">		<!-- first <milestone> -->
					<xsl:attribute name="href" select="concat('/archive_testimonies#', $root_id)"/>
					<xsl:text>[ </xsl:text>
					<xsl:value-of select="f:testimony-label($root_id)"/>					
					<xsl:text>: </xsl:text>										
				</xsl:when>
				<xsl:when test="self::milestone and $position > 1"> <!-- continuation milestone -->
					<xsl:attribute name="href" select="concat('#', $root_id)"/>
					<xsl:text>[ </xsl:text>
					<xsl:value-of select="f:testimony-label($root_id)"/>					
					<xsl:text> (weiter): </xsl:text>					
				</xsl:when>
				<xsl:when test="$position > 1">
					<xsl:attribute name="href" select="concat('#', $root_id, '_', $position - 1)"/>
					<xsl:attribute name="title" select="concat('Ende ', f:testimony-label($root_id), ' (forts.)')"/>
					<xsl:text> ]</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="href" select="concat('#', $root_id)"/>
					<xsl:attribute name="title" select="concat('Ende ', f:testimony-label($root_id))"/>
					<xsl:text> ]</xsl:text>					
				</xsl:otherwise>
			</xsl:choose>
		</a>
	</xsl:template>
	
	<!-- following template generates a f:citation element for the current split testimony -->
	<xsl:template name="get-citations" exclude-result-prefixes="#default">
		<xsl:variable name="real-id" select="//t:testimony/@id"/>
		<xsl:choose>
			<xsl:when test="count($real-id) = 1">
				<xsl:variable name="id" select="tokenize($real-id, '_')"/>
				<f:citation
					taxonomy="{id($id[1], $taxonomies)}"
					n="{$id[2]}"
					testimony="{$real-id}"
					rs="{f:find-rs(//text[@type='testimony' and @n=$real-id])}">
					<xsl:value-of select="$biburl"/>
				</f:citation>									
			</xsl:when>
			<xsl:otherwise>
				<xsl:variable name="msg" select="concat('WARNING: Trying to create citation for doc with ', count($real-id), ' testimony ids ', string-join($real-id, '; '), ' → ', $biburl)"/>
				<xsl:message select="$msg"/>
				<xsl:comment select="$msg"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="milestone-content">
		<xsl:param name="milestone" select="self::milestone"/>
		<!-- Prepared in testimony-split.xsl -->
		<xsl:sequence select="root($milestone)//text[@copyOf=concat('#', $milestone/@xml:id)]"/>
	</xsl:template>
	
	<xsl:function name="f:find-rs">		
		<xsl:param name="content"/>
		<xsl:variable name="content-str" select="normalize-space(string-join($content, ''))"/>
		<xsl:variable name="rs" select="$content//rs"/>
		<xsl:choose>
			<xsl:when test="$rs">… <xsl:value-of select="string-join(for $single-rs in $rs return f:normalize-space($single-rs), ' … ')"/> …</xsl:when>			
			<xsl:when test="string-length($content-str) &lt; 50"><xsl:value-of select="$content-str"/> …</xsl:when>
			<xsl:otherwise><xsl:value-of select="replace(substring($content-str, 1, 50), ' ?\w+$', ' …')"/></xsl:otherwise>			
		</xsl:choose>		
	</xsl:function>
	
	<!-- suppress pb when there's no content afterwards, before the next pb or document end -->
	<xsl:template match="pb">
		<xsl:variable name="next" select="(following::pb)[1]"/>
		<xsl:variable name="inbetween" select="following::node() intersect $next/preceding::node()"/>
		<xsl:if test="$next and not(matches(string-join($inbetween, ''), '^\s*$'))">
			<xsl:next-match/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="text[@copyOf]"/>
	
</xsl:stylesheet>
