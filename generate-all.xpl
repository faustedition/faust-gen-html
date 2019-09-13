<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:pxp="http://exproc.org/proposed/steps"
	xmlns:pxf="http://exproc.org/proposed/steps/file"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:l="http://xproc.org/library" name="main" version="1.0">
	
	<p:input port="source"><p:empty/></p:input>
	<p:input port="parameters" kind="parameter"/>
	
	<p:output port="result" sequence="true">
		<p:empty/>
	</p:output>
	
	<p:option name="paths" select="resolve-uri('paths.xml')"/>
	
	<p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
	<p:import href="library/store.xpl"/>
	
	<p:import href="collect-metadata.xpl"/>
	<p:import href="generate-search.xpl"/>
	<p:import href="apply-edits.xpl"/>
	<p:import href="collate-variants.xpl"/>
	<p:import href="print2html.xpl"/>
	
	<p:import href="generate-app.xpl"/>
	<p:import href="generate-print.xpl"/>
	<p:import href="generate-metadata-js.xpl"/>
	<p:import href="metadata-html.xpl"/>
	<p:import href="bibliography.xpl"/>
	<p:import href="create-para-table.xpl"/>	
	<p:import href="testimony.xpl"/>
	
	<p:import href="generate-reading-text.xpl"/>
	<p:import href="generate-emendations.xpl"/>
	
	<p:import href="whoami.xpl"/>
	
	<p:import href="pages-json.xpl"/>
	<p:import href="reading-text-extras.xpl"/>
	<p:import href="indexes-and-redirects.xpl"/>
	<p:import href="bargraph.xpl"/>

<!--	
	<p:import href="generate-indexes.xpl"/>
-->	
	
	
	
	<!-- Konfiguration laden -->
	<p:xslt name="config" template-name="param">
		<p:input port="source"><p:empty/></p:input>
		<p:input port="stylesheet"><p:document href="xslt/config.xsl"/></p:input>
		<p:with-param name="path_config" select="$paths"></p:with-param>
	</p:xslt>
	
	<p:xslt name="paths" template-name="config">
		<p:input port="source"><p:empty/></p:input>
		<p:input port="stylesheet"><p:document href="xslt/config.xsl"/></p:input>
		<p:with-param name="path_config" select="$paths"></p:with-param>
	</p:xslt>
		
	<p:group>	
		<p:variable name="source" select="//f:source/text()"/>
		<p:variable name="html" select="//f:html/text()"/> <!-- traditional -->
		<p:variable name="builddir" select="//f:builddir"/>

		<f:whoami name="whoami">
			<p:with-option name="paths" select="$paths"/>
		</f:whoami>
		
		<!--Step 1a Archivmetadaten -->
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
		
		
		
		<!-- ############ STEP 1: Create list of all transcripts -->			

		<!-- Collect all transcript's metadata in an XML document. This also copies the artificial reading texts. -->
		<f:list-transcripts name="transcripts">
			<p:with-option name="paths" select="$paths"/>
		</f:list-transcripts>	
		
		
		<!-- We need to save it now, its referenced later. -->
		<l:store name="save-transcripts">
			<p:with-option name="href" select="resolve-uri('faust-transcripts.xml', $builddir)"/>
		</l:store>
		
		<!-- ## Step 1.5: Lesetext -->
		<f:generate-reading-text name="generate-reading-text"><p:with-option name="paths" select="$paths"/></f:generate-reading-text>				

		
		<!-- ############ STEP 2: Enhance all transcripts with metadata -->
		<f:generate-search name="generate-search">
			<p:input port="source"><p:pipe port="result" step="save-transcripts"/></p:input>
			<p:with-option name="paths" select="$paths"/>
		</f:generate-search>
		<!-- TODO this by side-effect also collects the bargraph information  -->
				
		<cx:message message="Creating emended versions ..."/>
		
		<!-- ############ STEP 3: Create the emended version -->
		<f:generate-emendations name="emended-version"><p:with-option name="paths" select="$paths"/></f:generate-emendations>
		
		<!-- ############## STEP 4: Creating the variant apparatus -->
		<f:collate-variants name="collate-variants"><p:with-option name="paths" select="$paths"/></f:collate-variants>
				
		<!-- ############## STEP 5a: Creating the print versions -->
		<f:generate-print name="generate-print"><p:with-option name="paths" select="$paths"/></f:generate-print>
		
		
		<!-- ############################################################################## -->
		<!-- The following steps don't depend on the full workflow, but rather only on parts. -->
		
		<!-- ### Step 1a: scene line mapping -->
		<p:xslt>
			<p:input port="source"><p:document href="xslt/scenes.xml"></p:document></p:input>
			<p:input port="stylesheet"><p:document href="xslt/scene-line-mapping.xsl"></p:document></p:input>		
		</p:xslt>
		<p:store method="text" encoding="utf-8">
			<p:with-option name="href" select="resolve-uri('www/data/scene_line_mapping.js', resolve-uri($builddir))"/>
		</p:store>
		
		<!-- ### Step 3a: Inline Apparatus -->
		<f:generate-app>
			<p:input port="source"><p:pipe port="result" step="generate-search"></p:pipe></p:input>
			<p:with-option name="paths" select="$paths"/>
		</f:generate-app>		
		
		<!-- ### Step 3b: pages.json -->
		<f:pages-json>
			<p:input port="source"><p:pipe port="result" step="generate-search"></p:pipe></p:input>
			<p:with-option name="paths" select="$paths"/>
		</f:pages-json>

		<!-- ### Step 3c-e: Reading text extras -->
		<f:reading-text-extras name="reading-text-extras">
			<p:input port="source"><p:pipe port="result" step="generate-reading-text"/></p:input>
			<p:with-option name="paths" select="$paths"/>
		</f:reading-text-extras>
		
		<!-- ### Bargraph info -->
		<f:bargraph name="bargraph">
			<p:input port="source"><p:pipe port="result" step="generate-search"/></p:input>
			<p:with-option name="paths" select="$paths"/>
		</f:bargraph>
		
		<!-- ### Step 3b: Metadata HTML -->
		<f:metadata-html name="metadata-html">
			<p:input port="source"><p:pipe port="result" step="generate-search"></p:pipe></p:input>
			<p:with-option name="paths" select="$paths"/>			
		</f:metadata-html>
		
		<!-- ### Step 2b: Metadaten nach JSON -->
		<f:metadata-js>
			<p:input port="source"><p:pipe port="result" step="generate-search"></p:pipe></p:input>			
		</f:metadata-js>
		
		
		<!-- ## Step 2d: testimony -->
		
		<f:testimony name="testimony">
			<p:input port="source"><p:pipe port="result" step="save-transcripts"></p:pipe></p:input>
			<p:with-option name="paths" select="$paths"/>
		</f:testimony>

		<!-- ## Step 2c: prints index -->
		<!-- ## Step 2e: Redirect-Tabellen für /print /meta /app -->
		<f:indexes-and-redirects name="indexes-and-redirects">
			<p:input port="source"><p:pipe port="result" step="save-transcripts"/></p:input>
			<p:with-option name="paths" select="$paths"/>
		</f:indexes-and-redirects>
		
		
		<!-- ## Step 3a: bibliography -->
		<f:bibliography>
			<p:input port="source">
				<p:pipe port="result" step="metadata-html"/>
				<p:pipe port="result" step="testimony"/>
				<p:pipe port="citations" step="reading-text-extras"/>
			</p:input>
			<p:with-option name="paths" select="$paths"/>
		</f:bibliography>
		
		<!-- ### Step 4a: Paralipomena-Tabelle -->
		<f:generate-para-table>
			<p:input port="source">
				<p:pipe port="result" step="emended-version"/>
			</p:input>
			<p:with-option name="paths" select="$paths"/>
		</f:generate-para-table>
		
		
		<!-- ### Step XXX: Wortindex -->
		<p:for-each>
			<p:iteration-source select="//f:textTranscript">
				<p:pipe port="result" step="emended-version"/>
			</p:iteration-source>
			<p:variable name="sigil_t" select="/f:textTranscript/@sigil_t"/>	
			<p:load>
				<p:with-option name="href" select="resolve-uri(concat('emended/', $sigil_t, '.xml'), $builddir)"/>
			</p:load>
		</p:for-each>		
		<p:wrap-sequence wrapper="doc" name="wrap-emended"/>
		<p:xslt name="do-word-index">
			<p:input port="stylesheet"><p:document href="xslt/word-index.xsl"/></p:input>
		</p:xslt>		
		<p:store method="xhtml" indent="true">
			<p:with-option name="href" select="resolve-uri('www/word-index.html', $builddir)"/>
		</p:store>
		<p:store method="xhtml" indent="true">
			<p:with-option name="href" select="resolve-uri('emended-texts.xml', $builddir)"/>
			<p:input port="source"><p:pipe port="result" step="wrap-emended"></p:pipe></p:input>
		</p:store>
		
		
	</p:group>
	
	<!--<p:sink/>-->
</p:declare-step>
