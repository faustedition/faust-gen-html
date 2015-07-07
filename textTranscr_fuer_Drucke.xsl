<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:f="http://www.faustedition.net/ns" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs f" version="2.0" xmlns:ge="http://www.tei-c.org/ns/geneticEditions">

    <xsl:import href="harmonize-antilabes.xsl"/>

    <xsl:template match="@* | node()">
        <xsl:choose>
            <xsl:when test="name() = 'status'"/>
            <xsl:when test="name() = 'xml:space'"/>
            <xsl:when test="name() = 'f:revType'"/>
            <xsl:when test="name() = 'ge:stage'"/>
            <xsl:otherwise>
                <xsl:copy>
                    <xsl:apply-templates select="@* | node()"/>
                </xsl:copy>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="abbr[parent::choice]">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="expan[parent::choice]"/>
    <xsl:template match="add">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="add[@f:rejectedBy]"/>
    <xsl:template match="am[parent::choice]">
        <xsl:apply-templates></xsl:apply-templates>
    </xsl:template>
    <xsl:template match="app">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="lem">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="rdg"/>
    <xsl:template match="choice">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="corr"/>

    <xsl:template match="del">
        <xsl:apply-templates mode="del"/>
    </xsl:template>
    <xsl:template mode="del" match="restore">
        <xsl:apply-templates mode="#default"/>
    </xsl:template>
    <xsl:template mode="del" match="node()">
        <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:template>

    <xsl:template match="restore/subst">
        <xsl:apply-templates select="del/node()"/>
    </xsl:template>

    <xsl:template match="subst/del/restore[../../add/del]" mode="del">
        <!--        <xsl:message select="concat('Experimental suppression of del that will appear in add. del: ', normalize-space(.), ' in ', document-uri(/))"/>-->
    </xsl:template>
    <xsl:template match="subst/add/del[../../del/restore]" priority="1">
        <xsl:apply-templates select="../../del/restore"/>
        <!--        <xsl:message select="concat('Experimental add/del-restore-substitution. add: ', normalize-space(..), 
            ' del: ', normalize-space(.), ' @', position(), ' in ', document-uri(/))"/>
-->
    </xsl:template>

    <xsl:template match="encodingDesc"/>
    <xsl:template match="facsimile"/>
    <!--    <xsl:template match="ex"/>
    <xsl:template match="expan"/>
    -->
    <xsl:template match="g[matches(@ref, '#parenthesis_left')]">
        <xsl:text>(</xsl:text>
    </xsl:template>
    <xsl:template match="g[matches(@ref, '#parenthesis_right')]">
        <xsl:text>)</xsl:text>
    </xsl:template>
    <xsl:template match="note[@type = 'editorial']"/>
    <xsl:template match="note[@resp = '#hwg']"/>
    <!-- wieso headerelemente rauswerfen? 
    <xsl:template match="profileDesc"/>
    <xsl:template match="publicationStmt"/> -->
    <xsl:template match="restore">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="revisionDesc"/>


    <xsl:template match="s">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="seg">
        <xsl:apply-templates/>
    </xsl:template>

    <!--    <xsl:template match="sourceDesc"/>-->
    <!--<xsl:template match="supplied"/>-->
    <xsl:template match="supplied[matches(@evidence, 'internal')]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="supplied[@reason = 'typesetting-error']"/>

    <xsl:template match="subst">
        <xsl:apply-templates/>
    </xsl:template>
    <!--<xsl:function name="v:fetch-delSpan" as="element(delSpan)?">
        <xsl:param name="n" as="node()"/>
        <!-\- del will be the most recent delSpan milestone -\->
        <xsl:variable name="del" select="$n/preceding::delSpan[1]"/>
        <!-\- $del/id(@spanTo) will be its end anchor -\->
        <!-\- return $del if its end anchor appears after the argument node -\->
        <xsl:sequence select="$del[id(@spanTo) >> $n]"/>
    </xsl:function>-->
    <!--    <xsl:template match="teiHeader">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="titleStmt">
        <xsl:apply-templates/>
    </xsl:template>-->
    <!-- Zeichen -->
    <!-- XXX string-replace im xproc direkt? -->
    <xsl:template match="text()" priority="1">
        <xsl:variable name="tmp1" select="replace(., 'ā', 'aa')"/>
        <xsl:variable name="tmp2" select="replace($tmp1, 'ē', 'ee')"/>
        <xsl:variable name="tmp3" select="replace($tmp2, 'm̄', 'mm')"/>
        <xsl:variable name="tmp4" select="replace($tmp3, 'n̄', 'nn')"/>
        <xsl:variable name="tmp5" select="replace($tmp4, 'r̄', 'rr')"/>
        <xsl:variable name="tmp6" select="replace($tmp5, 'ſ', 's')"/>
        <xsl:variable name="tmp7" select="replace($tmp6, '—', '–')"/>
        <xsl:variable name="tmp8" select="replace($tmp7, '&#x00AD;', '')"/>
        <!-- Soft Hyphen -->
        <xsl:value-of select="$tmp8"/>
    </xsl:template>
    <xsl:strip-space elements="app choice subst"/>



    <!--    <xsl:template match="orig/text()">
        <xsl:value-of select=" replace(., 'a','ä')"></xsl:value-of>
        </xsl:template>
    -->
    <!--<xsl:template match="orig/text()">
        <xsl:value-of select=" replace(., 'o','ö')"></xsl:value-of>
        </xsl:template>
        <xsl:template match="orig/text()">
        <xsl:value-of select=" replace(., 'u','ü')"></xsl:value-of>
        </xsl:template>-->
    <!--    <xsl:template match="text()[parent::orig]">
        <xsl:value-of select="replace('a', 'a','ä')"></xsl:value-of>
        </xsl:template>
        <xsl:template match="text()[parent::orig]">
        <xsl:value-of select=" replace('o', 'o','ö')"></xsl:value-of>
        </xsl:template>
        <xsl:template match="text()[parent::orig]">
        <xsl:value-of select=" replace('u', 'u','ü')"></xsl:value-of>
        </xsl:template>
    -->
    <!--<xsl:template match="text()"><xsl:value-of select="replace(., '','’')"/></xsl:template>-->

    <!-- <xsl:template match="text()"><xsl:value-of select="translate($desc,''',' ')"/></xsl:template> -->

    <!--  <xsl:variable name="apos">'</xsl:variable>
        <xsl:template match="text()"><xsl:value-of select="translate($desc, $apos,'’')"></xsl:value-of></xsl:template> -->
</xsl:stylesheet>
