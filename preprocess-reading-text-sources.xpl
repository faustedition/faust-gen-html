<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
	type="f:preprocess-reading-text-sources"
	xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:pxp="http://exproc.org/proposed/steps"
	xmlns:pxf="http://exproc.org/proposed/steps/file" xmlns:f="http://www.faustedition.net/ns"
	xmlns:ge="http://www.tei-c.org/ns/geneticEditions" xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:l="http://xproc.org/library" name="main" version="2.0">
	
	<!-- 
	
		This pipeline preprocesses a single input document that is to be partial source
		for the reading text. Especially, all steps involving standoff markup or header
		contents must happen here, since the document assembly doesn't 
	
	-->
	
	<p:input port="source" primary="true"/>
	<p:output port="result" primary="true"/>
	
	<!-- Transformationsschritte aus apply-edits.xpl -->
	<p:xslt>
		<p:input port="stylesheet">
			<p:document href="xslt/normalize-characters.xsl"/>
		</p:input>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
	</p:xslt>
	
	<!-- Vereinheitlicht die Transpositionsdeklarationen im Header -->
	<p:xslt>
		<p:input port="stylesheet">
			<p:document href="xslt/textTranscr_pre_transpose.xsl"/>
		</p:input>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
	</p:xslt>
	
	<!-- Führt die Transpositionen aus -->
	<p:xslt>
		<p:input port="stylesheet">
			<p:document href="xslt/textTranscr_transpose.xsl"/>
		</p:input>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
	</p:xslt>
	
	<!-- Emendationsschritte für <del> etc. -->
	<p:xslt initial-mode="emend">
		<p:input port="stylesheet">
			<p:inline>
				<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
					version="2.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
					
					<xsl:include href="xslt/emend-core.xsl"/>
					
					<xsl:template match="choice[abbr|expan]" priority="4.0" mode="emend">
						<!-- Später, cf. #111 -->
						<xsl:copy>
							<xsl:apply-templates select="@*, node()" mode="#current"/>
						</xsl:copy>
					</xsl:template>
					
					<xsl:template match="*[@ge:stage='#posthumous']" priority="10.0"
						mode="#all">
						<xsl:copy-of select="."/>
					</xsl:template>
					
					<xsl:template match="choice[sic]" mode="emend">
						<xsl:copy>
							<xsl:apply-templates select="@*, node()" mode="#current"/>
						</xsl:copy>
					</xsl:template>
					
				</xsl:stylesheet>
			</p:inline>
		</p:input>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
	</p:xslt>
	
	<!-- Emendationsschritte für <delSpan> etc. -->
	<p:xslt>
		<p:input port="stylesheet">
			<p:document href="xslt/text-emend.xsl"/>
		</p:input>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
	</p:xslt>
	
	<!-- leere Elemente entfernen -->
	<p:xslt>
		<p:input port="stylesheet">
			<p:document href="xslt/clean-up.xsl"/>
		</p:input>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
	</p:xslt>
	
	<!-- Komischen Whitespace rund um Interpunktionszeichen aufräumen -->
	<p:xslt>
		<p:input port="stylesheet">
			<p:document href="xslt/fix-punct-wsp.xsl"/>
		</p:input>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
	</p:xslt>
	
	<!-- join/@type='antilabe' -> l/@part=('I', 'M', 'F') -->
	<p:xslt>
		<p:input port="stylesheet">
			<p:document href="xslt/harmonize-antilabes.xsl"/>
		</p:input>
		<p:input port="parameters">
			<p:empty/>
		</p:input>
	</p:xslt>
	
	
	
	<p:identity/>
</p:declare-step>