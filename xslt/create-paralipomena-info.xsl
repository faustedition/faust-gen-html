<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	xmlns:f="http://www.faustedition.net/ns"
	exclude-result-prefixes="xs f"
	version="2.0">


	<!-- 
	
		Collect the paralipomena from the textual transcripts and write a JSON table of them.
		
		This script can be called in two ways:
		
		(1) provided with a single TEI document.		
		    In this scenario, it writes a <f:document> element containing <f:item>s with the 
		    JSON excerpt for each paralipomenon
		    
		(2) with the start template `collection` and a collection of TEI documents as default collection.
	        It will then write a <f:document> containing a sorted JSON excerpt for all the stuff.
	        
	     Input format
	     ============
	     
	     All input XML files need to be preprocessed using add-metadata.xsl. Ideally, they would be 
	     the emended files, since we don't do anything to perform emendation when extracting text content.
	     
	     
	     Output format
	     =============
	     
	     JSON list of items in the following form:
	     
		   {
		      "n" : "  1",                    // Paralipomenon number
		      "sigil" : "H P1",               // Faustedition sigil
		      "uri" : "faust://xml/document/paralipomena/gsa_390720.xml",   // document URI
		      "text" : "Ideales ſtreben nach Einwircken und" // Incipit, first $incipit_words words
		   },

		 Please note the n values are left-padded with spaces to become lexicographically sortable.     	     
	
	-->
	
	
	<xsl:import href="emend-core.xsl"/>

	<xsl:param name="incipit_words" as="xs:integer">5</xsl:param>
	
	
		
	<xsl:output method="xml"/>
	
	<!-- We don't want anything that is pointed to by a @next attribute -->
	<xsl:key name="next" match="*[@next]" use="substring(@next, 2)"/>
	
	<!-- Iterate over collection. -->	
	<xsl:template name="collection">
		<xsl:variable name="documents">
			<xsl:for-each select="collection()">
				<xsl:call-template name="document"/>
			</xsl:for-each>
		</xsl:variable>
		
		<xsl:variable name="items">
			<xsl:perform-sort select="$documents/*">
				<xsl:sort select="@n"/>
			</xsl:perform-sort>
		</xsl:variable>
		
		<!-- f:json is required for XProc processing, will be removed by p:store -->
		<f:json>
			<xsl:text>var paralipomena = [&#10;</xsl:text>
			<xsl:value-of select="string-join($items/*, ',&#10;')"/>
			<xsl:text>]</xsl:text>
		</f:json>
	</xsl:template>
	
	<!-- entry point for single-document call -->
	<xsl:template match="/">
		<f:document>
			<xsl:apply-templates/>
		</f:document>
	</xsl:template>
	
	<!-- collect paralipomena from each document -->
	<xsl:template match="TEI" name="document">
		<xsl:variable name="uri" select="//idno[@type='fausturi']"/>
		<xsl:variable name="sigil" select="//idno[@type='faustedition']"/>		
			<xsl:for-each select="//milestone[@unit='paralipomenon' and not(@xml:id and key('next', @xml:id))]">			
				<xsl:variable name="no" select="f:pad-para-no(replace(@n, 'p(\d+)', '$1'))"/>
				<xsl:variable name="spanTo" select="document(current()/@spanTo)"/>
				<xsl:variable name="rawContent" as="node()*"> <!-- XML nodes within the paralipomenon -->
					<xsl:choose>
						<xsl:when test="count($spanTo) eq 1">
							<xsl:sequence select="following::node()[$spanTo >> .]"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:message select="concat('WARNING: Paralipomenon ', $no, ' in ', $sigil, ': spanTo points to ', count($spanTo), ' nodes!')"/>
							<xsl:sequence select="following::node()"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<xsl:variable name="emendedContent">
					<xsl:apply-templates mode="emend" select="$rawContent except $rawContent/node()"/>
				</xsl:variable>
				<xsl:variable name="rawText"> <!-- Plain text within the paralipomenon -->
					<xsl:apply-templates select="$emendedContent" mode="text"/>
				</xsl:variable>
				
				
				<!-- extract first $incipit_words tokens -->
				<xsl:variable name="words" select="tokenize(normalize-space(string-join($rawText, '')), ' ')"/>
				<xsl:variable name="text" select="$words[position() le $incipit_words + count($words[position() le $incipit_words + 2][. = '/'])]"/>
				
<!--				<xsl:message select="concat('&#10;&#10;&#10;######################## ', $no, '&#9;', $sigil, '&#9;', string-join($text, ' '), ' ######################')"/>
				<xsl:message select="$rawContent"/>
-->				<f:item n="{$no}"> <!-- @n used for sorting -->
					<xsl:text>{</xsl:text>
					<xsl:text>"n":"</xsl:text>		
					<xsl:value-of select="$no"/><xsl:text>",</xsl:text>
					<xsl:text>"sigil":"</xsl:text>	
					<xsl:value-of select="$sigil"/><xsl:text>",</xsl:text>
					<xsl:text>"id":"</xsl:text>	
					<xsl:value-of select="concat('para_', normalize-space($no), '_', id('sigil_n'))"/><xsl:text>",</xsl:text>					
					<xsl:text>"uri":"</xsl:text>     
					<xsl:value-of select="$uri"/><xsl:text>",</xsl:text>
					<xsl:text>"page":"</xsl:text>
					<xsl:value-of select="preceding::pb[1]/@f:docTranscriptNo"/><xsl:text>",</xsl:text>
					<xsl:text>"line":"</xsl:text><xsl:value-of select="following::*[f:hasvars(.)][1]/@n"/><xsl:text>",</xsl:text>
					<xsl:text>"text":"</xsl:text>
					<xsl:value-of select="$text"/><xsl:text>"</xsl:text>
					<xsl:text>}</xsl:text>
				</f:item>
			</xsl:for-each>
	</xsl:template>
	
	<!-- 
		Left-pads the para number with spaces such that the numeric parts are always 3 chars wide. i.e. "5a" -> "  5a".
		Makes the "alphabetical" order (i.e. by codepoint) match the intended semantics. 
	-->
	<xsl:function name="f:pad-para-no" as="xs:string">
		<xsl:param name="n"/>
		<xsl:variable name="result">
			<xsl:analyze-string select="$n" regex="^\d+">
				<xsl:matching-substring>
					<xsl:choose>
						<xsl:when test="string-length(.) = 2"><xsl:text> </xsl:text></xsl:when>
						<xsl:when test="string-length(.) = 1"><xsl:text>  </xsl:text></xsl:when>					
					</xsl:choose>
					<xsl:value-of select="."/>
				</xsl:matching-substring>
				<xsl:non-matching-substring>
					<xsl:copy/>
				</xsl:non-matching-substring>
			</xsl:analyze-string>
		</xsl:variable>
		<xsl:value-of select="string-join($result, '')"/>
	</xsl:function>
	
	
	<!-- 
		
		The following templates in mode="text" allow to customize the content that is used to form the incipit.
	
	-->
	
	<xsl:template mode="text" match="l|p|head|stage">
		<xsl:apply-templates mode="#current"/>
		<xsl:if test="position() != last()">
			<xsl:text> / </xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template mode="text" match="speaker|label"/>
	
</xsl:stylesheet>
