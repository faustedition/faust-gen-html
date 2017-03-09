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
			
			<!-- Now, the file we've just converted is read again and we collect all the <milestone unit='testimony' xml:id='two_part_id' -->
			<p:xslt>
				<p:input port="source"><p:pipe port="result" step="load"/></p:input>			
				<p:input port="parameters"><p:pipe port="result" step="config"/></p:input>
				<p:with-param name="from" select="replace($filename, concat('^', $source), 'faust://xml/')"/>
				<p:with-param name="outfile" select="$outfile"/>
				<p:with-option name="template-name" select="'get-citations'"></p:with-option>
				<p:input port="stylesheet"><p:document href="xslt/testimony2html.xsl"/></p:input>
			</p:xslt>      
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
		<p:xslt>
			<p:input port="stylesheet"><p:document href="xslt/testimony-table.xsl"></p:document></p:input>
			<p:input port="source"><p:pipe port="result" step="testimony-index"></p:pipe></p:input>
			<p:input port="parameters"><p:pipe port="result" step="config"/></p:input>			
		</p:xslt>
		
		<!-- and directly store the resulting HTML file. -->
		<p:store method="xhtml" include-content-type="false" indent="true">
			<p:with-option name="href" select="resolve-uri('www/archive_testimonies.html', $builddir)"></p:with-option>
		</p:store>
			
	
	</p:group>
	
	
	
</p:declare-step>
