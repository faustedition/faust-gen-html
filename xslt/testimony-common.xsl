<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:f="http://www.faustedition.net/ns"
    xmlns:t="http://www.faustedition.net/ns/testimony"
    exclude-result-prefixes="xs f t"
    version="2.0">
    
    <!-- 
    
        This stylesheet contains common code used throughout various parts
        of the testimony handling.
    
    -->
    
    <xsl:param name="builddir-resolved" select="resolve-uri('../../../../target/')"/>
    <xsl:param name="transcript-list" select="resolve-uri('faust-transcripts.xml', resolve-uri($builddir-resolved))"/>
    
    
    
    <!-- 
		
		The following variable contains the basic configuration for the testimony metadata header. For some fields,
		more specific rules are required, these are implemented as explicit template rules further below.
		
		The <fieldspec> elements are taken from the start of testimony-table.xml and edited. Semantics:
		
		- @name: the normalized field name as found in testimony-table.xml
		- @spreadsheet: the original column name in the Excel table (for reference)
		- @ignore="yes": Don't generate a metadata entry for this field 
		- text content: The label, if present; otherwise @spreadsheet is used
		
	-->	
    <xsl:variable name="fields" xmlns="http://www.faustedition.net/ns/testimony">
        <!--These fields have been found in the excel table:-->
        <fieldspec name="status" spreadsheet="Status" ignore="yes"/><!-- raus -->
        <fieldspec name="lfd-nr-neu-2" spreadsheet="lfd. Nr. (neu-2)">Zeugnis-Nr.</fieldspec>        
        <fieldspec name="lfd-nr-neuneu" spreadsheet="lfd. Nr. (neuneu)" ignore="yes"/>
        <fieldspec name="lfd-nr-allerneuestens" spreadsheet="lfd. Nr. (allerneuestens)" ignore="yes"/> <!-- alle anderen weg -->
        <fieldspec name="lfd-nr-neuestens" spreadsheet="lfd. Nr. (neuestens)" ignore="yes"/>
        <fieldspec name="lfd-nr-ganz-neu" spreadsheet="lfd. Nr. (ganz neu)" ignore="yes"/>
        <fieldspec name="lfd-nr-neu" spreadsheet="lfd. Nr. (neu)" ignore="yes"/>
        <fieldspec name="lfd-nr-alt" spreadsheet="lfd. Nr. (alt)" ignore="yes"/>
        <fieldspec name="graef-nr" spreadsheet="Gräf-Nr."/>
        <fieldspec name="graef-verweisnr" spreadsheet="Gräf-Verweisnr."/>
        <fieldspec name="wa-brief-nr" spreadsheet="WA-Brief-Nr."/>
        <fieldspec name="pniower-nr" spreadsheet="Pniower-Nr."/>
        <fieldspec name="tille-nr" spreadsheet="Tille-Nr."/>
        <fieldspec name="biedermann-nr-alt" spreadsheet="Biedermann- Nr. alt">Biedermann¹</fieldspec>
        <fieldspec name="biedermann-2" spreadsheet="Biedermann-2">Biedermann²</fieldspec>
        <fieldspec name="biedermann-herwignr" spreadsheet=" Biedermann-HerwigNr.">Biedermann³</fieldspec>
        <fieldspec name="quz" spreadsheet="QuZ"/>
        <fieldspec name="h-sigle" spreadsheet="H-Sigle">Handschrift</fieldspec><!-- Links auch im Header -->
        <fieldspec name="verfasser" spreadsheet="Verfasser"/>
        <fieldspec name="verfasser-gsa-personennummer" spreadsheet="Verfasser_GSA-Personennummer" ignore="yes"/> <!-- erstmal raus, später links nach GSA setzen → Issue -->
        <fieldspec name="dokumenttyp" spreadsheet="Dokumenttyp"/><!-- siehe Issue Beschreibungsspalte -->
        <fieldspec name="div-type" spreadsheet="&lt;div type=&quot;…&quot;&gt;" ignore="yes"/> <!-- raus -->
        <fieldspec name="titel" spreadsheet="Titel"/>
        <fieldspec name="adressat" spreadsheet="Adressat"/>
        <fieldspec name="adressat-gsa-personennummer" spreadsheet="Adressat_GSA-Personennummer" ignore="yes"/> <!-- s.o. -->
        <fieldspec name="gespraechspartner-wenn-nicht-identisch-mit-verfasser" spreadsheet="Gesprächspartner (wenn nicht identisch mit Verfasser)">Gesprächspartner</fieldspec>
        <fieldspec name="gespraechspartner-gsa-personennummer" spreadsheet="Gesprächspartner_GSA-Personennummer" ignore="yes"/> <!-- s.o. -->
        <fieldspec name="datum-ereignis-genau" spreadsheet="Datum Ereignis (genau)" ignore="yes"/> <!-- raus -->
        <fieldspec name="datum-von" spreadsheet="Datum.(von)">Datum (von)</fieldspec> <!-- »Datum: « wenn datum-von und datum-bis dann »zwischen a und b«  sonst: »Datum: xxx« -->
        <fieldspec name="datum-bis" spreadsheet="Datum (bis)" ignore="yes"/> <!-- raus -->
        <fieldspec name="intervall-erschlossen" spreadsheet="Intervall erschlossen" ignore="yes"/> <!-- wenn x dann an datum oben " (erschlossen)" anhängen, feld raus -->
        <fieldspec name="datierungsvermerk" spreadsheet="Datierungsvermerk" ignore="yes"/> <!-- raus -->
        <fieldspec name="datum-zeugnis" spreadsheet="Datum (Zeugnis)" ignore="yes"/> <!-- raus -->
        <fieldspec name="vermerk" spreadsheet="Vermerk" ignore="yes"/> <!-- raus -->
        <fieldspec name="bemerkung" spreadsheet="Bemerkung" ignore="yes"/> <!-- raus -->
        <fieldspec name="zuordnung-zu-wanderjahren-trunz-aber-vgl-quz-ii-s-477f-anm-2" spreadsheet="Zuordnung zu “Wanderjahren” (Trunz; aber vgl. QuZ II, S. 477f., Anm. 2)" ignore="yes"/> <!-- raus -->
        <fieldspec name="wa-druckort" spreadsheet="WA-Druckort" ignore="yes"/> <!-- raus -->
        <fieldspec name="druckort" spreadsheet="Druckort"/> <!-- Druckort; alternativer Druckort -->
        <fieldspec name="alternativer-druckort" spreadsheet="Alternativer Druckort" ignore="yes"/> <!-- raus (s.o.) -->
        <fieldspec name="fremdzeugnis-nr" spreadsheet="Fremdzeugnis-Nr." ignore="yes"/> <!-- raus -->
        <fieldspec name="texttranscript" spreadsheet="textTranscript" ignore="yes"/> <!-- raus -->
        <fieldspec name="fehler-in-zeno" spreadsheet="Fehler in Zeno" ignore="yes"/> <!-- raus -->
        <fieldspec name="digitalisat-dateiname" spreadsheet="Digitalisat-Dateiname" ignore="yes"/> <!-- raus -->
        <fieldspec name="vorlage" spreadsheet="Vorlage" ignore="yes"/> <!-- raus -->
        <fieldspec name="vorlage-seite-von" spreadsheet="Vorlage-Seite von" ignore="yes"/> <!-- raus -->
        <fieldspec name="vorlage-absatz-von" spreadsheet="Vorlage-Absatz von" ignore="yes"/> <!-- raus -->
        <fieldspec name="vorlage-seite-bis" spreadsheet="Vorlage-Seite bis" ignore="yes"/> <!-- raus -->
        <fieldspec name="vorlage-absatz-bis" spreadsheet="Vorlage-Absatz bis" ignore="yes"/> <!-- raus -->
        <fieldspec name="unnamed-46" spreadsheet="Unnamed: 46" ignore="yes"/> <!-- raus -->
    </xsl:variable>
    
    <xsl:function name="f:fieldspec" as="element()?">
        <xsl:param name="name"/>
        <xsl:sequence select="$fields//t:fieldspec[@name=$name]"/>
    </xsl:function>    
    
    <!-- ### Rendering of the field 'dokumenttyp' -> 'beschreibung'.  -->
    
    
    <!-- Expands the fields according to the rules above. -->
    <xsl:function name="f:expand-fields">
        <xsl:param name="template" as="xs:string"/>
        <xsl:param name="context" as="node()*"/>
        <xsl:analyze-string select="$template" regex="\$[a-z0-9_-]+">
            <xsl:matching-substring>
                <xsl:variable name="field" select="substring(., 2)"/>
                <xsl:variable name="substitution" select="$context//*[@name = $field]"/>
                <xsl:choose>
                    <xsl:when test="$substitution">
                        <span title="{$field}"><xsl:value-of select="$substitution"/></span>
                    </xsl:when>
                    <xsl:otherwise>
                        <span class="message warning">$<xsl:value-of select="$field"/></span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring><xsl:value-of select="."/></xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    
    <!-- Renders the dokumenttyp field. Context: <field name='dokumenttyp'/> -->
    <xsl:template name="render-dokumenttyp">
        <!-- This is the spec: 
        
         If the field has the value from the name attribute, use the corresponding template.
         Replace $verfasser with the value of t:field[@name='verfasser'] from the table and so on.
        -->
        <xsl:variable name="beschreibung" xmlns="http://www.faustedition.net/ns">
            <template name="Brief">Brief von $verfasser an $adressat</template>
            <template name="Tagebuch">Tagebucheintrag von $verfasser</template>
            <template name="Gespräch">Gesprächsbericht von $verfasser</template>
            <template name="Text">$titel</template>
        </xsl:variable>
        
        <xsl:variable name="type" select="normalize-space(.)"/>
        <xsl:variable name="template" select="$beschreibung//f:template[@name = $type]"/>
        <xsl:choose>
            <xsl:when test="$template">
                <xsl:sequence select="f:expand-fields($template, ..)"/>
            </xsl:when>
            <xsl:otherwise>
                <span class="message warning">
                    <xsl:value-of select="."/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- ### Sigil links
    
        Takes a list of sigils like '2 H; 1 H.2' and generates HTML links to the corresponding witnesses.     
    -->
    <xsl:function name="f:sigil-links" as="node()*">
        <xsl:param name="sigils"/>
        <xsl:for-each select="tokenize($sigils, ';\s*')">
            <xsl:variable name="sigil" select="."/>
            <xsl:variable name="document" select="doc($transcript-list)//*[@f:sigil=$sigil]"/>
            <xsl:variable name="sigil_t" select="$document/@sigil_t"/>
            
            <xsl:choose>
                <xsl:when test="not(doc-available($transcript-list))"><xsl:message select="concat('ERROR: Transcript list not found: ', $transcript-list)"/></xsl:when>
                <xsl:when test="not($document/*)"><xsl:message select="concat('ERROR: Sigil ', $sigil, ' not found in ', $transcript-list)"></xsl:message></xsl:when>
                <xsl:when test="not($sigil_t) or normalize-space($sigil_t) = ''"><xsl:message select="concat('ERROR: no URI found for ', $sigil, ', transcript ', $document)"/></xsl:when>
            </xsl:choose>
            
            <xsl:choose>
                <xsl:when test="not($document)">
                    <a class="message error">H-Sigle nicht gefunden: <a title="zur Handschriftenliste" href="/archive_manuscripts">»<xsl:value-of select="$sigil"/>«</a></a>
                </xsl:when>
                <xsl:otherwise>
                    <a href="{if ($document/@type='print')
                        then concat('/print/', $sigil_t)
                        else concat('/document?sigil=', $sigil_t)}"
                        title="{$document/f:headNote}">
                        <xsl:value-of select="$sigil"/>
                    </a>											
                </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="not(position() = last())">; </xsl:if>
        </xsl:for-each>
    </xsl:function>
    
    
    <!-- Returns a sequence of milestone and anchor elements that are linked from the given start milestone. --> 
    <xsl:function name="f:milestone-chain" as="element()*">
        <xsl:param name="start" as="element()*"/>      
        <xsl:for-each select="$start">
            <xsl:variable name="spanTo-target" select="id(substring-after(@spanTo, '#'))"/>
            <xsl:variable name="next-target" select="id(substring-after(@next, '#'))"/>
            <xsl:sequence select=".,
                if (@spanTo and not($spanTo-target is .)) 
                then f:milestone-chain($spanTo-target)
                else (),
                if (@next and not ($next-target is .))
                then f:milestone-chain($next-target)
                else ()
                "/>
        </xsl:for-each>
    </xsl:function>
    
    <!-- Removes leading zeroes from a testimony id -->
    <xsl:function name="f:real_id" as="xs:string">
        <xsl:param name="id"/>
        <xsl:value-of select="replace($id, '^(\w+)_0*(.*)$', '$1_$2')"/>
    </xsl:function>
    
    <!-- Returns the root milestone element for a given milestone -->
    <xsl:function name="f:root-milestone" as="element()?">
        <xsl:param name="el"/>
        <xsl:for-each select="$el">
            <xsl:variable name="previous" select="preceding::milestone[@next = concat('#', $el/@xml:id)]"/>
            <xsl:variable name="pointshere" select="preceding::milestone[@spanTo = concat('#', $el/@xml:id)]"/>
            <xsl:choose>
                <xsl:when test="$previous"><xsl:sequence select="f:root-milestone($previous)"/></xsl:when>
                <xsl:when test="$pointshere"><xsl:sequence select="f:root-milestone($pointshere)"/></xsl:when>
                <xsl:when test="self::milestone"><xsl:sequence select="."/></xsl:when>
                <xsl:otherwise><xsl:message select="concat('Warning: Nothing points to ', @xml:id)"/></xsl:otherwise>
            </xsl:choose>			
        </xsl:for-each>
    </xsl:function>
    
    <!-- ### Labels for the various testimony IDs -->
    <xsl:variable name="taxonomies">
        <f:taxonomies>
            <f:taxonomy xml:id='graef'>Gräf Nr.</f:taxonomy>
            <f:taxonomy xml:id='pniower'>Pniower Nr.</f:taxonomy>
            <f:taxonomy xml:id='quz'>QuZ Nr.</f:taxonomy>
            <f:taxonomy xml:id='bie3'>Biedermann-Herwig Nr.</f:taxonomy>			
            <f:taxonomy xml:id='tille'>Tille Nr.</f:taxonomy>
        </f:taxonomies>
    </xsl:variable>
    
    <xsl:function name="f:testimony-label">
        <xsl:param name="testimony-id"/>
        <xsl:variable name="id_parts" select="tokenize($testimony-id[1], '_')"/>
        <xsl:variable name="taxonomy" select="
            if (starts-with($id_parts[1], 'lfd-nr'))
            then 'Zeugnis Nr.' 
            else id($id_parts[1], $taxonomies)/text()"/>
        <xsl:value-of select="concat($taxonomy, ' ', $id_parts[2])"/>
    </xsl:function>
    
	
</xsl:stylesheet>
