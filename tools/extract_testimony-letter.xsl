<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0"
    xmlns="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:f="http://faustedition.net/ns"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns:svg="http://www.w3.org/2000/svg"
    xmlns:math="http://www.w3.org/1998/Math/MathML"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    >
    
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:template match="/">
        <xsl:processing-instruction name="oxygen">oxygen RNGSchema="https://faustedition.uni-wuerzburg.de/xml/schema/faust-tei_neu.rng" type="xml"</xsl:processing-instruction>
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
                    
                    <xsl:apply-templates select="descendant::div[@type='letter'][descendant::milestone[@unit='testimony']]"/>
                    
                </body>
            </text>
        </TEI>
    </xsl:template>
    
    <xsl:template match="div">
        <xsl:comment select="concat('Testimony ', string-join(descendant::milestone[@unit='testimony']/@xml:id, ', '))"/>
        <xsl:copy-of select="preceding::pb[1]"/>
        <xsl:copy-of select="."/>
    </xsl:template>
    
</xsl:stylesheet>