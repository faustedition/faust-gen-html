<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
  version="2.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
  <xsl:strip-space elements="TEI additional address adminInfo altGrp altIdentifier analytic app appInfo 
                             application arc argument availability back biblFull biblStruct bicond binding
                             bindingDesc body cRefPattern castGroup castList category certainty char 
                             charDecl charProp choice cit classDecl climate cond correction custodialHist 
                             decoDesc dimensions div div1 div2 div3 div4 div5 div6 div7 divGen docTitle 
                             document eLeaf eTree editionStmt editorialDecl encodingDesc epigraph epilogue 
                             event fDecl fLib facsimile figure fileDesc floatingText forest forestGrp front
                             fs fsConstraints fsDecl fsdDecl fvLib gap geneticGrp geneticNote glyph graph 
                             graphic group handDesc handNotes history hyphenation iNode if imprint index
                             interpGrp interpretation join joinGrp keywords langKnowledge langUsage layoutDesc
                             leaf lg linkGrp list listBibl listEvent listNym listOrg listPerson listPlace 
                             listWit location locusGrp metDecl monogr msContents msDesc msIdentifier msItem 
                             msItemStruct msPart namespace node normalization notesStmt nym objectDesc org
                             overw particDesc performance person personGrp physDesc place population postscript
                             precision profileDesc projectDesc prologue publicationStmt quotation rdgGrp
                             recordHist refsDecl relatedItem relation relationGrp respStmt respons revisionDesc
                             root row samplingDecl scriptDesc seal sealDesc segmentation seriesStmt set setting
                             settingDesc sourceDesc sp space spanGrp stageNotes state stdVals subst supportDesc
                             surface table tagsDecl taxonomy teiCorpus teiHeader terrain text textClass textDesc
                             timeline titlePage titleStmt trait transpose transposeGrp tree triangle typeDesc vAlt
                             vColl vDefault vLabel vMerge vNot vRange "/>
  
  <xsl:output method="xml" indent="yes" byte-order-mark="no" encoding="UTF-8"/>
  
  <xsl:template match="text()">
    <xsl:choose>
      <xsl:when test="ancestor::*[@xml:space][1]/@xml:space = 'preserve'">
        <xsl:value-of select="."/>
      </xsl:when>
      <xsl:otherwise>
        <!-- Retain one leading space if node isn't first, has
	     non-space content, and has leading space.-->
        <xsl:if test="position() != 1 and matches(., '^\s') and normalize-space() != ''">
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:choose>
          <!-- node is an only child, and has content but it's all space -->
          <xsl:when test="last() = 1 and string-length() != 0 and normalize-space() = ''">
            <xsl:text> </xsl:text>
          </xsl:when>
          <!-- node isn't last, isn't first, and has trailing space -->
          <xsl:when test="position() != 1 and position() != last() and matches(., '\s$')">
            <xsl:text> </xsl:text>
          </xsl:when>
          <!-- node isn't last, is first, has trailing space, and has non-space content   -->
          <xsl:when test="position() = 1 and matches(., '\s$') and normalize-space() != ''">
            <xsl:text> </xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="*|comment()|processing-instruction()|@*">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>
