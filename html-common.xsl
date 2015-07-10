<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml" xmlns:xh="http://www.w3.org/1999/xhtml"
	xmlns:f="http://www.faustedition.net/ns"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs f" 	
	version="2.0">
	
	<!-- common code for print2html and variant generation. not to be used standalone -->
	<xsl:import href="utils.xsl"/>
	
	
	<xsl:template match="figure" mode="#default single">
		<br class="figure {@type}"/>
	</xsl:template>
		
	<xsl:template match="gap[@unit='chars']" mode="#default single">
		<span class="{string-join(f:generic-classes(.), ' ')} gap-unit-chars generated-text appnote" 
			data-gap-length="{@quantity}" 
			title="{if (@cert='medium') then 'ungefähr ' else ''}{@quantity} unlesbare Zeichen">
			<xsl:value-of select="string-join(for $n in 1 to @quantity return '×', '')"/>
		</span>
	</xsl:template>
	
	<xsl:template match="gap[@unit='words']" mode="#default single">
		<span class="{string-join(f:generic-classes(.), ' ')} gap-unit-words generated-text appnote" data-gap-length="{@quantity}" title="{@quantity} unlesbare Wörter">
			<xsl:value-of select="string-join(for $n in 1 to @quantity return '×···×', ' ')"/>
		</span>
	</xsl:template>  
	
	<xsl:template match="space" mode="#default single" priority="2">
	  <xsl:choose>
	    <xsl:when test="$type = 'print'">
	      <xsl:next-match/>
	    </xsl:when>
	    <xsl:otherwise>
    	  <span class="{string-join(f:generic-classes(.), ' ')} generated-text appnote" title="Lücke">[***]</span>	      
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:template>
	
	<!-- 
		Render sth as enclosed with generated text.
		
		The template will render an all-enclosing span, the supplied prefix, the normal content at that position and the supplied suffix.
		Prefix and suffix will be styled with the class 'generated-text'. 
		
		Parameters:
		
		pre	    - Prefix   (may be nodes)
		post    - Postfix  (may be nodes)
		with    - alternative way to specify $pre and $post as a 2-tuple
		classes - sequence of strings to be used as classes for the enclosing element, f:generic-classes(.) by default
		title   - optional title (tooltip) for the enclosing element
	-->
	<xsl:template name="enclose">
		<xsl:param name="with" select="('', '')"/>
		<xsl:param name="pre" select="$with[1]"/>
		<xsl:param name="post" select="if ($with[2]) then $with[2] else $with"/>
		<xsl:param name="classes" select="f:generic-classes(.)"/>
		<xsl:param name="title"/>
		<span class="{string-join($classes, ' ')}">
			<xsl:if test="$title">
				<xsl:attribute name="title" select="$title"/>
			</xsl:if>
			<span class="generated-text">
				<xsl:copy-of select="$pre"/>
			</span>
			<xsl:apply-templates select="node()" mode="#current"/>
			<span class="generated-text">
				<xsl:copy-of select="$post"/>
			</span>
		</span>
	</xsl:template>
	
	<xsl:template match="supplied" mode="#default single">
		<xsl:call-template name="enclose">
			<xsl:with-param name="with" select="'[',']'"/>
			<xsl:with-param name="title">editorisch ergänzt</xsl:with-param>
			<xsl:with-param name="classes" select="f:generic-classes(.), 'appnote'"></xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="unclear[@cert='high']" mode="#default single">
		<xsl:call-template name="enclose">
			<xsl:with-param name="with" select="'{','}'"/>
			<xsl:with-param name="title">wahrscheinliche Lesung</xsl:with-param>
			<xsl:with-param name="classes" select="f:generic-classes(.), 'appnote'"></xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="unclear[@cert='low']" mode="#default single">
		<xsl:call-template name="enclose">
			<xsl:with-param name="with" select="'{{','}}'"/>
			<xsl:with-param name="classes" select="f:generic-classes(.), 'appnote'"/>
			<xsl:with-param name="title">sehr unsichere Lesung</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	
	<!-- choice: richtige Alternative wählen -->
	
	<xsl:template match="choice[sic and corr]">
			<xsl:apply-templates select="sic/node()"/>	<!-- komplett ignorieren -->
	</xsl:template>
	
	<xsl:template match="choice[abbr and expan]">
		<abbr class="{string-join((f:generic-classes(abbr), 'appnote'), ' ')}"			
			title="{expan}">
			<xsl:apply-templates select="abbr/node()"/>
		</abbr>
	</xsl:template>
	
	<xsl:template match="choice[orig and reg]">
		<span class="{string-join((f:generic-classes(orig), 'appnote'), ' ')}"
			title="{reg}">
			<xsl:apply-templates select="orig/node()"/>
		</span>		
	</xsl:template>
	
	<xsl:template match="app[lem and rdg]">
		<span class="{string-join((f:generic-classes(lem), 'appnote'), ' ')}">
			<xsl:attribute name="title">
				<xsl:for-each select="rdg">
					<xsl:value-of select="@resp"/>	<!-- FIXME can we resolve this? -->
					<xsl:text> liest »</xsl:text>
					<xsl:value-of select="."/>
					<xsl:text>«</xsl:text>
					<xsl:if test="following-sibling::rdg">; </xsl:if>
				</xsl:for-each>
			</xsl:attribute>
			<span class="{string-join((f:generic-classes(lem), 'appnote'), ' ')}">
				<xsl:apply-templates select="lem/node()"/>
			</span>
		</span>
	</xsl:template>
	
	<xsl:template match="choice|app">
		<xsl:message>WARNING: Unrecognized <xsl:value-of select="local-name(.)"/>, using COMPLETE content:
<xsl:copy-of select="."/>
in <xsl:value-of select="document-uri(/)"/>
		</xsl:message>
		<xsl:next-match/>
	</xsl:template>
	
	<!-- Es gibt wohl die Elemente auch noch ohne <choice> -->
	<xsl:template match="corr"/>
	<!-- die anderen werden einfach durchgereicht -->
	
	<xsl:template match="lb" mode="#default single">
		<xsl:text> </xsl:text>
	</xsl:template>
	
	<xsl:template match="lb[@break='no']" mode="#default single"/>
	
	<xsl:template match="pb" mode="#default single">
		<xsl:text> </xsl:text>
	</xsl:template>
  
  <xsl:template name="generate-pageno">
    <xsl:choose>
      <xsl:when test="@n">
        <xsl:value-of select="replace(@n, '^0+', '')"/>
      </xsl:when>
      <xsl:when test="@facs">
        <xsl:value-of select="replace(@facs, '^0*(.*)\.(tiff|jpg|jpeg|xml)$', '$1')"/>
      </xsl:when>
      <xsl:otherwise>
        <i class="icon-file-alt" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="pb[@f:docTranscriptNo]" priority="1"  mode="#default single">
    <xsl:text> </xsl:text>
    <a  
      class="{string-join((f:generic-classes(.), 'generated-text', 'pageno', 'doclink'), ' ')}"
      id="dt{@f:docTranscriptNo}"
      href="{f:doclink($documentURI, @f:docTranscriptNo)}"> 
      [<xsl:call-template name="generate-pageno"/>]
    </a>
  </xsl:template>
	
  <xsl:template match="pb[@n][following::*[1][self::pb]]" mode="#default single" priority="2">
  	<span id="pb{@n}" class="pb-supressed">
  		<xsl:comment>Supressed page break <xsl:value-of select="@n"/></xsl:comment>
  	</span>
  </xsl:template>
  
  <xsl:template match="pb[@n]"  mode="#default single">
    <xsl:text> </xsl:text>
    <span
      class="{string-join((f:generic-classes(.), 'generated-text', 'pageno'), ' ')}"
      id="pb{@n}">
      [<xsl:call-template name="generate-pageno"/>]
    </span>
  </xsl:template>
	
  <xsl:template match="fw"  mode="#default single"/>
	
	<!-- Erzeugt die Zeilennummer vor der Zeile -->
	<xsl:template name="generate-lineno">
		<xsl:variable name="display-line" select="f:lineno-for-display(@n)"/>
		<xsl:choose>
			<xsl:when test="number($display-line) gt 0">
				<!-- Klick auf Zeilennummer führt zu einem Link, der wiederum auf die Zeilennummer verweist -->
				<xsl:attribute name="id" select="concat('l', @n)"/>
				<a href="#l{@n}">
					<xsl:attribute name="class">
						<xsl:text>lineno</xsl:text>
						<!-- Jede 5. ist immer sichtbar, alle anderen nur wenn über die Zeile gehovert wird -->
						<xsl:if test="$display-line mod 5 != 0">
							<xsl:text> invisible</xsl:text>
						</xsl:if>
					</xsl:attribute>
					<xsl:value-of select="$display-line"/>
				</a>
			</xsl:when>
			<xsl:otherwise>
				<a class="lineno invisible">&#160;</a>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
</xsl:stylesheet>