<?xml version="1.1" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:f="http://www.faustedition.net/ns"	
	xmlns:l="http://xproc.org/library" version="1.0" name="main" type="f:fix-restore-nesting">
	<p:input port="source"/>	
	<p:input port="parameters" kind="parameter"/>
	
	<!-- Am Output-Port legen wir zu Debuggingzwecken ein XML-Dokument mit allen Varianten an -->
<!--	<p:output port="result" primary="true">
		<p:pipe port="result" step="collect-lines"/>
	</p:output>
	<p:serialization port="result" indent="true"/>
-->	
	<p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
	<p:import href="apply-edits.xpl"/>
	
	<!-- Parameter laden -->
	<p:parameters name="config">
		<p:input port="parameters">
			<p:document href="config.xml"/>
			<p:pipe port="parameters" step="main"></p:pipe>
		</p:input>
	</p:parameters>
	
	<p:identity><p:input port="source"><p:pipe port="source" step="main"/></p:input></p:identity>
	
	<p:group>
		<p:variable name="apphtml" select="//c:param[@name='apphtml']/@value"><p:pipe port="result" step="config"></p:pipe></p:variable>
	
	<cx:message log="info">
		<p:with-option name="message" select="'Reading transcript files ...'"/>
	</cx:message>
	
	<!-- 
    Wir iterieren über die Transkripteliste, die vom Skript in collect-metadata.xpl generiert wird.
    Für die Variantengenerierung berücksichtigen wir dabei jedes dort verzeichnete Transkript.
  -->
	<p:for-each>
		<p:iteration-source select="//f:textTranscript"/>
		<p:variable name="transcriptFile" select="/f:textTranscript/@href"/>
		<p:variable name="transcriptURI" select="/f:textTranscript/@uri"/>
		<p:variable name="documentURI" select="/f:textTranscript/@document"/>
		<p:variable name="type" select="/f:textTranscript/@type"/>
		<p:variable name="sigil" select="/f:textTranscript/f:idno[1]/text()"/>
		<p:variable name="sigil-type" select="/f:textTranscript/f:idno[1]/@type"/>


		<cx:message>
			<p:with-option name="message" select="concat('Reading ', $transcriptFile)"/>
		</cx:message>


		<!-- Das Transkript wird geladen ... -->
		<p:load>
			<p:with-option name="href" select="$transcriptFile"/>
		</p:load>
	
		<p:xslt>
			<p:input port="stylesheet">
				<p:document href="xslt/fix-restore-nesting.xsl"/>
			</p:input>
		</p:xslt>
		
		<p:store omit-xml-declaration="false" standalone="false">
			<p:with-option name="href" select="resolve-uri(concat('target/fixed/', $transcriptURI))"/>
		</p:store>

	</p:for-each>
	
		
	</p:group>

	
	<!-- das Stylesheet erzeugt keinen relevanten Output auf dem Haupt-Ausgabeport. -->
<!--	<p:sink>
		<p:input port="source">
			<p:pipe port="result" step="variant-fragments"/>
		</p:input>
	</p:sink>
--></p:declare-step>