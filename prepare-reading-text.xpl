<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:pxp="http://exproc.org/proposed/steps"
	xmlns:pxf="http://exproc.org/proposed/steps/file" xmlns:f="http://www.faustedition.net/ns"
	xmlns:ge="http://www.tei-c.org/ns/geneticEditions" xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:l="http://xproc.org/library" name="main" version="2.0">
	
	<!-- 
	
		This pipeline loads a bunch of source input files and massages them to a form that will
		also be used by the reading text. It prepares raw files that are used to prepare the
		apparatus. 
		
		This pipeline is not part of the global pipeline to generate the edition but rather
		to be run standalone.
	
	-->

	<p:input port="source">
		<p:empty/>
	</p:input>
	<p:input port="parameters" kind="parameter"/>


	<p:option name="user"/>
	<p:option name="password"/>


	<p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
	<p:import href="http://xproc.org/library/store.xpl"/>

	<p:import href="preprocess-reading-text-sources.xpl"/>


	<p:identity name="config">
		<p:input port="source">
			<p:inline>
				<config>
					<!-- URL, von der die Quelldaten kommen sollen: -->
					<!--<base>https://faustedition.uni-wuerzburg.de/xml</base>-->
					<base>http://dev.faustedition.net/xml</base>
					<!--<base>file:/home/tv/git/faust-gen/data/xml</base>-->
					<!--					<base>file:/Users/bruening.FDH-FFM/faustedition/xml</base>-->

					<!-- URL, unter der die transformierten Dateien
					     gespeichert werden sollen:	-->
					<!--<target>file:/home/tv/git/faust-gen/target/prepare-reading-text/</target>-->
					<target>file:/Users/bruening.FDH-FFM/faustedition/xml/</target>
					<!-- Quell-Transkripte: -->
					<transcript path="transcript/test/test.xml"/>
					<transcript path="transcript/gsa/391098/391098.xml" output="h.xml"/>
					<transcript
						path="transcript/bl_oxford/MS_M_D_Mendelsson_c_21/MS_M_D_Mendelsson_c_21.xml"
						output="ih12a.xml"/>
					<transcript path="transcript/gsa/390643/390643.xml" output="h14.xml"/>
					<transcript
						path="transcript/dla_marbach/Cotta-Archiv_Goethe_23/Marbach_Deutsches_Literaturarchiv.xml"
						output="h0a.xml"/>
					<transcript path="print/C(1)4_IIIB24.xml" output="c14.xml"/>
					<transcript path="print/C(2a)4_IIIB28.xml" output="c2a4.xml"/>
					<transcript path="print/C(3)4_IIIB27.xml" output="c34.xml"/>
					<transcript path="transcript/gsa/390295/390295.xml" output="ivh1.xml"/>
					<transcript path="transcript/gsa/389863/389863.xml" output="ivh2.xml"/>
					<transcript path="transcript/gsa/389786/389786.xml" output="ivh3.xml"/>
					<transcript path="transcript/gsa/389773/389773.xml" output="ivh7.xml"/>
					<transcript path="transcript/bb_cologny/G-30_07/G-30_07.xml" output="ivh7b.xml"/>
					<transcript path="transcript/gsa/390881/390881.xml" output="ivh8.xml"/>
					<transcript path="transcript/gsa/390000/390000.xml" output="ivh10.xml"/>
					<transcript path="transcript/gsa/389992/389992.xml" output="ivh13.xml"/>
					<!-- 390690 h.15 -->
					<transcript path="transcript/gsa/391325/391325.xml" output="ivh18.xml"/>
					<transcript path="transcript/gsa/390706/390706.xml" output="ivh20.xml"/>
					<transcript path="transcript/bb_cologny/G-30_09/G-30_09.xml" output="ivh21a.xml"/>
					<transcript path="transcript/bb_cologny/G-30_10/G-30_10.xml" output="ivh22d.xml"/>
					<transcript path="transcript/bb_cologny/G-30_11/G-30_11.xml" output="ivh22e.xml"/>
					<transcript path="transcript/bb_cologny/G-30_12/G-30_12.xml" output="ivh22f.xml"/>
					<transcript path="transcript/sa_hannover/Slg_Culemann_0666/0666.xml"
						output="ivh22g.xml"/>
				</config>
			</p:inline>
		</p:input>
	</p:identity>

	<p:group>
		<p:variable name="base" select="/config/base"/>
		<p:variable name="target" select="/config/target"/>
		<p:for-each>
			<!-- Das folgende wird pro transcript-Eintrag oben ausgeführt: -->
			<p:iteration-source select="//transcript"/>
			<p:variable name="path" select="/transcript/@path"/>
			<p:variable name="filename"
				select="if (/transcript/@output) 
												then /transcript/@output 
												else replace($path, '.*/([^/]+)$', '$1')"/>
			<p:variable name="output" select="resolve-uri($filename, $target)"/>

			<cx:message log="info">
				<p:with-option name="message"
					select="concat('Transforming ', $path, ' to ', $filename, ' ...')"/>
			</cx:message>

			<p:identity name="in"/>

			<p:choose>
				<!-- XML-Datei aus dem Netz laden: -->
				<p:when test="starts-with($base, 'http')">
					<p:in-scope-names name="vars"/>
					<p:template>
						<p:input port="source">
							<p:pipe port="result" step="in"/>
						</p:input>
						<p:input port="parameters">
							<p:pipe port="result" step="vars"/>
						</p:input>
						<p:input port="template">
							<p:inline>
								<c:request method="GET" href="{$base}/{$path}" username="{$user}"
									password="{$password}" auth-method="Digest"
									send-authorization="true"/>
							</p:inline>
						</p:input>
					</p:template>
					<p:http-request/>
				</p:when>
				<p:otherwise>
					<!-- von Platte etc. -->
					<p:load>
						<p:with-option name="href" select="concat($base, '/', $path)"/>
					</p:load>
				</p:otherwise>
			</p:choose>

			<f:preprocess-reading-text-sources/>

			<!-- weitere Aufräumschritte -->
			<p:xslt>
				<p:input port="stylesheet">
					<p:document href="xslt/text-cleanup.xsl"/>
				</p:input>
				<p:input port="parameters">
					<p:empty/>
				</p:input>
			</p:xslt>

			<!-- Speichern der Einzeldatei -->
			<p:identity name="final-single-text"/>
			<p:store>
				<p:with-option name="href" select="$output"/>
			</p:store>

			<!-- Kopie der fertigen Einzeldatei soll hinten aus der for-each-Schleife fallen: -->
			<p:identity>
				<p:input port="source">
					<p:pipe port="result" step="final-single-text"/>
				</p:input>
			</p:identity>
		</p:for-each>

		<!-- alles zusammenkleben zum gemeinsamen Bearbeiten: -->
		<p:wrap-sequence wrapper="tei:teiCorpus"/>

		<p:xslt>
			<p:input port="stylesheet">
				<p:inline>
					<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
						xpath-default-namespace="http://www.tei-c.org/ns/1.0"
						xmlns="http://www.tei-c.org/ns/1.0">
						<xsl:import href="xslt/utils.xsl"/>
						<xsl:template match="/">
							<f:expan-map xmlns="http://www.tei-c.org/ns/1.0">
								<xsl:for-each-group
									select="//abbr[not(preceding-sibling::expan | following-sibling::expan)]"
									group-by="f:normalize-space(.)">
									<xsl:variable name="abbr" select="current-grouping-key()"/>
									<choice>
										<xsl:comment select="string-join(current-group()/ancestor::*[f:hasvars(.)]/@n, ', ')"/>
										<abbr>
											<xsl:value-of select="$abbr"/>
										</abbr>

										<!-- find all expansions for the current abbr elsewhere in the text -->
										<xsl:variable name="expansions">
											<xsl:for-each-group
												select="//expan[
											preceding-sibling::abbr[f:normalize-space(.) = $abbr] |
											following-sibling::abbr[f:normalize-space(.) = $abbr]
										]"
												group-by="f:normalize-space(.)">
												<expan>
												<xsl:value-of select="current-grouping-key()"/>
												</expan>
											</xsl:for-each-group>
										</xsl:variable>

										<xsl:choose>
											<xsl:when test="$expansions//expan">
												<xsl:copy-of select="$expansions"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:comment>TODO</xsl:comment>
												<expan>
												<xsl:value-of select="$abbr"/>
												</expan>
											</xsl:otherwise>
										</xsl:choose>
									</choice>
								</xsl:for-each-group>
							</f:expan-map>
						</xsl:template>
					</xsl:stylesheet>
				</p:inline>
			</p:input>
			<p:input port="parameters"/>
		</p:xslt>

		<p:store indent="true">
			<p:with-option name="href" select="resolve-uri('expan-map.xml.in', $target)"/>
		</p:store>

	</p:group>

</p:declare-step>
