<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="http://www.faustedition.net/ns"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:function name="f:milestone-chain" as="element()*">
        <xsl:param name="start" as="element()*"/>      
        <xsl:for-each select="$start">
            <xsl:variable name="spanTo-target" select="id(substring-after(@spanTo, '#'))"/>
            <xsl:variable name="next-target" select="id(substring-after(@next, '#'))"/>
            <xsl:sequence select=".,
                if (@spanTo and not($spanTo-target is .)) 
                then f:milestone-chain($spanTo-target)
                else (),
                if (@next and not ($next-target is .))
                then f:milestone-chain($next-target)
                else ()
                "/>
        </xsl:for-each>
    </xsl:function>
    
    <xsl:function name="f:real_id" as="xs:string">
        <xsl:param name="id"/>
        <xsl:value-of select="replace($id, '^(\w+)_0*(.*)$', '$1_$2')"/>
    </xsl:function>
    
    <xsl:function name="f:root-milestone" as="element()?">
        <xsl:param name="el"/>
        <xsl:for-each select="$el">
            <xsl:variable name="previous" select="preceding::milestone[@next = concat('#', $el/@xml:id)]"/>
            <xsl:variable name="pointshere" select="preceding::milestone[@spanTo = concat('#', $el/@xml:id)]"/>
            <xsl:choose>
                <xsl:when test="$previous"><xsl:sequence select="f:root-milestone($previous)"/></xsl:when>
                <xsl:when test="$pointshere"><xsl:sequence select="f:root-milestone($pointshere)"/></xsl:when>
                <xsl:when test="self::milestone"><xsl:sequence select="."/></xsl:when>
                <xsl:otherwise><xsl:message select="concat('Warning: Nothing points to ', @xml:id)"/></xsl:otherwise>
            </xsl:choose>			
        </xsl:for-each>
    </xsl:function>
    
    <xsl:variable name="taxonomies">
        <f:taxonomies>
            <f:taxonomy xml:id='graef'>Gräf Nr.</f:taxonomy>
            <f:taxonomy xml:id='pniower'>Pniower Nr.</f:taxonomy>
            <f:taxonomy xml:id='quz'>QuZ Nr.</f:taxonomy>
            <f:taxonomy xml:id='bie3'>Biedermann-Herwig Nr.</f:taxonomy>			
        </f:taxonomies>
    </xsl:variable>
    
    <xsl:function name="f:testimony-label">
        <xsl:param name="testimony-id"/>
        <xsl:variable name="id_parts" select="tokenize($testimony-id[1], '_')"/>
        <xsl:variable name="taxonomy" select="
            if (starts-with($id_parts[1], 'lfd-nr'))
            then 'Lfd. Nr.' 
            else id($id_parts[1], $taxonomies)/text()"/>
        <xsl:value-of select="concat($taxonomy, ' ', $id_parts[2])"/>
    </xsl:function>
    
    
    
</xsl:stylesheet>