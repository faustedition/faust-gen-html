<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.faustedition.net/ns"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:f="http://www.faustedition.net/ns"
    xpath-default-namespace="http://www.faustedition.net/ns" exclude-result-prefixes="xs f"
    version="2.0">

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <!--    <xsl:template match="@xsi:schemaLocation[parent::Dokument]">

        <xsl:attribute name="xsi:schemaLocation"
            select="'http://www.faustedition.net/ns https://faustedition.uni-wuerzburg.de/xml/schema/metadata.xsd'"> </xsl:attribute>

    </xsl:template>
-->
    <xsl:template match="disjunctLeaf">
        
            <xsl:apply-templates select="node()"/>
        
    </xsl:template>

    <xsl:template match="page">
        <xsl:apply-templates select="@*|node()"/>
    </xsl:template>

    <xsl:template match="metadata">

        <page>
            <metadata>
                <xsl:apply-templates select="@*|node()"/>
            </metadata>
        </page>

    </xsl:template>

</xsl:stylesheet>
