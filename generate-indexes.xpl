<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns:c="http://www.w3.org/ns/xproc-step" 
	type="f:generate-indexes"
	version="1.0">
	<p:input port="source"/>
	<p:option name="html" required="true"/>
	<p:output port="result" sequence="true">
		<p:pipe port="result" step="end"/>
	</p:output>
	
	
	<p:identity name="transcripts"/>
	
	<!-- TODO more refactoring, less copypaste -->
	<p:xslt name="index">
		<p:input port="source">
			<p:pipe port="result" step="transcripts"/>
		</p:input>
		<p:input port="stylesheet">
			<p:document href="index.xsl"/>
		</p:input>
		<p:with-param name="type" select="'overview'"/>
	</p:xslt>		
	<p:store method="xhtml" include-content-type="true" indent="true">
		<p:with-option name="href" select="concat($html, 'index.html')"/>		
	</p:store>
	
	<p:xslt name="index-prints">
		<p:input port="source">
			<p:pipe port="result" step="transcripts"/>
		</p:input>		
		<p:input port="stylesheet">
			<p:document href="index.xsl"/>
		</p:input>
		<p:with-param name="type" select="'print'"/>
	</p:xslt>		
	<p:store method="xhtml" include-content-type="true" indent="true">
		<p:with-option name="href" select="concat($html, 'prints.html')"/>		
	</p:store>
	
	<p:xslt name="index-text">
		<p:input port="source">
			<p:pipe port="result" step="transcripts"/>
		</p:input>		
		<p:input port="stylesheet">
			<p:document href="index.xsl"/>
		</p:input>
		<p:with-param name="type" select="'text'"/>
	</p:xslt>		
	<p:store method="xhtml" include-content-type="true" indent="true">
		<p:with-option name="href" select="concat($html, 'text.html')"/>		
	</p:store>
	
	
	<p:xslt name="index-ad">
		<p:input port="source">
			<p:pipe port="result" step="transcripts"/>
		</p:input>		
		<p:input port="stylesheet">
			<p:document href="index.xsl"/>
		</p:input>
		<p:with-param name="type" select="'archivalDocument'"/>
	</p:xslt>		
	<p:store method="xhtml" include-content-type="true" indent="true">
		<p:with-option name="href" select="concat($html, 'archivalDocuments.html')"/>		
	</p:store>
	
	<p:identity name="end">
		<p:input port="source">
			<p:empty/>
		</p:input>
	</p:identity>
	
</p:declare-step>