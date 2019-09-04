<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:f="http://www.faustedition.net/ns"
	xmlns:pxf="http://exproc.org/proposed/steps/file"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:j="http://www.ibm.com/xmlns/prod/2009/jsonx"
	xmlns:l="http://xproc.org/library" version="1.0" name="main" type="f:generate-search">
	<p:input port="source"/>	
	<p:input port="parameters" kind="parameter"/>
	<p:output port="result"/>
	<p:option name="paths" select="resolve-uri('paths.xml')"/>
	
	
	<p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
	<p:import href="apply-edits.xpl"/>
	
	<!-- Parameter laden -->
	<p:xslt name="config" template-name="param">
		<p:input port="source"><p:empty/></p:input>
		<p:input port="stylesheet"><p:document href="xslt/config.xsl"/></p:input>
		<p:with-param name="path_config" select="$paths"></p:with-param>
	</p:xslt>
	
	<p:identity name="source"><p:input port="source"><p:pipe port="source" step="main"/></p:input></p:identity>
	
	<p:group name="body">
		<p:variable name="apphtml" select="//c:param[@name='apphtml']/@value"><p:pipe port="result" step="config"></p:pipe></p:variable>
		<p:variable name="builddir" select="resolve-uri(//c:param[@name='builddir']/@value)"><p:pipe port="result" step="config"/></p:variable>
		
	
	<cx:message log="info">
		<p:with-option name="message" select="'Adding generated markup to transcripts ...'"/>
	</cx:message>
		
	<!-- Zunächst sortieren wir die Transkripteliste chronologisch -->
	<p:xslt name="sort-transcripts">
		<p:input port="stylesheet"><p:inline>
			<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
				<xsl:import href="xslt/utils.xsl"/>
				
				<xsl:template match="/*">
					<xsl:copy>
						<xsl:copy-of select="@*"/>
						<xsl:perform-sort select="*">
							<xsl:sort select="number(f:get-wit-index(@sigil_t))"/>
						</xsl:perform-sort>
					</xsl:copy>
				</xsl:template>			
			</xsl:stylesheet>
		</p:inline></p:input>
		<p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
	</p:xslt>
	
	<!-- 
    Wir iterieren über die Transkripteliste, die vom Skript in collect-metadata.xpl generiert wird.
    Für die Variantengenerierung berücksichtigen wir dabei jedes dort verzeichnete Transkript.
  -->
	<p:for-each>
		<p:iteration-source select="//f:textTranscript"/>
		<p:variable name="transcriptFile" select="/f:textTranscript/@href"/>
		<p:variable name="transcriptURI" select="/f:textTranscript/@uri"/>
		<p:variable name="sigil_t" select="/f:textTranscript/@sigil_t"/>
		<p:variable name="documentURI" select="/f:textTranscript/@document"/>
		<p:variable name="type" select="/f:textTranscript/@type"/>
		<p:variable name="sigil" select="/f:textTranscript/f:idno[1]/text()"/>
		<p:variable name="sigil-type" select="/f:textTranscript/f:idno[1]/@type"/>
		<p:variable name="number" select="/f:textTranscript/@number"/>


		<!--<cx:message>
			<p:with-option name="message" select="concat('Adding generated markup to ', $sigil, ' (', $transcriptFile, ')')"/>
		</cx:message>-->


		<!-- Das Transkript wird geladen ... -->
		<p:load>
			<p:with-option name="href" select="$transcriptFile"/>
		</p:load>
		
		<p:xslt name="add-metadata">
			<p:input port="stylesheet">
				<p:document href="xslt/add-metadata.xsl"/>
			</p:input>
			<p:with-param name="documentURI" select="$documentURI"/>
			<p:with-param name="type" select="$type"/>
			<p:with-param name="transcriptURI" select="$transcriptURI"/>
			<p:with-param name="number" select="$number"/>
			<p:with-param name="sigil_t" select="$sigil_t"/>
			<p:input port="parameters">
				<p:pipe port="result" step="config"/>            
			</p:input>
		</p:xslt>
		
		
		<p:choose>
			
			
			<p:when test="$type = 'lesetext'">
				<p:identity/>
			</p:when>
			
			<p:otherwise>
				
				
				<!-- Wir suchen die Transkriptnummern aus den <pb>s heraus, bzw. versuchen das -->
				<p:xslt name="pbs">
					<p:input port="stylesheet">
						<p:document href="xslt/resolve-pb.xsl"/>
					</p:input>
					<p:with-param name="documentURI" select="$documentURI"></p:with-param>			
					<p:input port="parameters">
						<p:pipe port="result" step="config"/>            
					</p:input>
				</p:xslt>
				
				
			</p:otherwise>
		</p:choose>
		
		<p:identity name="prepared-xml"/>
		
		<!-- erste Kopie: Unnormalisierte Zeichen zum Weiterarbeiten -->
		<p:store>
			<p:with-option name="href" select="resolve-uri(concat('prepared/textTranscript/', $sigil_t, '.xml'), $builddir)"/>
		</p:store>
		
		<p:identity><p:input port="source"><p:pipe port="result" step="prepared-xml"/></p:input></p:identity>

		<!-- Ansonsten nur Zeichen normalisieren -->
		<p:xslt name="normalize-characters">
			<p:input port="stylesheet">
				<p:document href="xslt/normalize-characters.xsl"/>
			</p:input>
			<p:input port="parameters">
				<p:pipe port="result" step="config"/>            
			</p:input>
		</p:xslt>
		
		<!-- Notes aus dem Lesetext für die Suche wieder rauswerfen -->
		<p:choose>
			<p:when test="$sigil_t = 'faust'">
				<p:delete match="tei:note[@type='textcrit']"/>
			</p:when>
			<p:otherwise>
				<p:identity/>
			</p:otherwise>
		</p:choose>


		<!-- zweite Kopie: Normalisierte Zeichen für die Suche -->
		<p:store>
			<p:with-option name="href" select="resolve-uri(concat('search/textTranscript/', $sigil_t, '.xml'), $builddir)"/>
		</p:store>		
		
		<p:identity><p:input port="source"><p:pipe port="result" step="prepared-xml"/></p:input></p:identity>
		
		<!-- Hack: Generierung der Bargraph-Informationen -->
		<p:choose>
			<p:when test="$type != 'lesetext' and not(contains($documentURI, 'test.xml'))">
				<p:xslt name="bargraph-info">
					<p:input port="stylesheet"><p:document href="xslt/create-bargraph-info.xsl"/></p:input>
					<p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
				</p:xslt>
			</p:when>
			<p:otherwise>
				<p:identity>
					<p:input port="source">
						<p:empty/>
					</p:input>
				</p:identity>
			</p:otherwise>
		</p:choose>

	</p:for-each>
	

	<p:wrap-sequence wrapper="f:documents"/>
	<p:xslt>
		<p:input port="stylesheet">
			<p:inline>
				<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
					<xsl:strip-space elements="*"/>
					<xsl:output method="text"/>
					<xsl:template match="/*">
						<wrapper>
						<xsl:text>[</xsl:text>
						<xsl:for-each select="*">
							<xsl:value-of select="."/>
							<xsl:if test="position() != last()">,</xsl:if>
						</xsl:for-each>
						<xsl:text>]</xsl:text>
						</wrapper>
					</xsl:template>
				</xsl:stylesheet>
			</p:inline>
		</p:input>
		<p:input port="parameters"><p:empty/></p:input>
	</p:xslt>
	
	<p:store method="text">
		<p:with-option name="href" select="resolve-uri('www/data/genetic_bar_graph.json', $builddir)"/>
	</p:store>

	
	</p:group>
	
	<p:identity><p:input port="source"><p:pipe port="result" step="source"></p:pipe></p:input></p:identity>

</p:declare-step>
