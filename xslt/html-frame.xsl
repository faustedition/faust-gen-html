<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns="http://www.w3.org/1999/xhtml"
	xmlns:h="http://www.w3.org/1999/xhtml"
	xmlns:f="http://www.faustedition.net/ns" exclude-result-prefixes="xs f h"
	version="2.0">

	<xsl:param name="title">Faustedition</xsl:param>
	<xsl:param name="edition"></xsl:param>
	<xsl:param name="assets" select="$edition"/>
	<xsl:param name="debug" select="false()"/>
	<xsl:param name="documentURI"/>
	<xsl:param name="headerAdditions"/>
	<xsl:param name="scriptAdditions"/>
	<xsl:param name="query" select="/f:results/@query"/>

	<xsl:output method="xhtml" indent="yes" include-content-type="no"
		omit-xml-declaration="yes"/>
	
	<xsl:function name="f:enquote" as="xs:string">
		<xsl:param name="what" as="xs:string"/>
		<xsl:variable name="quote">'</xsl:variable>
		<xsl:value-of select="concat($quote, $what, $quote)"/>
	</xsl:function>
	
	
	<!-- Creates the JSON required by Faust.createBreadcrumbs  -->
	<xsl:function name="f:breadcrumb-json">
		<xsl:param name="breadcrumb-html"/>
		<xsl:choose>
			<xsl:when test="$breadcrumb-html//h:a">
				<xsl:text>[</xsl:text>
				<xsl:for-each select="$breadcrumb-html//h:a">
					<xsl:text>{caption:"</xsl:text><xsl:value-of select="replace(normalize-space(.), '&quot;', '')"/><xsl:text>"</xsl:text>
					<xsl:if test="@href">
						<xsl:text>,link:"</xsl:text><xsl:value-of select="@href"/><xsl:text>"</xsl:text>
					</xsl:if>
					<xsl:text>}</xsl:text>
					<xsl:if test="position() != last()">,</xsl:if>
				</xsl:for-each>
				<xsl:text>]</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="normalize-space($breadcrumb-html)"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<!-- 
		Creates a short JS fragment that inserts breadcrumbs. The argument can be either:
		(a) text: will just create a single text node as heading
		(b) sequence of html a elements: will create a regular breadcrumb sequence
		(c) two html spans, each with a sequence of a elements: will create a double breadcrumb 
	-->
	<xsl:template name="f:breadcrumb-script">
		<xsl:param name="breadcrumb-def" required="yes"/>
		<xsl:variable name="double" as="xs:boolean" select="not(empty($breadcrumb-def[count(h:span) = 2]))"/>
			var breadcrumbs = document.getElementById("breadcrumbs");
			breadcrumbs.appendChild(Faust.createBreadcrumbs(<xsl:value-of select="f:breadcrumb-json(if ($double) then $breadcrumb-def/h:span[1] else $breadcrumb-def)"/>));
		<xsl:if test="$double">
			breadcrumbs.appendChild(document.createElement("br"));
			breadcrumbs.appendChild(Faust.createBreadcrumbs(<xsl:value-of select="f:breadcrumb-json($breadcrumb-def/h:span[2])"/>));				
		</xsl:if>		
	</xsl:template>
	

	<xsl:template name="html-head">
		<xsl:param name="title" select="$title" tunnel="yes"/>
		<xsl:param name="headerAdditions" select="$headerAdditions"/>
		<xsl:param name="scriptAdditions"/>
		<xsl:comment select="concat('Generated: ', current-dateTime())"/>
		<head>
			<meta charset="utf-8"/>

			<script type="text/javascript" src="{$assets}/js/require.js"/>
			<script type="text/javascript" src="{$assets}/js/faust_config.js"/>

			<link rel="stylesheet" href="{$assets}/css/webfonts.css"/>
			<link rel="stylesheet" href="{$assets}/css/fontawesome-min.css"/>
			<link rel="stylesheet" href="{$assets}/css/pure-min.css"/>
			<link rel="stylesheet" href="{$assets}/css/pure-custom.css"/>
			<link rel="stylesheet" href="{$assets}/css/basic_layout.css"/>
			<link rel="stylesheet" href="{$assets}/css/overlay.css"/>
			<link rel="stylesheet" href="{$assets}/css/textual-transcript.css"/>
			<link rel="stylesheet" href="{$assets}/css/prints-viewer.css"/>
			<xsl:if test="$scriptAdditions">
				<script>
					requirejs(["faust_common"], function(Faust) {
	    				<xsl:copy-of select="$scriptAdditions"/>				  
					});
				</script>				
			</xsl:if>

			<link rel="icon" type="image/png" href="/favicon-16x16.png"
				sizes="16x16"/>
			<link rel="icon" type="image/png" href="/favicon-32x32.png"
				sizes="32x32"/>

			<xsl:copy-of select="$headerAdditions"/>
		</head>

	</xsl:template>

	<xsl:template name="header">
		<xsl:param name="breadcrumbs" tunnel="yes">***</xsl:param>
		<xsl:if test="$breadcrumbs != '***'"><xsl:message>ERROR: breadcrumbs param is not supported any longer</xsl:message></xsl:if>
		<header>
			<div class="logo">
				<a href="{$edition}/" title="Faustedition">
					<img src="{$assets}/img/faustlogo.svg" alt="Faustedition"/>
				</a>
				<sup class="pure-fade-50">
					<mark>alpha</mark>
				</sup>
			</div>
			
			<div class="breadcrumbs pure-right pure-nowrap pure-fade-50">
				<small id="breadcrumbs"/>
			</div>
			<div id="current" class="pure-nowrap"/>

			<nav id="nav_all" class="pure-menu pure-menu-open pure-menu-horizontal pure-right pure-nowrap pure-noprint">
				<ul>
					<li><a href="/help" title="Hilfe"><i class="fa fa-help-circled fa-lg"></i></a></li>
					<li><a href="#quotation" title="Zitieremfehlung"><i class="fa fa-bookmark fa-lg"></i></a></li>
					<li><a href="#download" title="Download"><i class="fa fa-download fa-lg"></i></a></li>
					<li><form class="pure-form" action="/query" method="GET"><input id="quick-search" name="q" type="text" onblur="this.value=''" /><button type="submit" class="pure-fade-30"><i class="fa fa-search fa-lg"></i></button></form></li>
					<li><a href="#navigation" title="Seitennavgation"><i class="fa fa-menu fa-lg"></i> Menü</a></li>
				</ul>
			</nav>
		</header>
	</xsl:template>

	<xsl:template name="footer">		
		<xsl:param name="breadcrumb-def" tunnel="yes" select="false()"/>
		<!-- 
			either a sequence of <a href>, or two spans each enclosing a sequence of <a href> for one- or two-line breadcrumbs,
			or just a string for title without breadcrumbs		
		-->
		<xsl:param name="jsRequirements" as="xs:string*"/>
		<!-- 
			additional requirements for the script additions. Syntax of each string: requirejs_name:variable_name 
		-->
		<xsl:param name="scriptAdditions" select="$scriptAdditions"/>
		<!-- additional javascript -->
		<noscript>
			<div class="pure-alert pure-alert-warning">
				<h3>JavaScript erforderlich</h3>
				<p>Die Faustedition bietet ein interaktives Userinterface, für das JavaScript erforderlich ist.</p>
				<p>Bitte deaktivieren Sie ggf. vorhandene Skriptblocker für diese Seite.</p>
			</div>
		</noscript>
		
		<div id="cookie-consent" class="pure-modal center" style="top:auto;">
     <div class="pure-modal-body">
       <p>Diese Website verwendet Cookies und vergleichbare Technologien zur Sicherstellung der
         Funktionalität und – optional entsprechend Ihren Einstellungen – für eine anonymisierte
         Nutzungsstatistik zur Analyse der Nutzung und zur Verbesserung der
         Edition. Lesen Sie auch unsere <a href="imprint#privacy">Datenschutzerklärung</a>.</p>
       <p class="pure-right">
         <a id="functional-cookies-button" class="pure-button">nur funktionale Cookies zulassen</a>
         <a id="cookie-consent-button" class="pure-button">auch Statistik erlauben</a>
       </p>
     </div>

		</div>
		
		
		<footer>
			<div class="center pure-g-r">
				<div class="pure-u-1-2 pure-fade-50">
					<a class="undecorated" rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons Lizenzvertrag" src="https://i.creativecommons.org/l/by-nc-sa/4.0/80x15.png" align="middle" /></a>
				</div>
				<div class="pure-u-1-2 pure-right pure-fade-50 pure-noprint">
					<a href="project">Projekt</a>
					·
					<a href="intro">Ausgabe</a>
					·
					<a href="contact">Kontakt</a>
					·
					<a href="imprint">Impressum</a>
					·
					<a href="intro#sitemap">Sitemap</a>
				</div>
			</div>
		</footer>
		
		<script type="text/template" id="navigation">
			<div class="center pure-g-r navigation">
				<div class="pure-u-1-4 pure-gap">
					<a href="/archive"><big>Archiv</big></a>
					<a href="/archive_locations">Aufbewahrungsorte</a>
					<a href="/archive_manuscripts">Handschriften</a>
					<a href="/archive_prints">Drucke</a>
					<a href="/archive_testimonies">Entstehungszeugnisse</a>
					<a href="/archive_materials">Materialien</a>
				</div>
				<div class="pure-u-1-4 pure-gap">
					<a><big>Genese</big></a>
					<a href="/genesis">Werkgenese</a>
					<a href="/genesis_faust_i">Genese Faust I</a>
					<a href="/genesis_faust_ii">Genese Faust II</a>
					<a href="/macrogenesis">Makrogenese-Lab</a>
				</div>
				<div class="pure-u-1-4 pure-gap">
					<a href="/text"><big>Text</big></a>
					<a href="/print/faust">Faust: Konstituierter Text</a>
					<a href="/print/app">Apparat</a>
					<a href="/intro_text">Editorischer Bericht</a>
					<br />
					<a href="/paralipomena">Paralipomena</a>
				</div>
				<div class="pure-u-1-4 pure-gap pure-fade-50">
					<a><big>Informationen</big></a>
					<a href="/intro">Über die Ausgabe</a>
					<a href="/project">Über das Projekt</a>
					<a href="/contact">Kontakt</a>
					<a href="/imprint">Impressum</a>
					<a href="/intro#sitemap">Sitemap</a>
					<a class="undecorated" rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons Lizenzvertrag" src="https://i.creativecommons.org/l/by-nc-sa/4.0/80x15.png" align="middle" /></a>
				</div>
			</div>
		</script>
		
		
		<script type="text/template" id="quotation">
			<div class="center pure-g-r quotation">
				<div class="pure-u-1">
					<h3>Zitierempfehlung</h3>
					<p class="quotation-content">
						Johann Wolfgang Goethe: Faust. Historisch-kritische Edition.
						Herausgegeben von Anne Bohnenkamp, Silke Henke und Fotis Jannidis
						unter Mitarbeit von Gerrit Brüning, Katrin Henzel, Christoph Leijser, Gregor Middell, Dietmar Pravida, Thorsten Vitt und Moritz Wissenbach.
						alpha-Version. Frankfurt am Main / Weimar / Würzburg 2019,
						<span>{context}</span>,
						<span>URL: <a href="{url}">{url}</a></span>,
						abgerufen am {date}.
					</p>
					<p><i class="fa fa-paste pure-fade-50"></i> <a href="#" data-target=".quotation-content">kopieren</a></p>
				</div>
			</div>
		</script>
		
		
		<script type="text/template" id="download">
			
			<div class="center pure-g-r navigation">
				<div class="pure-u-1">
					<h3><i class="fa fa-code" aria-hidden="true"></i> XML-Quellen</h3>
				</div>
				<div id="xml-global" class="pure-u-1-3 pure-gap">
					<a><big>Globale TEI-Daten</big></a>
					<a href="https://github.com/faustedition/faust-xml"><i class="fa fa-github-circled"></i> alle XML-Daten</a>
					<a href="/downloads/testimony-split.zip" disabled="disabled"><i class="fa fa-file-archive"></i> Entstehungszeugnisse</a>
					<a href="/downloads/faust.xml" disabled="disabled"><i class="fa fa-file-code"></i> konstituierter Text</a>
				</div>
				
				<div id="xml-current" class="pure-u-1-3 pure-gap disabled">
					<a><big>aktueller Datensatz</big></a>
					<a id="xml-current-doc-source-page" href="#"><i class="fa fa-file-code"></i> Dokumentarisches Transkript</a>
					<a id="xml-current-text-source"     href="#"><i class="fa fa-file-code"></i> Textuelles Transkript</a>
					<a id="xml-current-metadata"        href="#"><i class="fa fa-file-code"></i> Metadaten</a>
				</div>
				
				<div id="more-downloads" class="pure-u-1-3 pure-gap"  >
					<a>mehr …</a>
					<a>weitere Downloadmöglichkeiten demnächst.</a>
				</div>
			</div>
		</script>
		
		
		<script>
			requirejs(['faust_common', 'jquery', 'jquery.chocolat', 'jquery.overlays', 'jquery.clipboard', 'js.cookie', 'faust_print_interaction'<xsl:value-of 
				select="string-join(('', for $spec in $jsRequirements return f:enquote(substring-before($spec, ':'))), ', ')"/>], 
				 function (Faust, $, $chocolat, $overlays, $clipboard, Cookies, addPrintInteraction<xsl:value-of 
				 	select="string-join(('', for $spec in $jsRequirements return substring-after($spec, ':')), ', ')"/>) {
            $('main').Chocolat({
              className: 'faustedition',
              loop: true
            });
            $('header nav').menuOverlays({
              highlightClass: 'pure-menu-selected',
              onAfterShow: function() {
                $('[data-target]').copyToClipboard();
              }
            });
						$(function(){addPrintInteraction('/', undefined, '<xsl:value-of select="if ($documentURI) then $documentURI else 'undefined'"/>');})
					  Faust.addToTopButton();
					  					  
            var _paq = window._paq = window._paq || [];
            var consent = Cookies.get('faust-cookie-consent');
            if (consent == 'yes') {
              _paq.push(['rememberConsentGiven'])
            } else if (navigator.cookieEnabled &amp;&amp; (consent != 'yes' &amp;&amp; consent != 'no')) {
              $('#cookie-consent-button').bind('click', function() {
                _paq.push(['rememberConsentGiven'])
                var domain = window.location.hostname;
                if (/faustedition\.net$/.test(domain))
                  domain = '.faustedition.net';
                Cookies.set('faust-cookie-consent', 'yes', {
                  expires: 365,
                  domain: domain
                });
                $('#cookie-consent').hide();
              });
              $('#functional-cookies-button').bind('click', function() {
                var domain = window.location.hostname;
                if (/faustedition\.net$/.test(domain))
                  domain = '.faustedition.net';
                Cookies.set('faust-cookie-consent', 'no', {
                  expires: 365,
                  domain: domain
                });
                $('#cookie-consent').hide();
              })
              $('#cookie-consent').show();
            }

					<xsl:if test="$breadcrumb-def">
						<xsl:call-template name="f:breadcrumb-script">
							<xsl:with-param name="breadcrumb-def" select="$breadcrumb-def"/>
						</xsl:call-template>
					</xsl:if>
					<xsl:value-of select="$scriptAdditions"/>
				});
		</script>
		<!-- Matomo -->
		<script type="text/javascript">
		  var _paq = window._paq = window._paq || [];
		  /* tracker methods like "setCustomDimension" should be called before "trackPageView" */
		  _paq.push(['trackPageView']);
		  _paq.push(['enableLinkTracking']);
		  (function() {
		    var u="//analytics.faustedition.net/";
		    _paq.push(['setTrackerUrl', u+'matomo.php']);
		    _paq.push(['setSiteId', '2']);
		    var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
		    g.type='text/javascript'; g.async=true; g.src=u+'matomo.js'; s.parentNode.insertBefore(g,s);
		  })();
		</script>
		<noscript><p><img src="//analytics.faustedition.net/matomo.php?idsite=2&amp;rec=1" style="border:0;" alt="" /></p></noscript>
		<!-- End Matomo Code -->
	</xsl:template>


	<xsl:template name="html-frame">
		<xsl:param name="content"/>
		<xsl:param name="page-id" as="item()*"/>
		<xsl:param name="grid-content"/>
		<xsl:param name="section-classes" as="item()*"/>
		<xsl:param name="headerAdditions" select="$headerAdditions"/>
		<xsl:param name="scriptAdditions" select="$scriptAdditions"/>
		<xsl:param name="jsRequirements" as="xs:string*"/>
		<xsl:param name="breadcrumb-def" select="false()" tunnel="yes"/>
		<html>
			<xsl:call-template name="html-head">
				<xsl:with-param name="headerAdditions" select="$headerAdditions"/>				
			</xsl:call-template>
			<body>
				<xsl:if test="$page-id">
					<xsl:attribute name="class" select="$page-id" separator=" "/>
				</xsl:if>
				<xsl:call-template name="header"/>
				<main>
					<section>
						<xsl:attribute name="class" select="($section-classes, if ($grid-content) then 'pure-g-r' else ())" separator=" "/>
						<xsl:choose>
							<xsl:when test="$grid-content">								
								<xsl:sequence select="$grid-content"/>	
							</xsl:when>
							<xsl:when test="$content">
								<article>
									<xsl:sequence select="$content"/>
								</article>
							</xsl:when>
							<xsl:otherwise>
								<article>
									<xsl:apply-templates/>
								</article>
							</xsl:otherwise>
						</xsl:choose>
					</section>
				</main>
				<xsl:call-template name="footer">
					<xsl:with-param name="jsRequirements" select="$jsRequirements"/>					
					<xsl:with-param name="breadcrumb-def" select="$breadcrumb-def" tunnel="yes"/>
					<xsl:with-param name="scriptAdditions" select="$scriptAdditions"/>
				</xsl:call-template>
			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>
