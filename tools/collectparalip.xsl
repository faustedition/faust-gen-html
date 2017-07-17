<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <!-- source mit 
        <id>391352</id>
        <id>391353</id>
        etc.
 -->
    <xsl:template match="id">
        <xsl:copy-of
            select="doc(concat('http://beta:beta@beta.faustedition.net/print/', ., '-emended.xml'))"
        />
    </xsl:template>
    <xsl:template match="/">
        <teiCorpus>
            <xsl:apply-templates></xsl:apply-templates>
        </teiCorpus>
    </xsl:template>
</xsl:stylesheet>