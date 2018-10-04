<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:f="http://www.faustedition.net/ns"
	exclude-result-prefixes="xs"
	default-collation="http://www.w3.org/2013/collation/UCA?lang=de"
	version="2.0">
	
	<xsl:import href="bibliography.xsl"/>
	<xsl:import href="html-frame.xsl"/>
	<xsl:import href="utils.xsl"/>
	
	<xsl:param name="headerAdditions">
		<style type="text/css">
			.bibliography dt .hover-link {
				color: gray;
				font-weight: normal;
				padding-left: 0.25em;
				visibility: hidden;				
			}
			.bibliography dt:hover .hover-link {
				visibility: visible;
			}
			.bib-backrefs a {
				white-space: nowrap;
			}
		</style>
	</xsl:param>
	
	<xsl:template match="/">
		<xsl:call-template name="html-frame">
			<xsl:with-param name="title" tunnel="yes">Bibliographie</xsl:with-param>
			<xsl:with-param name="breadcrumb-def" tunnel="yes"><a href="archive">Archiv</a><a href="bibliography">Bibliographie</a></xsl:with-param>
			<xsl:with-param name="content">
				<xsl:variable name="entries" as="element()*">
					<xsl:for-each-group select="//f:citation" group-by=".">
						<xsl:variable name="citation" select="f:cite(current-grouping-key(), 'dd')"/>
						<xsl:variable name="backrefs" as="element()*">
							<xsl:for-each select="current-group()[@from]">							
								<xsl:sequence select="f:resolve-faust-doc(@from, $transcript-list)"/>
							</xsl:for-each>
						</xsl:variable>
						<xsl:variable name="backref-part">
							<small class="bib-backrefs">								
								<xsl:for-each-group select="$backrefs" group-by=".">
									<xsl:sort select="f:splitSigil(.)[1]" stable="yes"/>
									<xsl:sort select="f:splitSigil(.)[2]" data-type="number"/>
									<xsl:sort select="f:splitSigil(.)[3]"/>								                    
									
									<xsl:copy-of select="current-group()[1]"/>
									<xsl:if test="position() != last()">, </xsl:if>
								</xsl:for-each-group>
							</small>
						</xsl:variable>
						<xsl:variable name="testimonies" select="current-group()[@testimony]" as="element()*"/>
						<xsl:variable name="testimony-part">
							<xsl:for-each-group select="$testimonies" group-by=".">
								<small class="bib-testimonies">
									Entstehungszeugnisse:
									<xsl:for-each-group select="current-group()" group-by="@taxonomy">
										<xsl:value-of select="current-grouping-key()"/><xsl:text> </xsl:text>
										<xsl:for-each select="current-group()">
											<a href="/testimony/{@testimony}"><xsl:value-of select="@n"/></a>
											<xsl:if test="position() != last()">, </xsl:if>
										</xsl:for-each>
										<xsl:if test="position() != last()">; </xsl:if>
									</xsl:for-each-group>
								</small>
							</xsl:for-each-group>
						</xsl:variable>							
						<xsl:variable name="app-citations" select="current-group()[@app]" as="element()*"/>
						<xsl:variable name="app-part">
							<small class="bib-app">
								Apparat:
								<xsl:for-each select="$app-citations">
									<a href="{$edition}/print/faust.{@section}#{@app}"><xsl:value-of select="@ref"/></a>
									<xsl:if test="position() != last()">, </xsl:if>
								</xsl:for-each>								
							</small>
						</xsl:variable>
						<xsl:for-each select="$citation">
							<xsl:copy>
								<xsl:copy-of select="@*"/>
								<xsl:copy-of select="node()"/>
								<xsl:variable name="all-backref-parts" as="item()*" select="
									if ($backrefs) then $backref-part else (),
									if ($app-citations) then $app-part else (),
									if ($testimonies) then $testimony-part else ()"/>
								
								<xsl:if test="$all-backref-parts">
									<xsl:text> </xsl:text>
									<xsl:for-each select="$all-backref-parts">
										<xsl:sequence select="."/>
										<xsl:if test="position() != last()"> • </xsl:if>
									</xsl:for-each>
								</xsl:if>							
							</xsl:copy>
						</xsl:for-each>
					</xsl:for-each-group>
				</xsl:variable>
			
				<section class="center pure-g-r" data-title="Bibliographie">
					<article class="pure-u-1">
						
						<dl class="bibliography">
							<xsl:for-each select="$entries">
								<xsl:sort select="lower-case(replace(@data-citation, '(\D+)(\d*)(\D*)(\d*)', '$1'))"/>
								<xsl:sort select="    number(replace(@data-citation, '(\D+)(\d*)(\D*)(\d*)', '$2'))"/>
								<xsl:sort select="lower-case(replace(@data-citation, '(\D+)(\d*)(\D*)(\d*)', '$3'))"/>
								<xsl:sort select="    number(replace(@data-citation, '(\D+)(\d*)(\D*)(\d*)', '$4'))"/>
								<xsl:variable name="id"
									select="replace(@data-bib-uri, '^faust://bibliography/', '')"/>
								<xsl:choose>
									<xsl:when test="tokenize(@class, '\s+') = 'bib-notfound'">
										<xsl:comment>WARNING: No bibliography entry for <xsl:value-of select="."/></xsl:comment>
									</xsl:when>
									<xsl:otherwise>
										<dt id="{$id}">
											<xsl:value-of select="@data-citation"/>
											<a href="#{$id}" class="hover-link">¶</a>
										</dt>
										<xsl:sequence select="."/>										
									</xsl:otherwise>
								</xsl:choose>
							</xsl:for-each>
						</dl>
						
					</article>
				</section>				
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	
</xsl:stylesheet>
