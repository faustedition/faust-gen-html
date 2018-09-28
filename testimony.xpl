<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:f="http://www.faustedition.net/ns"
	xmlns:pxf="http://exproc.org/proposed/steps/file"
	xmlns:l="http://xproc.org/library" type="f:testimony" name="main" version="1.0">
	
	<p:input port="source"><p:empty/></p:input>
	<p:input port="parameters" kind="parameter"/>
	<p:output port="result" primary="true"/>

	
	
	<p:import href="http://xproc.org/library/recursive-directory-list.xpl"/>
	<p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
	
	<!-- Parameter laden -->
	<p:parameters name="config">
		<p:input port="parameters">
			<p:document href="config.xml"/>
			<p:pipe port="parameters" step="main"></p:pipe>
		</p:input>
	</p:parameters>
	
	<p:group>
		<p:variable name="source" select="//c:param[@name='source']/@value"><p:pipe port="result" step="config"/></p:variable>
		<p:variable name="debug" select="//c:param[@name='debug']/@value"><p:pipe port="result" step="config"/></p:variable>
		<p:variable name="builddir" select="resolve-uri(//c:param[@name='builddir']/@value)"><p:pipe port="result" step="config"/></p:variable>
		<p:variable name="testihtml" select="concat($builddir, 'www/testimony/')"><p:pipe port="result" step="config"></p:pipe></p:variable>
		<cx:message log="info">  
			<p:input port="source"><p:pipe port="source" step="main"></p:pipe></p:input>      
			<p:with-option name="message" select="concat('Collecting testimony from ', $source)"/>
		</cx:message>

		<!-- Recursively list all files in testimony/**/*.xml -->
		<l:recursive-directory-list name="ls">
			<p:with-option name="path" select="concat($source, '/testimony')"/>
			<p:with-option name="include-filter" select="'^\w\S+$'"/>
			<p:with-option name="exclude-filter" select="'.*\.html$'"></p:with-option>
		</l:recursive-directory-list>
				
		<!-- Convert each file to HTML -->
		<p:for-each name="convert-testimonies">
			<p:iteration-source select="//c:file[$debug or not(ends-with(@name, 'test.xml'))]"/>
			<p:variable name="filename" select="p:resolve-uri(/c:file/@name)"/>
			<p:variable name="basename" select="replace(replace($filename, '.*/', ''), '.xml$', '')"/>
			<p:variable name="outfile" select="p:resolve-uri(concat($basename, '.html'), $testihtml)"/>
			
			<p:load name="load-testimony">
				<p:with-option name="href" select="$filename"/>
			</p:load>

			
			<p:xslt name="testimony-xml">
				<p:with-option name="output-base-uri" select="p:base-uri()"/>
				<p:input port="source"><p:pipe port="result" step="load-testimony"/></p:input>
				<p:input port="stylesheet"><p:document href="xslt/normalize-characters.xsl"/></p:input>
				<p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
			</p:xslt>			
			
			<p:xslt name="split-testimony">
				<p:with-option name="output-base-uri" select="p:base-uri()"/>			
				<p:input port="stylesheet"><p:document href="xslt/testimony-split.xsl"/></p:input>
				<p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
				<p:with-param name="builddir-resolved" select="$builddir"/>
				<p:with-param name="source-uri" select="$filename"/>
			</p:xslt>
			<p:sink/>
			<p:for-each>
				<p:iteration-source>
					<p:pipe port="secondary" step="split-testimony"/>
				</p:iteration-source>
				<p:variable name="base-uri" select="p:base-uri()"/>
				
				<p:identity name="single-testimony-tei"/>
				
				<p:store indent="true">
					<p:with-option name="href" select="p:base-uri()"/>
				</p:store>
				
				<p:xslt>
					<p:input port="source"><p:pipe port="result" step="single-testimony-tei"/></p:input>
					<p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
					<p:input port="stylesheet"><p:document href="xslt/single-testimony-html.xsl"/></p:input>
					<p:with-param name="builddir-resolved" select="$builddir"></p:with-param>
				</p:xslt>
				
				<p:store encoding="utf-8" method="xhtml" include-content-type="false" indent="true">
					<p:with-option name="href" select="p:resolve-uri(replace(p:base-uri(), '.*/([^/.]*)\.xml$', '$1.html'), $testihtml)"/>
				</p:store>
				
				<!-- For search, we skip the context data -->
				<p:xslt>					
					<p:input port="source"><p:pipe port="result" step="single-testimony-tei"/></p:input>
					<p:input port="stylesheet">
						<p:inline>
							<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
								<xsl:template match="/TEI/text">
									<xsl:apply-templates select="group/text[@copyOf]"/>
								</xsl:template>
								<xsl:template match="node()|@*">
									<xsl:copy copy-namespaces="no">
										<xsl:apply-templates select="@*, node()"/>
									</xsl:copy>
								</xsl:template>
							</xsl:stylesheet>
						</p:inline>
					</p:input>
					<p:input port="parameters"><p:empty/></p:input>
				</p:xslt>
							
				<p:store encoding="utf-8" method="xhtml" include-content-type="false" indent="true">
					<p:with-option name="href" select="p:resolve-uri(replace($base-uri, '.*/([^/.]*)\.xml$', '$1.xml'), concat($builddir, '/search/testimony/'))"/>
				</p:store>
				
				<!-- Now, the file we've just converted is read again and we collect all the <milestone unit='testimony' xml:id='two_part_id' -->
				<p:xslt>
					<p:input port="source"><p:pipe port="result" step="single-testimony-tei"/></p:input>			
					<p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
					<p:with-param name="from" select="replace($filename, concat('^', $source), 'faust://xml/')"/>
					<p:with-param name="outfile" select="$outfile"/>
					<p:with-param name="builddir-resolved" select="$builddir"></p:with-param>
					<p:with-option name="template-name" select="'get-citations'"></p:with-option>
					<p:input port="stylesheet"><p:document href="xslt/testimony2html.xsl"/></p:input>
				</p:xslt>      
				
			</p:for-each>
			
			<p:wrap-sequence wrapper="f:citations" name="citations-by-source"/>			
		</p:for-each>
		
		<!-- Now we've an index doc for every testimony file, join them together -->
		<p:identity name="testimony-index-parts"/>		
		<p:wrap-sequence wrapper="f:testimony-index" name="wrapped-testis">
			<p:input port="source">
				<p:pipe port="result" step="testimony-index-parts"/>				
			</p:input>
		</p:wrap-sequence>		
		<p:unwrap match="f:citations" name="testimony-index"/>		
		
		<!-- We save this for debugging purposes, but its also the input for the next step -->
		<p:store method="xml" include-content-type="false" indent="true">
			<p:with-option name="href" select="resolve-uri('testimony-index.xml', $builddir)"/>
		</p:store>
				
		<!-- now convert the table, using the usage index just collected ... -->
		<p:xslt name="testimony-table">
			<p:input port="stylesheet"><p:document href="xslt/testimony-table.xsl"></p:document></p:input>
			<p:input port="source"><p:pipe port="result" step="testimony-index"></p:pipe></p:input>
			<p:input port="parameters"><p:pipe port="result" step="config"/></p:input>			
			<p:with-param name="builddir-resolved" select="$builddir"/>
		</p:xslt>
		
		<!-- and directly store the resulting HTML file. -->
		<p:store method="xhtml" include-content-type="false" indent="false">
			<p:with-option name="href" select="resolve-uri('www/archive_testimonies.html', $builddir)"></p:with-option>
		</p:store>
		
		
		<p:xslt name="pseudo-testimonies" template-name="generate-pseudo-testimonies">
			<p:input port="stylesheet"><p:document href="xslt/testimony-table.xsl"></p:document></p:input>
			<p:input port="source"><p:pipe port="result" step="testimony-index"></p:pipe></p:input>
			<p:input port="parameters"><p:pipe port="result" step="config"/></p:input>			
			<p:with-param name="builddir-resolved" select="$builddir"/>
		</p:xslt>
		
		
		<!-- Store the generated fake TEI files -->
		<p:for-each>
			<p:iteration-source>
				<p:pipe port="secondary" step="pseudo-testimonies"/>
			</p:iteration-source>
			<p:variable name="base-uri" select="p:base-uri()"/>
			
			<p:identity name="pseudo-testimony-tei"/>
			
			<p:store indent="true">
				<p:with-option name="href" select="p:base-uri()"/>
			</p:store>
			
			<!-- and convert to html -->
			<p:xslt>
				<p:input port="source"><p:pipe port="result" step="pseudo-testimony-tei"/></p:input>
				<p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
				<p:input port="stylesheet"><p:document href="xslt/single-testimony-html.xsl"/></p:input>
				<p:with-param name="builddir-resolved" select="$builddir"></p:with-param>
			</p:xslt>
						
			<p:store encoding="utf-8" method="xhtml" include-content-type="false" indent="true">
				<p:with-option name="href" select="p:resolve-uri(replace($base-uri, '.*/([^/.]*)\.xml$', '$1.html'), $testihtml)"/>
			</p:store>
			
		</p:for-each>
		
		<p:identity><p:input port="source"><p:pipe port="result" step="testimony-index"/></p:input></p:identity>
	
	</p:group>
	
	
	
</p:declare-step>
