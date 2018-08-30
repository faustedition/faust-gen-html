<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:f="http://www.faustedition.net/ns"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <xsl:import href="../xslt/utils.xsl"/>
  
  <xsl:output method="html"/>
  
  
  <xsl:template match="/">
    <html>
      <head>
        <title>lem vs. seg im Text</title>
        <style>
          tr { background: #eeeeee; }
          tr:hover { background: white; }          
          tr.equal { background: #efe;  color: gray; }
          tr.different { background: #fee; }
          tr.equal .sgn { color: green; }
          tr.different .sgn { color: red; }
          .sgn { font-weight: bold; }
          .verse { text-align: right; }
        </style>
      </head>
      <body>
        <table>
          <thead>
            <th>Vers</th>
            <th/>
            <th>Lemma</th>
            <th>im Text</th>
            <th>@from</th>            
          </thead>
          <tbody>
            <xsl:apply-templates select="//app[@from]"/>          
          </tbody>
        </table>
      </body>    
    </html>
  </xsl:template>
  
  <xsl:template match="app[@from]">
    <xsl:variable name="lemma_raw">
      <xsl:apply-templates mode="lem" select="descendant::lem"/>
    </xsl:variable>
    <xsl:variable name="lemma" select="normalize-space(f:contract-space($lemma_raw))" as="xs:string?"/>
    <xsl:variable name="lemma_clean" select="replace($lemma, '[‸]', '')"/>
    <xsl:variable name="segment" select="normalize-space(f:contract-space(string-join(for $ptr in tokenize(@from, '\s+') return id(substring($ptr, 2)), ' ')))" as="xs:string?"/>
    <xsl:variable name="equal" select="$lemma_clean eq $segment"/>
    <tr class="{if ($equal) then 'equal' else 'different'}">      
      <td class="verse"><a href="http://dev.faustedition.net/print/app#{ancestor::note[@type='textcrit']/@xml:id}"><xsl:value-of select="preceding-sibling::ref"/></a></td>
      <td class="sgn"><xsl:value-of select="if ($equal) then '=' else '≠'"/></td>
      <td><xsl:value-of select="$lemma"/></td>
      <td><xsl:value-of select="$segment"/></td>
      <td><xsl:value-of select="@from"/></td>
    </tr>
  </xsl:template>
  
  
  <xsl:template mode="lem" match="wit"/>
  
  
</xsl:stylesheet>