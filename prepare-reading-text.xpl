<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:pxp="http://exproc.org/proposed/steps"
	xmlns:pxf="http://exproc.org/proposed/steps/file"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns:ge="http://www.tei-c.org/ns/geneticEditions"
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns:l="http://xproc.org/library" name="main" version="1.0">
	
	<p:input port="source"><p:empty/></p:input>
	<p:input port="parameters" kind="parameter"/>	
	
	
	<p:option name="user"/>
	<p:option name="password"/>
	
	
	<p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
	<p:import href="http://xproc.org/library/store.xpl"/>
	
	<p:import href="apply-edits.xpl"/>
	

	<p:identity name="config">
		<p:input port="source">
			<p:inline>
				<config>
					<!-- URL, von der die Quelldaten kommen sollen: -->
					<base>https://faustedition.uni-wuerzburg.de/xml</base>
					<!-- <base>http://dev.faustedition.net/xml</base> -->
					
					<!-- URL, unter der die transformierten Dateien
					     gespeichert werden sollen:	-->
					<target>file:/home/tv/git/faust-gen/target/prepare-reading-text/</target>
					
					<!-- Quell-Transkripte: -->
					<transcript path="transcript/test/test.xml"/>
					<transcript path="transcript/gsa/391098/391098.xml" output="2_H.xml"/>
					<transcript path="transcript/gsa/389763/389763.xml" output="2_III_H_31.xml"/>
				</config>
			</p:inline>
		</p:input>
	</p:identity>
	
	<p:group>
		<p:variable name="base" select="/config/base"/>
		<p:variable name="target" select="/config/target"></p:variable>
		<p:for-each>
			<!-- Das folgende wird pro transcript-Eintrag oben ausgeführt: -->
			<p:iteration-source select="//transcript"/>
			<p:variable name="path" select="/transcript/@path"/>
			<p:variable name="filename" select="if (/transcript/@output) 
												then /transcript/@output 
												else replace($path, '.*/([^/]+)$', '$1')"/>
			<p:variable name="output" select="resolve-uri($filename, $target)"/>
			
			<cx:message log="info">
				<p:with-option name="message" select="concat('Transforming ', $path, ' to ', $filename, ' ...')"/>
			</cx:message>
			
			<!-- XML-Datei aus dem Netz laden: -->
			<p:identity name="in"/>
			<p:in-scope-names name="vars"/>			
			<p:template>
				<p:input port="source"><p:pipe port="result" step="in"/></p:input>
				<p:input port="parameters"><p:pipe port="result" step="vars"/></p:input>
				<p:input port="template">
					<p:inline>
						<c:request 
							method="GET" 
							href="{$base}/{$path}"
							username="{$user}"
							password="{$password}"
							auth-method="Basic"
							send-authorization="true"							
						/>						
					</p:inline>
				</p:input>
			</p:template>
			<p:http-request/>
			
			
			<!-- Transformationsschritte aus apply-edits.xpl -->
			<p:xslt>
				<p:input port="stylesheet">
					<p:document href="xslt/normalize-characters.xsl"/>
				</p:input>
				<p:input port="parameters">
					<p:empty/>
				</p:input>
			</p:xslt>
			
			<!-- Vereinheitlicht die Transpositionsdeklarationen im Header -->
			<p:xslt>
				<p:input port="stylesheet">
					<p:document href="xslt/textTranscr_pre_transpose.xsl"/>
				</p:input>
				<p:input port="parameters">
					<p:empty/>
				</p:input>
			</p:xslt>
			
			<!-- Führt die Transpositionen aus -->
			<p:xslt>
				<p:input port="stylesheet">
					<p:document href="xslt/textTranscr_transpose.xsl"/>
				</p:input>
				<p:input port="parameters">
					<p:empty/>
				</p:input>
			</p:xslt>
			
			<!-- Emendationsschritte für <del> etc. -->
			<p:xslt initial-mode="emend">
				<p:input port="stylesheet">
					<p:inline>
						<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
							
							<xsl:include href="xslt/emend-core.xsl"/>
							
							<xsl:template match="*[@ge:stage='#posthumous']" priority="5.0">
								<xsl:copy>
									<xsl:apply-templates select="@*, node()"/>
								</xsl:copy>
							</xsl:template>
							
						</xsl:stylesheet>
					</p:inline>
				</p:input>
				<p:input port="parameters">
					<p:empty/>
				</p:input>
			</p:xslt>
			
			<!-- Emendationsschritte für <delSpan> etc. -->
			<p:choose>
				<p:when test="//tei:delSpan | //tei:modSpan">
					<p:xslt>
						<p:input port="stylesheet">
							<p:document href="xslt/text-emend.xsl"/>
						</p:input>
						<p:input port="parameters">
							<p:empty/>
						</p:input>
					</p:xslt>
				</p:when>
				<p:otherwise>
					<p:identity/>
				</p:otherwise>
			</p:choose>
			
			<!-- leere Elemente entfernen -->
			<p:xslt>
				<p:input port="stylesheet">
					<p:document href="xslt/clean-up.xsl"/>
				</p:input>
				<p:input port="parameters">
					<p:empty/>
				</p:input>
			</p:xslt>
			
			<!-- Komischen Whitespace rund um Interpunktionszeichen aufräumen -->
			<p:xslt>
				<p:input port="stylesheet">
					<p:document href="xslt/fix-punct-wsp.xsl"/>
				</p:input>
				<p:input port="parameters">
					<p:empty/>
				</p:input>
			</p:xslt>
			
			<!-- join/@type='antilabe' -> l/@part=('I', 'M', 'F') -->
			<p:xslt>
				<p:input port="stylesheet">
					<p:document href="xslt/harmonize-antilabes.xsl"/>      
				</p:input>
				<p:input port="parameters">
					<p:empty/>
				</p:input>
			</p:xslt>
			
			
			<!-- weitere Aufräumschritte -->
			<p:xslt>
				<p:input port="stylesheet">
					<p:inline>
						<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
										xpath-default-namespace="http://www.tei-c.org/ns/1.0"
							version="2.0">
							
							<!-- Identitätstransformation -->
							<xsl:template match="node()|@*">
								<xsl:copy>
									<xsl:apply-templates select="@*, node()"/>
								</xsl:copy>
							</xsl:template>
														
							<xsl:template match="fw"/>
														
							<xsl:template match="l/hi[@rend='big']">
								<xsl:apply-templates/>
							</xsl:template>
							
							<xsl:template match="creation"/>
							
							<!-- lb -> Leerzeichen -->
							<xsl:template match="lb">
								<xsl:if test="not(@break='no')">
									<xsl:text> </xsl:text>
								</xsl:if>
							</xsl:template>
							
						</xsl:stylesheet>
					</p:inline>
				</p:input>
				<p:input port="parameters"><p:empty/></p:input>
			</p:xslt>
			
			
			<p:store>
				<p:with-option name="href" select="$output"/>
			</p:store>
			
			
		</p:for-each>
		
	</p:group>
	
</p:declare-step>
