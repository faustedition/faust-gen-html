<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"    
    xmlns:f="http://www.faustedition.net/ns" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs f" version="2.0" xmlns:ge="http://www.tei-c.org/ns/geneticEditions">
    
    <!-- 

       This stylesheet undoes posthumous changes that are not encoded in a standoff manner.
       It should run before emend-core.xsl is applied, so the latter doesn't see what happend 
       posthumously …
       
       The script is limited to cases that actually are in the sources, so no undo handling
       and complex nested edits here.
    
    -->
        
      
    <xsl:template match="add[matches(@change,'#posthumous')]"/>
    
    <xsl:template match="restore[matches(@change,'#posthumous')]"/>

    <xsl:template match="del[matches(@change,'#posthumous')]">
        <xsl:apply-templates mode="#current"/>
    </xsl:template>
    
    <xsl:template match="subst[matches(@change,'#posthumous')]">
        <xsl:apply-templates select="del/node()" mode="#current"/>
    </xsl:template>
    
    
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="@*, node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
