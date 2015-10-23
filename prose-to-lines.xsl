<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	exclude-result-prefixes="xs"
	xmlns="http://www.tei-c.org/ns/1.0"
	xpath-default-namespace="http://www.tei-c.org/ns/1.0"
	version="2.0">

	<!-- 

		Transformiert die teils vorhandene Prosastruktur in <lg>/<l>. Das ist vermutlich
		philologisch nicht korrekt, erleichtert aber das nachfolgende prozessieren		

	-->

	<xsl:template match="p[milestone[@unit='refline']]"> <!-- Wir matchen auf alle <p>s, in denen ein <milestone unit="refline"/> ist -->
		<lg rend="{concat('ann-p ', @rend)}"> <!-- Zunächst statt <p> ein <lg> erzeugen. Das rend-Attribut bekommt zusätzlich den wert 'ann-p'. Hätte man auch als  <lg rend="ann-p {@rend}"> schreiben könnnen -->
			<xsl:apply-templates select="@* except @rend"/> <!-- andere Attribute kopieren -->

			<!-- 

				Nun das eigentliche Zerlegen anhand der Milestones.

				xsl:for-each-group nimmt die durch select angegebene Knotensequenz (alle Kindknoten) und zerlegt 
				sie in Teilgruppen. Das Gruppierungskriterium ist hier, dass der erste Knoten einer Gruppe ein
				milestone[@unit="refline"] ist, d.h. eine Gruppe recht vom <milestone> bis vor das nächste 
				<milestone> (oder bis zum Ende der Sequenz).

				Auf jede Gruppe wird dann der Inhalt des for-each-group angewandt

			-->
			<xsl:for-each-group select="node()" group-starting-with="milestone[@unit='refline']">

				<!-- 
					current-group() ist die aktuelle Gruppe, das erste Element dann natürlich der Milestone.
					Die {} im Attribut bilden ein Attributwert-Template: http://www.w3.org/TR/xslt20/#attribute-value-templates
					Ihr Inhalt ist ein XPath-Ausdruck, der ausgewertet wird; das Ergebnis ersetzt dann das Template.

					Das @n unserer l kommt also aus dem <milestone unit="refline">.
				-->
				<l n="{current-group()[1]/@n}">
					<!-- Innerhalb dieser <l> soll alles kopiert mit zwei ausnahmen, also ein besonderer Modus für das Processing … -->
					<xsl:apply-templates select="current-group()" mode="in-artificial-lg"/>
				</l>
			</xsl:for-each-group>
		</lg>
	</xsl:template>	
	<!-- ... in den künstlichen <l> wollen wir sonderbehandlung für milestone und lb -->
	<xsl:template mode="in-artificial-lg" match="milestone[@unit='refline']"/>
	<xsl:template mode="in-artificial-lg" match="lb"><xsl:text> </xsl:text></xsl:template>
	<xsl:template mode="in-artificial-lg" match="lb[@break='no']"/>

	<!-- Identitätstransformation, für alle Modi, auch für in-artificial-lg. -->
	<xsl:template match="node()|@*" mode="#all">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
