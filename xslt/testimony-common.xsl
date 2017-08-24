<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="http://www.faustedition.net/ns"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- 
    
        This stylesheet contains common code used throughout various parts
        of the testimony handling.
    
    -->
    
    <xsl:param name="builddir-resolved" select="resolve-uri('../../../../target/')"/>
    <xsl:param name="transcript-list" select="resolve-uri('faust-transcripts.xml', resolve-uri($builddir-resolved))"/>
    
    
    <!-- ### Rendering of the field 'dokumenttyp' -> 'beschreibung'.  -->
    
    <!-- This is the spec: 
        
         If the field has the value from the name attribute, use the corresponding template.
         Replace $verfasser with the value of f:field[@name='verfasser'] from the table and so on.
    -->
    <xsl:variable name="beschreibung" xmlns="http://www.faustedition.net/ns">
        <template name="Brief">Brief von $verfasser an $adressat</template>
        <template name="Tagebuch">Tagebucheintrag von $verfasser</template>
        <template name="Gespräch">Gesprächsbericht von $verfasser</template>
        <template name="Text">$titel</template>
    </xsl:variable>
    
    <!-- Expands the fields according to the rules above. -->
    <xsl:function name="f:expand-fields">
        <xsl:param name="template" as="xs:string"/>
        <xsl:param name="context" as="node()*"/>
        <xsl:analyze-string select="$template" regex="\$[a-z0-9_-]+">
            <xsl:matching-substring>
                <xsl:variable name="field" select="substring(., 2)"/>
                <xsl:variable name="substitution" select="$context//*[@name = $field]"/>
                <xsl:choose>
                    <xsl:when test="$substitution">
                        <span title="{$field}"><xsl:value-of select="$substitution"/></span>
                    </xsl:when>
                    <xsl:otherwise>
                        <span class="message warning">$<xsl:value-of select="$field"/></span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    
    <!-- Renders the dokumenttyp field. Context: <field name='dokumenttyp'/> -->
    <xsl:template name="render-dokumenttyp">
        <!--<xsl:param name="beschreibung"/>-->
        <xsl:variable name="type" select="normalize-space(.)"/>
        <xsl:variable name="template" select="$beschreibung//template[@name = $type]"/>
        <xsl:choose>
            <xsl:when test="$template">
                <xsl:sequence select="f:expand-fields($template, ..)"/>
            </xsl:when>
            <xsl:otherwise>
                <div class="message warning">
                    <xsl:value-of select="."/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- ### Sigil links
    
        Takes a list of sigils like '2 H; 1 H.2' and generates HTML links to the corresponding witnesses.     
    -->
    <xsl:function name="f:sigil-links" as="node()*">
        <xsl:param name="sigils"/>
        <xsl:for-each select="tokenize($sigils, ';\s*')">
            <xsl:variable name="sigil" select="."/>
            <xsl:variable name="document" select="doc($transcript-list)//*[@f:sigil=$sigil]"/>
            <xsl:variable name="uri" select="$document/idno[@type='faust-doc-uri']/text()"/>
            <xsl:choose>
                <xsl:when test="not($document)">
                    <a class="message error">H-Sigle nicht gefunden: <a title="zur Handschriftenliste" href="/archive_manuscripts">»<xsl:value-of select="$sigil"/>«</a></a>
                </xsl:when>
                <xsl:otherwise>
                    <a href="{if ($document/@type='print')
                        then concat('/print/', replace(replace($document/@uri, '^.*/', ''), '\.xml$', ''))
                        else concat('/documentViewer?faustUri=', $uri)}"
                        title="{$document/headNote}">
                        <xsl:value-of select="$sigil"/>
                    </a>											
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="not(position() = last())">; </xsl:if>
        </xsl:for-each>
    </xsl:function>
    
    
    <!-- Returns a sequence of milestone and anchor elements that are linked from the given start milestone. --> 
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
    
    <!-- Removes leading zeroes from a testimony id -->
    <xsl:function name="f:real_id" as="xs:string">
        <xsl:param name="id"/>
        <xsl:value-of select="replace($id, '^(\w+)_0*(.*)$', '$1_$2')"/>
    </xsl:function>
    
    <!-- Returns the root milestone element for a given milestone -->
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
    
    <!-- ### Labels for the various testimony IDs -->
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