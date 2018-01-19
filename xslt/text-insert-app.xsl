<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:f="http://www.faustedition.net/ns"
    exclude-result-prefixes="xs f" 
    version="2.0">
    
    <xsl:import href="utils.xsl"/>
    <xsl:output method="xml" indent="yes"/>
       
    <!-- The apparatus specification in XML form -->
    <xsl:variable name="spec" select="doc('../text/app1norm.xml'), 
                                      doc('../text/app2norm.xml'), 
                                      doc('../text/app2norm_test-cases.xml')"/>
    
    <xsl:template match="/">
        <xsl:variable name="inserted-apps">
            <xsl:apply-templates/>
        </xsl:variable>
        
        <xsl:apply-templates mode="fix-lgs" select="$inserted-apps"/>        
    </xsl:template>
    
    
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
    
    
    
    <xsl:template name="create-app-note">
        <xsl:param name="apps"/>
        <note type="textcrit">
            <xsl:for-each select="$apps">
                <xsl:copy-of select="ref" copy-namespaces="no"/>
                <app from="#{generate-id(f:ins[1])}">
                    <xsl:apply-templates select="lem" mode="app"/>
                    <xsl:apply-templates select="rdg" mode="app"/>
                </app>
            </xsl:for-each>
        </note>
    </xsl:template>
    
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
                        <seg type="lem" xml:id="{generate-id($current-app//f:ins[@n = $current-line])}"> <!-- TODO klären was hier passiert -->
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
    
    <xsl:template mode="fix-lgs" match="lg[milestone[@unit='lg']]" name="build-lgs">
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
    
    <xsl:template mode="fix-lgs" match="sp[milestone[@unit='lg']]">
        <xsl:copy copy-namespaces="no">
            <!-- collect children up to the first l -->
            <xsl:variable name="not-to-group" select="node()[not(preceding-sibling::l | self::l | self::milestone[@unit='lg'])]"/>
            <xsl:copy-of select="@*, $not-to-group" copy-namespaces="no"/>
            <xsl:for-each select="node() except $not-to-group">
                <xsl:call-template name="build-lgs"><xsl:with-param name="original-lg" select="()"/></xsl:call-template>
            </xsl:for-each>
        </xsl:copy>
    </xsl:template>
    
    
    
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates mode="#current" select="@*, node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>