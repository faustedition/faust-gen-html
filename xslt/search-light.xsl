<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xh="http://www.w3.org/1999/xhtml"
	
	xmlns:f="http://www.faustedition.net/ns"
	xmlns:ge="http://www.tei-c.org/ns/geneticEditions"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	
	xmlns:exist="http://exist.sourceforge.net/NS/exist"
	
	exclude-result-prefixes="xs f ge xh exist"
	
	version="2.0">
	
	<!-- 
	
		Mark up search results as coming from our eXist query.
		
		EXPERIMENTAL.
		
		
		The input document to this stylesheet is a search result as created by 
		the accompagnying eXist XQuery on the documents prepared by the prepare-search
		statement. 
		
		A full-text result item is formatted as follows:
		
	    <f:hit sigil="A 8" headnote="Erste Gesamtausgabe bei Cotta, 1808" type="print" n="2088" href="print/A8_IIIB18.4.html">
        	<l n="2088">A! <exist:match>tara</exist:match> lara da!</l>
    	</f:hit>

	-->
	
	<xsl:import href="apparatus.xsl"/>
	
	<xsl:output method="xhtml" indent="yes"/>
		

	<!-- Page numbers are not useful here -->
	<xsl:template name="generate-pageno"/>
	
	<!-- Line numbers that aren't exactly Ströer numbers are marked up like ~ 1234 -->
	<xsl:function name="f:display-line" as="xs:string">
		<xsl:param name="n"/>
		<xsl:value-of select="
		if (matches($n, '^\d+$')) 
			then $n 
			else replace($n, '^\D*(\d+).*$', '~ $1')"/>
	</xsl:function>
	
	<!-- Line numbers need href from f:hit and should be shown for every line -->
	<xsl:template name="generate-lineno">	
		<a href="{ancestor::*/@data-href[1]}#l{@n}" class="lineno">
			<xsl:value-of select="f:display-line(@n)"/>
		</a>		
	</xsl:template>
	
	<xsl:template match="*[f:breadcrumbs/*]">
		<xsl:copy>
			<xsl:apply-templates select="@*"/>
			<div class="subhit-content">
				<xsl:apply-templates select="node() except f:breadcrumbs"/>
			</div>
			<xsl:apply-templates select="f:breadcrumbs"/>
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="f:breadcrumbs">
		<xsl:if test="*">
			<ul class="breadcrumbs">
				<xsl:apply-templates/>
			</ul>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="f:breadcrumb">
		<li><xsl:value-of select="
			if (@n and @n = $scenes//*/@n)
			then $scenes//*[@n=current()/@n]/f:title
			else @f:label"/></li>
	</xsl:template>
	
	
	<!-- Matches are marked up & made to links. Maybe include match term in URI some time -->
	<xsl:template match="exist:match">
		<mark class="match">
			<xsl:choose>
				<xsl:when test="ancestor::a">
					<!-- We're already inside an <a> -->
					<xsl:apply-templates/>
				</xsl:when>
				<xsl:otherwise>
					<a class="match" href="{ancestor::*/@data-href[1]}#l{ancestor::*[@n][1]/@n}">
						<xsl:apply-templates/>
					</a>					
				</xsl:otherwise>
			</xsl:choose>
		</mark>
	</xsl:template>
		
	<xsl:template match="exist:exception">
		<xsl:variable name="severe" select="not(/*/*[not(self::exist:exception)])"/>
		<div class="pure-alert {if ($severe) then 'pure-alert-danger' else 'pure-alert-info pure-alert-dismissable'}">
			<h3>Fehler <xsl:value-of select="if (@where = 'sigil') then 'bei der Siglensuche' else if (@where = 'fulltext') then 'bei der Volltextsuche' else ()"/></h3>
			<p><xsl:value-of select="@code"/> | <xsl:value-of select="@location"/></p>
			<pre>
				<xsl:apply-templates/>
			</pre>
		</div>
	</xsl:template>
	
	
</xsl:stylesheet>
