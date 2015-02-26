<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:pxp="http://exproc.org/proposed/steps"
	xmlns:pxf="http://exproc.org/proposed/steps/file"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns:l="http://xproc.org/library" name="main" version="1.0">
	
	<p:input port="source"><p:empty/></p:input>
	<p:input port="parameters" kind="parameter"/>

	<p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
	<p:import href="collect-metadata.xpl"/>
	<p:import href="collate-variants.xpl"/>
	<p:import href="print2html.xpl"/>
		
	
	<!-- Parameter laden -->
	<p:parameters name="config">
		<p:input port="parameters">
			<p:document href="config.xml"/>
			<p:pipe port="parameters" step="main"></p:pipe>
		</p:input>
	</p:parameters>
	
	<p:group>
		<p:variable name="source" select="//c:param[@name='source']/@value"><p:pipe port="result" step="config"/></p:variable>
		<p:variable name="html" select="//c:param[@name='html']/@value"><p:pipe port="result" step="config"/></p:variable>
	
		<!-- Metadaten -->
		<f:list-transcripts name="transcripts">
			<p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
		</f:list-transcripts>
		
		<!-- Variantenapparat generieren -->
		<f:collate-variants name="variants">
			<p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
		</f:collate-variants>
		<p:sink/>
		
		<!-- Faust 1 -->
		<p:load>
			<p:with-option name="href" select="concat($source, 'print/A8_IIIB18.xml')"/>
		</p:load>
		<f:print2html basename="faust1"/>
		
		<!-- Faust 2 -->
		<p:load>
			<p:with-option name="href" select="concat($source, 'transcript/gsa/391098/391098.xml')"/>
		</p:load>
		<f:print2html basename="faust2"/>
		
		<!-- jetzt könnte man die ganzen drucke machen. und ein inhaltsverzeichnis. -->		
		<p:for-each>
			<p:iteration-source select="//f:textTranscript">
				<p:pipe port="result" step="transcripts"/>
			</p:iteration-source>
			<p:variable name="transcript" select="/f:textTranscript/@href"/>
			
			<p:load>
				<p:with-option name="href" select="$transcript"/>
			</p:load>
			<f:print2html/>	<!-- basename will be detected from the source -->

		</p:for-each>
		
		<!-- Das ist mehr so'n hack mit dem Inhaltsverzeichnis. -->
		<p:xslt name="index">
			<p:input port="source">
				<p:pipe port="result" step="transcripts"/>
			</p:input>
			<p:input port="stylesheet">
				<p:document href="index.xsl"/>
			</p:input>
		</p:xslt>		
		
		<p:store method="xhtml" include-content-type="true">
			<p:with-option name="href" select="concat($html, 'index.html')"/>		
		</p:store>
		
		<!-- Assets kopieren -->
		<pxf:copy href="lesetext.css">
			<p:with-option name="target" select="concat($html, 'lesetext.css')"/>
		</pxf:copy>

	</p:group>
</p:declare-step>
