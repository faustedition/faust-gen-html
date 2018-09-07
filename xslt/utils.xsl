<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:f="http://www.faustedition.net/ns"
  xmlns="http://www.tei-c.org/ns/1.0"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <!-- should we split inside the current document or not? -->
  <xsl:param name="splitchars" select="5000"/>
  <xsl:param name="splitdivs" select="5"/>
  <xsl:param name="docbase">/document?sigil=</xsl:param>
  <xsl:param name="printbase"/>
  <xsl:param name="documentURI"/>
  <xsl:param name="sigil_t" select="//idno[@type='sigil_t']"/>
  <xsl:param name="type" select="data(/TEI/@type)"/>
  <xsl:param name="apptypes" select="doc('../text/apptypes.xml')"/>
  
  <xsl:param name="order-url">http://dev.digital-humanities.de/ci/view/Faust/job/faust-macrogen/lastSuccessfulBuild/artifact/target/macrogenesis/order.xml</xsl:param>
  <xsl:variable name="order" select="doc($order-url)"/>  
      
  <!-- 
    
    Returns true if this document should be split into sections.
    
    Note that add-metadata.xsl saves this in /TEI/@f:splittable, so its easier for all later steps
    to just check for that attribute.
  
  -->
  <xsl:function name="f:is-splitable-doc" as="xs:boolean">
    <xsl:param name="document"/>
    <xsl:value-of select="count(root($document)//div[not(@type='stueck')]) ge number($splitdivs) 
                      and string-length(normalize-space(string-join(root($document)//text//text()[not(ancestor::div[@type='stueck'])], ' '))) ge number($splitchars)"/>
  </xsl:function>
  
  <!-- 
    Calculates the section number for any element. This only works _after_ step 2 since it uses
    the @f:section elements inserted there. Returns an empty string if this document is not to 
    be split.
  -->
  <xsl:function name="f:get-section-number" as="xs:string?">
    <xsl:param name="el" as="node()?"/>
    <xsl:value-of select="f:get-section-div($el)/@f:section"/>
  </xsl:function>
  
  <xsl:function name="f:get-section-div" as="element()?">
    <xsl:param name="el" as="node()?"/>
    <xsl:choose>
      <xsl:when test="not($el//ancestor-or-self::TEI/@f:split)"/>
      <xsl:when test="$el/ancestor-or-self::div/@f:section"><xsl:sequence select="$el/ancestor-or-self::div[@f:section][1]"/></xsl:when>
      <xsl:when test="$el/descendant::div/@f:section"><xsl:sequence select="($el/descendant::div[@f:section])[1]"/></xsl:when>
      <xsl:when test="$el/following::div/@f:section"><xsl:sequence select="($el/following::div[@f:section])[1]"/></xsl:when>
      <xsl:otherwise><xsl:sequence select="$el/preceding::div[@f:section][1]"/></xsl:otherwise>
    </xsl:choose>    
  </xsl:function>
  
  <xsl:function name="f:get-section-label">
    <xsl:param name="el" as="node()"/>
    <xsl:variable name="secno" select="f:get-section-number($el)"/>
    <xsl:variable name="basename" select="root($el)//idno[@type='sigil_t']"/>    
    <xsl:value-of select="if ($secno != '') then concat($basename, '.', $secno) else $basename"/>
  </xsl:function>
  
  <!-- These functions return the scene info even on non-annotated divs -->
  <xsl:variable name="scenes" select="doc('scenes.xml')"/>
  
  <xsl:function name="f:integer" as="xs:integer*">
    <xsl:param name="input" as="xs:string*"/>
    <xsl:param name="max" as="xs:boolean"/>
    <xsl:variable name="nums" as="xs:integer*" select="
        for $s in tokenize(string-join($input, ' '), '\D+') 
          return if ($s != '') then xs:integer($s) else ()"/>
    <xsl:sequence select="xs:integer(if ($max) then max($nums) else min($nums))"/>      
  </xsl:function>
  
  <xsl:function name="f:get-containing-scene-info" as="node()*">
    <xsl:param name="first-verse-raw"/>
    <xsl:param name="last-verse-raw"/>
    
    <xsl:variable name="first-verse" select="f:integer($first-verse-raw, false())"/>
    <xsl:variable name="last-verse" select="f:integer($last-verse-raw, true())"/>
    
    <xsl:variable name="first-verse-scene" select="$scenes//*[xs:integer(@first-verse) le $first-verse and xs:integer(@last-verse) ge $first-verse]"/>
    <xsl:variable name="last-verse-scene" select="$scenes//*[xs:integer(@first-verse) le $last-verse and xs:integer(@last-verse) ge $last-verse]"/>
    <xsl:variable name="common-scene" select="($first-verse-scene/ancestor-or-self::* intersect $last-verse-scene/ancestor-or-self::*)[position() = last()]"/>
    <xsl:sequence select="$common-scene"/>    
  </xsl:function>
  
  <xsl:function name="f:get-scene-info" as="node()*">
    <xsl:param name="div" as="element()"/>
    <xsl:variable name="explicit-scene" select="$scenes//*[@n = $div/@n]"/>
    <xsl:choose>
      <xsl:when test="$explicit-scene">
        <xsl:sequence select="$explicit-scene"/>
      </xsl:when>
      <xsl:otherwise>		
        <xsl:variable name="contained-verses" select="$div//*[f:is-schroer(.)]/@n"/>
        <xsl:variable name="first-verse" select="tokenize($contained-verses[1], '\s+')[1]"/>
        <xsl:variable name="last-verse"  select="tokenize($contained-verses[position() = last()], '\s+')[position()=last()]"/>			
        <xsl:variable name="scene" select="f:get-containing-scene-info($first-verse, $last-verse)"/>
        <xsl:sequence select="$scene"/>
<!--        <xsl:message select="concat('Detected scene info for ', $first-verse, '-', $last-verse, ':  ', $scene/@n)"/>-->
      </xsl:otherwise>
    </xsl:choose>		
  </xsl:function>
  
  
  
  
  <xsl:function name="f:numerical-lineno">
    <xsl:param name="n"/>
    <xsl:value-of select="number(replace($n, '\D*(\d+).*', '$1'))"/>
  </xsl:function>
  
  <xsl:function name="f:raw-output-group">
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
  
  <xsl:function name="f:output-group">
    <xsl:param name="n"/>
    <xsl:value-of select="if (contains($n, ' ')) then '_' else f:raw-output-group($n)"/>
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
        or self::head or self::closer or (@n and not(self::milestone or self::pb))]">
        <xsl:sequence select="false()"/>
      </xsl:when>
      <xsl:when test="$element[self::hi or self::seg or self::w or self::pb]">
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
  
  <xsl:template mode="remove-notes" match="node() | @*">
    <xsl:copy><xsl:apply-templates select="@*, node()" mode="#current"/></xsl:copy>
  </xsl:template>
  <xsl:template mode="remove-notes" match="note"/>
  <xsl:function name="f:remove-notes" as="item()*">
    <xsl:param name="content"/>
    <xsl:apply-templates mode="remove-notes" select="$content"/>
  </xsl:function>

  <xsl:template name="generate-style">
    <xsl:if test="@n and @part and @part != 'I'">
      <xsl:variable name="n" select="@n"/>
      <xsl:variable name="start" select="preceding::*[@part='I'][1]"/>
      <xsl:variable name="sigil" select="@f:sigil"/>
      <xsl:variable name="before"
        select="normalize-space(string-join(f:remove-notes(($start, preceding::*[@part and . >> $start and 
          (if (@f:sigil) then @f:sigil=$sigil else true())])), ' '))"/>
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
    <xsl:param name="sigil_t"/>
    <xsl:param name="page"/>
    <xsl:param name="n"/>
    <xsl:variable name="lineid" select="concat('l', replace($n, '\s+', '_'))"/>
    <xsl:value-of select="concat('/document?sigil=', $sigil_t, '&amp;view=print')"/>
    <xsl:if test="$page">
      <xsl:value-of select="concat('&amp;page=', $page)"/>
    </xsl:if>
    <xsl:if test="$n">
      <xsl:value-of select="concat('#', $lineid)"/>
    </xsl:if>
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
      )])'/>
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
  
  <xsl:template match="lb[not(@break='no')]" mode="normalize-space">
    <xsl:text> </xsl:text>
  </xsl:template>
  
  <xsl:template match="*|comment()|processing-instruction()|@*" mode="normalize-space">
    <xsl:copy>
      <xsl:apply-templates mode="#current" select="@*, node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:function name="f:normalize-space" as="xs:string">
    <xsl:param name="text" as="node()*"/>
    <xsl:variable name="nodes">
      <xsl:apply-templates select="$text" mode="normalize-space"/>
    </xsl:variable>
    <xsl:value-of select="replace(string-join($nodes, ''), '&#x00AD;', '')"/> <!-- Soft Hyphen -->
  </xsl:function>
  
  
  <xsl:function name="f:is-schroer" as="xs:boolean">
    <xsl:param name="element"/>
    <xsl:value-of select="f:hasvars($element) and matches($element/@n, '^\d+')"/>
  </xsl:function>
 

  <!-- Reuse IDs from the XML source (since they are manually crafted) -->
  <xsl:function name="f:generate-id" as="xs:string">
    <xsl:param name="element"/>
    <xsl:value-of select="if ($element/@xml:id) then $element/@xml:id else generate-id($element)"/>
  </xsl:function>
  
  <!-- Zeichen -->
  <xsl:function name="f:normalize-print-chars_">
    <xsl:param name="text"/>
    <xsl:variable name="tmp1" select=" replace($text,'ā','aa')"/>
    <xsl:variable name="tmp2" select=" replace($tmp1,'ē','ee')"/>
    <xsl:variable name="tmp3" select=" replace($tmp2,'m̄','mm')"/>
    <xsl:variable name="tmp4" select=" replace($tmp3,'n̄','nn')"/>
    <xsl:variable name="tmp5" select=" replace($tmp4,'r̄','rr')"/>
    <xsl:variable name="tmp5a" select=" replace($tmp5,'ſs','ß')"/>
    <xsl:variable name="tmp6" select=" replace($tmp5a,'ſ','s')"/>
    <xsl:variable name="tmp7" select=" if ($text instance of node() and $text/ancestor-or-self::pc[@type='censorship']) 
                                          then $tmp6 else replace($tmp6,'—','–')"/>    
    <xsl:value-of select="$tmp7"/>
  </xsl:function>
  <xsl:function name="f:normalize-print-chars" as="item()*">
    <xsl:param name="texts" as="item()*"/>
    <xsl:sequence select="for $text in $texts return f:normalize-print-chars_($text)"/>
  </xsl:function>
  
  <xsl:function name="f:sigil-for-uri" as="xs:string">
    <xsl:param name="sigil" as="xs:string"/>
    <xsl:value-of select="if ($sigil = 'Lesetext' or $sigil = 'Text') 
                          then 'faust' 
                          else replace(replace(normalize-space($sigil), 'α', 'alpha'), '[^A-Za-z0-9.-]', '_')"/>
  </xsl:function>
  
  <xsl:function name="f:contract-space" as="xs:string">
    <xsl:param name="input" as="xs:string"/>
    <xsl:value-of select="replace($input, '[\p{Z}\r\n\t]+', ' ')"/>
  </xsl:function>
  
  
  <!-- apparatus entry types -->
  <xsl:function name="f:format-rdg-type" as="xs:string">
    <xsl:param name="type"/>
    <xsl:variable name="typeno" select="replace($type, '^type_', '')"/>
    <xsl:variable name="formatted-typeno" as="item()*">
      <xsl:analyze-string select="$typeno" regex="\d+">
        <xsl:matching-substring>
          <xsl:number format="I" value="."/>          
        </xsl:matching-substring>
        <xsl:non-matching-substring>
          <xsl:copy/>
        </xsl:non-matching-substring>
      </xsl:analyze-string>
    </xsl:variable>
    <xsl:value-of select="string-join($formatted-typeno, '&#x200a;')"/><!-- Hair Space -->
  </xsl:function>
  
  <xsl:function name="f:rdg-type-descr" as="xs:string">
    <xsl:param name="type"/>
    <xsl:variable name="exact-match" select="$apptypes//f:apptype[@type=$type]"/>
    <xsl:variable name="start-match" select="$apptypes//f:apptype[starts-with($type, @type)][1]"/>
    <xsl:variable name="result">
      <xsl:choose>
        <xsl:when test="$exact-match[self::f:apptype]">
          <xsl:value-of select="$exact-match"/>
        </xsl:when>
        <xsl:when test="$start-match">
          <xsl:value-of select="$start-match"/>
          <xsl:variable name="rest" select="substring($type, string-length($start-match/@type)+1)"/>
          <xsl:choose>
            <xsl:when test="$rest = '*'"> (nicht übernommen)</xsl:when>
            <xsl:otherwise> (<xsl:value-of select="$rest"/>)<xsl:message select="concat('WARNING: Label for app type ', $type, ' incomplete: rest »', $rest, '«')"/></xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$type"/>
          <xsl:message select="concat('ERROR: No apparatus type description for ', $type)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$result"/>
  </xsl:function>
  
  <xsl:function name="f:get-order-info" as="element()?">
    <xsl:param name="sigil_t"/>
    <xsl:sequence select="$order//f:item[@sigil_t = $sigil_t]"/>
  </xsl:function>
  
  <!-- Macrogenetic order. Returns an index for a given sigil_t. If used with two parameters, the second is added to the index. -->
  <xsl:function name="f:get-wit-index">
    <xsl:param name="sigil_t"/>
    <xsl:param name="extra"/>
    <xsl:variable name="el" select="f:get-order-info($sigil_t)"/>
    <xsl:variable name="idx" select="if ($el) then number($el/@index) else 99999"/>
    <xsl:value-of select="$idx + $extra"/>
  </xsl:function>
  <xsl:function name="f:get-wit-index">
    <xsl:param name="sigil_t"/>
    <xsl:value-of select="f:get-wit-index($sigil_t, 0)"/>
  </xsl:function>
  
    
  
</xsl:stylesheet>
