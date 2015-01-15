<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:f="http://www.faustedition.net/ns" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs" version="2.0">
    
    <!--<xsl:output method="text"/>-->
    
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="abbr[parent::choice]"></xsl:template>
    <xsl:template match="add">
        <xsl:apply-templates></xsl:apply-templates>
    </xsl:template>
    <xsl:template match="app/text()"/>
    <xsl:template match="choice/text()"/>
    <xsl:template match="choice">
        <xsl:apply-templates></xsl:apply-templates>
    </xsl:template>
    <xsl:template match="corr"/>
    <xsl:template match="del"/>
    <xsl:template match="del[parent::restore]">
        <xsl:apply-templates></xsl:apply-templates>
    </xsl:template>
    <xsl:template match="encodingDesc"></xsl:template>
    <!--    <xsl:template match="ex"/>
        <xsl:template match="expan"/>
    -->    <xsl:template match="g[matches(@ref, '#parenthesis_left')]">
        <xsl:text>(</xsl:text>
    </xsl:template>
    <xsl:template match="g[matches(@ref, '#parenthesis_right')]">
        <xsl:text>)</xsl:text>
    </xsl:template>
    <xsl:template match="profileDesc"></xsl:template>
    <xsl:template match="rdg"/>
    <xsl:template match="restore">
        <xsl:apply-templates></xsl:apply-templates>
    </xsl:template>
    <xsl:template match="revisionDesc"></xsl:template>
    <!--<xsl:template match="supplied"/>-->
    <xsl:template match="supplied[matches(@evidence, 'internal')]">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"></xsl:apply-templates>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="subst/text()"/>
    <xsl:template match="subst">
        <xsl:apply-templates></xsl:apply-templates>
    </xsl:template>
    <!--<xsl:template match="teiHeader"/>-->
    <!-- Zeichen -->
    <xsl:template match="text()">
        <xsl:variable name="tmp1" select=" replace(.,'ā','aa')"/>
        <xsl:variable name="tmp2" select=" replace($tmp1,'ē','ee')"/>
        <xsl:variable name="tmp3" select=" replace($tmp2,'m̄','mm')"/>
        <xsl:variable name="tmp4" select=" replace($tmp3,'r̄','rr')"></xsl:variable>
        <xsl:variable name="tmp5" select=" replace($tmp4, 'ſ','s')"></xsl:variable>
        <xsl:value-of select="$tmp5"/>
    </xsl:template>
    
    <!--    <xsl:template match="orig/text()">
        <xsl:value-of select=" replace(., 'a','ä')"></xsl:value-of>
        </xsl:template>
    -->    <!--<xsl:template match="orig/text()">
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
    
    <!--    <xsl:template match="text()">
        <xsl:value-of select="replace(.,'ſ','s')"/>
        </xsl:template>
    -->    <!--<xsl:template match="text()"><xsl:value-of select="replace(., '','’')"/></xsl:template>-->
    
    <!-- <xsl:template match="text()"><xsl:value-of select="translate($desc,''',' ')"/></xsl:template> -->
    
    <!--  <xsl:variable name="apos">'</xsl:variable>
        <xsl:template match="text()"><xsl:value-of select="translate($desc, $apos,'’')"></xsl:value-of></xsl:template> -->
</xsl:stylesheet>