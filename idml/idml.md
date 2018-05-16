IDML-Synthese
=============================

Hier werden die zur IDML-Synthese notwendigen Festlegungen getroffen. 

# Offene Punke
https://github.com/faustedition/faust-gen-html/labels/c%3Aidml

# Verwendete Kürzel und Bezeichnungen
* BA = Bühnenanweisung (`stage`)
* Sprecher = Sprecherbezeichnung (`speaker`)
* Musterseite / Stammseite in InDesign: Seiten, auf denen Gestaltungen definiert werden, die für alle Seiten gelten sollen, auf die sich die Stammseite bezieht (`Musterseite A` mit Kolumnenzeile und Pagina als Textvariablen definiert, `Musterseite B` ohne Kolumnenzeile). 

# Absatzformate

## Apparat
XML: `note[@type='textcrit']`.

Output: Fußnotenartiges Konstrukt ohne Anmerkungsziffer.

## Apparat zentriert
XML: `rdg/speaker`

(https://github.com/faustedition/faust-gen-html/issues/277#issuecomment-389164702)

## (BA)
Die für die `BA`-Formate relevanten XML-Elemente sind `stage` (gut 700) und außerdem öfters `speaker` (gut 2100 Vorkommen). 
Unter welchen Umständen `speaker` ins Spiel kommt, wird im folgenden erklärt.  

### (BA aus `speaker` und `stage`)
Oft ergibt sich ein `BA ...`-Absatz aus der Kombination von `speaker` und `stage`.
Nämlich dann, wenn Sprecherbezeichnung (`speaker`) und eine Bühnenanweisung zusammen in derselben Zeile stehen:
* bezogen auf die `stage`: `stage[matches(@rend, 'inline')]`
* bezogen auf den `speaker`: `speaker[following-sibling::*[1][self::stage[matches(@rend,'inline')]]]`
Bsp.:
    <speaker n="before_482f_a">Faust</speaker>
    <stage n="before_482f_b" rend="inline small">abgewendet.</stage>
In allen derartigen Fällen (gut 170 Vorkommen) steht eine Bühnenanweisung in derselben Zeile mit der Sprecherbezeichnung.

### (BA aus `speaker`)
XML: `speaker[hi]` (evtl. folgt noch eine `stage` mit `inline`, dann gilt das im vorigen Abschnitt gesagte.

Format: `C BA zentr. 2,3 / 0,0`.

### (Länge)
Je nach Länge werden BAs unterschiedlich behandelt:
* `BA zentr.` (für zentriert)
* `BA Blocks.` (für Blocksatz)

Lange BA (ab drei Zeilen im Outputba mit ) stehen im Blocksatz mit linksbündiger letzter Zeile. Als ungefähre Heuristik wird eine Zahl von Zeichen genommen, ab der mit hoher Wahrscheinlichkeit im Umbruch mehr als drei Zeilen entstehen. 
Momentane Heuristik: 210 Zeichen als Richtwert, der zur Zuweisung von `BA Blocks. ...` führt.
(Könnte sich evtl. verschieben in Abhängigkeit von [#209](https://github.com/faustedition/faust-gen-html/issues/209)!).

Im folgenden ist nur von zentierten BAs (`... BA zentr. ...`) die Rede, weil diese den Normalfall darstellen.
Dass bei entsprechender Länge das Format `... BA Blocks. ...` zugewiesen werden muss, wird nicht immer wiederholt. 

### (Abstände)
Die differenzierte Formatzuweisung dient der Regelung der Abstände. 
Entscheidend für die Zuweisung der richtigen Abstände ist zweierlei:
* In welche Kontext steht die BA?
* Was enthält die BA: nur Text oder auch Figur oder Auftritt?

Die unterschiedlichen Kombinationen von Kontext und Inhalt wird im folgenden aufgeführt. 

### (BA unterschieden nach Kontext und Inhalt)
Momentan sind es gut 700 `stage`-Elemente, die Mehrheit davon (gut 460) innerhalb von Repliken.

#### (BA **in** Replik)
* Kombination von Sprecherbezeichnung und Bühnenanweisung auf derselben Zeile (`speaker/following-sibling::*[1][self::stage and @rend[contains(.,'inline')]]`)
  * → `C BA zentr. 2,3 / 0,0  (0,75 pt. nach oben)`
* dasselbe, dabei Sprecher- zugleich Auftrittsbezeichnung  (`move/following-sibling::*[1][self::sp]/speaker/following-sibling::*[1][self::stage and @rend[contains(.,'inline')]]`)
  * → `C BA zentr. 2,3 / 0,0  (0,75 pt. nach oben)`
* direkt nach Sprecherbezeichnung auf eigener Zeile ohne Figur (`speaker/following-sibling::*[1][self::stage[not(hi)] and not(matches(@rend,'inline'))]`)
  * → `A BA zentr. 0,0 / 0,0`
* direkt nach Sprecherbezeichnung auf eigener Zeile mit Figur (`speaker/following-sibling::*[1][self::stage[hi] and not(matches(@rend,'inline'))]`)
  * → `H BA zentr. 0,0 / 0,0`
* BA auf eigener Zeile, nach Kombination von Sprecherbezeichnung und Bühnenanweisung auf derselben Zeile (`speaker/following-sibling::*[1][self::stage and matches(@rend,'inline')]/following-sibling::*[1][self::stage]`)
  * → `A BA zentr. 0,0 / 0,0`  
* zwischen Versen ohne Figur (`stage[not(hi)][preceding-sibling::*[1][self::l] and following-sibling::*[1][self::l]]`)
  * Bspp.: `before_430` "Er schlägt ...", `before_447` "Er beschaut ..."   
  * → `A BA zentr. 0,0 / 0,0`
* zwischen Versen mit Figur (`stage[hi][preceding-sibling::*[1][self::l] and following-sibling::*[1][self::l]]`) 
  * → `H BA zentr. 0,0 / 0,0`
* zwischen Versgruppen (`stage[preceding-sibling::*[1][self::lg] and following-sibling::*[1][self::lg]]`)
  * → `C BA zentr. 2,3 / 0,0  (0,75 pt. nach oben)`

#### (BA im Anschluss an Replik, ohne Figur)
z.B. 
* `before_514_a` "Verschwindet."
* `before_4666_a` "Ungeheures Getöse ..."
* Auch `before_4412` "er ergreift ... Es singt inwendig", worauf keine Sprecherbezeichnung folgt, wird nach demselben allgemeinen Prinzip behandelt.

XML: `sp/following-sibling::*[1][self::stage[not(hi)]]`.

Format: `F BA zentr. 1,15 / 0,0  (0,75 pt. nach oben)`

#### (BA im Anschluss an Replik, mit Figur)
(Quasi-Replik)
z.B.
* `before_993_a` "Das Volk ..."

XML: `sp/following-sibling::*[1][self::stage[hi]]`

Format: `C BA zentr. 2,3 / 0,0  (0,75 pt. nach oben)`

#### (freie BA)
(z.B. `before_7040_a` "Die Luftfahrer oben", oft auch vor der ersten Replik)

XML: `stage[not(ancestor::sp) and not(preceding-sibling::*[1][self::sp])]`

Format: `C BA zentr. 2,3 / 0,0  (0,75 pt. nach oben)`

Priority: niedriger als die rule für BA nach Überschrift.

#### (BA nach Überschrift)
(Bsp.: `before_4613_f` "Faust auf blumigen ...")

Betrifft Aufeinanderfolge von
* `head` -- (evtl. `move`) -- `stage`
* `head` -- (evtl. `move`) -- `sp/speaker` -- `stage` mit `inline` (d.h. Sprecher-BA-Kombination)

Die Aufeinanderfolge `head` -- (evtl. `move`) -- `sp/speaker` ohne nachfolgendes `stage` mit `inline` wird hier nicht berücksichtigt, da das betreffende `speaker`-Element keine BA wird, sondern `Sprecher nach Überschrift`, s.u.

XML:
* `head/following-sibling::*[1][self::stage]`
* `head/following-sibling::*[1][self::move]/following-sibling::*[1][self::stage]`
* `head/following-sibling::*[1][self::sp]/speaker[following-sibling::*[1][self::stage[matches(@rend,'inline')]]]`
* `head/following-sibling::*[1][self::move]/following-sibling::*[1][self::sp]/speaker[following-sibling::*[1][self::stage[matches(@rend,'inline')]]]`

Format: `A BA zentr. 0,0 / 0,0`

Priority:
* höher als rules für BAs in Repliken (s.o.)
* höher als rule für freie BA (s.o.)

#### (BA mit Auftritt, nicht zugleich Sprecher)
* `before_354_c`
* `before_482i_a`
* `before_522_a`
* `before_2337_b`
* nicht `before_2465_a`

XML: `move/following-sibling::*[1][self::stage]`

Priority: niedriger als die rule für BA nach Überschrift

Format: `C BA zentr. 2,3 / 0,0  (0,75 pt. nach oben)`

## Unterszene (Finis)
XML: `trailer`

## Kolumne
Kolumnentitel mit Text. Alles weitere unten zu den dazugehörigen Zeichenformaten.

## Kolumne transparent
Nicht relevant für XML.

## Eine LZ
(betrifft Lücken nach 6062 und nach 6358) 

XML:
* `space[@unit='lines' and @quantity='2']`
* `space[@unit='lines' and @quantity='5']`

Output: Anzahl der Leerzeilen nach Wert von `@quantity` (2 bzw. 5). 

## Prosa EB
(Erzwungener Blocksatz)

XML: `p/text()[not(position()=last())]`

## Prosa LB
(Linksbündig)

XML: `p/text()[position()=last()]`

## Sprecher

XML: `speaker[not(hi) and not(following-sibling::*[1][self::stage[matches(@rend,'inline')]])]`

Priority: niedriger als die rule für Sprecher nach Überschrift

## Sprecher nach Überschrift
Bei Auftritten steht noch ein `move` dazwischen, deswegen

XML:
* `head/following-sibling::*[1][self::sp]/speaker[not(following-sibling::*[1][self::stage[matches(@rend,'inline')]])]`
* `head/following-sibling::*[1][self::move]/following-sibling::*[1][self::sp]/speaker[not(following-sibling::*[1][self::stage[matches(@rend,'inline')]])]`

`speaker` mit nochfolgendem `stage` mit `inline` werden zu einem BA-Format (s.o.).

Priority: höher als die rule für `Sprecher`

### Teil
(Zueignung, ..., Teilüberschrift) 

XML: `body/div/head`

Formatierung:
* `Teil` soll immer auf einer neuen rechten Seite stehen.
* Der folgende Text soll ebenfalls auf einer neuen rechten Seite beginnen. 
* Am Anfang des Absatzes 3 Zeilenumbrüche
 
### Akt
XML: `div[@type='act']/head`

Formatierung:
* neue Seite (kann auch eine linke sein)
* 3 Zeilenumbrüche am Anfang des Absatzes

### Szene
(Szenenüberschrift)

XML: `div[@type='scene' and not(@n='1.1.22')]/*[1][self::head]`

Formatierung: 
* neue Seite (kann auch eine linke sein)
* 3 Zeilenumbrüche am Anfang des Absatzes

### Szene 2zeilig
(Szenenüberschrift mit Zeilenumbruch)

XML: `div[@type='scene']/*[1][self::head and lb]`

### Szene vor Szenenunter
XML: `div[@type='scene']/head[@type='main']`

### Szene nach Akt
(Szenenüberschrift nach Aktüberschrift)

XML: `div[@type='act']/div[@type='scene' and position()=(1)]/head[1]`

Formatierung: 
* *keine* neue Seite
* *keine* 3 Zeilenumbrüche am Anfang des Absatzes

### Szenenunter
XML: `div[@type='scene']/head[2]` (sollte auch ein `type='sub'` tragen)

### Unterszene
XML: `div[@type='subscene']/*[1][self::head]`

### Unterszene vor Unterszenenunter
XML: `div[@type='subscene']/head[@type='main']`

### Unterszene nach Szene
(Unterszenenüberschrift nach Szenenüberschrift)

XML: `div[@type='scene']/head/following-sibling::*[1][self::div[@type='subscene']]/head[1]` 

### Unterszene 2zeilig
XML: `div[@type='subscene']/*[1][self::head and lb]`

### Unterszene nach Szene 2zeilig
XML: `div[@type='scene']/head/following-sibling::*[1][self::div[@type='subscene']]/head[1 and lb]`

### Unterszene nach Szene vor Unterszenenunter
XML: `div[@type='scene']/head/following-sibling::*[1][self::div[@type='subscene']]/head[1 and @type='main']`

### Unterszenenunter
XML: `div[@type='subscene']/head[2]`

## (Verse)

### Vers
`l[not(parent::lg[rend='indented'])]`.

Priority: niedriger als rule für `Vers Abstand`.

### Vers Abstand
XML: zweite, dritte, ... nicht eingerückte Versgruppe, darin jeweils erster Vers (`l`): `lg[not(@rend='indented') and preceding-sibling::lg]/*[1][self::l]`.

Priority: siehe `Vers`.

Formatierung: halbzeiliger Abstand nach oben (ca. 2,3 mm)

### Vers Einrückung
XML: `lg[@rend='indented'/l`.

Priority: niedriger als rule für `Vers Einrückung Abstand`.

Umsetzung:
> linksbündigen Tab auf 18 mm vom linken Satzspiegelrand

([#337, comment](https://github.com/faustedition/faust-gen-html/issues/337#issuecomment-372939872))

#### (Weiter eingerückte Verse)
An einer Stelle werden Verse weiter eingerückt als die vorherigen eingerückten Verse.

XML: `lg[@rend='indented']/l[@rend='indented']`

Umsetzung: 
>  linksbündigen Tab ... auf 28 mm [vom linken Satzspiegelrand]

([#337, comment](https://github.com/faustedition/faust-gen-html/issues/337#issuecomment-372939872))

### Vers Einrückung Abstand
`lg[@rend='indented' and preceding-sibling::lg]/*[1][self::l]`

Priority: siehe `Vers Einrückung`.

### Vers Antilabe
XML: `l[@part="M"]` oder `l[@part="M"]` (`l[@part="I"]` bleibt unverändert). 

Die Verse mit `part="M"` und `part="F"` werden gemäß der Länge des vorherigen Teils einer Antilabe eingerückt.

Wenn vorhergehende `l[@part]`-Textknoten mit n-dash enden, wird der folgende `l[@part]` um ein Leerzeichen mehr eingerückt.

# (Absatzformate Sonderfälle)

## Individualregeln für BAs

### (BAs vor 350)
Betrifft gemeinschaftlich
* XML: `stage before_350_a` ("Der Himmel schließt, ...").
* XML: `before_350_b` ("Mephistopheles")
* XML: `before_350_c` ("allein")

Umsetzung:
* `stage before_350_a` soll im Ergebnis eine eigene Zeile sein mit halbzeiligem Abstand nach oben (nicht viertelzeilig, obwohl direkt auf eine Replik folgend).
* `before_350_b` und `before_350_c` werden standardmäßig in einen Absatz zusammengefasst wg. `@rend`-Wert `inline`. So weit in Ordnung. Aber außerdem sollen sie keinen Abstand nach oben erhalten.

Das gewünschte Ergebnis kann auf zwei Weisen erreicht werden (je nachdem, was für @pglatza einfacher ist):
* Entweder `stage before_350_a`, `before_350_b` und `before_350_c` in einen Absatz, Zeilenumbruch nach `stage before_350_a` (das schwebt MC vor)
* Oder
  * `stage before_350_a` → `C BA zentr. 2,3 / 0,0` (halbzeiligen Abstand nach oben)
  * `before_350_b` + `before_350_c` → `A BA zentr. 0,0 / 0,0` (keinen Abstand nach oben)

### (BAs vor 2284)
Betrifft:
* `before_2284_a` ("Nachdem die Löcher ... sind,")
* `before_2284_b` + `before_2284_c` (da mit `inline`)

Umsetzung genau analog zu [BAs vor 350](https://github.com/faustedition/faust-gen-html/blob/master/idml/idml.md#bas-vor-350).

### (Vers nach BA vor before_4412)
(s.o. zu `before_4412`)

XML: `l[@n='4412']`

Format: `Vers Einrückung Abstand`

### (BA vor 8217)
(siehe xml #267)

XML: `before_8217`

Format: `C BA zentr. 2,3 / 0,0` 

### (BAs zu "Innerer Burghof" und "Schattiger Hain")
Dies sind eigentlich normale BAs in Anschluss an Repliken.
Für die Kolumnentitel wurden aber `div`s eingefügt, deren erste Kind-Elemente die BAs sind.

XML: `div[@n='2.3']/div/*[1][self::stage]`

Format: `F BA zentr. 1,15 / 0,0`

## (Walpurgisnachtstraum)

### Teil (WNT)
XML: `head[@n="before_4223_a"]/hi[1]`.

### Unterszene nach Szene (oder)
(für das "oder")

XML: `head[@n="before_4223_a"]/hi[2][text()[contains(.,'oder')]]`.

### Szene (OuTgH)
für "Oberons ..."

XML: der Rest von `head[@n='before_4223_a']/node()`

### (Sprecher nach WNT-Titel)

## Titel (Faust)
XML: `titlePart[@n='before_1_a']`.

## Untertitel (Eine Tragödie)
XML: `titlePart[@n='before_1_b']`.

Formatierung: am Anfang des Absatzes 7 Zeilenumbrüche einfügen.

# Zeichenformate

## (Apparateinträge)
(Zeichenformate in der ungefähren Reihenfolge, wie sie im Apparateintrag vorkommen)

### BA App
XML: `*[self::lem or self::rdg]/stage`.

### Sprecher App
XML: `*[self::lem or self::rdg]/speaker`

### App Strich <u>mit</u> umgebenden Leerzeichen

https://github.com/faustedition/faust-gen-html/issues/458

### (Zeilenreferenz)
XML: `ref`

Umsetzung
* → `Kursiv`
* Wenn mehre Ziffern mit `–` auf einander folgen, soll vor und nach dem `–` ein 24stelgeviert eingefügt werden.

### (Lemma)
XML: `lem[node()]` (die leeren `lem` entfallen)

Umsetzung
* davor ein Leerzeichen
* kein eigenes Zeichenformat
* danach ein Achtelgeviertabstand
* danach Zeichen `]` 

### (Lesart)
XML: `rdg`
* → davor **zwei** Leerzeichen
* → kein eigenes Zeichenformat

### (Auslassung)
XML: `gap`

Umsetzung:
* Zeichenformat `Kursiv` (s. dort)
* Wort `bis` einfügen

### (Apparat-Zitat)
XML: `quote`

Umsetzung: ohne Zeichenformat

## (Zeichenformate mit Sperrung)
* Auftritt
* Doppelunterstreichung
* Figur
* Sperrung
* Sprecher
* (veraltet: Sprecher gesperrt)

Allgemeine Regeln zur Umsetzung:
* Umgebende Leerzeichen werden mitgesperrt (#321).
* todo: Interpunktion ([#321 (comment)](https://github.com/faustedition/faust-gen-html/issues/321#issuecomment-372240044))

## Auftritt
(innerhalb von Absatzformat `BA ...`)

Grundsätzliches XML-Pattern: `move/following-sibling::*[1]`, d.h. der `move` bekommt nichts, sondern der Inhalt oder Teile des Inhalts des folgenden Element (in 37 Fällen `stage`, in 22 Fällen `sp/speaker`).

Das Zeichenformat `Auftritt` bekommt nun entweder der 
* der Inhalt der ganzen BA (`move/following-sibling::*[1][self::stage[not(hi)]]`) oder
* der Inhalt der einfachen Hervorhebung in der BA (`move/following-sibling::*[1][self::stage]/hi[not(hi)]`)  <!-- tel. besprochen am 5.2.18 --> oder
* der Inhalt der Hervorhebung in der Hervorhebung in der BA (`move/following-sibling::*[1][self::stage]/hi/hi`) oder
* bei BA aus dem Inhalt von `speaker` und `stage[matches(@rend, 'inline')]`: davon der Inhalt von `move/following-sibling::*[1][self::sp/speaker]/speaker`
  * sowie ggf. `move/following-sibling::*[1][self::sp/speaker]/speaker/following-sibling::*[1][self::stage]/hi/hi` (Spezialfall `before_1178_b` "Pudel")
  
Formatierung: s.o. zur Sperrung (umgebende Leerzeichen).

## Bibelstelle
Betrifft
* `after_10094` "(Ephes. 6. 12)" [in FA in derselben Zeile]
* `after_10131` "(Matth. 4)"
* `before_10323_b` "Sam. II. 23. 8." ohne Klammern [in WA in Klammern und zentriert]
* `after_11287` "(Regum I. 21.)"
* `before_12037_b` "(St Lucae VII. 36)"
* `before_12045_b` "(St. Joh. IV." ohne schließende Klammer
* `before_12053_b` "(Acta Sanctorum)"

XML: `note[@n]`

Umsetzung:
* einfügen in das jeweils vorhergehende Element `note[@n]/preceding-sibling::*[1]`.
* davor einen Abstand von `1 em` hinzufügen 

## Doppelunterstreichung
(individuelle Vorkommen im Faust II, siehe [xml/issues/66](https://github.com/faustedition/xml/issues/66)) 

XML: `*[self::hi or self::stage or self::speaker]/emph`.

Formatierung: vorläufig wie `Auftritt`.

## Dot
Im rechten Kolumnentitel soll ein middle dot eingefügt werden zwischen den Kolumnentitelteilen "Akt" und "Szene", versehen mit dem Zeichenformat `Dot`.

## Figur
(Hervorhebungen in BA) 

XML: `stage/hi`, `speaker/hi`

## (Kolumnentitel)
* entfallen bei Akt- und Szenenanfängen (= Absenkung)
* gemäß [xslt/scenes.xml](https://github.com/faustedition/faust-gen-html/blob/master/xslt/scenes.xml)

### Kolumne links
* Faust. Eine Tragödie (Vorspann Faust I)
* Der Tragödie erster Teil
* Der Tragödie zweiter Teil

### Kolumne rechts
* Szene (Faust I)
* Akt ("Erster Akt", "Zweiter " etc.) · Szene (Faust II)

## Kursiv
XML:
* `note/ref`
* `*[self::lem or self::rdg]/wit`
* `*[self::lem or self::rdg]/note`
* `gap`

## (Hochstellungen)

### Hochgestellt
Mglw. nicht relevant, vgl. https://github.com/faustedition/faust-gen-html/issues/460.

### Kursiv Hochgestellt
dito

### Versalziffer recte
dito

### Versalziffer kursiv hoch
(für "die hochgestellten Ziffern im Apparat", siehe https://github.com/faustedition/faust-gen-html/issues/374#issuecomment-382695777)

XML: `wit/hi[@rend='superscript']` 

(kann außer Ziffern auch Buchstaben, griechische Buchstaben, : und * enthalten)

## Sperrung
XML: `*[self::l or self::rdg or self::lem]/emph`

## Typ
Hängt ab von https://github.com/faustedition/faust-gen-html/issues/429.

XML: `note[@type="type"]`

Umsetzung: davor zwei Leerzeichen einfügen

## Verszahl
Wert von `@n` ausgeben,
* wenn `self::l and matches(@n, '^\d+') and @n mod 5 = 0`.
* wenn `@n=`
  * `3994`
  * `4342` 
  * `6359`

## Transparent
Siehe https://github.com/faustedition/faust-gen-html/issues/207#issuecomment-361256998

# (Zeilenumbruch)
XML: `lb`.

Output: Zeilenumbruch.

# Seitengestaltung 

## (Absenkung)
Siehe [#210](https://github.com/faustedition/faust-gen-html/issues/210).

# Sonderphänomene

# (XML-Elemente, die in der XML-Vorlage nicht mehr vorkommen sollten)
Für diese braucht in der Transformation nichts zu geschehen, also auch keine Regel geschrieben werden.
* `abbr` (siehe [#195](https://github.com/faustedition/faust-gen-html/issues/195). Bitte gerne zurückmelden, wenn es nach dem Fix von 
[#112](https://github.com/faustedition/faust-gen-html/issues/112) doch noch auftreten sollte.)
* `add`
* `br` ([#265](https://github.com/faustedition/faust-gen-html/issues/265))
* `c` ([#266](https://github.com/faustedition/faust-gen-html/issues/266))
* `choice`
* `corr`
* `expan`
* `del`
* `sic`
* BAs am Ende von Repliken (`sp/*[self::stage and position()=last()]`)
* `subst`
* `titlePart`, siehe [#270](https://github.com/faustedition/faust-gen-html/issues/270)

# XML-Elemente, die keine besondere Behandlung benötigen
* `TEI`
* `ab`
* `body`
* `date`
* `div`
* `fileDesc`
* `lg`
* `listWit` (content löschen)
* `publicationStmt` (content löschen)
* `sourceDesc`
* `sp`
* `teiHeader`
* `text`
* `titleStmt`
* `witStart`
* `witness` (content löschen, `child` von `listWit`, s.o.)