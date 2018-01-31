<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:f="http://www.faustedition.net/ns"
    exclude-result-prefixes="xs f" 
    version="2.0">
    
    <xsl:import href="utils.xsl"/>
    <xsl:import href="bibliography.xsl"/>
    <xsl:output method="xml" indent="yes"/>
    <xsl:strip-space elements="app choice subst"/>
       
    <!-- The apparatus specification in XML form -->
    <xsl:variable name="spec" select="doc('../text/app1norm.xml'), 
                                      doc('../text/app2norm.xml'), 
                                      doc('../text/app2norm_test-cases.xml')"/>

    <xsl:template match="/">
        <xsl:variable name="inserted-apps">
            <xsl:apply-templates/>
        </xsl:variable>        
        <xsl:apply-templates mode="pass2" select="$inserted-apps"/>        
    </xsl:template>

    <!-- calculates an id for the seg corresponding to an app's f:ins -->
    <xsl:function name="f:seg-id" as="xs:string">
        <xsl:param name="ins" as="element(f:ins)"/>
        <xsl:variable name="parts" as="item()*">
            <xsl:for-each select="$ins">
                <xsl:variable name="strrep" select="replace(lower-case(.), '\W+', '')"/>
                <xsl:text>lem</xsl:text>
                <xsl:value-of select="@n"/>
                <xsl:choose>
                    <xsl:when test="$strrep != ''"><xsl:value-of select="$strrep"/></xsl:when>
                    <xsl:when test="@place"><xsl:value-of select="@place"/></xsl:when>
                    <xsl:otherwise><xsl:value-of select="count($ins/../preceding::app)"/></xsl:otherwise>
                </xsl:choose>                        
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="string-join($parts, '.')"/>
    </xsl:function>
    
    
    <!-- lines for which an apparatus entry exists -->
    <xsl:template match="*[f:hasvars(.)][tokenize(@n, '\s+') = $spec//f:ins/@n]">
        <xsl:variable name="current-line" select="tokenize(@n, '\s+')"/>
        <xsl:variable name="apps" select="$spec//f:replace[@n=$current-line]/.." as="element()*"/>
        <xsl:for-each select="$spec//f:ins[@place='before' and @n= $current-line]">
            <xsl:copy-of select="node()" copy-namespaces="no"/>
            <xsl:call-template name="create-app-note"><xsl:with-param name="apps" select=".."/></xsl:call-template>
        </xsl:for-each>
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@*, node()" mode="with-app">
                <xsl:with-param name="apps" select="$apps" tunnel="yes"/>
                <xsl:with-param name="current-line" select="$current-line" tunnel="yes"/>
            </xsl:apply-templates>
            <xsl:call-template name="create-app-note">
                <xsl:with-param name="apps" select="$apps"/>
            </xsl:call-template>
        </xsl:copy>
        <xsl:for-each select="$spec//f:ins[@place='after' and @n= $current-line]">
            <xsl:copy-of select="node()" copy-namespaces="no"/>
            <xsl:call-template name="create-app-note"><xsl:with-param name="apps" select=".."/></xsl:call-template>
        </xsl:for-each>
    </xsl:template>
    
    <!-- creates the note[@type="textcrit"] for the givven app element -->    
    <xsl:template name="create-app-note">
        <xsl:param name="apps"/>
        <note type="textcrit">
            <xsl:for-each select="$apps">
                <xsl:copy-of select="ref" copy-namespaces="no"/>
                <app from="#{f:seg-id(f:ins[1])}">
                    <xsl:apply-templates select="lem" mode="app"/>
                    <xsl:apply-templates select="rdg" mode="app"/>
                </app>
            </xsl:for-each>
        </note>
    </xsl:template>
    
    <!-- 
        esp. for the printed edition, we create a short sigil that leaves out the leading arabic number
        and uses superscript indexes for sigil parts that are preceded by .
        
        This function creates a TEI representation.
    -->
    <xsl:function name="f:short-sigil" as="item()*">
        <xsl:param name="sigil"/>
        <xsl:variable name="noprefix" select="replace($sigil, '^\d+\s*', '')"/>
        <xsl:analyze-string select="$noprefix" regex="\.(\S+)">
            <xsl:matching-substring>
                <hi rend="superscript">
                    <xsl:value-of select="regex-group(1)"/>
                </hi>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:copy/>
            </xsl:non-matching-substring>            
        </xsl:analyze-string>
    </xsl:function>
    
    <!-- We add a <wit> element with the sigil as it should be rendered at the end  -->
    <xsl:template match="lem|rdg" mode="app">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates mode="#current" select="@*, node()"/>
            <xsl:for-each select="tokenize(@wit, '\s+')">
                <xsl:variable name="uri" select="if (starts-with(., 'faust://')) then . else concat('faust://document/faustedition/', .)"/>
                <xsl:variable name="sigil" select="$idmap//f:idno[@uri=$uri]"/>
                <xsl:text> </xsl:text>
                <wit wit="{$uri}">
                    <xsl:sequence select="f:short-sigil($sigil)"/>                    
                </wit>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    
    <!-- the with-app mode is chosen for content where we know there is a lemma inside somewhere -->
    <!-- 
        This processes a relevant text node: It searches the text content for any lem inside, and
        if it finds one, it encloses it with <seg> and adds an apparatus note.
    -->
    <xsl:template mode="with-app" match="text()" priority="1">
        <xsl:param name="apps" tunnel="yes"/>
        <xsl:param name="current-line" tunnel="yes"/>        
        <xsl:variable name="re" select="replace(string-join($apps/f:replace, '|'), '([\]().*+?\[])', '\$1')"/>
        <!--<xsl:message select="concat('searching for /', $re, '/ in ', string-join($apps/@n, ', '))"/>-->
        <xsl:choose>
            <xsl:when test="$re = ''">
                <xsl:copy/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:analyze-string select="." regex="{$re}">
                    <xsl:matching-substring>
                        <xsl:variable name="current-match" select="."/>
                        <xsl:variable name="current-app" select="$apps[descendant::f:replace = $current-match]"/>
                        <seg type="lem" xml:id="{f:seg-id($current-app//f:ins[@n = $current-line])}"> <!-- TODO klären was hier passiert -->
                            <xsl:value-of select="$current-app//f:ins[@n = $current-line]"/>
                        </seg> 
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:copy copy-namespaces="no"/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template mode="app" match="@wit">
        <xsl:attribute name="wit" select="
            for $wit in tokenize(., '\s+')
                return concat('faust://document/faustedition/', $wit)"/>
    </xsl:template>
    
    <!-- f:ins[@place='enclosing-lg'] allows to set attributes on the lg enclosing a specific verse -->
    <xsl:template match="lg[*[@n = $spec//f:ins[@place='enclosing-lg']/@n]]">
        <xsl:variable name="insert-element" select="$spec//f:ins[@place='enclosing-lg'][@n = current()/l/@n]"/>
        <xsl:variable name="app-spec" select="$insert-element/.."/>
        <xsl:copy copy-namespaces="no">
            <!-- attributes from the apparatus -->
            <xsl:copy-of select="$insert-element/*/@*[data(.) != '']"/>
            <!-- attributes from the lg that are _not_ in the apparatus -->
            <xsl:apply-templates select="@*[not(name() = (for $attr in $insert-element/*/@* return name($attr)))]" mode="#current"/>
            <!-- text-critical note -->
            <xsl:call-template name="create-app-note">
                <xsl:with-param name="apps" select="$app-spec"/>
            </xsl:call-template>
            <!-- Everything else -->
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- 
        To split an existing lg, insert a <milestone unit='lg'/> at the break point. This template
        takes care of actually performing the split. The apparatus has already been generated when
        inserting the milestone. Attributes except @unit are copied from the milestone to the lg.    
    -->
    <xsl:template mode="pass2" match="lg[milestone[@unit='lg']]" name="build-lgs">
        <xsl:param name="original-lg" select="."/>
        <xsl:for-each-group select="node()" group-starting-with="milestone[@unit='lg']">
            <lg>
                <xsl:choose>
                    <xsl:when test="self::milestone[@unit='lg']">
                        <xsl:copy-of select="@* except @unit"/>
                        <xsl:apply-templates mode="#current" select="subsequence(current-group(), 2)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:copy-of select="$original-lg/@*"/>
                        <xsl:apply-templates mode="#current" select="current-group()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </lg>
        </xsl:for-each-group>
    </xsl:template>
    
    <!-- 
        To create lgs out of thin air, insert <milestone unit="@lg"/> in the appropriate places.
        This template takes the <sp> as outer boundary.
    -->
    <xsl:template mode="pass2" match="sp[milestone[@unit='lg']]">
        <xsl:copy copy-namespaces="no">
            <!-- collect children up to the first l -->
            <xsl:variable name="not-to-group" select="node()[not(preceding-sibling::l | self::l | self::milestone[@unit='lg'])]"/>
            <xsl:copy-of select="@*, $not-to-group" copy-namespaces="no"/>
            <xsl:for-each select="node() except $not-to-group">
                <xsl:call-template name="build-lgs"><xsl:with-param name="original-lg" select="()"/></xsl:call-template>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    
    <!-- 
        List of witnesses.
    -->
    <xsl:template mode="pass2" match="sourceDesc">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates mode="#current" select="@*"/>
            <listWit>
                <xsl:for-each-group select="for $wit in (//lem|//rdg)/@wit return tokenize($wit, '\s+')" group-by=".">
                    <xsl:variable name="uri" select="current-grouping-key()"/>                    
                    <witness corresp="{$uri}"><xsl:value-of select="$idmap//f:idno[@uri=$uri]/../f:idno[@type='faustedition']"/></witness>                    
                </xsl:for-each-group>
            </listWit>
        </xsl:copy>
    </xsl:template>
    
    <!-- Pass through unchanged everything else. -->
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates mode="#current" select="@*, node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>