<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.tei-c.org/ns/1.0"	
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	exclude-result-prefixes="xs"
	version="2.0">
	
	<xsl:import href="utils.xsl"/>
	
	<xsl:output method="xml" indent="yes"/>
	
	<!-- This list is from the TEI's stylesheets: -->
	<xsl:strip-space elements="additional adminInfo altGrp altIdentifier analytic
		app appInfo application arc argument attDef attList availability back
		biblFull biblStruct bicond binding bindingDesc body broadcast cRefPattern
		calendar calendarDesc castGroup castList category certainty char charDecl
		charProp choice cit classDecl classSpec classes climate cond constraintSpec
		correction custodialHist decoDesc dimensions div div1 div2 div3 div4 div5
		div6 div7 divGen docTitle eLeaf eTree editionStmt editorialDecl elementSpec
		encodingDesc entry epigraph epilogue equipment event exemplum fDecl fLib
		facsimile figure fileDesc floatingText forest front fs fsConstraints fsDecl
		fsdDecl fvLib gap glyph graph graphic media group handDesc handNotes
		history hom hyphenation iNode if imprint incident index interpGrp
		interpretation join joinGrp keywords kinesic langKnowledge langUsage
		layoutDesc leaf lg linkGrp list listBibl listChange listEvent listForest
		listNym listOrg listPerson listPlace listRef listRelation listTranspose
		listWit location locusGrp macroSpec metDecl moduleRef moduleSpec monogr
		msContents msDesc msIdentifier msItem msItemStruct msPart namespace node
		normalization notatedMusic notesStmt nym objectDesc org particDesc
		performance person personGrp physDesc place population postscript precision
		profileDesc projectDesc prologue publicationStmt quotation rdgGrp
		recordHist recording recordingStmt refsDecl relatedItem relation
		relationGrp remarks respStmt respons revisionDesc root row samplingDecl
		schemaSpec scriptDesc scriptStmt seal sealDesc segmentation seriesStmt set
		setting settingDesc sourceDesc sourceDoc sp spGrp space spanGrp specGrp
		specList state stdVals subst substJoin superEntry supportDesc surface
		surfaceGrp table tagsDecl taxonomy teiCorpus teiHeader terrain text
		textClass textDesc timeline titlePage titleStmt trait transpose tree
		triangle typeDesc vAlt vColl vDefault vLabel vMerge vNot vRange valItem
		valList vocal"/>
	
	<xsl:template match="/">
		<xsl:apply-templates mode="normalize-space"/>
	</xsl:template>
	
</xsl:stylesheet>