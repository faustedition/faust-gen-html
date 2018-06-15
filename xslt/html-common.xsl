<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml" xmlns:xh="http://www.w3.org/1999/xhtml"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns:ge="http://www.tei-c.org/ns/geneticEditions"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs f xh ge" 	
	version="2.0">
	
	<!-- common code for print2html and variant generation. not to be used standalone -->
	<xsl:import href="utils.xsl"/>
	
	<xsl:param name="edition"></xsl:param>
	
	<xsl:key name="alt" match="alt" use="for $ref in tokenize(@target, '\s+') return substring($ref, 2)"/>		
	
	<xsl:template name="breadcrumbs">
		<xsl:variable name="section" select="f:get-section-number(.)"/>
		<xsl:variable name="section-div" select="if ($section) then //*[@f:section = $section] else ()"/>		
		<xsl:variable name="hierarchy" select="($section-div/ancestor-or-self::div)" as="element()*"/>
		<xsl:variable name="scenes" select="(if ($section) then $section-div else .)/ancestor-or-self::div[@f:label]"/>
		<xsl:variable name="scene-id" select="data(($scenes/@n)[last()])"/>
		<xsl:variable name="faust" select="if ($scene-id) then number(substring-before($scene-id, '.')) else 0"/>
			
		<xsl:choose>
			
			<!-- Reading text: We have appropriate @n and @label annotations, just use these -->
			<xsl:when test="$type = 'lesetext'">
				<a href="/text">Text</a>
				<xsl:for-each select="$hierarchy">
					<a href="{string-join(('faust', f:get-section-number(.)), '.')}#{@xml:id}" title="{@f:label}">
						<xsl:value-of select="@f:label"/>
					</a>
				</xsl:for-each>
			</xsl:when>
						
			<!-- For the rest, we need a double Archive / Genesis breadcrumb -->
			<xsl:otherwise>
				<span>
					<a href="../archive">Archiv</a>
					<xsl:choose>
						<xsl:when test="$type = 'print'">
							<a href="../archive_prints">Drucke</a>
						</xsl:when>
						<xsl:otherwise>
							<a href="../archive_locations_detail?id={/TEI/@f:repository}">
								<xsl:value-of select="/TEI/@f:repository-label"/>
							</a>
						</xsl:otherwise>
					</xsl:choose>
					<a title="{//idno[@type='faustedition'][1]}">
						<xsl:value-of select="//idno[@type='faustedition'][1]"/>
					</a>
				</span>
				
				<span>							
					<a href="{$edition}/genesis">Genese</a>
					
					<xsl:choose>
						<xsl:when test="starts-with($scene-id, '1.') and not($hierarchy[@n='1.1'])">
							<a href="{$edition}/genesis_faust_i">Faust I</a>
						</xsl:when>
						<xsl:when test="starts-with($scene-id, '2.') and not($hierarchy[@n='2'])">
							<a href="{$edition}/genesis_faust_ii">Faust II</a>
						</xsl:when>
					</xsl:choose>
					
					<xsl:for-each select="$hierarchy">
						<xsl:choose>
							<xsl:when test="@n = '1.1'"><a href="{$edition}/genesis_faust_i">Faust I</a></xsl:when>
							<xsl:when test="@n = '2'"><a href="{$edition}/genesis_faust_ii">Faust II</a></xsl:when>
							<xsl:when test="@f:verse-range">
								<xsl:variable name="range" select="tokenize(@f:verse-range, '\s+')"/>
								<a href="{$edition}/genesis_bargraph?rangeStart={$range[1]}&amp;rangeEnd={$range[2]}">
									<xsl:value-of select="@f:label"/>
								</a>
							</xsl:when>
						</xsl:choose>
					</xsl:for-each>
				</span>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template mode="debugxml" match="*">
		<xsl:value-of select="concat('&lt;', name(), ' ', string-join((for $attr in @* return concat(name($attr), '=&quot;', $attr, '&quot;')), ' '), '>')"/>
			<xsl:apply-templates select="node()" mode="#current"/>
		<xsl:value-of select="concat('&lt;/', name(), '>')"/>
	</xsl:template>
	
	<!-- Returns the local name of the appropriate HTML element for the given tei element -->
	<xsl:function name="f:html-tag-name">
		<xsl:param name="element"/>
		<xsl:choose>
			<xsl:when test="$element[self::p]">p</xsl:when>
			<xsl:when test="$element/@rend = 'sup'">sup</xsl:when>
			<xsl:when test="f:isInline($element)">span</xsl:when>
			<xsl:when test="$element/self::head/parent::div[@type='subscene']">h5</xsl:when>
			<xsl:when test="$element/self::head[parent::div[@type='scene']/parent::div
				or parent::body]">h4</xsl:when>
			<xsl:when test="$element/self::head/parent::div/parent::body">h3</xsl:when>
			<xsl:otherwise>div</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<!-- Returns a sequence of classes for the HTML equivalant to a TEI element. -->
	<xsl:function name="f:generic-classes">
		<xsl:param name="element"/>
		<xsl:for-each select="$element">
			<xsl:sequence select="local-name($element)"/>
			<xsl:sequence select="for $rend in tokenize($element/@rend, ' ') return
				if ($rend = 'indented' and $element[self::l] and $element is $element/ancestor::lg[1])
				then ('rend-indented-but-ignored')
				else concat('rend-', $rend)"/>
			<!-- 
	      @rend values will be included as rend-<value> in the class attribute. However, there is an exception:
	      hi elements having _only_ 'big' or 'small' as rend value should not be highlighted. We deal with this
	      by adding a nohighlight class to them.    
	    -->
			<xsl:sequence select="if ($element/@rend=('big','small')) then ('nohighlight') else ()"/>
			<xsl:sequence select="for $type in tokenize($element/@type, ' ') return concat('type-', $type)"/>
			<xsl:sequence select="for $subtype in tokenize($element/@subtype, ' ') return concat('subtype-', $subtype)"/>
			<xsl:if test="key('alt', @xml:id)">
				<xsl:sequence select="('alt', 'appnote', 'affected')"/>
			</xsl:if>
			<xsl:if test="$element/@n">
				<xsl:sequence select="concat('n-', $element/@n)"/>
			</xsl:if>
		</xsl:for-each>
	</xsl:function>
	
	
	
	<xsl:template match="figure">
		<br class="figure {@type}"/>
	</xsl:template>
		
	<xsl:template match="gap[@unit='chars']">
		<span class="{string-join(f:generic-classes(.), ' ')} gap-unit-chars generated-text appnote" 
			data-gap-length="{@quantity}" 
			title="{if (@precision='medium') then 'ungefähr ' else ''}{@quantity} unlesbare Zeichen">
			<xsl:value-of select="string-join(for $n in 1 to @quantity return '×', '')"/>
		</span>
	</xsl:template>
	
	<xsl:template match="gap[@unit='words']">
		<span class="{string-join(f:generic-classes(.), ' ')} gap-unit-words generated-text appnote" 
			  data-gap-length="{@quantity}" 
			  title="{if (@precision='medium') then 'ungefähr ' else ''}{@quantity} unlesbare Wörter">
			<xsl:value-of select="string-join(for $n in 1 to @quantity return '×···×', ' ')"/>
		</span>
	</xsl:template>  
	
	<xsl:template match="space" priority="2">
	  <xsl:choose>
	    <xsl:when test="$type != 'print'">
    	  <span class="{string-join(f:generic-classes(.), ' ')} generated-text appnote" title="Lücke">[***]</span>	      
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:next-match/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:template>
	
	<xsl:template match="space[@unit='lines']" priority="3">	
		<div class="{string-join(f:generic-classes(.), ' ')} generated-text appnote"
			 title="{@quantity} Zeilen Lücke">
			<xsl:comment><xsl:copy-of select="."/></xsl:comment>
			<xsl:apply-templates/><!-- there might be a note -->
			<xsl:for-each select="1 to xs:integer(round(@quantity))">
				<br/>
			</xsl:for-each>			
		</div>
	</xsl:template>
	
	
	<!-- 
		Sometimes we need to highlight not only the currently hovered element but also some others which are, in a way,
		connected. E.g., <addSpan/> and corresponding target, or all elements of a transposition group.
		
		For JS efficiency, it is probably best to give every HTML element that could be in a highlight group an id, and
		to add an attribute listing _all_ relevant other IDs to the element.
		
		This should be called immediately inside an .appnote element
	-->
	<xsl:key name="samestage" match="*[@ge:stage]" use="string(@ge:stage)"/>
	<xsl:template name="highlight-group">
		<xsl:param name="others" as="element()*"/>
		<xsl:param name="prefix" as="xs:string" select="''"/>
		<xsl:variable name="samestage" select="if (@ge:stage) then key('samestage', @ge:stage) else ()"/>
		<xsl:variable name="alt" select="
			if (@xml:id and key('alt', @xml:id)) 
				then f:resolve-target(key('alt', @xml:id))						
				else ()"/>
		<xsl:variable name="others" select="
			for $el in ($others, $samestage, $alt) except . 
				return concat($prefix, f:generate-id($el))"/>
		<xsl:if test="count($others) > 0">
			<xsl:attribute name="id" select="concat($prefix, f:generate-id(.))"/>
			<xsl:attribute name="data-also-highlight" select="string-join($others, ' ')"/>
		</xsl:if>	
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
			<xsl:call-template name="highlight-group"/>
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
	
	<xsl:template match="supplied">
		<xsl:call-template name="enclose">
			<xsl:with-param name="with" select="'[',']'"/>
			<xsl:with-param name="title">editorisch erschlossen</xsl:with-param>
			<xsl:with-param name="classes" select="f:generic-classes(.), 'appnote'"></xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="supplied[@evidence='conjecture']"/>
	
	<xsl:template match="supplied[@reason='typesetting-error']"/>
	
	<xsl:template match="unclear[@cert='high']">
		<xsl:call-template name="enclose">
			<xsl:with-param name="with" select="'{','}'"/>
			<xsl:with-param name="title">unsichere Lesung – wahrscheinlich</xsl:with-param>
			<xsl:with-param name="classes" select="f:generic-classes(.), 'appnote'"></xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="unclear[@cert='low']">
		<xsl:call-template name="enclose">
			<xsl:with-param name="with" select="'{{','}}'"/>
			<xsl:with-param name="classes" select="f:generic-classes(.), 'appnote'"/>
			<xsl:with-param name="title">unsichere Lesung – möglich</xsl:with-param>
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
	
	<xsl:template match="app[lem and rdg and not(ancestor::note[@type='textcrit'])]">
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
	
	<xsl:template match="choice[unclear[@cert='high'] and unclear[@cert='low']]">
		<xsl:for-each select="unclear[@cert='high']">
			<xsl:call-template name="enclose">
				<xsl:with-param name="pre">{</xsl:with-param>
				<xsl:with-param name="post">}</xsl:with-param>
				<xsl:with-param name="classes" select="f:generic-classes(.), 'appnote'"/>
				<xsl:with-param name="title" select="concat('wahrscheinliche Lesung; Alternative: ', ../unclear[cert='low'])"/>
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="choice|app">
		<xsl:message>WARNING: Unrecognized <xsl:value-of select="local-name(.)"/>, using COMPLETE content:
<xsl:copy-of select="."/>
in <xsl:value-of select="document-uri(/)"/>
		</xsl:message>
		<xsl:next-match/>
	</xsl:template>
	
	<xsl:template match="app[rdg[witStart]]" priority="1"/>
	
	<!-- Es gibt wohl die Elemente auch noch ohne <choice> -->
	<xsl:template match="corr"/>
	<!-- die anderen werden einfach durchgereicht -->
	
	<xsl:template match="lb">
		<xsl:text> </xsl:text>
	</xsl:template>
	
	<xsl:template match="lb[@break='no']"/>
	
	<xsl:template match="pb">
		<xsl:text> </xsl:text>
	</xsl:template>
	
	<xsl:template match="pb[$type = 'lesetext']" priority="5">
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
  
  <xsl:template match="pb[@f:docTranscriptNo|@n]" priority="1">
  	<xsl:variable name="no-from-transcript">
  		<xsl:call-template name="generate-pageno"/>
  	</xsl:variable>
  	<xsl:variable name="docTranscriptNo" select="data(@f:docTranscriptNo)"/>
  	<xsl:variable name="reference-pageno" select="if ($docTranscriptNo) then $docTranscriptNo else $no-from-transcript"/>
  	
    <xsl:text> </xsl:text>
    <a  
      class="{string-join((f:generic-classes(.), 'generated-text', 'pageno', 'doclink'), ' ')}"
      id="dt{$reference-pageno}"
      href="{if ($type != 'lesetext') then f:doclink($sigil_t, $docTranscriptNo, ()) else concat('#dt', $reference-pageno)}"> 
      <xsl:attribute name="title" select="$no-from-transcript"/>
      <xsl:sequence select="if ($type = 'print') then $no-from-transcript else $reference-pageno"/>
    </a>
  </xsl:template>
	
  <xsl:template match="pb[@n][following::*[1][self::pb]]" priority="2">
  	<span id="pb{@n}" class="pb-supressed">
  		<xsl:comment>Supressed page break <xsl:value-of select="@n"/></xsl:comment>
  	</span>
  </xsl:template>
  		
  <xsl:key name="next" match="*[@next]" use="substring(@next, 2)"/>
  <xsl:template match="milestone[@unit='paralipomenon' and not(@xml:id and key('next', @xml:id))]">
  	<xsl:variable name="no" select="replace(@n, 'p(\d+)', '$1')"/>
  	<xsl:variable name="id" select="concat('para_', $no, '_', id('sigil_n'))"/>
  	<a  class="{string-join((f:generic-classes(.), 'generated-text', 'paralipomenon'), ' ')}"
  		id="{$id}"
  		title="Paralipomenon {$no}"
  		href="/paralipomena#{$id}"
  		name="{$id}">P <xsl:value-of select="$no"/></a>
  </xsl:template>
  
  <xsl:template match="milestone"/> <!-- Oder besser ein <a name/>? -->
	
  <xsl:template match="fw"/>
	
	<!-- Erzeugt die Zeilennummer vor der Zeile -->
	<xsl:template name="generate-lineno">
		<xsl:variable name="display-line" select="if (@f:schroer) then @f:schroer else 0"/>
		<xsl:choose>
			<xsl:when test="number($display-line) gt 0">
				<!-- Klick auf Zeilennummer führt zu einem Link, der wiederum auf die Zeilennummer verweist -->
				<xsl:attribute name="id" select="concat('l', @n)"/>
				<a href="#l{@n}">
					<xsl:attribute name="class">
						<xsl:text>lineno</xsl:text>
						<!-- Jede 5. ist immer sichtbar, alle anderen nur wenn über die Zeile gehovert wird -->
						<xsl:if test="$display-line mod 5 != 0 and not (ancestor::*[@f:first-verse]/(@f:first-verse, @f:last-verse) = data(@f:schroer))">
							<xsl:text> invisible</xsl:text>
						</xsl:if>
					</xsl:attribute>
					<xsl:value-of select="$display-line"/>
				</a>
			</xsl:when>
			<xsl:when test="@n and $type='lesetext'">
				<a id="l{@n}" href="#l{@n}" class="lineno technical-lineno"><xsl:value-of select="@n"/></a>
			</xsl:when>
			<xsl:when test="@n">
				<a id="l{@n}" href="#l{@n}" class="lineno invisible">∞</a>
			</xsl:when>
			<xsl:when test="not(f:isInline(.))">
				<a class="lineno invisible">&#160;</a>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	
	
	<!-- Tabellen -->
	<xsl:template match="table">
	  <table class="{string-join((f:generic-classes(.)), ' ')}">
	      <xsl:attribute name="xml:id" select="f:generate-id(.)"/>
			<xsl:apply-templates mode="#current"/>
		</table>
	</xsl:template>
	<xsl:template match="row">
		<tr class="{string-join(f:generic-classes(.), ' ')}">
			<xsl:apply-templates/>
		</tr>
	</xsl:template>
	<xsl:template match="cell">
		<td class="{string-join(f:generic-classes(.), ' ')}">
			<xsl:apply-templates/>
		</td>
	</xsl:template>
	
	
	<!-- Sonderzeichen -->
	<xsl:template match="g[@ref]">
		<xsl:variable name="map">
			<f:g ref="#g_break">[</f:g>
			<f:g ref="#g_transp_1">⊢</f:g>
			<f:g ref="#g_transp_2">⊨</f:g>
			<f:g ref="#g_transp_2a">⫢</f:g>
			<f:g ref="#g_transp_3">⫢</f:g>
			<f:g ref="#g_transp_3S">⎱</f:g>
			<f:g ref="#g_transp_4">+</f:g>
			<f:g ref="#g_transp_5">✓</f:g>
			<f:g ref="#g_transp_6">#</f:g>
			<f:g ref="#g_transp_7">◶</f:g>
			<f:g ref="#g_transp_8">⊣</f:g>
			<f:g ref="#parenthesis_left">(</f:g>
			<f:g ref="#parenthesis_right">)</f:g>
			<f:g ref="#truncation">.</f:g>			
		</xsl:variable>
		<span class="g g-{substring(@ref, 2)}">
			<xsl:choose>
				<xsl:when test="$map/f:g[@ref=current()/@ref]">
					<xsl:value-of select="$map/f:g[@ref=current()/@ref]"/>					
				</xsl:when>				
				<xsl:when test="document(@ref)//mapping">
					<xsl:value-of select="document(@ref)//mapping"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>�</xsl:text>
					<xsl:message select="concat(document-uri(.), ': Unresolved glyph: ', @ref)"/>
				</xsl:otherwise>
			</xsl:choose>			
		</span>
	</xsl:template>
	
	
	<!-- Einfacher als in print2html da kein Variantenapparat -->
	<xsl:template match="*">
		<xsl:element name="{f:html-tag-name(.)}">
			<xsl:call-template name="generate-style"/>
			<xsl:attribute name="class" select="string-join((f:generic-classes(.),				
				if (@n and @part) then ('antilabe', concat('part-', @part)) else ()), ' ')"/>
			<xsl:if test="key('alt', @xml:id)">
				<xsl:attribute name="title">zur Auswahl</xsl:attribute>				
			</xsl:if>
			<xsl:call-template name="highlight-group">
				<xsl:with-param name="others" select="f:resolve-target(key('alt', @xml:id))"/>
			</xsl:call-template>
			<xsl:if test="@n">
				<xsl:call-template name="generate-lineno"/>
			</xsl:if>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<!-- Pass through existing HTML from previous steps -->
	<xsl:template match="xh:*">
		<xsl:copy>
			<xsl:copy-of select="@*"/>				
			<xsl:apply-templates select="node() except namespace::*"/>
		</xsl:copy>
	</xsl:template>	
	
	<!-- Just strip those standoff indicators -->
	<xsl:template match="alt|ge:transposeGrp|ge:transpose|join" priority="1"/>
	
	<!-- Simple link mechanism -->
	<xsl:template match="anchor">
		<a id="{@xml:id}" name="{@xml:id}" class="{string-join(f:generic-classes(.), ' ')}"/>
	</xsl:template>
	
	<xsl:template match="ref">
		<a href="{@target}" class="{string-join(f:generic-classes(.), ' ')}">
			<xsl:apply-templates/>
		</a>
	</xsl:template>
	
	<xsl:template match="desc[@type='editorial']">
		<div class="pure-alert {if (@subtype) then concat('pure-alert-', @subtype) else ()}">
			<xsl:apply-templates/>
		</div>
	</xsl:template>
	
	<xsl:template match="hi[tokenize(@rend, '\s+') = 'superscript']">
		<sup class="{string-join(f:generic-classes(.), '')}">
			<xsl:apply-templates mode="#current" select="node()"/>
		</sup>
	</xsl:template>
	
	<!-- will be overridden in print2html, but we don't want it in the variant app etc. -->
	<xsl:template match="note[@type='textcrit']"/>


</xsl:stylesheet>
