<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:f="http://www.faustedition.net/ns"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <!-- 
  
  e.g., 
  
  Reference:
  
                      <date when="1832-09-20">[20. 9. 1832]<anchor xml:id="N29"/><ref target="#F29"
                                ><hi rend="sup">4</hi></ref></date>

  
  Footnote:
  
                  <p>
                    <anchor xml:id="F29"/>
                    <ref target="#N29"><hi rend="sup">4</hi><gap reason="copyright"/>
                            <milestone unit="testimony" spanTo="#quz_III-44A_end"
                            xml:id="quz_III-44A"/><quote>Mit Riemer werde ich noch heute <rs>wegen
                                Faust pp. sprechen</rs></quote>.<anchor xml:id="quz_III-44A_end"/>
                        <gap reason="copyright"/></ref>
                </p>
  
  -->
  
  <xsl:function name="f:is-footnote-anchor" as="xs:boolean">
    <xsl:param name="footnote-anchor"/>
    <xsl:variable name="backref" select="$footnote-anchor/following-sibling::*[1][self::ref]"/>
    <xsl:choose>
      <xsl:when test="$backref">
        <xsl:variable name="backref-target" select="id(substring-after($backref/@target, '#'), $footnote-anchor)[$footnote-anchor >> .]"/>
        <xsl:variable name="footnote-ref" select="$backref-target/following-sibling::*[1][self::ref]"/>
        <xsl:value-of select="not(empty($footnote-ref/@target)) and (substring-after($footnote-ref/@target, '#') eq $footnote-anchor/@xml:id)"/>        
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="false()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="f:is-footnote-ref" as="xs:boolean">
    <xsl:param name="footnote-ref"/>    
    <xsl:value-of select="if ($footnote-ref/@target) 
        then f:is-footnote-anchor(id(substring-after($footnote-ref/@target, '#'), $footnote-ref)) 
        else false()"/>
  </xsl:function>
  
  
  <!-- Anchor for the backref -> suppress -->
  <xsl:template match="anchor[f:is-footnote-ref(following-sibling::*[1])]"/>
  
  <!-- Footnote reference -> render and render actual footnote immediately afterwards -->
  <xsl:template match="ref[f:is-footnote-ref(.)]">
    <xsl:next-match/>
    <xsl:variable name="footnote" select="id(substring-after(@target, '#'))"/>
    <note place="foot">
      <xsl:sequence select="$footnote/@xml:id"/>
      <xsl:apply-templates select="$footnote/node()"/>
    </note>
  </xsl:template>
  
  <xsl:template match="p[anchor[f:is-footnote-anchor(.)]]">
    <xsl:variable name="remaining-content" select="node() except (anchor[f:is-footnote-anchor(.)]|ref|gap)"/>
    <xsl:if test="normalize-space(string-join($remaining-content, '')) != ''">
      <xsl:message select="concat('WARNING: In ', document-uri(/), ', p containing anchor ', 
        string-join(anchor/@xml:id, ', '), ' contains more than the footnote.')"/>
      <xsl:apply-templates/>
    </xsl:if>
  </xsl:template>  
  
  <xsl:template match="node()|@*">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates mode="#current" select="@*, node()"/>
    </xsl:copy>
  </xsl:template>
  
  
</xsl:stylesheet>