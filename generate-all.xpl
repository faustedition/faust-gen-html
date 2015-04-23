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
	<p:import href="generate-indexes.xpl"/>
		
	
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
		<p:store href="target/variants.xml" indent="true"/>	
		<p:store href="target/faust-transcripts.xml" indent="true">
			<p:input port="source">
				<p:pipe port="result" step="transcripts"/>
			</p:input>
		</p:store>
		
		
		<!-- Faust 1 -->
		<p:load>
			<p:with-option name="href" select="concat($source, 'print/A8_IIIB18.xml')"/>
		</p:load>
		<f:print2html basename="faust1" cx:depends-on="variants">
		  <p:with-param name="type" select="'print'"/>
		  <p:with-param name="title" select="'Faust I'"/>		  
		</f:print2html>
		
		<!-- Faust 2 -->
		<p:load>
			<p:with-option name="href" select="concat($source, 'transcript/gsa/391098/391098.xml')"/>
		</p:load>
		<f:print2html basename="faust2" cx:depends-on="variants">
		  <p:with-param name="type" select="'archivalDocument'"/>
		  <p:with-param name="title" select="'Faust II'"/>		  
		</f:print2html>
		
		<!-- jetzt könnte man die ganzen drucke machen. und ein inhaltsverzeichnis. -->		
		<p:for-each>
			<p:iteration-source select="//f:textTranscript">
				<p:pipe port="result" step="transcripts"/>
			</p:iteration-source>
			<p:variable name="transcript" select="/f:textTranscript/@href"/>		  		  
		  <p:variable name="documentURI" select="/f:textTranscript/@document"/>
		  <p:variable name="type" select="/f:textTranscript/@type"/>
		  <p:variable name="sigil" select="/f:textTranscript/f:idno[1]/text()"/>
		  <p:variable name="sigil-type" select="/f:textTranscript/f:idno[1]/@type"/>
	  
			
			<p:try>
			  <p:group>
    			<p:load>
    				<p:with-option name="href" select="$transcript"/>
    			</p:load>
			  	<f:print2html cx:depends-on="variants">
			  	  <p:with-param name="documentURI" select="$documentURI"/>
			  	  <p:with-param name="type" select="$type"/>
			  	  <p:with-param name="title" select="$sigil"/>
			  	</f:print2html>	<!-- basename will be detected from the source -->
			  </p:group>
			  <p:catch>
			    <cx:message log="warn">
			      <p:with-option name="message" select="concat('Failed to transform ', $transcript, 'to HTML.')"/>
			    </cx:message>
			  </p:catch>
			</p:try>

		</p:for-each>
		
		<p:wrap-sequence wrapper="foo"/>
		
		<!-- Das ist mehr so'n hack mit dem Inhaltsverzeichnis. -->
		<f:generate-indexes>
			<p:input port="source">
				<p:pipe port="result" step="transcripts"/>
			</p:input>
			<p:with-option name="html" select="$html"/>
		</f:generate-indexes>		
		
		<!-- Assets kopieren -->
		<pxf:copy href="lesetext.css">
			<p:with-option name="target" select="concat($html, 'lesetext.css')"/>
		</pxf:copy>

	</p:group>
</p:declare-step>
