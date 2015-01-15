<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0"
  xmlns="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0">
  <xsl:output indent="no"/>
  <xsl:template match="*">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>
  <xsl:template match="@*|processing-instruction()|comment()">
    <xsl:copy/>
  </xsl:template>
  <xsl:template match="text()">
    <xsl:choose>
      <xsl:when test="ancestor::*[@xml:space][1]/@xml:space='preserve'">
        <xsl:value-of select="."/>
      </xsl:when>
      <xsl:otherwise>
        <!-- Retain one leading space if node isn't first, has
          non-space content, and has leading space.-->
        <xsl:if
          test="position()!=1 and          matches(.,'^\s') and          normalize-space()!=''">
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:choose>
          <!-- node is an only child, and has content but it's all space -->
          <xsl:when test="last()=1 and string-length()!=0 and      normalize-space()=''">
            <xsl:text> </xsl:text>
          </xsl:when>
          <!-- node isn't last, isn't first, and has trailing space -->
          <xsl:when test="position()!=1 and position()!=last() and matches(.,'\s$')">
            <xsl:text> </xsl:text>
          </xsl:when>
          <!-- node isn't last, is first, has trailing space, and has non-space content   -->
          <xsl:when test="position()=1 and matches(.,'\s$') and normalize-space()!=''">
            <xsl:text> </xsl:text>
          </xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:strip-space
    elements="TEI additional address adminInfo altGrp altIdentifier analytic app appInfo application arc argument attDef attList availability back biblFull biblStruct bicond binding bindingDesc body broadcast cRefPattern calendar calendarDesc castGroup castList category certainty char charDecl charProp choice cit classDecl classSpec classes climate cond constraintSpec correction custodialHist decoDesc dimensions div div1 div2 div3 div4 div5 div6 div7 divGen docTitle eLeaf eTree editionStmt editorialDecl elementSpec encodingDesc entry epigraph epilogue equipment event exemplum fDecl fLib facsimile figure fileDesc floatingText forest front fs fsConstraints fsDecl fsdDecl fvLib gap glyph graph graphic group handDesc handNotes history hom hyphenation iNode if imprint incident index interpGrp interpretation join joinGrp keywords kinesic langKnowledge langUsage layoutDesc leaf lg linkGrp list listApp listBibl listChange listEvent listForest listNym listOrg listPerson listPlace listPrefixDef listRef listRelation listTranspose listWit location locusGrp macroSpec media metDecl moduleRef moduleSpec monogr msContents msDesc msIdentifier msItem msItemStruct msPart namespace node normalization notatedMusic notesStmt nym objectDesc org particDesc performance person personGrp physDesc place population postscript precision prefixDef profileDesc projectDesc prologue publicationStmt quotation rdgGrp recordHist recording recordingStmt refsDecl relatedItem relation relationGrp remarks respStmt respons revisionDesc root row samplingDecl schemaSpec scriptDesc scriptStmt seal sealDesc segmentation seriesStmt set setting settingDesc sourceDesc sourceDoc sp spGrp space spanGrp specGrp specList state stdVals styleDefDecl subst substJoin superEntry supportDesc surface surfaceGrp table tagsDecl taxonomy teiCorpus teiHeader terrain text textClass textDesc timeline titlePage titleStmt trait transpose tree triangle typeDesc vAlt vColl vDefault vLabel vMerge vNot vRange valItem valList vocal "
  />
</xsl:stylesheet>
