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
	<xsl:variable name="spec" select="doc('../text/app12norm_special-cases.xml'),
		doc('../text/app1norm.xml'),
		doc('../text/app2norm.xml')"/>
	
	
	<xsl:variable name="text" select="/"/>
	
	<xsl:template match="/">
		<html>
			<head>
				<title>Lesetext-Validierung</title>
				<style>
					
					nav { display: flex; margin: 0 1em }
					nav a { flex: content; margin: 0 1ex; padding: 0 6px; box-shadow: 1px 1px 2px silver;}
					
					tr { background: #f8f8f8; }
					
					.passed:before { content: "✔ "; color: green; } 
					.passed strong { color: green; }
					.failed:before { content: "✘ "; color: red;  }
					.failed strong { color: red; }
					.warn:before   { content: "⚠ "; color: yellow; font-weight: bold; text-shadow: 0px 0px 1px black; }
					.warn strong { text-shadow: 1px 1px 2px yellow; }
					
					.app { font-family: "Ubuntu derivative Faust", sans-serif; font-size: smaller;}
					
					.help { color: #444; font-style: italic; }
					
					.code { border: 1px inset silver; background: #f8f8f8; padding: 3px; }
					.code pre { margin: 0 }
					.ERROR { background: #fdd; }
					.WARNING { background: #ff8; }
					.INFO { background: #efe; }
				</style>
			</head>
			<body>			
				<p>Berichtsdatum: <xsl:value-of select="current-dateTime()"/></p>
				<nav>
					<a href="#apps-without-ins">app ohne ins</a>
					<a href="#usage">Verwendung</a>
					<a href="#dangling">Anwendung im Text</a>
					<a href="#wits">kaputte wits</a>
					<a href="#notes">Kommentare im Apparat</a>
					<a href="#app2xml">app2xml</a>
					<a href="#free-floating-apps">herumfliegende Apparate</a>
				</nav>
				<p class="help">
					<a href="https://github.com/faustedition/faust-gen-html/blob/master/text/README-app_norm.md">die wichtigsten Regeln für die app*norm.txt-Dateien</a> 
				</p>
				<xsl:message>Validating apparatus insertion ...</xsl:message>
				<xsl:variable name="results">					
					<xsl:call-template name="apps-without-ins"/>			
					<xsl:call-template name="all-apps-used"/>	
					<xsl:call-template name="broken-app-links"/>
					<xsl:call-template name="find-broken-wits"/>
					<xsl:call-template name="summarize-notes"/>
					<xsl:call-template name="free-floating-apps"/>
					<xsl:call-template name="app2xml"/>
				</xsl:variable>
				<xsl:sequence select="$results"/>
				<xsl:for-each select="$results//*[self::p|self::tr][contains(@class, 'failed')]">
					<xsl:message select="string-join(('ERROR', .), ' ')"/>				
				</xsl:for-each>				
			</body>
		</html>
		
	</xsl:template>
	
	
	<xsl:template name="apps-without-ins">
		<a name="apps-without-ins"/>
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
				<xsl:variable name="id" select="f:app-id(.)"/>
				<xsl:variable name="apps-in-text" select="$text//*[@xml:id=$id]"/>
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
					<li>Dass ein Eintrag eingefügt wurde, <a href="#dangling">heißt noch nicht, dass alles gut ging</a>.</li>
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
			<a href="http://dev.faustedition.net/print/app#l{f:app-id(.)}"><strong class="n"><xsl:value-of select="@n"/></strong>
			<xsl:text> </xsl:text>
			<span class="lem"><xsl:value-of select="lem"/>]</span></a><xsl:text> </xsl:text>
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
				<h3 id="wits" class="failed"><strong><xsl:value-of select="count($analyzed-wits[@class='failed'])"/></strong> invalid witness references 
				(<xsl:value-of select="count($analyzed-wits[@class='passed'])"/> witnesses are identified correctly)</h3>
				<xsl:copy-of select="$analyzed-wits[@class='failed']"/>
			</xsl:when>
			<xsl:otherwise>
				<p id="wits" class="passed"><xsl:value-of select="count($analyzed-wits[@class='passed'])"/> korrekte Siglen gefunden.</p>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="summarize-notes">
		<h3 id="notes">Apparat-Notes, nach Länge sortiert</h3>
		<div class="help">
			<p>Diese Liste enthält alle unterschiedlichen Kommentare aus dem Apparat, die nicht als Schreiberhand, Sigle etc.
			erkannt wurden. Nur einige diese Einträge weisen auf Fehler hin.</p>
			<ul>
				<li>Steht hier eine <strong>Sigle</strong>, so ist sie nicht in der korrekten Form (d.h. konnte keiner
					URI zugeordnet werden) und muss angepasst werden.</li>
				<li>Steht hier eine Schreiberhand oder Abkürzung, so muss sie in die entsprechende Liste aufgenommen werden (z.Z. in app2xml.py)</li>
				<li>Typen, spitze Klammern etc. weisen auf Formatierungsfehler im zugehörigen Eintrag.</li>				
			</ul>			
		</div>
		<table>
			<tr>
				<th>Kommentar</th>
				<th>Anzahl</th>
				<th>Stellen</th>
			</tr>
		
			<xsl:for-each-group select="$spec//note/node()[not(self::seg[@type]|self::wit)]" group-by="normalize-space(.)">
				<xsl:sort select="string-length(.)"/>
				<xsl:if test="current-grouping-key() != ''">
					<tr>
						<td><xsl:value-of select="."/></td> 
						<td><xsl:value-of select="count(current-group())"/></td>
						<td><xsl:apply-templates select="for $note in current-group() return $note/ancestor::app"/></td>					
					</tr>
				</xsl:if>
			</xsl:for-each-group>	
		</table>
		
	</xsl:template>
	
	<xsl:template name="app2xml">
		<h3 id="app2xml">XML-Konvertierung</h3>
		<xsl:variable name="parsed-log">
			<xsl:variable name="logtext" select="unparsed-text('../text/app2xml.log', 'utf-8')"/>
			<xsl:analyze-string select="$logtext" regex=".+\n">
				<xsl:matching-substring>
					<xsl:choose>
						<xsl:when test="matches(., '^(ERROR|WARNING|INFO):')">
							<pre class="{substring-before(., ':')}"><xsl:value-of select="."/></pre>
						</xsl:when>
						<xsl:otherwise>
							<pre><xsl:value-of select="."/></pre>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:matching-substring>
				<xsl:non-matching-substring>
					<p class="failed">Fehler beim Parsen des Texts</p>
					<pre>
						<xsl:copy-of select="$logtext"/>
					</pre>
				</xsl:non-matching-substring>
			</xsl:analyze-string>			
		</xsl:variable>
				
		<div class="help">
			Dies ist das Logfile der Konvertierung des Apparats aus dem Text- ins XML-Format. Fehler (<span class="ERROR">ERROR</span>) hier weisen
			auf Einträge hin, die gar nicht erst im XML landen und damit in den anderen Validierungsberichten <em>nicht</em>
			enthalten sind. <span class="WARNING">WARNINGS</span> kennzeichnen Einträge, die nicht vollständig korrekt verarbeitet werden konnten und
			damit kaputt im XML landen. <span class="INFO">INFO</span> kennzeichnet erfolgreich geparste Einträge,
			sonstige Zeilen sind Details.			
		</div>
		<p>
			<strong class="failed"><xsl:value-of select="count($parsed-log//*[@class='ERROR'])"/></strong> Fehler,
			<strong class="warn"><xsl:value-of select="count($parsed-log//*[@class='WARNING'])"/></strong> Warnungen,
			<strong class="passed"><xsl:value-of select="count($parsed-log//*[@class='INFO'])"/></strong> erfolgreich geparste Einträge:
		</p>
		
		<div class="code">
			<xsl:sequence select="$parsed-log"/>
		</div>
	</xsl:template>
	
	<xsl:template name="broken-app-links">
		<xsl:variable name="details">
			<xsl:for-each select="$text//note[@type='textcrit']//app[@from]">
				<xsl:variable name="app" select="."/>
				<xsl:for-each select="tokenize(@from, '\s+')">
				
				<xsl:variable name="id" select="substring(., 2)"/>
				<xsl:variable name="referenced" as="element()*" select="$text//*[@xml:id=$id]"/>
				<xsl:variable name="count" select="count($referenced)"/>
				<xsl:variable name="n" select="tokenize($id, '\.')[2]"/>
				<xsl:variable name="ins" select="$spec//f:ins[@n=$n]"/>
				<xsl:variable name="repl" select="$spec//f:replace[@n=$n]"/>
				<xsl:variable name="line">
					<xsl:apply-templates mode="noapp" select="$app/ancestor::*[@n][self::l or self::stage][1]"/>
				</xsl:variable>				
				<xsl:variable name="case">
					<xsl:choose>
						<xsl:when test="$count=1">passed</xsl:when>
						<xsl:when test="$count>1">duplicate</xsl:when>
						<xsl:when test="$ins[@place]">place</xsl:when>
						<xsl:otherwise>dangling</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				<tr data-case="{$case}">					
					<td><xsl:value-of select="$n"/></td>					
					<xsl:choose>
						<xsl:when test="$case = 'dangling'">
							<td><xsl:value-of select="$repl"/></td>
							<td><xsl:value-of select="$ins"/></td>
							<td><xsl:value-of select="$line"/></td>
						</xsl:when>
						<xsl:when test="$case = 'duplicate'">
							<td><xsl:value-of select="$count"/></td>
							<td><xsl:value-of select="$repl"/></td>
							<td><xsl:value-of select="$line"/></td>							
						</xsl:when>
					</xsl:choose>
				</tr>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:variable>
		
		<h3 id="dangling">Apparat ohne Verankerung im Text</h3>
		<p class="passed"><strong><xsl:value-of select="count($details/*[@data-case='passed'])"/></strong> Apparateinträge haben genau eine Stelle im Text</p>
		<p class="warn"><strong><xsl:value-of select="count($details/*[@data-case='place'])"/></strong> Einträge beziehen sich auf eingefügte Inhalte oder ganze Elemente</p>
		<h4 class="failed">Bei <strong><xsl:value-of select="count($details/*[@data-case='dangling'])"/></strong> Einträgen hat das Einfügen nicht geklappt:</h4>		
		<div class="help">
			<p>Die folgende Tabelle listet alle Apparateinträge auf, die es zwar in den Lesetext geschafft haben, aber für
			die kein passendes &lt;seg&gt; eingetragen werden konnte. Ausgenommen sind Fälle, die nicht an einer Textstelle,
			sondern lediglich an einem Vers oder an generiertem Inhalt aufgehängt sind (place-Fälle). Im Text hat das diese Auswirkungen:</p>
			<ul>
				<li>es gibt keinen (unterstrichenen/gehighlighteten) Eintrag im Text</li>
				<li>der Eintrag der replace-Spalte wurde nicht durch die insert-Spalte ersetzt.</li>
			</ul>
			<p>Leere replace-Werte weisen auf einen falschen Apparateintrag hin oder auf einen Fall, in dem ein Apparat sich nur
				auf eine Zeile / Element bezieht, aber keine explizite Stelle darin. Vorhandene replace-Werte müssen wörtlich so im Text
			vorkommen, damit das funktioniert, XML oder <code>^</code> sind in replace verboten. Leere Verse weisen auf falsches @n hin.</p>
		</div>
		<table>
			<th>@n</th>
			<th>[replace]</th>
			<th>{insert}</th>
			<th>Vers</th>
			<xsl:sequence select="$details/*[@data-case='dangling']"/>
		</table>
		
		<xsl:variable name="duplicateSegCount" select="count($details/*[@data-case='duplicate'])"/>
		<h4 class="{if ($duplicateSegCount = 0) then 'passed' else 'failed'}">Bei <strong><xsl:value-of select="$duplicateSegCount"/></strong> Einträgen sind mehr als ein seg im Text markiert:</h4>
		<p class="help">Weist darauf hin, das das Lemma (bzw. der replace-Wert) nicht eindeutig gewählt wurde → besseres replace / lemma wählen.</p>
		<table>
			<th>@n</th>
			<th>Anzahl</th>
			<th>[replace]</th>
			<th>Vers</th>
			<xsl:sequence select="$details/*[@data-case='duplicate']"/>
		</table>		
	</xsl:template>
	
	<xsl:template match="note[@type='textcrit']" mode="noapp"/>
	
	
	<xsl:template name="free-floating-apps">
		<xsl:variable name="floating-app-reports">
			<xsl:for-each select="$text//note[@type='textcrit'][not(ancestor::*[f:hasvars(.)])]">
				<xsl:variable name="note" select="."/>
				<xsl:variable name="app" select="descendant::app"/>
				<xsl:for-each select="tokenize($app/@from, '\s+')">				
					<xsl:variable name="id" select="substring(., 2)"/>
					<xsl:variable name="referenced" as="element()*" select="$text//*[@xml:id=$id]"/>				
					<xsl:variable name="n" select="tokenize($id, '\.')[2]"/>
					<xsl:variable name="ins" select="$spec//f:ins[@n=$n]"/>				
					<tr>
						<td><xsl:value-of select="$note/ref"/></td>
						<td><xsl:value-of select="$n"/></td>
						<td><xsl:value-of select="$ins/@place"/></td>
						<td>
							<xsl:value-of select="name($ins/*[1])"/>
							<xsl:if test="$ins/*[@n]">
								n=<xsl:value-of select="$ins/*[1]/@n"/>
							</xsl:if>
						</td>
						<td><xsl:value-of select="$note/preceding-sibling::*[1]/@n"/></td>
						<td><xsl:value-of select="$note/following-sibling::*[1]/@n"/></td>
					</tr>
				</xsl:for-each>
			</xsl:for-each>
		</xsl:variable>
		
		<h3 id="free-floating-apps" class="{if ($floating-app-reports/*) then 'failed' else 'passed'})">
			<strong><xsl:value-of select="count($floating-app-reports/*)"/></strong> Apparateinträge außerhalb von <i>Zeilen</i></h3>
		<p class="help">Diese Elemente sind im TEI nicht innerhalb eines Verses/BA/Sprechers gelandet, sondern irgendwo dazwischen. Sie sind damit z.B. nicht gescheit klickbar. (Problem der Transformation, nicht des Apparats)</p>
		
		<table>
			<thead>
				<tr>
					<th>Referenz</th>
					<th>@n</th>
					<th>f:ins/@place</th>
					<th>erstes eingefügtes Element</th>
					<th>@n davor</th>
					<th>@n danach</th>
				</tr>
			</thead>
			<tbody>
				<xsl:copy-of select="$floating-app-reports"/>
			</tbody>
		</table>
	</xsl:template>
	
</xsl:stylesheet>