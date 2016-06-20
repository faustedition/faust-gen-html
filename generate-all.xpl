<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:pxp="http://exproc.org/proposed/steps"
	xmlns:pxf="http://exproc.org/proposed/steps/file"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:l="http://xproc.org/library" name="main" version="1.0">
	
	<p:input port="source"><p:empty/></p:input>
	<p:input port="parameters" kind="parameter"/>

	<p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
	<p:import href="http://xproc.org/library/store.xpl"/>
	<p:import href="collect-metadata.xpl"/>
	<p:import href="collate-variants.xpl"/>
	<p:import href="print2html.xpl"/>
	<p:import href="generate-indexes.xpl"/>
	<p:import href="generate-app.xpl"/>
	<p:import href="generate-search.xpl"/>
	<p:import href="generate-metadata-js.xpl"/>
	<p:import href="metadata-html.xpl"/>
	<p:import href="create-para-table.xpl"/>
	
	
	
	
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
		<p:variable name="builddir" select="resolve-uri(//c:param[@name='builddir']/@value)"><p:pipe port="result" step="config"/></p:variable>
		
		
		<!-- Archivmetadaten -->
		<p:load><p:with-option name="href" select="resolve-uri('archives.xml', resolve-uri($source))"/></p:load>
		<cx:message log="info">
			<p:with-option name="message" select="'Converting archive metadata to js...'"/>
		</cx:message>
		<p:xslt>
			<p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
			<p:input port="stylesheet"><p:document href="xslt/create-archives-metadata.xsl"/></p:input>
		</p:xslt>
		<p:store method="text">
			<p:with-option name="href" select="resolve-uri('www/data/archives.js', $builddir)"/>
		</p:store>
		
	
		<!-- Metadaten -->
		<f:list-transcripts name="transcripts">
			<p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
		</f:list-transcripts>
		
		<!-- Variantenapparat generieren -->
		<f:collate-variants name="variants">
			<p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
		</f:collate-variants>
		<p:store indent="true">
			<p:with-option name="href" select="resolve-uri('variants.xml', $builddir)"/>
		</p:store>	
		<p:store indent="true" name="store-transcript-list">
			<p:with-option name="href" select="resolve-uri('faust-transcripts.xml', $builddir)"/>
			<p:input port="source">
				<p:pipe port="result" step="transcripts"/>
			</p:input>
		</p:store>
		
		
		<!-- Faust 1 -->
		<p:load>
			<p:with-option name="href" select="concat($source, 'print/A8_IIIB18.xml')"/>
		</p:load>
		<f:print2html basename="faust1" cx:depends-on="variants">
		  <p:with-param name="type" select="'lesetext'"/>
		  <p:with-param name="title" select="'Faust I'"/>		  
		</f:print2html>
		
		<!-- Faust 2 -->
		<p:load>
			<p:with-option name="href" select="concat($source, 'transcript/gsa/391098/391098.xml')"/>
		</p:load>
		
		<p:delete match="tei:div[@type='stueck']"/>
		
		<f:print2html basename="faust2" cx:depends-on="variants">
		  <p:with-param name="type" select="'lesetext'"/>
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
		
		<!-- 
			Das Ergebnis des print2html-Schritts ist jeweils eine XML-Pagemap. Die kleben wir
			jetzt alle zusammen und machen ein einzelnes großes JSON draus.
		-->
		<p:wrap-sequence wrapper="pagemaps"/>

		<l:store>
			<!-- Zu Debug-Zwecken speichern wir mal die XML-Datei der Pagemaps -->
			<p:with-option name="href" select="resolve-uri('pagemaps.xml', $builddir)"/>
		</l:store>

		<p:xslt name="pagemap2json">
			<p:input port="stylesheet">
				<p:document href="xslt/pagelist2json.xsl"/>
			</p:input>
		</p:xslt>
		
		<p:store method="text" media-type="application/json">
			<p:with-option name="href" select="concat($html, '/pages.json')"/>
		</p:store>
		
		
		<!-- Das ist mehr so'n hack mit dem Inhaltsverzeichnis. -->
		<f:generate-indexes>
			<p:input port="source">
				<p:pipe port="result" step="transcripts"/>
			</p:input>
		</f:generate-indexes>
				
		<!-- Nun noch der Apparat -->
		<f:generate-app>
			<p:input port="source">
				<p:pipe port="result" step="transcripts"/>
			</p:input>
		</f:generate-app>
		
		<!-- Quelldaten für die Suche und die Genesegraphen -->
		<f:generate-search>
			<p:input port="source">
				<p:pipe port="result" step="transcripts"/>
			</p:input>
		</f:generate-search>
				
		<!-- Paralipomena-Tabelle -->
		<f:generate-para-table>
			<p:input port="source">
				<p:pipe port="result" step="transcripts"/>
			</p:input>		
		</f:generate-para-table>
		
		<!-- Metadaten nach HTML -->
		<f:metadata-html cx:after="store-transcript-list"/>
		
		<!-- Metadaten nach JSON -->
		<f:metadata-js cx:after="store-transcript-list"/>	
		
	</p:group>
</p:declare-step>
