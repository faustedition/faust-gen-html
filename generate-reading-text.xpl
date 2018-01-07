<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:pxp="http://exproc.org/proposed/steps"
	xmlns:pxf="http://exproc.org/proposed/steps/file" xmlns:f="http://www.faustedition.net/ns"
	xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:l="http://xproc.org/library" name="main"
	type="f:generate-reading-text" version="2.0">

	<p:input port="source">
		<p:empty/>
	</p:input>
	<p:input port="parameters" kind="parameter"/>

	<p:output port="result" sequence="true"/>



	<p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
	<p:import href="http://xproc.org/library/store.xpl"/>
	<p:import href="preprocess-reading-text-sources.xpl"/>


	<!-- Parameter laden -->
	<p:parameters name="config">
		<p:input port="parameters">
			<p:document href="config.xml"/>
			<p:pipe port="parameters" step="main"/>
		</p:input>
	</p:parameters>

	<p:group>
		<p:variable name="source" select="//c:param[@name='source']/@value">
			<p:pipe port="result" step="config"/>
		</p:variable>
		<p:variable name="html" select="//c:param[@name='html']/@value">
			<p:pipe port="result" step="config"/>
		</p:variable>
		<p:variable name="builddir" select="resolve-uri(//c:param[@name='builddir']/@value)">
			<p:pipe port="result" step="config"/>
		</p:variable>

		<p:for-each>
			<p:iteration-source select="//c:file">
				<p:inline>
					<c:directory>
						<c:file href="print/A8_IIIB18.xml"/>
						<c:file href="transcript/gsa/391098/391098.xml"/>
						<c:file
							href="transcript/dla_marbach/Cotta-Archiv_Goethe_23/Marbach_Deutsches_Literaturarchiv.xml"/>
						<c:file href="print/C(1)4_IIIB24.xml"/>
					</c:directory>
				</p:inline>
			</p:iteration-source>
			<p:variable name="source-uri" select="resolve-uri(/c:file/@href, $source)"/>

			<cx:message>
				<p:with-option name="message" select="concat('Loading ', $source-uri)"/>
			</cx:message>
			<p:load>
				<p:with-option name="href" select="$source-uri"/>
			</p:load>

			<f:preprocess-reading-text-sources/>

			<pxp:set-base-uri>
				<p:with-option name="uri" select="$source-uri"/>
			</pxp:set-base-uri>

		</p:for-each>


		<p:xslt template-name="faust">
			<p:input port="stylesheet">
				<p:document href="xslt/assemble-reading-text.xsl"/>
			</p:input>
			<p:input port="parameters">
				<p:inline>
					<c:param-set>
						<c:param name="use-collection" value="true"/>
					</c:param-set>
				</p:inline>
			</p:input>
		</p:xslt>


		<p:xslt>
			<p:input port="stylesheet">
				<p:document href="xslt/text-cleanup.xsl"/>
			</p:input>
			<p:input port="parameters">
				<p:empty/>
			</p:input>
		</p:xslt>

	</p:group>

</p:declare-step>
