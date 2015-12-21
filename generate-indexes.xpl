<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns:c="http://www.w3.org/ns/xproc-step" 
	type="f:generate-indexes"
	name="main"
	version="1.0">
	<p:input port="source"/>
	<p:input port="parameters" kind="parameter"/>
	<p:output port="result" sequence="true">
		<p:pipe port="result" step="end"/>
	</p:output>
	
	<!-- Parameter laden -->
	<p:parameters name="config">
		<p:input port="parameters">
			<p:document href="config.xml"/>
			<p:pipe port="parameters" step="main"></p:pipe>
		</p:input>
	</p:parameters>
	
	<p:group name="body">
		<p:variable name="source" select="//c:param[@name='source']/@value"><p:pipe port="result" step="config"/></p:variable>
		<p:variable name="html" select="//c:param[@name='html']/@value"><p:pipe port="result" step="config"/></p:variable>

	
		<p:identity name="transcripts">
			<p:input port="source">
				<p:pipe port="source" step="main"/>
			</p:input>
		</p:identity>
		
		<!-- TODO more refactoring, less copypaste -->
		<p:xslt name="index">
			<p:input port="source">
				<p:pipe port="result" step="transcripts"/>
			</p:input>
			<p:input port="stylesheet">
				<p:document href="xslt/index.xsl"/>
			</p:input>
			<p:input port="parameters">
				<p:pipe port="result" step="config"/>
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
				<p:document href="xslt/index.xsl"/>
			</p:input>
			<p:input port="parameters">
				<p:pipe port="result" step="config"/>
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
				<p:document href="xslt/index.xsl"/>
			</p:input>
			<p:input port="parameters">
				<p:pipe port="result" step="config"/>
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
				<p:document href="xslt/index.xsl"/>
			</p:input>
			<p:input port="parameters">
				<p:pipe port="result" step="config"/>
			</p:input>
			<p:with-param name="type" select="'archivalDocument'"/>
		</p:xslt>		
		<p:store method="xhtml" include-content-type="true" indent="true">
			<p:with-option name="href" select="concat($html, 'archivalDocuments.html')"/>		
		</p:store>
		
			
	</p:group>
	
	<p:identity name="end">
		<p:input port="source">
			<p:empty/>
		</p:input>
	</p:identity>
	

</p:declare-step>