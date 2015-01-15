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
    <xsl:template match="add">
        <xsl:apply-templates></xsl:apply-templates>
    </xsl:template>
    <xsl:template match="app/text()"/>
    <xsl:template match="choice/text()"/>
    <xsl:template match="choice">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="corr"/> 
    <xsl:template match="del"/>
    <xsl:template match="editionStmt"></xsl:template>
    <xsl:template match="encodingDesc"></xsl:template>
    <xsl:template match="ex"/>
    <xsl:template match="expan"/>
    <xsl:template match="front"></xsl:template>
    <xsl:template match="note"></xsl:template>
    <xsl:template match="publicationStmt"></xsl:template>
    <xsl:template match="rdg"/>
    <xsl:template match="revisionDesc"></xsl:template>
    <xsl:template match="sic">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="sourceDesc"></xsl:template>
    <xsl:template match="subst/text()"/>
    <xsl:template match="supplied"></xsl:template>
<!--    <xsl:template match="teiHeader"/>
-->    
<!--    <xsl:template match="rdg[matches(@resp, 'fl')]">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="lem[parent::app/rdg[matches(@resp, 'fl')]]"/>
-->
<!--    <xsl:template match="speaker/text()">
        <xsl:value-of select="upper-case(.)"/>
    </xsl:template>
    <xsl:template match="hi[@status='name']/text()">
        <xsl:value-of select="upper-case(.)"/>
    </xsl:template>
-->    <!-- Zeichen -->
    <!--     <xsl:template match="text()"><xsl:value-of select=" replace(.,'m̄','mm')"></xsl:value-of></xsl:template>
        <xsl:template match="text()"><xsl:value-of select="replace(.,'n̄','nn')"></xsl:value-of></xsl:template>
        <xsl:template match="text()"><xsl:value-of select="replace(.,'ſ','s')"></xsl:value-of></xsl:template>
    -->
    <!--<xsl:template match="text()"><xsl:value-of select="replace(., '','’')"/></xsl:template>-->

    <!-- <xsl:template match="text()"><xsl:value-of select="translate($desc,''',' ')"/></xsl:template> -->

    <!--  <xsl:variable name="apos">'</xsl:variable>
        <xsl:template match="text()"><xsl:value-of select="translate($desc, $apos,'’')"></xsl:value-of></xsl:template> -->
</xsl:stylesheet>
