<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:f="http://www.faustedition.net/ns"
	xmlns:ge="http://www.tei-c.org/ns/geneticEditions"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs f ge"
	version="2.0">
	
	<xsl:import href="html-frame.xsl"/>
	<xsl:include href="html-common.xsl"/>
	<xsl:include href="split.xsl"/>
	
	<xsl:param name="headerAdditions">
		<script type="text/javascript" src="faust_app_tmp.js"/>
	</xsl:param>
	
	<xsl:output method="xhtml" indent="yes"/>


	<xsl:template match="add[not(parent::subst)]">		
		<xsl:call-template name="enclose">
			<xsl:with-param name="pre" select="'⟨'"/>
			<xsl:with-param name="post"> <span class="app"> erg</span>⟩</xsl:with-param>
			<xsl:with-param name="classes" select="f:generic-classes(.), 'appnote'"/>
			<xsl:with-param name="title" select="concat('»', ., '« ergänzt')"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="del[not(parent::subst)]">
		<span class="appnote" title="{concat('»', ., '« getilgt')}">
			<xsl:call-template name="highlight-group"/>
			<span class="affected deleted"><xsl:apply-templates select="node()"/> </span>
			<span class="generated-text">⟨<span class="app">tilgt</span>⟩</span>			
		</span>
	</xsl:template>
	
	<xsl:template match="del[@f:revType='instant']" priority="1">
		<xsl:call-template name="enclose">
			<xsl:with-param name="with" select="('⟨', ' &gt;⟩')"/>
			<xsl:with-param name="title" select="concat('»', ., '« sofort getilgt')"/>
			<xsl:with-param name="classes" select="f:generic-classes(.), 'appnote'"></xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template match="subst[del[@f:revType='instant']]" priority="1">
		<xsl:apply-templates select="del"/>
		<xsl:apply-templates select="add/node()"/>
	</xsl:template>
	
	<xsl:template match="subst">
		<span class="appnote" title="{concat('»', normalize-space(string-join(del, '')), '« durch »', normalize-space(string-join(add, '')), '« ersetzt')}">
			<xsl:call-template name="highlight-group"/>
			<span class="affected deleted">
				<xsl:apply-templates select="del"/>
			</span>			
			<xsl:for-each select="add">
				<xsl:call-template name="enclose">
					<xsl:with-param name="with" select="('⟨: ', '⟩')"/>
				</xsl:call-template>
			</xsl:for-each>
		</span>
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
		<span class="appnote" title="{concat('»', normalize-space(string-join(del/subst/del, '')), 
			'« zunächst durch »', normalize-space(string-join(del/subst/add, '')), 
			'«, dann durch »', normalize-space(string-join(add, '')), '« ersetzt')}">
			<xsl:call-template name="highlight-group"/>
			<span class="affected deleted">
				<xsl:apply-templates select="del/subst/del"/>
			</span>
			<span class="generated-text">⟨ <span class="app">:</span> </span>
			<xsl:apply-templates select="del/subst/add"/>
			<span class="generated-text app"> : </span>
			<xsl:apply-templates select="add"/>
			<span class="generated-text">⟩</span>
		</span>
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
		<span class="appnote">
			<xsl:call-template name="highlight-group"/>
			<xsl:attribute name="title">
				<xsl:text>»</xsl:text>
				<xsl:value-of select="f:normalized-text(.)"/>
				<xsl:text>« wiederhergestellt</xsl:text>
			</xsl:attribute>
			<span class="restored">
				<xsl:apply-templates select="child::node()"/>
			</span>
			<span class="generated-text">⟨wdhst⟩</span>
		</span>
	</xsl:template>
	
	<!-- Vollständige Wiederherstellung einer Löschung -->
	<xsl:template match="del[f:only-child(., restore)]|restore[f:only-child(., del)]" priority="1">
		<span class="appnote">
			<xsl:call-template name="highlight-group"/>
			<xsl:attribute name="title">
				<xsl:text>»</xsl:text>
				<xsl:value-of select="f:normalized-text(child::*)"/>
				<xsl:text>« zunächst getilgt, dann wiederhergestellt</xsl:text>
			</xsl:attribute>
			<span class="affected restored">
				<xsl:apply-templates select="child::*/node()"/>
			</span>
			<span class="generated-text">⟨<span class="app">tilgt wdhst</span>⟩</span>
		</span>
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
		<span class="{f:generic-classes(.)} appnote">
			<xsl:call-template name="highlight-group"/>
			<xsl:attribute name="title">
				<xsl:text>Ersetzung von »</xsl:text>
				<xsl:value-of select="f:normalized-text($original)"/>
				<xsl:text>« durch »</xsl:text>
				<xsl:value-of select="f:normalized-text($unused-replacement)"/>
				<xsl:text>« rückgängig gemacht</xsl:text>
			</xsl:attribute>
			<span class="affected restored">
				<xsl:apply-templates select="$original"/>
			</span>
			<span class="generated-text">⟨<span class="app">: </span></span>
			<xsl:apply-templates select="$unused-replacement"/>
			<span class="generated-text"><span class="app"> : </span></span>
			<xsl:apply-templates select="$original"/>
			<span class="generated-text"><span class="app"> wdhst</span>⟩</span>
		</span>		
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
		<span class="appnote" data-same-app="{@xml:id}" title="von ⌜ bis ⌟ getilgt">
			<xsl:call-template name="highlight-group">
				<xsl:with-param name="others" select="$source"/>
			</xsl:call-template>
			<xsl:if test="count($source) > 1">
				<xsl:message select="concat('WARNING: ', count($source), ' delSpans point to ', @xml:id, ' in ', document-uri(/))"/>
			</xsl:if>
			<span class="generated-text">
<!--				<xsl:variable name="idx">
					<xsl:for-each select="key('delSpan', @xml:id)">
						<xsl:number count="delSpan" from="/" level="any" format="1"/>
					</xsl:for-each>
				</xsl:variable>
				<xsl:value-of select="$idx"/>-->⌟⟨<i>tilgt<!-- ab ⌜<xsl:value-of select="$idx"/>--></i>⟩
			</span>
		</span>
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
		<span class="appnote">
			<xsl:call-template name="highlight-group">
				<xsl:with-param name="others" select="$source"/>
			</xsl:call-template>
			<span class="generated-text"><i>erg</i>⟩</span>
		</span>
		<xsl:if test="key('delSpan', @xml:id)">
			<xsl:next-match/>
		</xsl:if>
	</xsl:template>
	
	
	<!-- Transpositions. Requires textTranscr_pre_transpose.xsl.   -->
	
	<!-- delivers the tei:ptr in a not-undone ge:transpose element that points to the given @xml:id string -->
	<xsl:key 
		name="transpose" 
		match="ge:transpose/ptr[not(..[@xml:id and concat('#', @xml:id) = //ge:undo/@target])]" 
		use="substring(@target, 2)"/>
	
	<!-- 
		Template called for an element that is part of a transposition.	
	-->
	<xsl:template match="*[@xml:id and key('transpose', @xml:id)]">
		<xsl:variable name="ptr" select="key('transpose', @xml:id)"/>
		<xsl:variable name="transpose" select="$ptr/.."/>				
		<xsl:variable name="currentPos" select="count(preceding::*[@xml:id and key('transpose', @xml:id)/.. is $transpose]) + 1"/>
		<xsl:variable name="replacementTarget" select="$transpose/ptr[$currentPos]/@target"/>		
		<xsl:variable name="replacement" select="id(substring($replacementTarget, 2))"/>
		<xsl:element name="{f:html-tag-name(.)}">
			<xsl:attribute name="class" select="string-join((f:generic-classes(.), 'appnote', 'transpose'), ' ')"/>
			<xsl:call-template name="highlight-group">
				<!-- XXX geht das nicht irgendwie einfacher? über die pointer aufzählen? -->
				<xsl:with-param name="others" select="//*[@xml:id and key('transpose', @xml:id)/.. is $transpose]"/>
			</xsl:call-template>
			<xsl:attribute name="title" select="concat('Vertauscht mit »', $replacement, '«')"/>
			<xsl:apply-templates/>
			<sup class="generated-text"><xsl:value-of select="count($ptr/preceding-sibling::*) + 1"/></sup>
			<!-- Add ⟨umst⟩ after the last element in this transposition -->
			<xsl:if test="not(following::*[@xml:id and key('transpose', @xml:id)/.. is $transpose])">
				<span class="generated-text">⟨<i>umst</i>⟩</span>
			</xsl:if>
		</xsl:element>
	</xsl:template>


	
	<xsl:key name="alt" match="alt" use="for $ref in tokenize(@target, '\s+') return substring($ref, 2)"/>
	<!-- Einfacher als in print2html da kein Variantenapparat -->
	<xsl:template match="*">
		<xsl:element name="{f:html-tag-name(.)}">
			<xsl:call-template name="generate-style"/>
			<xsl:attribute name="class" select="string-join((f:generic-classes(.),
				if (@xml:id and key('alt', @xml:id)) then 'alt' else (),
				if (@n and @part) then ('antilabe', concat('part-', @part)) else ()), ' ')"/>
			<xsl:call-template name="highlight-group">
				<xsl:with-param name="others" select="key('alt', @xml:id)"/>
			</xsl:call-template>
			<xsl:call-template name="generate-lineno"/>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	
	
</xsl:stylesheet>
