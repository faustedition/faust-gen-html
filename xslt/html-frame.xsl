<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:f="http://www.faustedition.net/ns" exclude-result-prefixes="xs f"
	version="2.0">

	<xsl:param name="title">Faust-Edition [beta]</xsl:param>
	<xsl:param name="edition">..</xsl:param>
	<xsl:param name="assets" select="$edition"/>
	<xsl:param name="debug" select="false()"/>
	<xsl:param name="headerAdditions"/>
	<xsl:param name="query"/>

	<xsl:output method="xhtml" indent="yes" include-content-type="no"
		omit-xml-declaration="yes"/>

	<xsl:template name="html-head">
		<xsl:param name="title" select="$title"/>
		<head>
			<meta charset="utf-8"/>

			<script src="{$assets}/js/sortable.min.js"/>
			<script type="text/javascript" src="{$assets}/js/faust_common.js"/>
			<script src="{$assets}/js/faust_print_interaction.js"/>
			

			<link rel="stylesheet" href="{$assets}/css/document-text.css"/>
			<link rel="stylesheet" href="{$assets}/css/document-transcript.css"/>
			<link rel="stylesheet"
				href="{$assets}/css/document-transcript-highlight-hands.css"/>
			<link rel="stylesheet"
				href="{$assets}/css/document-transcript-interaction.css"/>
			<link rel="stylesheet" href="{$assets}/css/webfonts.css"/>
			<link rel="stylesheet" href="{$assets}/css/fontawesome-min.css"/>
			<link rel="stylesheet" href="{$assets}/css/pure-min.css"/>
			<link rel="stylesheet" href="{$assets}/css/pure-custom.css"/>
			<link rel="stylesheet" href="{$assets}/css/basic_layout.css"/>
			<link rel="stylesheet" href="{$assets}/css/textual-transcript.css"/>
			<script><xsl:text>window.addEventListener("DOMContentLoaded", function(){addPrintInteraction("../");});</xsl:text></script>

			<link rel="icon" type="image/png" href="/favicon-16x16.png"
				sizes="16x16"/>
			<link rel="icon" type="image/png" href="/favicon-32x32.png"
				sizes="32x32"/>

			<xsl:copy-of select="$headerAdditions"/>
		</head>

	</xsl:template>

	<xsl:template name="header">
		<xsl:param name="breadcrumbs">
			<div class="breadcrumbs pure-right pure-nowrap pure-fade-50">
				<small id="breadcrumbs"/>
			</div>
			<div id="current" class="pure-nowrap"/>
		</xsl:param>
		<header>
			<div class="logo">
				<a href="{$edition}/" title="Faustedition">
					<img src="{$assets}/img/faustlogo.svg" alt="Faustedition"/>
				</a>
				<sup class="pure-fade-50">
					<mark>beta</mark>
				</sup>
			</div>

			<xsl:copy-of select="$breadcrumbs"/>

			<nav
				class="pure-menu pure-menu-open pure-menu-horizontal pure-right pure-nowrap pure-noprint">
				<ul>
					<li>
						<a href="{$edition}/archive">Archiv</a>
					</li>
					<li>
						<a href="{$edition}/genesis">Genese</a>
					</li>
					<li>
						<a href="{$edition}/text">Text</a>
					</li>
					<li>
						<form class="pure-form" action="/search" method="GET">
							<input id="quick-search" name="q" type="text"
								onblur="this.value=''"/>
							<button type="submit" class="pure-fade-30">
								<i class="fa fa-search fa-lg"/>
							</button>
						</form>
					</li>
					<li>
						<a href="{$edition}/imprint">
							<small class="pure-fade-50">Impressum</small>
						</a>
					</li>
					<li>
						<a href="{$edition}/help">
							<i class="fa fa-help-circled fa-lg"/>
						</a>
					</li>
				</ul>
			</nav>
		</header>
	</xsl:template>

	<xsl:template name="footer">
		<!-- Piwik -->
		<script type="text/javascript">
  var _paq = _paq || [];
  _paq.push(['trackPageView']);
  _paq.push(['enableLinkTracking']);
  (function() {
    var u="//analytics.faustedition.net/";
    _paq.push(['setTrackerUrl', u+'piwik.php']);
    _paq.push(['setSiteId', 1]);
    var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
    g.type='text/javascript'; g.async=true; g.defer=true; g.src=u+'piwik.js'; s.parentNode.insertBefore(g,s);
  })();
</script>
		<noscript>
			<p>
				<img src="//analytics.faustedition.net/piwik.php?idsite=1"
					style="border:0;" alt=""/>
			</p>
		</noscript>
		<!-- End Piwik Code -->
	</xsl:template>


	<xsl:template name="html-frame">
		<xsl:param name="content">
			<xsl:apply-templates/>
		</xsl:param>
		<html>
			<xsl:call-template name="html-head"/>
			<body>
				<xsl:call-template name="header"/>
				<main class="nofooter">
					<section>
						<article>
							<xsl:sequence select="$content"/>
						</article>
					</section>
				</main>
				<xsl:call-template name="footer"/>
			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>
