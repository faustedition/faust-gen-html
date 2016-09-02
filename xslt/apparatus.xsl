<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:xh="http://www.w3.org/1999/xhtml"
	
	xmlns:f="http://www.faustedition.net/ns"
	xmlns:ge="http://www.tei-c.org/ns/geneticEditions"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	
	xmlns:exist="http://exist.sourceforge.net/NS/exist"
	
	exclude-result-prefixes="xs f ge xh exist"
	version="2.0">
	
	<xsl:import href="html-frame.xsl"/>
	<xsl:import href="emend-core.xsl"/>
	<xsl:include href="html-common.xsl"/>
	<xsl:include href="split.xsl"/>

	
	<xsl:param name="headerAdditions">
		<script type="text/javascript" src="{$assets}/js/faust_app.js"/>
	</xsl:param>
	
	<xsl:param name="view">text</xsl:param>
	
	<xsl:output method="xhtml" indent="yes"/>
	
	<xsl:function name="f:totext">
		<xsl:param name="content"/>
		<xsl:variable name="emended"><xsl:apply-templates mode="emend" select="$content"/></xsl:variable>
		<xsl:value-of select="f:normalize-space($emended)"/>
	</xsl:function>


	<xsl:template match="add[not(parent::subst)]">
		<xsl:call-template name="app">
			<xsl:with-param name="app" select="node()"/>
			<xsl:with-param name="label">erg</xsl:with-param>
			<xsl:with-param name="title" select="concat('»', f:totext(.), '« ergänzt')"/>
		</xsl:call-template>		
	</xsl:template>
	
	<xsl:template match="add[@place='inspace']" priority="1">
		<xsl:call-template name="app">
			<xsl:with-param name="app" select="node()"/>
			<xsl:with-param name="label">in Lücke erg</xsl:with-param>
			<xsl:with-param name="title" select="concat('»', f:totext(.), '« in Lücke ergänzt')"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="seg[@f:questionedBy]">
		<xsl:call-template name="app">
			<xsl:with-param name="affected" select="node()"/>
			<xsl:with-param name="affected-class">questioned</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="del[not(parent::subst)]">
		<xsl:call-template name="app">
			<xsl:with-param name="affected" select="node()"/>
			<xsl:with-param name="affected-class">deleted</xsl:with-param>
			<xsl:with-param name="label">tilgt</xsl:with-param>
			<xsl:with-param name="title" select="concat('»', f:totext(./node()), '« getilgt')"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="del[@f:revType='instant']" priority="1">
		<xsl:call-template name="app">
			<xsl:with-param name="braces" select="('⟨', ' &gt;⟩')"/>
			<xsl:with-param name="app">
				<xsl:call-template name="del-instant-body"/>
			</xsl:with-param>
			<xsl:with-param name="title" select="concat('»', f:totext(./node()), '« sofort getilgt')"/>
		</xsl:call-template>
	</xsl:template>
	
	<!-- Recursively add all immediately following instant revisions -->	
	<xsl:template name="del-instant-body">
		<xsl:apply-templates select="node()"/>
		<xsl:for-each select="following-sibling::node()[not(self::text() and normalize-space(.) = '')][1][self::del[@f:revType='instant']]">
			<span class="generated-text"> > </span>
			<xsl:call-template name="del-instant-body"/>
		</xsl:for-each>
	</xsl:template>
	
	<!-- since this already handled immediately following instant revisions: -->
	<xsl:template 
		match="del[@f:revType='instant'][preceding-sibling::node()[not(self::text() and normalize-space(.) = '')][1][self::del[@f:revType='instant']]]"
		priority="2"
	/>
	
	<xsl:template match="subst[del[@f:revType='instant']]" priority="1">
		<xsl:apply-templates select="del"/>
		<xsl:apply-templates select="add/node()"/>
	</xsl:template>
	
	<xsl:template match="subst">
		<xsl:call-template name="app">
			<xsl:with-param name="affected" select="del"/>
			<xsl:with-param name="affected-class">deleted</xsl:with-param>
			<xsl:with-param name="pre">:</xsl:with-param>
			<xsl:with-param name="app" select="add"/>
			<xsl:with-param name="title" select="concat('»', f:totext(del/node()), '« durch »', f:totext(add/node()), '« ersetzt')"/>
		</xsl:call-template>
	</xsl:template>

	<!-- 
		Double Replacement
		
		The following construct:
		
		Eine <subst>
				<del><subst>
             	 	   <del>simple</del>
             			<add>einfache</add>
          			</subst>
          		</del>
     			<add>zweifache</add>
  			  </subst> Ersetzung.
  		
  		should be contracted to »Eine simple ⟨: einfache : zweifache ⟩ Ersetzung«. 
  		
  		However, this is only applicable if the inner <subst> is the only non-whitespace child of the outer del. 

	-->
	<xsl:template match="subst[del/subst][f:only-child(del, del/subst)]">
		<xsl:call-template name="app">
			<xsl:with-param name="title" select="concat('»', f:totext(del/subst/del/node()), 
				'« zunächst durch »', f:totext(del/subst/add/node()), 
				'«, dann durch »', f:totext(add/node()), '« ersetzt')"/>
			<xsl:with-param name="affected" select="del/subst/del"/>
			<xsl:with-param name="affected-class">deleted</xsl:with-param>
			<xsl:with-param name="pre">:</xsl:with-param>
			<xsl:with-param name="app">
				<xsl:sequence select="del/subst/add/node()"/>
				<span class="generated-text app"> : </span>
				<xsl:sequence select="add/node()"/>
			</xsl:with-param>			
		</xsl:call-template>
	</xsl:template>

	<xsl:function name="f:normalized-text" as="xs:string">
		<xsl:param name="seq" as="node()*"/>
		<xsl:value-of select="normalize-space(string-join($seq, ''))"/>
	</xsl:function>

	<xsl:function name="f:same-text-content" as="xs:boolean">
		<xsl:param name="a"/>
		<xsl:param name="b"/>
		<xsl:value-of select="f:normalized-text($a) = f:normalized-text($b)"/>
	</xsl:function>
	
	<xsl:function name="f:only-child" as="xs:boolean">
		<xsl:param name="parent"/>
		<xsl:param name="child"/>
		<xsl:choose>
			<xsl:when test="count($parent/child::*) != 1">
				<xsl:value-of select="false()"/>
			</xsl:when>
			<xsl:when test="not($parent/child::* is $child)">
				<xsl:value-of select="false()"/>
			</xsl:when>
			<xsl:when test="f:normalized-text(($child/preceding-sibling::text(), $child/following-sibling::text()))">
				<xsl:value-of select="false()"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:sequence select="true()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>

	<!-- Normale Wiederherstellung (d.h. kleinerer Teil eines Del -->
	<xsl:template match="restore">
		<xsl:call-template name="app">
			<xsl:with-param name="title">
				<xsl:text>»</xsl:text>
				<xsl:value-of select="f:totext(.)"/>
				<xsl:text>« wiederhergestellt</xsl:text>				
			</xsl:with-param>
			<xsl:with-param name="affected" select="child::node()"/>
			<xsl:with-param name="affected-class">restored</xsl:with-param>
			<xsl:with-param name="label">wdhst</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- Vollständige Wiederherstellung einer Löschung -->
	<xsl:template match="del[f:only-child(., restore)]|restore[f:only-child(., del)]" priority="1">
		<xsl:call-template name="app">
			<xsl:with-param name="title">
				<xsl:text>»</xsl:text>
				<xsl:value-of select="f:totext(child::*)"/>
				<xsl:text>« zunächst getilgt, dann wiederhergestellt</xsl:text>				
			</xsl:with-param>
			<xsl:with-param name="affected" select="child::*/node()"/>
			<xsl:with-param name="affected-class">restored</xsl:with-param>
			<xsl:with-param name="label">tilgt wdhst</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<!-- Vollständig rückgängig gemachte ersetzung. Leider mindestens drei mögliche Codierungen :-( sollte vielleicht vereinheitlicht werden? 
	
	(1) TEI-konforme nesting Order nach Gerrit
	<subst>
		<del><restore>Originaltext</restore></del>
		<add><del>doch nicht vorgenommene Ersetzung</del></add>
	</subst>
	
	(2) Verbreitete Nesting Order:
	<subst>
		<restore><del>Originltext</del></restore>
		<del><add>doch nicht ersetz</add></del>
	</subst>
	
	(3) restore außen
	<restore>
		<subst>
			<del>Originaltext</del>
			<add>ungültig</add>
		</subst>
	</restore>
	
	Ich frage mich, ob es da noch Mischformen gibt? also z.B.
	(1a) = (1) ohne del im add
	(2a) = (2) ohne add im del
	-->
	<!-- Wir ignorieren im match erstmal das add. Das del sollte reichen um herauszufinden
		 ob dies wirklich eine rückgängig gemachte ersetzung ist.
	-->
	<xsl:template match="subst[
			del[f:only-child(., restore)]  (: 1 TEI-Konforme nesting order :)
		or	restore[f:only-child(., del)]] (: 2 häufigere nesting order    :)
		|   restore[f:only-child(., subst)](: 3 dritter Fall: Restore ganz außen :) 
		">
		<!-- Bei den ganzen Fällen sortieren wir uns erstmal -->
		<!-- $original = die originalen nodes, ohne irgendein Element drumherum -->
		<xsl:variable name="original">
			<xsl:sequence select="
				  (:1:)	self::subst/del/restore/node()
				| (:2:) self::subst/restore/del/node()
				| (:3:) self::restore/subst/del/node()"/>			
		</xsl:variable>
		<!-- Für das Replacement haben wir noch keinen only-child-Test. Suchen wir erstmal das add-Element : -->
		<!-- $add = das add oder del element, in dem das $unused-replacement und eventuell noch ein umschließendes del/add drin ist -->
		<xsl:variable name="add" select="
				   if (self::subst/del/restore) then add					  			 (:1, 1a -> add mit ggf. del drin  :)
			  else if (self::subst/restore/del and self::subst/del) then self::subst/del (:2, 2a -> del mit ggf. add drin  :)
			  else restore/subst/add                                                     (:3     -> add mit hoffentlich nix drin :)
			"/>
		<!-- $unused-replacement = die dann doch nicht verwendete Ersetzung, ohne irgendwelche tags drumherum -->
		<xsl:variable name="unused-replacement">
			<xsl:choose>
				<xsl:when test="self::restore">	<!-- (3) -->
					<xsl:sequence select="subst/add/node()"/>
				</xsl:when>
				<xsl:when test="$add[self::add]"> <!-- 1, 1a -->
					<xsl:sequence select="if (f:only-child($add, $add/del)) then $add/del/node() else $add/node()"/>
				</xsl:when>
				<xsl:when test="$add[self::del]"> <!-- 2, 2a -->
					<xsl:sequence select="if (f:only-child($add, $add/add)) then $add/add/node() else $add/node()"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message>ERROR: Unrecognized restored subst encoding variant:
<xsl:copy-of select="."/>
in <xsl:value-of select="document-uri(/)"/>						
					</xsl:message>
				</xsl:otherwise>
			</xsl:choose>		
		</xsl:variable>
		
		
		<!-- So. Der Rest ist einfach :-) -->
		<xsl:call-template name="app">
			<xsl:with-param name="title">
				<xsl:text>Ersetzung von »</xsl:text>
				<xsl:value-of select="f:totext($original)"/>
				<xsl:text>« durch »</xsl:text>
				<xsl:value-of select="f:totext($unused-replacement)"/>
				<xsl:text>« rückgängig gemacht</xsl:text>				
			</xsl:with-param>
			<xsl:with-param name="affected" select="$original"/>
			<xsl:with-param name="pre">:</xsl:with-param>
			<xsl:with-param name="app">
				<xsl:sequence select="$unused-replacement"/>
				<span class="generated-text"><span class="app"> : </span></span>
				<xsl:sequence select="$original"/>				
			</xsl:with-param>
			<xsl:with-param name="label">wdhst</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	
	<!-- delSpan -->
	<xsl:template match="delSpan">
		<xsl:variable name="id" select="substring(@spanTo, 2)"/>
		<span class="appnote delSpan">
			<xsl:call-template name="highlight-group">
				<xsl:with-param name="others" select="id($id)"/>
			</xsl:call-template>
			<xsl:attribute name="title">Getilgt bis <!--<xsl:number from="/" level="any" format="1"/>-->⌟</xsl:attribute>
			<span class="generated-text">⌜<!--<xsl:number from="/" level="any" format="1"/>--></span>
		</span>
	</xsl:template>
	<xsl:key name="delSpan" match="delSpan[@spanTo]" use="substring(@spanTo, 2)"/>
	<xsl:template match="*[@xml:id and key('delSpan', @xml:id)]">
		<xsl:variable name="source" select="key('delSpan', @xml:id)"/>
		<xsl:next-match/>
		<xsl:call-template name="app">
			<xsl:with-param name="context" select="$source"/>
			<xsl:with-param name="prebracket">⌟</xsl:with-param>
			<xsl:with-param name="label">tilgt</xsl:with-param>
			<xsl:with-param name="title">von ⌜ bis ⌟ getilgt</xsl:with-param>
			<xsl:with-param name="also-highlight" select="$source"/>
		</xsl:call-template>
		<xsl:if test="count($source) > 1">
			<xsl:message select="concat('WARNING: ', count($source), ' delSpans point to ', @xml:id, ' in ', document-uri(/))"/>
		</xsl:if>
	</xsl:template>
	
	<!-- addSpan -->
	<xsl:template match="addSpan">
		<xsl:variable name="id" select="substring(@spanTo, 2)"/>
		<span class="appnote addSpan">
			<xsl:call-template name="highlight-group">
				<xsl:with-param name="others" select="id($id)"/>
			</xsl:call-template>
			<span class="generated-text">⟨</span>
		</span>
	</xsl:template>
	<xsl:key name="addSpan" match="addSpan[@spanTo]" use="substring(@spanTo, 2)"/>
	<xsl:template match="*[@xml:id and key('addSpan', @xml:id)]" priority="1">
		<xsl:variable name="source" select="key('addSpan', @xml:id)"/>
		<xsl:if test="count($source) > 1">
			<xsl:message select="concat('WARNING: ', count($source), ' addSpans point to ', @xml:id, ' in ', document-uri(/))"/>
		</xsl:if>
		<xsl:call-template name="app">
			<xsl:with-param name="also-highlight" select="$source"/>
			<xsl:with-param name="context" select="$source"/>
			<xsl:with-param name="braces" select="('', '⟩')"/>
			<xsl:with-param name="label">erg</xsl:with-param>
		</xsl:call-template>
		<xsl:if test="key('delSpan', @xml:id)">
			<xsl:next-match/>
		</xsl:if>
	</xsl:template>
	
	
	<!-- Transpositions. Requires textTranscr_pre_transpose.xsl.   -->
	
	<!-- delivers the tei:ptr in a not-undone ge:transpose element that points to the given @xml:id string -->
	<xsl:key 
		name="transpose" 
		match="ge:transpose/ptr" 
		use="substring(@target, 2)"/>
	
	<!-- 
		Template called for an element that is part of a transposition.
	-->
	<xsl:template match="*[@xml:id and key('transpose', @xml:id)]">
		<xsl:variable name="ptr" select="key('transpose', @xml:id)"/>
		<xsl:variable name="transpose" select="$ptr/.."/>
		<xsl:variable name="undone" select="boolean($transpose[@xml:id and concat('#', @xml:id) = //ge:undo/@target])"/>
		<xsl:variable name="currentPos" select="count(preceding::*[@xml:id and key('transpose', @xml:id)/.. is $transpose]) + 1"/>
		<xsl:variable name="swappedPos" select="count($ptr/preceding-sibling::*) + 1"/>
		<xsl:variable name="replacementTarget" select="$transpose/ptr[$currentPos]/@target"/>		
		<xsl:variable name="replacement" select="id(substring($replacementTarget, 2))"/>
		<xsl:variable name="last" select="not(following::*[@xml:id and key('transpose', @xml:id)/.. is $transpose])"/>
	
		<xsl:call-template name="app">
			<xsl:with-param name="affected" select="node()"/>
			<xsl:with-param name="prebracket">
				<sup><xsl:value-of select="if ($undone) then concat('(', $swappedPos, ')') else $swappedPos"/></sup>
			</xsl:with-param>
			<xsl:with-param name="label" select="
				if ($last)
				then concat('umst', if ($undone) then ' rückg' else '')
				else ''"/>
			<xsl:with-param name="context" select="if ($last) then $transpose else ()"/>
			<xsl:with-param name="braces" select="if ($last) then ('⟨', '⟩') else ('','')"/>
			<xsl:with-param name="title" select="concat('Vertauscht mit »', f:totext($replacement), '«', if ($undone) then ' (rückgängig gemacht)' else ())"/>
			<xsl:with-param name="also-highlight" select="//*[@xml:id and key('transpose', @xml:id)/.. is $transpose]"/>
		</xsl:call-template>		
	</xsl:template>
	
	
	<xsl:variable name="agents">
		<f:agent xml:id="g" shorthand="G">Goethe</f:agent>
		<f:agent xml:id="g_bl_lat" shorthand="G">Goethe</f:agent>
		<f:agent xml:id="g-o-ri" shorthand="G od Ri">Goethe oder Riemer</f:agent>
		<f:agent xml:id="go" shorthand="Gö">Göttling</f:agent>
		<f:agent xml:id="go_bl" shorthand="Gö">Göttling</f:agent>
		<f:agent xml:id="ri" shorthand="Ri">Riemer</f:agent>
		<f:agent xml:id="sc" shorthand="zS">zeitgenöss Schreiber</f:agent> 		
	</xsl:variable>
	<xsl:function name="f:agent">
		<xsl:param name="ref"/>
		<xsl:sequence select="$agents/f:agent[@xml:id = (if (starts-with($ref, '#')) then substring($ref, 2) else $ref)]"/>
	</xsl:function>
	
	<!-- 
		
		Creates and formats everything belonging to an apparatus. All parameters may be left out. The template automatically
		adds info that is the same for all templates, e.g., proposed change info and same-stage indexing.
		
		Parameters that receive original content may also be interspersed with XHTML content which will be copied verbatim
		to the output.
	
	-->
	<xsl:template name="app">
		<!-- The content from the base layer that is affected by the, e.g., deletion. Will be underlined in some form. Original markup (possibly mixed with HTML) -->
		<xsl:param name="affected"/>
		<!-- Class additional to affected for the content from $affected. Token(s) -->
		<xsl:param name="affected-class"/>
		<!-- Text that appears  immediately before the ⟨, in generated-text style -->
		<xsl:param name="prebracket"/>
		<!-- Apparatus text to be inserted after the ⟨, before the $app -->
		<xsl:param name="pre"/>
		<!-- Content that appears inside the ⟨⟩. original TEI, possibly mixed with XHTML -->
		<xsl:param name="app"/>
		<!-- This is the element from which we get f:proposed etc. -->
		<xsl:param name="context" select="."/>
		<!-- Apparatus label, like 'tilgt'. This will be augmented with information on proposed, accepted content etc. -->
		<xsl:param name="label"/>
		<!-- The tooltip in its raw form. Text content. Will be augmented with information on proposed, accepted content etc. -->
		<xsl:param name="title"/>
		<!-- Original TEI elements that are synchronous to the current apparatus. The apparatus for these elements, together with
		     stuff found automatically via ge:stage, will be highlighted together with this apparatus element. -->
		<xsl:param name="also-highlight" as="element()*"/>
		<!-- opening and closing apparatus brace. Customization only for special cases … -->
		<xsl:param name="braces" select="('⟨', '⟩')"/>
		
		<xsl:variable name="real-title">
			<xsl:value-of select="$title"/>
			<xsl:for-each select="$context">
				<xsl:if test="@f:questionedBy">
					<xsl:text>moniert von </xsl:text>
					<xsl:value-of select="f:agent(@f:questionedBy)"/>
				</xsl:if>
				<xsl:if test="@f:proposedBy">
					<xsl:text>:	vorgeschlagen von </xsl:text><xsl:value-of select="f:agent(@f:proposedBy)"/>
					<xsl:if test="@f:acceptedBy">
						<xsl:text>, gebilligt von </xsl:text><xsl:value-of select="f:agent(@f:acceptedBy)"/>
					</xsl:if>
					<xsl:if test="@f:rejectedBy">
						<xsl:text>, verworfen von </xsl:text><xsl:value-of select="f:agent(@f:rejectedBy)"/>
					</xsl:if>
				</xsl:if>
			</xsl:for-each>
			<xsl:if test="key('alt', $context/@xml:id)">
				<xsl:text> / zur Auswahl</xsl:text>
			</xsl:if>
		</xsl:variable>
		
		<xsl:element name="{f:html-tag-name(.)}">
			<xsl:attribute name="class" select="string-join((f:generic-classes(.), 'appnote'), ' ')"/>
			<xsl:attribute name="title" select="$real-title"/>
		
			<xsl:call-template name="highlight-group">
				<xsl:with-param name="others" select="$also-highlight"/>
			</xsl:call-template>
			<xsl:if test="$affected">
				<span class="affected {$affected-class}">
					<xsl:apply-templates select="$affected"/>
				</span>
			</xsl:if>
			<span class="generated-text">
				<xsl:copy-of select="$prebracket"/>
				<xsl:value-of select="$braces[1]"/>
				<xsl:if test="$pre">
					<i class="app"><xsl:value-of select="$pre"/></i>
					<xsl:text> </xsl:text>
				</xsl:if>
			</span>
			<xsl:if test="$app">
				<xsl:apply-templates select="$app"/>
			</xsl:if>
			<xsl:if test="$app and string-length($label) > 0">
				<xsl:text> </xsl:text>				
			</xsl:if>
			<span class="generated-text">
				<xsl:if test="string-length($label) > 0">
					<i class="app"><xsl:value-of select="$label"/></i>
				</xsl:if>
				<xsl:for-each select="$context">
				<xsl:if test="@f:questionedBy">
					<i class="app"> mon <xsl:value-of select="f:agent(@f:questionedBy)/@shorthand"/></i>
				</xsl:if>					
				<xsl:if test="@f:proposedBy">
					<i class="app">	vorschl <xsl:value-of select="f:agent(@f:proposedBy)/@shorthand"/></i>
					<xsl:if test="@f:acceptedBy">
						<i class="app"> bill <xsl:value-of select="f:agent(@f:acceptedBy)/@shorthand"/></i>
					</xsl:if>
					<xsl:if test="@f:rejectedBy">
						<i class="app"> verw <xsl:value-of select="f:agent(@f:rejectedBy)/@shorthand"/></i>
					</xsl:if>
				</xsl:if>
				</xsl:for-each>
				<xsl:value-of select="$braces[2]"/>
			</span>
		</xsl:element>		
	</xsl:template>
	
	<xsl:template match="exist:match">
		<mark class="match">
			<xsl:for-each select="@*">
				<xsl:attribute name="data-{local-name(.)}" select="."/>
			</xsl:for-each>
			<xsl:apply-templates/>
		</mark>
	</xsl:template>
	
</xsl:stylesheet>
