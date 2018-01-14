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
       
    <xsl:variable name="app" select="doc('../text/app1norm.xml'), doc('../text/app2norm.xml')"/>
    
    
    <xsl:template match="*[f:hasvars(.)][@n = $app//f:replace/@n]">
        <xsl:variable name="current-line" select="@n"/>
        <xsl:variable name="apps" select="$app//f:replace[@n=$current-line]/.." as="element()*"/>
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates select="@*, node()" mode="with-app">
                <xsl:with-param name="apps" select="$apps" tunnel="yes"/>
            </xsl:apply-templates>
            <note type="textcrit">
                <xsl:for-each select="$apps">
                    <xsl:copy-of select="ref" copy-namespaces="no"/>
                    <app from="#{generate-id(f:ins[1])}">
                        <xsl:apply-templates select="lem" mode="app"/>
                        <xsl:apply-templates select="rdg" mode="app"/>
                    </app>
                </xsl:for-each>
            </note>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template mode="with-app" match="text()" priority="1">
        <xsl:param name="apps" tunnel="yes"/>
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
                        <seg type="lem" xml:id="{generate-id(($current-app//f:ins)[1])}"> <!-- TODO klären was hier passiert -->
                            <xsl:value-of select="$current-app//f:ins"/>
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
    
    <xsl:template match="node() | @*" mode="#all">
        <xsl:copy copy-namespaces="no">
            <xsl:apply-templates mode="#current" select="@*, node()"/>
        </xsl:copy>
    </xsl:template>


<!-- zwei Versnummern in @n möglich!!! -->
    
</xsl:stylesheet>