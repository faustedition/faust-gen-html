<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
    xmlns="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
    <!-- xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
        xmlns="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
        xmlns:ge="http://www.faustedition.net/ns"  -->
    <!--<xsl:output method="text"></xsl:output>-->
    <xsl:template match="@*|node()">
        <xsl:apply-templates select="attribute::* | child::node()"/>
    </xsl:template>
    <xsl:template match="/">
        <xsl:apply-templates select="attribute::* | child::node()"/>
    </xsl:template>
    <xsl:template
        match="node()[ancestor-or-self::div[@type='letter' and .//milestone[@unit='testimony']] or ancestor-or-self::pb] | @*[ancestor-or-self::div[@type='letter' and .//milestone[@unit='testimony']] or ancestor-or-self::pb] ">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="TEI">
        <!--<?oxygen RNGSchema="https://faustedition.uni-wuerzburg.de/schema/1.3/faust-tei.rng" type="xml"?>-->
        <TEI>
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title>WA IV ###</title>
                    </titleStmt>
                    <publicationStmt>
                        <p>Publication Information</p>
                    </publicationStmt>
                    <sourceDesc>
                        <p>Information about the source</p>
                    </sourceDesc>
                </fileDesc>
            </teiHeader>
            <text>
                <body>
                    
                    <xsl:apply-templates/>
                    
                </body>
            </text>
        </TEI>
    </xsl:template>
</xsl:stylesheet>