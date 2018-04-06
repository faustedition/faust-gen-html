<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:f="http://www.faustedition.net/ns"
	xmlns:pxf="http://exproc.org/proposed/steps/file"
	xmlns:l="http://xproc.org/library" version="1.0" name="main" type="f:generate-app">
	<p:input port="source"/>	
	<p:input port="parameters" kind="parameter"/>
	
	<!-- Am Output-Port legen wir zu Debuggingzwecken ein XML-Dokument mit allen Varianten an -->
<!--	<p:output port="result" primary="true">
		<p:pipe port="result" step="collect-lines"/>
	</p:output>
	<p:serialization port="result" indent="true"/>
-->	
	<p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
    <p:import href="apparatus.xpl"/>
	
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
		<p:variable name="builddir" select="resolve-uri(//c:param[@name='builddir']/@value)"><p:pipe port="result" step="config"/></p:variable>
	
	<cx:message log="info">
		<p:with-option name="message" select="'Generating inline apparatus ...'"/>
	</cx:message>
	
	<!-- 
    Wir iterieren über die Transkripteliste, die vom Skript in collect-metadata.xpl generiert wird.
    Für die Variantengenerierung berücksichtigen wir dabei jedes dort verzeichnete Transkript.
  -->
	<p:for-each>
		<p:iteration-source select="//f:textTranscript[@type != 'lesetext']"/>
		<p:variable name="transcriptFile" select="/f:textTranscript/@href"/>
		<p:variable name="transcriptURI" select="/f:textTranscript/@uri"/>
		<p:variable name="documentURI" select="/f:textTranscript/@document"/>
		<p:variable name="type" select="/f:textTranscript/@type"/>
		<p:variable name="sigil" select="/f:textTranscript/f:idno[1]/text()"/>
		<p:variable name="sigil-type" select="/f:textTranscript/f:idno[1]/@type"/>
		<p:variable name="sigil_t" select="/f:textTranscript/@sigil_t"/>


		<!--<cx:message>
			<p:with-option name="message" select="concat('Generating inline apparatus for ', $sigil, ' (',  $transcriptFile, ')')"/>
		</cx:message>-->


		<!-- Das Transkript wird geladen ... -->
		<p:load>
			<p:with-option name="href" select="resolve-uri(concat('prepared/textTranscript/', $sigil_t, '.xml'), $builddir)"></p:with-option>			
		</p:load>

		<f:apparatus name="apparatus">
			<p:with-option name="basename" select="$sigil_t"/>
			<p:with-param name="documentURI" select="$documentURI"/>
			<p:with-param name="type" select="$type"/>
		</f:apparatus>

	</p:for-each>
	
	<p:wrap-sequence wrapper="doc"/>
	
	<p:xslt name="index-ad">
		<p:input port="source">
			<p:pipe port="source" step="main"/>
		</p:input>		
		<p:input port="stylesheet">
			<p:document href="xslt/index.xsl"/>
		</p:input>
		<p:input port="parameters">
			<p:pipe port="result" step="config"/>
		</p:input>
		<p:with-param name="type" select="'archivalDocument'"/>
	</p:xslt>
	<cx:message log="info">
		<p:with-option name="message" select="concat('Saving index: ', $apphtml, 'index.html')"/>
	</cx:message>
	<p:store method="xhtml" include-content-type="true" indent="true">
		<p:with-option name="href" select="concat($apphtml, 'index.html')"/>		
	</p:store>
	
	</p:group>

	
	<!-- das Stylesheet erzeugt keinen relevanten Output auf dem Haupt-Ausgabeport. -->
<!--	<p:sink>
		<p:input port="source">
			<p:pipe port="result" step="variant-fragments"/>
		</p:input>
	</p:sink>
--></p:declare-step>
