<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="xs"
	version="2.0">
	
	<xsl:param name="title">Digitale Faustedition</xsl:param>
	
	<xsl:template name="html-head">
		<xsl:param name="title" select="$title"/>
		<head>
			<meta charset='utf-8'/>
			
			<script type="text/javascript" src="../js/faust_common.js"/>
			<script src="../js/faust_print_view.js"/>
			<link href="//netdna.bootstrapcdn.com/font-awesome/3.2.1/css/font-awesome.css" rel="stylesheet"/>
			<link rel="stylesheet" href="../css/document-text.css"/>
			<link rel="stylesheet" href="../css/document-transcript.css"/>
			<link rel="stylesheet" href="../css/document-transcript-highlight-hands.css"/>
			<link rel="stylesheet" href="../css/document-transcript-interaction.css"/>
			<link rel="stylesheet" href="../css/pure-custom.css"/>
			<link rel="stylesheet" href="../css/basic_layout.css"/>
			<link rel="stylesheet" href="lesetext.css"/>
		</head>
		
	</xsl:template>
	
	<xsl:template name="header">
		<header>
			<div class="header-content">
				<a class="faustedition-logo" title="Faustedition" href="../index.php">
					<img class="faustedition-logo-svg" src="../img/faustlogo.svg" alt="Faustedition logo"/>
				</a>
				<nav class="header-navigation pure-menu">
					<a href="../archives.php">Archiv</a>
					<xsl:text> </xsl:text>
					<a href="../chessboard_overview.php">Genese</a>
					<xsl:text> </xsl:text>
					<a href="../print/index.html">Text</a>
				</nav>
			</div>
		</header>
	</xsl:template>
	
	<xsl:template name="footer">
		<footer>
			<div id='footer-content' class='footer-content'>
				<b>Digitale Faust-Edition</b>
			</div>
			<div id="footer-navigation" class="footer-navigation">
				<a href="help.php">Hilfe</a>
			</div>
		</footer>
		<footer>
			<div id='footer-content' class='footer-content'>
				<b>Digitale Faust-Edition</b>
			</div>
			<div id="footer-navigation" class="footer-navigation">
				<a href="../help.php">Hilfe</a>
				<xsl:text> </xsl:text>
				<a href="../contact.php">Kontakt</a>
				<xsl:text> </xsl:text>
				<a href="../imprint.php">Impressum</a>
				<xsl:text> </xsl:text>
				<a href="../project.php">Projekt</a>
			</div>
		</footer>
	</xsl:template>
		
	
</xsl:stylesheet>