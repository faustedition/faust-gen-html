<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:f="http://www.faustedition.net/ns"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.faustedition.net/ns"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:param name="builddir">../../../target/</xsl:param>
    <xsl:param name="builddir-resolved" select="$builddir"/>	
    <xsl:param name="transcript-list" select="resolve-uri('faust-transcripts.xml', resolve-uri($builddir-resolved))"/>
    <xsl:param name="idmap" select="doc($transcript-list)"/>
    <xsl:param name="docbase">/document?sigil=</xsl:param>
    <xsl:param name="edition"></xsl:param>
    <xsl:param name="source-uri" select="document-uri(/)"/>
    <xsl:variable name="bibliography" select="doc('bibliography.xml')"/>
    
    
    
    <!-- 
		Liefert <cite>-Element mit Zitation.
		
		- uri: faust://bibliography-URI
		- full: wenn true() dann volle Referenz, sonst nur Autor/Jahr
	-->
    <xsl:function name="f:cite" as="element()">
        <xsl:param name="uri" as="xs:string"/>
        <xsl:param name="full" as="item()"/>
        <xsl:param name="linktext" as="item()?"/>
        <xsl:variable name="bib_" select="$bibliography//bib[@uri=$uri]"/>
        <xsl:variable name="bib" select="$bib_[1]"/>
        <xsl:if test="count($bib_) > 1">
            <xsl:message select="concat('WARNING: ', count($bib_), ' bibliography entries for ', $uri, ', ignoring all but the first')"/>
        </xsl:if>
        <xsl:variable name="id" select="replace($uri, 'faust://bibliography/', '')"/>
        <xsl:variable name="parsed-ref">
            <xsl:for-each select="$bib/reference/node()">
                <xsl:call-template name="parse-for-bib"/>
            </xsl:for-each>
        </xsl:variable>        
        <xsl:choose>
            <xsl:when test="$bib and $full">
                <xsl:element name="{$full}">
                    <xsl:attribute name="class">bib-full</xsl:attribute>
                    <xsl:attribute name="data-bib-uri" select="$uri"/>
                    <xsl:attribute name="data-citation" select="$bib/citation"/>					
                    <xsl:sequence select="$parsed-ref"/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="$bib">
                <cite class="bib-short" title="{$parsed-ref}" data-bib-uri="{string-join(($uri, $parsed-ref//*/@data-bib-uri), ' ')}">
                    <a href="{$edition}/bibliography#{$id}">
                        <xsl:choose>
                            <xsl:when test="$linktext">
                                <xsl:copy-of copy-namespaces="no" select="$linktext"/>
                            </xsl:when>
                            <xsl:otherwise>                                
                                <xsl:value-of select="$bib/citation"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </a>
                </cite>
            </xsl:when>
            <xsl:otherwise>
                <cite class="bib-notfound"><xsl:value-of select="$uri"/></cite>
                <xsl:message select="concat('WARNING: Citation not found: ', $uri, ' (in ', $source-uri, ')')"/>
            </xsl:otherwise>
        </xsl:choose>		
    </xsl:function>
    
    <xsl:function name="f:cite" as="element()">
        <xsl:param name="uri" as="xs:string"/>
        <xsl:param name="full" as="item()"/>
        <xsl:sequence select="f:cite($uri, $full, ())"/>
    </xsl:function>
        
    
    <xsl:function name="f:resolve-faust-doc" as="element()*">
        <xsl:param name="uri"/>
        <xsl:param name="transcript-list"/>
        <!-- Function doesn't resolve document parameters :-(, so let's pass this in -->
        <xsl:variable name="result" as="element()*">
            <xsl:for-each select="document($transcript-list)//idno[@uri=$uri]/..">
                <xsl:variable name="docinfo" select="."/>
                <xsl:choose>
                    <xsl:when test="$docinfo/@type='print'">
                        <a class="md-document-ref" href="../meta/{$docinfo/@sigil_t}" title="{$docinfo/headNote}">
                            <xsl:value-of select="$docinfo/@f:sigil"/>
                        </a>				
                    </xsl:when>                
                    <xsl:otherwise>
                        <a class="md-document-ref" href="{$docbase}{$docinfo/@sigil_t}" title="{$docinfo/headNote}">
                            <xsl:value-of select="$docinfo/@f:sigil"/>
                        </a>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$result">
                <xsl:sequence select="$result"/>
                <xsl:if test="count($result) > 1">
                    <xsl:message select="concat('WARNING: ', $uri, ' resolved to more than one docs: ', string-join($result, ', '))"/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <a class="pure-alert-error" title="Error: unresolved reference"><xsl:value-of select="$uri"/></a>
                <xsl:message select="concat('ERROR: Unresolved reference: ', $uri)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>		
    
    <xsl:template name="parse-for-bib">
        <xsl:analyze-string select="." regex="faust://[a-zA-Z0-9/_.-]*[a-zA-Z0-9/_-]+">
            <xsl:matching-substring>
                <xsl:variable name="uri" select="."/>
                <xsl:choose>
                    <xsl:when test="starts-with($uri, 'faust://bibliography')">
                        <xsl:copy-of select="f:cite($uri, false())"/>						
                    </xsl:when>
                    <xsl:when test="$idmap//idno[@uri=$uri]">
                        <xsl:sequence select="f:resolve-faust-doc($uri, $transcript-list)"/>
                    </xsl:when>
                    <xsl:when test="$idmap//idno[@uri=replace($uri, '^faust://', 'faust://xml/')]">
                        <xsl:sequence select="f:resolve-faust-doc(replace($uri, '^faust://', 'faust://xml/'), $transcript-list)"/>
                    </xsl:when>
                    <xsl:when test="$idmap//idno[@uri=replace($uri, '^faust://print/', 'faust://document/faustedition/')]">
                        <xsl:sequence select="f:resolve-faust-doc(replace($uri, '^faust://print/', 'faust://document/faustedition/'), $transcript-list)"/>
                    </xsl:when>					
                    <xsl:otherwise>
                        <mark class="md-unresolved-uri"><xsl:copy/></mark>
                        <xsl:message select="concat('WARNING: Unresolved URI reference in text: ', ., ' (in ', $source-uri, ')')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
    
    <xsl:function name="f:find-bib-refs" as="item()*">
        <xsl:param name="text"/>
        <xsl:analyze-string select="$text" regex="faust://bibliography/[a-zA-Z0-9/_.-]*[a-zA-Z0-9/_-]+">
            <xsl:matching-substring>
                <xsl:sequence select="."/>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    
    
</xsl:stylesheet>