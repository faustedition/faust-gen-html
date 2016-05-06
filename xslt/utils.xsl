<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:f="http://www.faustedition.net/ns"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <!-- should we split inside the current document or not? -->
  <xsl:param name="splitchars" select="5000"/>
  <xsl:param name="splitdivs" select="5"/>
  <xsl:param name="docbase"/>
  <xsl:param name="printbase"/>
  <xsl:param name="documentURI"/>
  <xsl:param name="type" select="data(/TEI/type)"/>
  
  <xsl:function name="f:is-splitable-doc" as="xs:boolean">
    <xsl:param name="document"/>
    <xsl:value-of select="count(root($document)//div) ge number($splitdivs) and string-length(normalize-space(string-join(root($document)//text, ' '))) ge number($splitchars)"/>
  </xsl:function>
  
  
  <xsl:function name="f:numerical-lineno">
    <xsl:param name="n"/>
    <xsl:value-of select="number(replace($n, '\D*(\d+).*', '$1'))"/>
  </xsl:function>
  
  <xsl:function name="f:output-group">
    <xsl:param name="n"/>
    <xsl:variable name="resolved-n" select="f:numerical-lineno($n)"/>
    <xsl:choose>
      <xsl:when test="matches(string($resolved-n), '\d+')">
        <xsl:value-of select="$resolved-n idiv 10"/>				
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>other</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <xsl:function name="f:lineno-for-display">
    <xsl:param name="n"/>
    <xsl:choose>
      <xsl:when test="matches($n, '^\d+$')">
        <xsl:value-of select="number($n)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="0"/>
      </xsl:otherwise>
    </xsl:choose>    
  </xsl:function>
  
  <!-- Returns true of the given TEI element should probably be rendered inline -->
  <xsl:function name="f:isInline">
    <xsl:param name="element"/>    
    <xsl:choose>
      <xsl:when test="$element[self::div or self::l or self::lg or self::p or self::sp
        or self::head or self::closer or (@n and not(self::milestone))]">
        <xsl:sequence select="false()"/>
      </xsl:when>
      <xsl:when test="$element[self::hi or self::seg or self::w]">
        <xsl:sequence select="true()"/>
      </xsl:when>
      <xsl:when test="some $descendant in $element//* satisfies not(f:isInline($descendant))">
        <xsl:sequence select="false()"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="true()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  
  <!-- Resolves @target references within the current document. 
    
       I.e. f:resolve-target(<alt target="#foo #bar #baz"/>) returns a
       sequence of the three elements with the ids foo, bar, and baz.  
  -->  
  <xsl:function name="f:resolve-target" as="element()*">
    <xsl:param name="elem" as="element()*"/>   
    <xsl:variable name="targets" select="tokenize(string-join($elem/@target, ' '), '\s+')"/>
    <xsl:choose>
      <xsl:when test="count($targets) > 0">
        <xsl:variable name="ids" select="for $target in $targets return substring-after($target, '#')"/>
        <xsl:variable name="resolved" select="for $id in $ids return id($id, $elem[1])"/>
        <xsl:sequence select="$resolved"/>        
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
    
  
  <xsl:function name="f:relativize" as="xs:anyURI">
    <xsl:param name="source" as="xs:string" />
    <xsl:param name="target" as="xs:string" />
    
    <!-- Fully qualified source and target to source-uri and target-uri. -->
    <xsl:variable name="target-uri" select="resolve-uri($target)" />
    <xsl:variable name="source-uri" select="resolve-uri($source)" />
    
    <!--
      Now we collapse consecutive slashes and strip trailing filenames from
      both to compute $a (source) and $b (target).
      
      We then split $a on '/' and walk through the sequence, comparing
      each part to the corresponding component in $b, concatenating the
      results with '/'. Result $c is a string representing the complete
      set of path components shared between the beginning of $a and the
      beginning of $b.
    -->
    <xsl:variable name="a"
      select="tokenize( replace( replace($source-uri, '//+', '/'), '[^/]+$', ''), '/')" />
    <xsl:variable name="b"
      select="tokenize( replace( replace($target-uri, '//+', '/'), '[^/]+$', ''), '/')" />
    <xsl:variable name="c"
      select="string-join(
      for $i in 1 to count($a)
      return (if ($a[$i] = $b[$i]) then $a[$i] else ()), '/')" />
    
    <xsl:choose>
      <!--
        if $c is empty, $a and $b do not share a common base, and we cannot
        return a relative path from the source to the target. In that case
        we just return the resolved target-uri.
      -->
      <xsl:when test="$c eq ''">
        <xsl:sequence select="$target-uri" />
      </xsl:when>
      <xsl:otherwise>
        <!--
          Given the sequence $a and the string $c, we join $a using '/' and
          extract the substring remaining  after the prefix $c is removed.
          We then replace all path components with '..', resulting in the
          steps up the directory path which must be made to reach the
          target from the source. This path is named $steps.
        -->
        <xsl:variable name="steps"
          select="replace(replace(
          substring-after(string-join($a, '/'), $c),
          '^/', ''), '[^/]+', '..')" />
        
        <!--
          Resolving $steps against $source-uri gives us $common-path, the
          fully qualified path shared between $source-uri and $target-uri.
          
          Stripping $common-path from $target-uri and prepending $steps will
          leave us with $final-path, the relative path from  $source-uri to
          $target-uri. If the result is empty, the destination is './'
        -->
        <xsl:variable name="common-path"
          select="replace(resolve-uri($steps, $source-uri), '[^/]+$', '')" />
        
        <xsl:variable name="final-path"
          select="replace(concat($steps, substring-after($target-uri, $common-path)), '^/', '')" />
        
        <xsl:sequence
          select="xs:anyURI(if ($final-path eq '') then './' else $final-path)" />
        
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>


  <xsl:template name="generate-style">
    <xsl:if test="@n and @part and @part != 'I'">
      <xsl:variable name="n" select="@n"/>
      <xsl:variable name="start" select="preceding::*[@part='I'][1]"/>
      <xsl:variable name="sigil" select="@f:sigil"/>
      <xsl:variable name="before"
        select="normalize-space(string-join(($start, preceding::*[@part and . >> $start and 
          (if (@f:sigil) then @f:sigil=$sigil else true())]), ' '))"/>
      <xsl:attribute name="style"
        select="concat('text-indent:', 1.5 + 0.49*string-length($before), 'em;')"/>
<!--      <xsl:message select="concat('n=', $n, '; part=', @part, '; .=', normalize-space(.) , '; start=', normalize-space($start), '; before=', normalize-space($before))"/>-->
    </xsl:if>
  </xsl:template>
  
  <xsl:function name="f:sigil-label">
    <xsl:param name="type"/>
    <xsl:variable name="label" select="doc('sigil-labels.xml')//f:label[@type=$type]"/>
    <xsl:value-of select="if ($label) then $label else $type"/>
  </xsl:function>
  
  
  <xsl:function name="f:doclink">
    <xsl:param name="document"/>
    <xsl:param name="page"/>
    <xsl:param name="n"/>
    <xsl:value-of select="concat($docbase, '/', $document, '&amp;view=print')"/>
    <xsl:if test="$page">
      <xsl:value-of select="concat('&amp;page=', $page)"/>
    </xsl:if>
    <xsl:if test="$n">
      <xsl:value-of select="concat('#l', $n)"/>
    </xsl:if>
  </xsl:function>
  
  <xsl:function name="f:printlink">
    <xsl:param name="transcript"/>
    <xsl:param name="n"/>
    
    <xsl:variable name="split" select="f:is-splitable-doc(document($transcript))"/>
    <xsl:variable name="targetpart">
      <xsl:choose>
        <xsl:when test="$split">
          <xsl:variable name="div" select='document($transcript)//*[@n = $n 
            and not(self::pb or self::div or 
            self::milestone[@unit="paralipomenon"] or self::milestone[@unit="cols"] or 
            @n[contains(.,"todo")] or @n[contains(.,"p")])]/ancestor::div[1]'/>
          <xsl:if test="count($div) > 1">
            <xsl:message select="concat('ERROR: f:printlink(', $transcript, ', ', $n, '): more than one div.')"/>
          </xsl:if>
          <xsl:if test="$div">
            <xsl:text>.</xsl:text>
            <xsl:number 
              select="$div[1]"
              level="any"
              from="TEI"						
            />
          </xsl:if>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="concat($printbase,
      replace($transcript, '^.*/(.*)\.xml$', '$1'), $targetpart, '#l', $n)"/>
  </xsl:function>
  
  <!-- Returns true() iff $element is one of those TEI elements for which a variant apparatus should be generated. -->
  <xsl:function name="f:hasvars" as="xs:boolean">
    <xsl:param name="element"/>
    <xsl:value-of select='boolean($element[@n 
      and not(
      self::pb 
      or self::div 
      or self::milestone[@unit="paralipomenon"] 
      or self::milestone[@unit="cols"] 
      or @n[contains(.,"todo")] 
      or @n[contains(.,"p")])])'/>
  </xsl:function>

  <xsl:function name="f:splitSigil" as="item()*">
    <xsl:param name="sigil"/>
    <xsl:variable name="split" as="item()*">
      <xsl:analyze-string select="$sigil" regex="^([12]?\s*[IV]{{0,3}}\s*[^0-9]+)(\d*)(.*)$">
        <xsl:matching-substring>
          <xsl:sequence select="(regex-group(1), regex-group(2), regex-group(3))"/>
        </xsl:matching-substring>
        <xsl:non-matching-substring>
          <xsl:message select="concat('WARNING: Sigil “', $sigil, '” cannot be analyzed.')"/>
          <xsl:sequence select="($sigil, '99999', '')"/>
        </xsl:non-matching-substring>
      </xsl:analyze-string>                
    </xsl:variable>
    <xsl:sequence select="(
      if ($split[1] = 'H P') then '3 H P' else $split[1], 
      if ($split[2] =  '')   then -1      else number($split[2]),
      $split[3]
      )"/>
  </xsl:function>
  
  
  <!-- Whitespace normalization, improved. Cf. http://wiki.tei-c.org/index.php/XML_Whitespace -->
  <xsl:template match="text()" mode="normalize-space">
    <xsl:choose>
      <xsl:when
        test="ancestor::*[@xml:space][1]/@xml:space='preserve'">
        <xsl:value-of select="."/>
      </xsl:when>
      <xsl:otherwise>
        <!-- Retain one leading space if node isn't first, has
	     non-space content, and has leading space.-->
        <xsl:if test="position()!=1 and          matches(.,'^\s') and          normalize-space()!=''">
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:choose>
          <!-- node is an only child, and has content but it's all space -->
          <xsl:when test="last()=1 and string-length()!=0 and      normalize-space()=''">
            <xsl:text> </xsl:text>
          </xsl:when>
          <!-- node isn't last, isn't first, and has trailing space -->
          <xsl:when test="position()!=1 and position()!=last() and matches(.,'\s$')">
            <xsl:text> </xsl:text>
          </xsl:when>
          <!-- node isn't last, is first, has trailing space, and has non-space content   -->
          <xsl:when test="position()=1 and matches(.,'\s$') and normalize-space()!=''">
            <xsl:text> </xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:function name="f:normalize-space" as="xs:string">
    <xsl:param name="text" as="node()*"/>
    <xsl:variable name="nodes">
      <xsl:apply-templates select="$text" mode="normalize-space"/>      
    </xsl:variable>
    <xsl:value-of select="$nodes"/>
  </xsl:function>
  
  
  
</xsl:stylesheet>
