<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"	
	xmlns:tei="http://www.tei-c.org/ns/1.0"
	xmlns="http://www.w3.org/1999/xhtml"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	xmlns:f="http://www.faustedition.net/ns"
	exclude-result-prefixes="xs f" 	
	version="2.0">
	
	<!-- Runs a bunch of validations on the final reading text -->
	
	<xsl:import href="text-insert-app.xsl"/>
	
	<xsl:output method="xhtml" indent="yes"/>
	
	<!-- The apparatus specification in XML form -->
	<xsl:variable name="spec" select="doc('../text/app1norm.xml'), 
		doc('../text/app2norm.xml'), 
		doc('../text/app2norm_test-cases.xml')"/>
	
	<xsl:variable name="text" select="/"/>
	
	<xsl:template match="/">
		<html>
			<head>
				<title>Lesetext-Validierung</title>
				<style>
					.passed:before { content: "✔ "; color: green; } 
					.passed > strong { color: green; }
					
					.failed:before { content: "✘ "; color: red;  }
					.failed > strong { color: red; }
					
					.warn:before   { content: "⚠ "; color: yellow; font-weight: bold; text-shadow: 0px 0px 1px black; }
					.warn > strong { background: yellow; }
					
					.app { font-family: "Ubuntu", sans-serif; font-size: smaller;}
					
					.help { color: #444; font-style: italic; }
				</style>
			</head>
			<body>
				<p>Berichtsdatum: <xsl:value-of select="current-dateTime()"/></p>				
				<xsl:call-template name="apps-without-ins"/>			
				<xsl:call-template name="all-apps-used"/>				
				<xsl:call-template name="find-broken-wits"/>
				<xsl:call-template name="summarize-notes"/>
			</body>
		</html>
		
	</xsl:template>
	
	
	<xsl:template name="apps-without-ins">
		<a name="no-ins"/>
		<xsl:variable name="apps-without-ins" select="$spec//app[not(f:ins)]" as="element()*"/>
		<xsl:choose>
			<xsl:when test="count($apps-without-ins) = 0">
				<p class="passed">Alle <code>app</code>-Elemente haben mindestens ein <code>f:ins</code>.</p>
			</xsl:when>
			<xsl:otherwise>
				<h3 class="failed"><xsl:value-of select="count($apps-without-ins)"/> <code>app</code>-Einträge
					ohne <code>f:ins</code>:</h3>
				<p class="help">Ohne <code>f:ins</code>-Element, d.h. Einfügeklammern in der Textform, werden die Einträge nicht aufgegriffen.</p>
				<ul>
					<xsl:for-each select="$apps-without-ins">
						<li><xsl:value-of select="@n"/>
							<xsl:value-of select="lem"/>]</li>
					</xsl:for-each>
				</ul>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	
	<xsl:template name="all-apps-used">
		<xsl:variable name="details" as="element()*">
			<xsl:for-each select="$spec//app">
				<xsl:variable name="id" select="f:seg-id(f:ins[1])"/>
				<xsl:variable name="apps-in-text" select="$text//app[@from = concat('#', $id)]"/>
				<xsl:choose>
					<xsl:when test="count($apps-in-text) = 1">
						<p class="passed"/>
					</xsl:when>
					<xsl:when test="count($apps-in-text) = 0">
						<p class="failed"><xsl:apply-templates select="."/>: Kein Apparat im Text (<xsl:value-of select="$id"/>)</p>
					</xsl:when>
					<xsl:otherwise>
						<p class="warn"><xsl:apply-templates select="."/>: <strong><xsl:value-of select="count($apps-in-text)"/></strong> apps in text</p>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</xsl:variable>

		<h1 id="usage">Apparatgebrauch</h1>
		<div class="help">
			<p>
				Das Apparateinfügen erfolgt textgetrieben, d.h. für jede mögliche Stelle im Text wird 
				anhand n-Attribut und Ersetzungstext geprüft, ob dafür ein relevanter Apparateintrag 
				gefunden wird. Dementsprechend können zwei Fehler auftreten: Ein Apparateintrag wird
				übersehen, oder er passt an mehreren Stellen.
				<ol>
					<li>Für <strong>nicht eingefügte Apparateinträge</strong>: n-Wert (ersten Eintrag 
						im Textapparat) prüfen, außerdem prüfen ob der Replace-String (<code>[…]</code>) 
						wirklich wörtlich dem Text oder einem vereinbarten Codezeichen entspricht.</li>
					<li>Mehrfache Einträge werden z.Z. noch nicht aufgeräumt</li>
					<li>
						Apparateinträge, die <a href="#app2xml">gar nicht erst geparst werden konnten</a>, werden hier nicht berücksichtigt
					</li>
				</ol>				
			</p>
		</div>
		
			<xsl:if test="$details[@class='failed']">
				<h3 class="failed">
					<strong><xsl:value-of select="count($details[@class='failed'])"/></strong>
					<xsl:text> Apparateinträge wurden nicht eingefügt: </xsl:text>					
				</h3>
				<xsl:sequence select="$details[@class='failed']"/>				
			</xsl:if>
		
			<xsl:if test="$details[@class='warn']">
				<h3 class="warn">
					<strong><xsl:value-of select="count($details[@class='warn'])"/></strong>
					<xsl:text> Apparateinträge wurden mehrfach eingefügt: </xsl:text>					
				</h3>
				<xsl:sequence select="$details[@class='warn']"/>				
			</xsl:if>
		
			<xsl:if test="$details[@class='passed']">
				<h3 class="passed"><strong><xsl:value-of select="count($details[@class='passed'])"/></strong> Apparateinträge wurden genau einmal eingefügt.</h3>
			</xsl:if>
		
	</xsl:template>
	
	<xsl:template match="app">
		<span class="app">
			<a href="http://dev.faustedition.net/print/faust.all#l{@n}"><strong class="n"><xsl:value-of select="@n"/></strong></a>
			<xsl:text> </xsl:text>
			<span class="lem"><xsl:value-of select="lem"/>] </span>
		</span>
	</xsl:template>
	
	<xsl:template name="find-broken-wits">
		<xsl:variable name="wits" as="element()*">
			<xsl:for-each select="$spec//*[@wit]">
				<xsl:variable name="app" select="ancestor::app"/>
				<xsl:for-each select="tokenize(@wit, '\s+')">
					<tei:wit wit="{.}">
						<xsl:copy-of select="$app"/>
					</tei:wit>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:variable>
				
		
		<xsl:variable name="analyzed-wits" as="element()*">
			
		<xsl:for-each-group select="$wits" group-by="@wit">
			<xsl:variable name="uri" select="concat('faust://document/faustedition/', current-grouping-key())"/>
			<xsl:message select="$uri"></xsl:message>
			<xsl:choose>
				<xsl:when test="$uri = $idmap//f:idno/@uri">
					<p class="passed"/>
				</xsl:when>
				<xsl:otherwise>
					<p class="failed">Sigle <strong><xsl:value-of select="current-grouping-key()"/></strong>
						nicht gefunden, benutzt in <xsl:value-of select="count(current-group())"/> Apparateinträgen:
					<xsl:for-each select="current-group()">
						<xsl:apply-templates select="."/>
						<xsl:if test="position() != last()">, </xsl:if>
					</xsl:for-each>
					</p>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each-group>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="$analyzed-wits[@class='failed']">
				<h3 class="failed"><strong><xsl:value-of select="count($analyzed-wits[@class='failed'])"/></strong> invalid witness references 
				(<xsl:value-of select="count($analyzed-wits[@class='passed'])"/> witnesses are identified correctly)</h3>
				<xsl:copy-of select="$analyzed-wits[@class='failed']"/>
			</xsl:when>
			<xsl:otherwise>
				<p class="passed"><xsl:value-of select="count($analyzed-wits[@class='passed'])"/> korrekte Siglen gefunden.</p>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="summarize-notes">
		<h3>Apparat-Notes, nach Länge sortiert</h3>
		<div class="help">
			<p>Diese Liste enthält alle unterschiedlichen Bemerkungen aus dem Apparat, die nicht als Schreiberhand, Sigle etc.
			erkannt wurden. Nur einige diese Einträge weisen auf Fehler hin.</p>
			<ul>
				<li>Steht hier eine <strong>Sigle</strong>, so ist sie nicht in der korrekten Form (d.h. konnte keiner
					URI zugeordnet werden) und muss angepasst werden.</li>
				<li>Steht hier eine Schreiberhand, so muss sie in die Liste aufgenommen werden (z.Z. in app2xml.py)</li>
				<li>Typen, spitze Klammern etc. weisen auf Formatierungsfehler im zugehörigen Eintrag.</li>				
			</ul>			
		</div>
		<table>
			<tr>
				<th>Bemerkung</th>
				<th>Anzahl</th>
				<th>Stellen</th>
			</tr>
		
			<xsl:for-each-group select="$spec//note/node()[not(self::seg[@type])]" group-by="normalize-space(.)">
				<xsl:sort select="string-length(.)"/>
				<tr>
					<td><xsl:value-of select="."/></td> 
					<td><xsl:value-of select="count(current-group())"/></td>
					<td><xsl:apply-templates select="for $note in current-group() return $note/ancestor::app"/></td>					
				</tr>
			</xsl:for-each-group>	
		</table>
		
	</xsl:template>
	
</xsl:stylesheet>