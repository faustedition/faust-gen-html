<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:f="http://www.faustedition.net/ns"
	exclude-result-prefixes="xs"
	version="2.0">
	
	
	<xsl:import href="html-common.xsl"/>
	<xsl:import href="html-frame.xsl"/>
	<xsl:import href="bibliography.xsl"/>	
	
	<xsl:variable name="basename" select="replace(document-uri(/), '^.*/([^/]+)\.xml', '$1')"/>
	<xsl:variable name="biburl" select="concat('faust://bibliography/', $basename)"/>
	
	
	<xsl:template match="/TEI">
		<xsl:call-template name="html-frame">
			<xsl:with-param name="content">				
					<xsl:apply-templates select="text"/>					
			</xsl:with-param>
			<xsl:with-param name="breadcrumbs" tunnel="yes">
				<div class="breadcrumbs pure-right pure-nowrap pure-fade-50">
					<small id="breadcrumbs">
						<span>
							<a href="/archive">Archiv</a>
							<i class="fa fa-angle-right"/>
							<a href="/archive_testimonies">Entstehungszeugnisse</a>
						</span>
					</small>
				</div>
				<div id="current" class="pure-nowrap">
					<span>
						<xsl:attribute name="title" select="f:cite($biburl, true())"/>
						<xsl:value-of select="f:cite($biburl, false())"></xsl:value-of>
					</span>
				</div>				
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>	
	
	<xsl:template match="rs">
		<mark class="{string-join(f:generic-classes(.), ' ')}">
			<xsl:apply-templates/>
		</mark>
	</xsl:template>
	
	<xsl:variable name="taxonomies">
		<f:taxonomies>
			<f:taxonomy xml:id='graef'>Gräf Nr.</f:taxonomy>
			<f:taxonomy xml:id='pniower'>Pniower Nr.</f:taxonomy>
			<f:taxonomy xml:id='quz'>QuZ Nr.</f:taxonomy>
			<f:taxonomy xml:id='bie3'>Biedermann-Herwig Nr.</f:taxonomy>			
		</f:taxonomies>
	</xsl:variable>
	
	<xsl:function name="f:testimony-label">
		<xsl:param name="testimony-id"/>
		<xsl:variable name="id_parts" select="tokenize($testimony-id[1], '_')"/>
		<xsl:value-of select="concat(id($id_parts[1], $taxonomies)/text(), ' ', $id_parts[2])"/>
	</xsl:function>
	
	<xsl:function name="f:real_id" as="xs:string">
		<xsl:param name="id"/>
		<xsl:value-of select="replace($id, '^(\w+)_0*(.*)$', '$1_$2')"/>
	</xsl:function>
	
	<xsl:template match="milestone[@unit='testimony']">
		<xsl:variable name="id" select="f:real_id(@xml:id)"/>
		<xsl:variable name="id_parts" select="tokenize($id, '_')"/>
		<xsl:choose>
			<xsl:when test="count($id_parts) = 2">
				<xsl:variable name="taxlabel" select="id($id_parts[1], $taxonomies)/text()"/>
				<xsl:if test="not($taxlabel) or $id_parts[2] = ''">
					<xsl:message select="concat('WARNING: Invalid testimony id ', $id, ' in ', document-uri(/))"/>
				</xsl:if>
				<a id="{$id}" href="/archive_testimonies#{$id}" class="testimony"><xsl:value-of select="f:testimony-label($id)"/></a>
			</xsl:when>
			<xsl:when test="count($id_parts) = 3 and string-length($id_parts[2]) > 0 and matches($id_parts[2], '.*\d.*')">
				<!--<xsl:message select="concat('INFO:',document-uri(/),': Skipping three-part testimony id ', @xml:id)"/>-->				
			</xsl:when>
			<xsl:otherwise>
				<xsl:message>WARNING:<xsl:value-of select="document-uri(/)"/>:Invalid/strange testimony id "<xsl:value-of select="$id"/>" <xsl:copy-of select="."/></xsl:message>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- following template extracts f:citation elements for all  -->
	<xsl:template name="get-citations">
		<f:citations>
			<xsl:for-each select="//milestone[@unit='testimony']">
				<xsl:variable name="real-id" select="f:real_id(@xml:id)"/>
				<xsl:variable name="id" select="tokenize($real-id, '_')"/>
				<xsl:if test="count($id) = 2">
					<f:citation 
						testimony="{$basename}#{$real-id}" 
						base="{$basename}" 
						taxonomy="{id($id[1], $taxonomies)}"
						n="{$id[2]}"
						testimony-id="{$real-id}"
						rs="{f:find-rs(.)}">
						<xsl:value-of select="$biburl"/>
					</f:citation>					
				</xsl:if>
			</xsl:for-each>
		</f:citations>		
	</xsl:template>
	
	<xsl:template name="milestone-content">
		<xsl:param name="milestone" select="self::milestone"/>
		<!-- Prepared in testimony-split.xsl -->
		<xsl:sequence select="root($milestone)//text[@copyOf=concat('#', $milestone/@xml:id)]"/>
	</xsl:template>
	
	<xsl:function name="f:find-rs">
		<xsl:param name="milestone"/>
		<xsl:variable name="content"><xsl:call-template name="milestone-content"><xsl:with-param name="milestone" select="$milestone"/></xsl:call-template></xsl:variable>
		<xsl:variable name="rs" select="($content//rs)[1]"/>
		<xsl:choose>
			<xsl:when test="$rs"><xsl:value-of select="f:normalize-space($rs)"/></xsl:when>
			<!--<xsl:otherwise><xsl:message select="concat('Testimony ', $milestone/@xml:id, ' has no &lt;rs> but content: ', f:normalize-space($content))"/></xsl:otherwise>-->
		</xsl:choose>		
	</xsl:function>
	
	<!-- suppress pb when there's no content afterwards, before the next pb or document end -->
	<xsl:template match="pb">
		<xsl:variable name="next" select="(following::pb)[1]"/>
		<xsl:variable name="inbetween" select="following::node() intersect $next/preceding::node()"/>
		<xsl:if test="not(matches(string-join($inbetween, ''), '^\s*$'))">
			<xsl:next-match/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="text[@copyOf]"/>
	
</xsl:stylesheet>