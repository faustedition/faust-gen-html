<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:f="http://www.faustedition.net/ns"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:cx="http://xmlcalabash.com/ns/extensions"
	xmlns:pxp="http://exproc.org/proposed/steps"
	xmlns:l="http://xproc.org/library"
	type="f:apparatus"
	name="main" version="1.0">
	<p:input port="source" primary="true"/>
	<p:input port="parameters" kind="parameter"/>
	<p:output port="result" primary="true" sequence="true">
		<p:pipe port="result" step="body"/>
	</p:output>
	
	<p:option name="basename" select="''">
		<p:documentation>Basis for the filename of the result documents. Must be relative
			to the $html parameter, and must not include a trailing .html</p:documentation>
	</p:option>	
	<p:serialization port="result" method="xhtml" indent="true" omit-xml-declaration="false"
		include-content-type="true"/>
	
	<p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
	<p:import href="library/store.xpl"/>	

	<!-- Parameter laden -->
	<p:parameters name="config">
		<p:input port="parameters">
			<p:document href="config.xml"/>
			<p:pipe port="parameters" step="main"/>
		</p:input>
	</p:parameters>
	<p:identity><p:input port="source"><p:pipe port="source" step="main"/></p:input></p:identity>
	
	<!-- wir müssen ein paar der Parameter auswerten: -->
	<p:group name="body">
		<p:output port="result" sequence="true"/>

		
		<!-- $html -> das Verzeichnis für die Ausgabedateien -->
		<p:variable name="html" select="resolve-uri(//c:param[@name='apphtml']/@value)">
			<p:pipe port="result" step="config"/>
		</p:variable>
		
		<p:variable name="output-base" select="resolve-uri(concat('./', $basename), $html)"></p:variable>		
		
		<!-- Antilaben in die Form mit part=I,M,F -->
		<p:xslt name="antilabes">
			<p:input port="stylesheet">
				<p:document href="xslt/harmonize-antilabes.xsl"/>
			</p:input>
			<p:input port="parameters">
				<p:pipe port="result" step="config"/>
			</p:input>
		</p:xslt>
		
		<!-- transpose/ptr/@target="bla fasel blubb" in mehrere ptr mit je einem Target umwandeln -->
		<p:xslt name="transpositions">
			<p:input port="stylesheet">
				<p:document href="xslt/textTranscr_pre_transpose.xsl"/>
			</p:input>
			<p:input port="parameters">
				<p:pipe port="result" step="config"/>
			</p:input>
		</p:xslt>
		
		

		<!-- Nun die eigentliche Transformation nach HTML. -->
		<p:xslt name="html">
			<p:input port="stylesheet">
				<p:document href="xslt/apparatus.xsl"/>
			</p:input>
			<p:input port="parameters">
				<p:pipe port="result" step="config"/>
			</p:input>
			<p:with-param name="output-base" select="$output-base"/>
		</p:xslt>
		
		<!-- Wir setzen jetzt noch den Dateinamen an die Hauptausgabedatei. -->
		<pxp:set-base-uri name="output">
			<p:with-option name="uri" select="concat($output-base, '.html')"/>
		</pxp:set-base-uri>

		<!-- Nun speichern wir die per <result-document> generierten Dateien. -->
		<p:for-each name="save">
			<p:output port="result">
				<p:pipe port="result" step="store"></p:pipe>
			</p:output>
			
			<p:iteration-source>
				<p:pipe step="output" port="result"/>
				<p:pipe step="html" port="secondary"/>
			</p:iteration-source>

			<!--cx:message>
				<p:with-option name="message" select="concat('Saving ', p:base-uri())"/>
			</cx:message-->

			<p:store name="store" method="xhtml" indent="true" include-content-type="true">
				<p:with-option name="href" select="p:base-uri()"/>
			</p:store>
		</p:for-each>
		
	</p:group>

</p:declare-step>
