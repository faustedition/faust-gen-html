<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:math="http://www.w3.org/1998/Math/MathML"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
	xmlns="http://www.tei-c.org/ns/1.0"	
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns:t="http://www.faustedition.net/ns/testimony"
	exclude-result-prefixes="xs xi svg math xd f t"
	version="2.0">
	
	<xsl:import href="bibliography.xsl"/>
	<xsl:import href="testimony-common.xsl"/>	
	
	
	<xsl:param name="builddir-resolved" select="resolve-uri('../../../../target/')"/>
	<xsl:param name="output" select="resolve-uri('testimony-split/', $builddir-resolved)"/>
	<xsl:param name="source-uri" select="document-uri(/)"/>
	<xsl:variable name="unfree-text" select="matches($source-uri, '/quz_.*(\.xml)?')"/>
	
	<xsl:variable name="basename" select="replace($source-uri, '^.*/([^/]+)\.xml', '$1')"/>
	<xsl:variable name="biburl" select="concat('faust://bibliography/', $basename)"/>
	
	<!-- XML version of the testimony table, generated by get-testimonies.py from the excel table -->
	<xsl:param name="table" select="doc('testimony-table.xml')"/>
	
	<xsl:function name="f:unfree-text" as="xs:boolean">
		<xsl:param name="el"/>
		<xsl:sequence select="$unfree-text and ($el/ancestor-or-self::div[@type='editorial'] or $el/descendant-or-self::div[@type='editorial'])"/>
	</xsl:function>
		
	<xsl:template match="/">
		<xsl:message select="concat('INFO: Splitting testimony source ', $basename, ' ...')"/>
		<xsl:variable name="root-divs" select="//div[descendant::milestone[@unit='testimony'] and not(ancestor::div)]"/>
		<xsl:if test="count($root-divs) = 0">
			<xsl:message select="concat('WARNING: No testimony divs found in ', $basename)"/>		
		</xsl:if>		
		
		<xsl:for-each select="$root-divs">
			<xsl:call-template name="process-testimony-div"/>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="process-testimony-div">
		<xsl:param name="div" select="."/>
		<!-- First find the testimony id(s). -->
		<xsl:variable name="milestones" select="descendant::milestone[@unit='testimony'][count(tokenize(@xml:id, '_')) = 2]"/>
		<xsl:if test="count($milestones) > 1">
			<xsl:message select="concat('INFO: div[', position(), '] in ', $basename, ' contains ', count($milestones), ' testimonies: ', string-join($milestones/@xml:id, ', '))"/>
			<!--<xsl:message><xsl:copy-of select="$milestones"/></xsl:message>-->
		</xsl:if>
		
		<xsl:for-each select="$milestones">
			<xsl:variable name="id" select="f:real_id(@xml:id)"/>
			<xsl:variable name="xml-id" select="@xml:id"/>
			<xsl:variable name="milestone" select="." as="element()"/>
			<xsl:variable name="chain" select="f:milestone-chain($milestone)" as="element()*"/>
			<xsl:variable name="last-milestone" select="$chain[position() = last()]"/>
			<xsl:variable name="last-div" select="$last-milestone/ancestor::div[not(ancestor::div)]"/>
			<xsl:variable name="context" select="$div, $div/following::node() except ($div/following::*//node(), $last-div/following::node())"/>
			<xsl:variable name="metadata0" select="$table//t:testimony[@id=$id]"/>
			<xsl:variable name="metadata" as="element()?">
				<xsl:choose>
					<xsl:when test="count($metadata0) > 1">
						<xsl:message terminate="no"><xsl:value-of select="concat('ERROR: Table has ', count($metadata0),' entries with id ', $id, '&#10;')"/>
					   	<xsl:sequence select="$metadata0"/>
					</xsl:message></xsl:when>					
					<xsl:when test="$metadata0"><xsl:sequence select="$metadata0"/></xsl:when>
					<xsl:otherwise>
						<xsl:variable name="id_parts" select="tokenize($id, '_')"/>
						<xsl:variable name="matching-md" as="element()*" select="$table//t:testimony[t:field[@name = $id_parts[1] and . = $id_parts[2]]]"/>
						<xsl:choose>
							<xsl:when test="count($matching-md) = 1">
								<xsl:for-each select="$matching-md">
									<xsl:copy>
										<xsl:attribute name="id" select="if (@id) then @id else $id"/>
										<xsl:copy-of select="*"/>
									</xsl:copy>
								</xsl:for-each>
								<xsl:message select="concat('WARNING: Using inferior testimony id ', $id, ' (in ', $basename, ')')"/>
							</xsl:when>
							<xsl:otherwise><xsl:message select="concat('ERROR: ', count($matching-md), ' metadata records match ', $id, ' (in ', $basename, ')')"/></xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:variable>
			<xsl:variable name="basename" select="
				if ($metadata/@id != $id and not(//milestone[@unit='testimony'][$metadata/@id = f:real_id(@xml:id)]))
				then $metadata/@id
				else $id"/>
			
			<xsl:result-document href="{resolve-uri(concat($basename, '.xml'), $output)}" exclude-result-prefixes="xs xi svg math xd f">
				
					<TEI>
						<xsl:for-each select="/TEI/teiHeader">
							<teiHeader>
								<xsl:comment>Preliminary TEI header</xsl:comment>								
								<fileDesc>
									<titleStmt>
										<title><xsl:value-of select="f:testimony-label($id)"/></title>
									</titleStmt>
									<publicationStmt>
										<p>Teil der <ref target="http://faustedition.net/">Faustedition</ref></p>
									</publicationStmt>
									<sourceDesc>
										<p><xsl:value-of select="f:cite($biburl, true())"/></p>										
									</sourceDesc>
								</fileDesc>
								<xenoData>
									<xsl:for-each select="$metadata">
										<xsl:copy>
											<xsl:copy-of select="@*"/>
											<xsl:copy-of select="*"/>
											<biburl xmlns="http://www.faustedition.net/ns/testimony"><xsl:value-of select="$biburl"/></biburl>										
										</xsl:copy>
									</xsl:for-each>								
								</xenoData>
								<xsl:copy-of select="revisionDesc"/>								
							</teiHeader>
						</xsl:for-each>
						<text>
							<group>
								<text>
									<body>
										<xsl:choose>
											<xsl:when test="f:unfree-text(.)">												
												<desc type="editorial" subtype="info">
													<xsl:text>Für die Veröffentlichung dieses Volltexts liegt noch keine Freigabe vor.</xsl:text>
													<xsl:copy-of select="$milestone"/>
												</desc>											
											</xsl:when>
											<xsl:otherwise>
												<xsl:copy-of select="$div/preceding::pb[1]"/>
												<xsl:copy-of select="$context"/>												
											</xsl:otherwise>
										</xsl:choose>
									</body>
								</text>
								<text n="{$id}" copyOf="#{$xml-id}" type="testimony">
									<body>
										<xsl:call-template name="milestone-content">
											<xsl:with-param name="milestone" select="id($xml-id)"/>
										</xsl:call-template>										
									</body>
								</text>
							</group>
						</text>
					</TEI>
				
			</xsl:result-document>
		</xsl:for-each>		
	</xsl:template>
	
	<xsl:template name="milestone-content">
		<xsl:param name="milestone" select="self::milestone"/>
		<xsl:param name="allow-leading-gap" select="true()"/>
		<xsl:for-each select="$milestone">
			<xsl:variable name="target" select="id(substring(@spanTo, 2))"/>
			<xsl:variable name="content">
				<xsl:if test="$allow-leading-gap and (preceding-sibling::* or normalize-space(string-join(preceding-sibling::text(), '')) != '')">
					<gap reason="irrelevant"/>
				</xsl:if>
				<xsl:variable name="actual-content" select="following::node() except (., $target, $target/following::node(), following::*/node())"/>
				<xsl:choose>
					<xsl:when test="not($target)">
						<xsl:message>ERROR: <xsl:value-of select="$milestone/@xml:id"/> spans to <xsl:value-of select="@spanTo"/>, which doesn't exist (#?). </xsl:message>
						<xsl:text>⚠# </xsl:text>
					</xsl:when>
					<xsl:when test="$target is $milestone">
						<xsl:message>ERROR: <xsl:value-of select="$milestone/@xml:id"/> spans to itself in <xsl:value-of select="$basename"/>!</xsl:message>
						<xsl:text>⚠↺ </xsl:text>					
					</xsl:when>
					<xsl:when test="not($actual-content)">
						<xsl:message>ERROR: <xsl:value-of select="$milestone/@xml:id"/> does not have any content in <xsl:value-of select="$basename"/>!</xsl:message>
						<xsl:text>⚠∅ </xsl:text>					
					</xsl:when>					
				</xsl:choose>
				<xsl:sequence select="$actual-content"/>
				<xsl:if test="@next or following-sibling::* or normalize-space(following-sibling::text()) != ''">
					<gap reason="irrelevant"/>
				</xsl:if>
			</xsl:variable>
			<xsl:choose>
				<xsl:when test="parent::div or parent::text">
					<xsl:sequence select="$content"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="parent::*">
						<xsl:copy>
							<xsl:sequence select="$content"/>
						</xsl:copy>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:call-template name="milestone-content">
				<xsl:with-param name="milestone" select="id(substring(@next, 2))"/>
				<xsl:with-param name="allow-leading-gap" select="false()"/>
			</xsl:call-template>						
		</xsl:for-each>
	</xsl:template>
	
</xsl:stylesheet>
