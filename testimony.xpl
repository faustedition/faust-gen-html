<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:c="http://www.w3.org/ns/xproc-step"
	xmlns:cx="http://xmlcalabash.com/ns/extensions" xmlns:f="http://www.faustedition.net/ns"
	xmlns:pxf="http://exproc.org/proposed/steps/file"
	xmlns:l="http://xproc.org/library" type="f:testimony" name="main" version="1.0">
	
	<p:input port="source"><p:empty/></p:input>
	<p:input port="parameters" kind="parameter"/>
	

	
	
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
				
		<l:recursive-directory-list name="ls">
			<p:with-option name="path" select="concat($source, '/testimony')"/>
			<p:with-option name="include-filter" select="'^\w\S+$'"/>
			<p:with-option name="exclude-filter" select="'.*\.html$'"></p:with-option>
		</l:recursive-directory-list>
				
		<p:for-each name="convert-testimonies">
			<p:iteration-source select="//c:file[$debug or not(ends-with(@name, 'test.xml'))]"/>
			<p:variable name="filename" select="p:resolve-uri(/c:file/@name)"/>
			<p:variable name="basename" select="replace(replace($filename, '.*/', ''), '.xml$', '')"/>
			<p:variable name="outfile" select="p:resolve-uri(concat($basename, '.html'), $testihtml)"/>
			
			<p:load name="load">
				<p:with-option name="href" select="$filename"/>
			</p:load>
					
			<p:xslt name="generate-html">
				<p:input port="stylesheet"><p:document href="xslt/testimony2html.xsl"/></p:input>
				<p:with-param name="builddir-resolved" select="$builddir"/>
				<p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
			</p:xslt>
			
			<p:store encoding="utf-8" method="xhtml" include-content-type="false" indent="true">
				<p:with-option name="href" select="$outfile"/>
			</p:store>
			
			
			<p:xslt>
				<p:input port="source"><p:pipe port="result" step="load"/></p:input>			
				<p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
				<p:with-param name="from" select="replace($filename, concat('^', $source), 'faust://xml/')"/>
				<p:with-param name="outfile" select="$outfile"/>
				<p:input port="stylesheet">
					<p:inline>
						<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
							<xsl:param name="from"/>
							<xsl:param name="outfile"/>
							<xsl:template match="/">
								<f:testimonies>
									<xsl:for-each select="//milestone[@unit='testimony']">								
										<f:testimony from="{$from}" html="{$outfile}" id="{@xml:id}"><xsl:value-of select="normalize-space((following::rs)[1])"/></f:testimony>                      										
									</xsl:for-each>
								</f:testimonies>
							</xsl:template>              
						</xsl:stylesheet>
					</p:inline>
				</p:input>
			</p:xslt>      
		</p:for-each>
		
		<p:identity name="testimony-index"/>
		
		<p:wrap-sequence wrapper="f:testimony-index" name="wrapped-testis">
			<p:input port="source">
				<p:pipe port="result" step="testimony-index"/>				
			</p:input>
		</p:wrap-sequence>
		
		<p:unwrap match="f:testimonies"/>
		
		<p:store method="xml" include-content-type="false" indent="true">
			<p:with-option name="href" select="resolve-uri('testimony-index.xml', $builddir)"/>
		</p:store>
			
	
	</p:group>
	
	
	
</p:declare-step>
