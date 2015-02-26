<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml" xmlns:xh="http://www.w3.org/1999/xhtml"
	xmlns:f="http://www.faustedition.net/ns"	
	exclude-result-prefixes="xs"
	version="2.0">
	
	<xsl:variable name="transcripts" select="collection()[2]"/>
	<xsl:param name="title">Lesetexte</xsl:param>
	<xsl:output method="xhtml"/>
	
	
	<xsl:template match="/">
		<html>
			<xsl:call-template name="html-head">
				<xsl:with-param name="title" select="$title"/>
			</xsl:call-template>
			<body>
				<xsl:call-template name="header"/>
				<div id="main" class="center">
					<div class="yui3-g" style="margin-top: 2em">
						<div class="yui3-u-1-5"/> <!-- 1. Spalte (1/5) bleibt erstmal frei -->
						<div class="yui3-u-3-5">  <!-- 2. Spalte (3/5) für den Inhalt -->
							
							
							<h2>Lesetexte</h2>
							<nav>
							<ul>
								<li><a href="faust1.html">Faust I</a></li>
								<li><a href="faust2.html">Faust II</a></li>
							</ul>
							</nav>
							
							<h2>Drucke</h2>
							
							<nav>
							<ul>
								<xsl:for-each select="//f:textTranscript[@type='print']">
									<xsl:variable name="filename" select="replace(@href, '^.*/([^/]+)', '$1')"/>
									<xsl:variable name="htmlname" select="replace($filename, '\.xml$', '')"/>
									<li><a href="{$htmlname}.html" title="{f:idno[1]/@type}">
										<xsl:value-of select="f:idno[1]"/>
									</a></li>
								</xsl:for-each>
							</ul>
							</nav>
						  
						  <h2>Handschriften</h2>
						  
						  <h2>Drucke</h2>
						  
						  <nav>
						    <ul>
						      <xsl:for-each select="//f:textTranscript[@type='archivalDocument']">
						        <xsl:variable name="filename" select="replace(@href, '^.*/([^/]+)', '$1')"/>
						        <xsl:variable name="htmlname" select="replace($filename, '\.xml$', '')"/>
						        <li><a href="{$htmlname}.html" title="{f:idno[1]/@type}">
						          <xsl:value-of select="f:idno[1]"/>
						        </a></li>
						      </xsl:for-each>
						    </ul>
						  </nav>
						  
						</div>
					</div>
				</div>
			</body>
		</html>
		
	</xsl:template>
	
	
	<xsl:template name="html-head">
		<xsl:param name="title" select="$title"/>
		<head>
			<title>Digitale Faust-Edition: <xsl:value-of select="$title"/></title>
			
			
			
			<!-- http://purecss.io/ -->
			<link rel="stylesheet"
				href="https://faustedition.uni-wuerzburg.de/new/static/css/pure-min.css"/>
			<!-- http://fortawesome.github.io/Font-Awesome/ -->
			<link
				href="//netdna.bootstrapcdn.com/font-awesome/3.2.1/css/font-awesome.css"
				rel="stylesheet"/>
			<!-- http://www.google.com/fonts/: light, normal, medium, bold -->
			<link
				href="https://fonts.googleapis.com/css?family=Ubuntu:300,300italic,400,400italic,500,500italic,700,700italic"
				rel="stylesheet" type="text/css"/>
			<!-- http://www.google.com/fonts/: normal, bold -->
			<link
				href="https://fonts.googleapis.com/css?family=Ubuntu+Mono:400,400italic,700,700italic"
				rel="stylesheet" type="text/css"/>
			<link rel="stylesheet"
				href="https://faustedition.uni-wuerzburg.de/new/static/css/pure-custom.css"/>
			<link rel="stylesheet"
				href="https://faustedition.uni-wuerzburg.de/new/static/css/style.css"/>
			<script src="https://code.jquery.com/jquery-1.11.0.min.js"/>
			<script src="https://faustedition.uni-wuerzburg.de/new/static/js/functions.js"/>
			
			
			
			<link rel="stylesheet" type="text/css"
				href="https://faustedition.uni-wuerzburg.de/new/resources?yui3/build/cssreset/reset-min.css&amp;yui3/build/cssgrids/grids-min.css&amp;yui3/build/cssbase/base-min.css"/>
			
			<link rel="stylesheet" type="text/css"
				href="https://faustedition.uni-wuerzburg.de/new/static/css/faust.css"/>
			
			<!-- FIXME merge with faust.css -->
			<link rel="stylesheet" type="text/css" href="lesetext.css"/>
			
			
			
			<script type="text/javascript">
				var cp = '/new';
				var Faust = { contextPath: cp, FacsimileServer: "https://faustedition.uni-wuerzburg.de/images/iipsrv.fcgi" };
			</script>
			<script type="text/javascript" src="https://faustedition.uni-wuerzburg.de/new/static/yui3/build/yui/yui-debug.js"/>
			<script type="text/javascript" src="https://faustedition.uni-wuerzburg.de/new/static/js/yui-config.js"/>
			<script type="text/javascript" src="https://faustedition.uni-wuerzburg.de/new/static/js/faust.js"/>
			
			<link rel="schema.DC" href="http://purl.org/dc/elements/1.1/"/>
			<link rel="schema.DCTERMS" href="http://purl.org/dc/terms/"/>
			<meta name="DC.format" scheme="DCTERMS.IMT" content="text/html"/>
			<meta name="DC.type" scheme="DCTERMS.DCMIType" content="Text"/>
			<meta name="DC.publisher" content="Digitale Faust-Edition"/>
			<meta name="DC.creator" content="Digitale Faust-Edition"/>
			<meta name="DC.subject"
				content="Faust, Johann Wolfgang von Goethe, Historisch-kritische Edition, digital humanities"/>
			<!-- 
	<meta name="DCTERMS.license"  scheme="DCTERMS.URI" content="http://www.gnu.org/copyleft/fdl.html">
	<meta name="DCTERMS.rightsHolder" content="Wikimedia Foundation Inc.">
	 -->
		</head>
	</xsl:template>
	<xsl:template name="header">
		<header class="">
			<div class="center">
				<a class="logo" href="/new/" title="Faustedition">
					<img
						src="https://faustedition.uni-wuerzburg.de/new/static/img/logo.svg"
						width="380" height="30" alt="Faustedition"/>
				</a>
				
				<div
					class="pure-menu pure-menu-open pure-menu-horizontal pure-submenu pure-right">
					<ul>
						<li>
							<a href="https://faustedition.uni-wuerzburg.de/new/xml-query/">
								<i class="icon-wrench"/> Query</a>
						</li>
						<li>
							<a
								href="https://faustedition.uni-wuerzburg.de/new/project/contact"
								>Kontakt</a>
						</li>
						<li>
							<a
								href="https://faustedition.uni-wuerzburg.de/new/project/imprint"
								>Impressum</a>
						</li>
						<li>
							<a href="https://faustedition.uni-wuerzburg.de/new/project/about"
								>Projekt</a>
						</li>
					</ul>
				</div>
				<nav class="pure-menu pure-menu-open pure-menu-horizontal pure-right">
					<ul>
						<li>
							<a href="https://faustedition.uni-wuerzburg.de/new/archive/"
								>Archiv</a>
						</li>
						<li>
							<a href="https://faustedition.uni-wuerzburg.de/new/genesis/work/"
								>Genese</a>
						</li>
						<li>
							<a href="https://faustedition.uni-wuerzburg.de/new/text/sample"
								>Text</a>
						</li>
						<li>
							<form class="pure-form">
								<input id="quick-search" type="text" placeholder="Suche"/>
							</form>
						</li>
					</ul>
				</nav>
			</div>
			
		</header>
	</xsl:template>
	
	
</xsl:stylesheet>