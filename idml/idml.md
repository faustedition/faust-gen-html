IDML-Synthese
=============================

Hier werden die zur IDML-Synthese notwendigen Festlegungen getroffen. 

# Fragen
Siehe https://github.com/faustedition/faust-gen-html/labels/c%3Aidml

# Verwendete Kürzel und Bezeichnungen
* BA = Bühnenanweisung (`stage`)
* Sprecher = Sprecherbezeichnung (`speaker`)
* Musterseite / Stammseite in InDesign: Seiten, auf denen Gestaltungen definiert werden, die für alle Seiten gelten sollen, auf die sich die Stammseite bezieht (`Musterseite A` mit Kolumnenzeile und Pagina als Textvariablen definiert, `Musterseite B` ohne Kolumnenzeile). 

# Allgemeine Regel zur Sperrung
Umgebende Leerzeichen werden mitgesperrt.

# Absatzformate

## Apparat
XML: `note type="textcrit"`.

Output: Fußnotenartiges Konstrukt ohne Anmerkungsziffer.

## (Bühnenanweisungen)
Die folgend beschriebenen `BA ...`-Absatzformate können dem XML-Pattern `speaker`, `stage`, aber auch `speaker`+`stage` entsprechen. 

### (Bühnenanweisungen aus `speaker` und `stage`)
`BA ...` aus dem Pattern `speaker`+`stage` hat folgende Form (Bsp.):

    <speaker n="before_350_b">Mephistopheles</speaker>
    <stage n="before_350_c" rend="inline small">allein.</stage>

Erkennungszeichen: `stage[matches(@rend, 'inline')]`.

Umsetzung: `speaker` und `stage`-Inhalt zusammen in einen Absatz mit `BA zentr. 1,5` (doch wohl nicht `0,0`?). Der Inhalt von `speaker` erhält das Zeichenformat `Figur`.

### (BA unterschieden nach Kontext)
Momentan sind es gut 700 `stage`-Elemente, die Mehrheit davon (gut 460) innerhalb von Repliken.

#### (BA **in** Replik)
* direkt nach Sprecher auf derselben Zeile (`speaker/following-sibling::*[1][self::stage and @rend[contains(.,'inline')]]`)
  * → Teil von BA zentr. 1,5
* direkt nach Sprecher auf eigener Zeile (`speaker/following-sibling::*[1][self::stage and not(@rend[contains(.,'inline')])]`)
  * → BA zentr. 0,0
* zwischen Versen (`stage[preceding-sibling::*[1][self::l] and following-sibling::*[1][self::l]]`)
  * → BA zentr. 0,0
* zwischen Versgruppen (`stage[preceding-sibling::*[1][self::lg] and following-sibling::*[1][self::lg]]`)
  * → BA Abstand
* am Ende von Repliken (`sp/*[self::stage and position()=last()]`)
  * kommt regulär nicht vor 

#### (BA nach Replik ohne Figur)
(z.B. `before_4666_a` "Ungeheures Getöse ...", siehe [#256](https://github.com/faustedition/faust-gen-html/issues/256))

XML: `stage[not(hi) and preceding-sibling::*[1][self::sp] and following-sibling::*[1][self::sp or self::move[following-sibling::*[1][self::sp]]]]`.

→ `BA zentr. 1,5`, siehe aber [#286](https://github.com/faustedition/faust-gen-html/issues/286) 

→ (bei entsprechender Länge) `BA Blocks. 1,5` (Bsp.: `before_2465_a` "Der Kessel ...") 

#### (BA nach Replik mit Figur)
XML: `stage[hi and preceding-sibling::*[1][self::sp] and following-sibling::*[1][self::sp or self::move[following-sibling::*[1][self::sp]]]]`.

→ `BA zentr. 1,5`

→ (bei entsprechender Länge) `BA Blocks. 1,5` (Bsp.: `before_2465_a` "Der Kessel ...") 

#### (BA nach Überschrift, kein Auftritt)
(Bsp.: `before_4613_f` "Faust auf blumigen ...")

XML: `//head/following-sibling::*[1][self::stage]`.

→ `BA zentr. 0,0` oder (bei entsprechender Länge) `BA Blocks. 0,0`.

Generelle Andersbehandlung von BA nach Überschriften ist fragwürdig, da weitere BAs direkt nachfolgen können.

#### (BA nach Überschrift mit Auftrittsbezeichnung, nicht Sprecher)
(überschneidet sich mit vorigem)

XML: `move[preceding-sibling::*[1][self::head]]/following-sibling::*[1][self::stage]`

→ `BA zentr. 0,0 / ?? unten` (`??` = Abstand nach unten, der zum normalen Replikenabstand hinzukommt)

#### (BA mit Auftrittsbezeichnung, nicht Sprecher)
(überschneidet sich mit vorigem)

XML: `move/following-sibling::*[1][self::stage]`

→ `BA zentr. ?? / ?? unten` (`??` = mehr als 1,5 Abstand nach oben / = Abstand nach unten, der zum normalen Replikenabstand hinzukommt)

#### (BA mit Auftrittsbezeichnung, nicht Sprecher **nach** BA mit Auftrittsbezeichnung, nicht Sprecher) 
(Bsp.: `before_2337_c` "Faust. Mephistopheles.")

XML: `move/following-sibling::*[1][self::stage]/following-sibling::*[1][self::move]/following-sibling::*[1][self::stage]`.

→ `BA zentr. 0,0 / ?? unten` (`??` = Abstand nach unten, der zum normalen Replikenabstand hinzukommt). Extra-Abstand nach oben braucht die BA nicht, dafür sorgt schon der Abstand nach der vorigen BA.  

#### (BA nach BA, nicht in Replik)
XML: `stage[not(ancestor::sp) and preceding-sibling::*[1][self::stage]]`.

→ `BA zentr. 1,5` 

→ (bei entsprechender Länge) `BA Blocks. 1,5` 

#### (BA nach BA mit Auftritt, nicht in Replik)
(Anlass: `before_243_c` "Die drey Erzengel ...")

XML: `stage[not(ancestor::sp) and preceding-sibling::*[1][self::stage]]`.

→ `BA zentr. 1,5` 

→ (bei entsprechender Länge) `BA Blocks. 1,5` 

### BA zentr. 0,0

### BA zentr. 0,0 / 2,3 unten

### BA zentr. 0,5
(entfällt möglicherweise, siehe [#213](https://github.com/faustedition/faust-gen-html/issues/213#issuecomment-362507356))

### BA zentr. 1,5 

### BA Blocks. ...
Lange BA (ab drei Zeilen im Output) stehen im Blocksatz mit linksbündiger letzter Zeile. Als ungefähre Heuristik wird eine Zahl von Zeichen genommen, ab der mit hoher Wahrscheinlichkeit im Umbruch mehr als drei Zeilen entstehen. (Hängt ab von [#209](https://github.com/faustedition/faust-gen-html/issues/209)!). Momentane Heuristik: 210 Zeichen als Richtwert, der zur Zuweisung von `BA Blocks. ...` führt.

#### BA Blocks. 0,0

#### BA Blocks. 1,5

#### BA Abstand
(für BA zwischen Versgruppen)

Abstand nach oben wie `Vers Abstand`.

## Bandtitel
XML: `title`.

Output: einfach zentrierte Absätze o.ä., nach dem letzten `title` ein Seitenumbruch. 

## NN (Bibelstelle eigene Zeile)
Betrifft:
* `after_10094` "(Ephes. 6. 12)" [in FA in derselben Zeile]
* `after_10131` "(Matth. 4)"
* `before_10323_b` "Sam. II. 23. 8." ohne Klammern [in WA in Klammern und zentriert]
* `after_11287` "(Regum I. 21.)"

XML: `note[not(@type='textcrit') and not(ancestor::app) and not(@rend='inline')]`

Formatierung: rechtsbündig.

## Finis
XML: `trailer`.

## Kolumne
Kolumnentitel mit Text. Alles weitere unten zu den dazugehörigen Zeichenformaten.

## Kolumne weiß
Nicht relevant für XML.

## Leerzeile
(betrifft Lücken nach 6062 und nach 6358) 

XML:
* `space[@unit='lines' and @quantity='2']`
* `space[@unit='lines' and @quantity='5']`

Output: Anzahl der Leerzeilen nach Wert von `@quantity` (2 bzw. 5). 

## Prosa
(Absätze in "Trüber Tag. Feld")

XML: `p`.

## Sprecher ... 
XML: `speaker` ohne folgende `stage` , mit `@rend`-Wert `inline`.

### Sprecher 0,5
Wenn Antilabenvers (`l[@part and not(@part="F")]`) vorhergeht, der weiter links als die BA endet ([#203](https://github.com/faustedition/faust-gen-html/issues/203#issuecomment-362506592)).

### Sprecher 1,5
Normalfall für `speaker` ohne ... (s.o.)

## (Überschriften)
Wenn `head/lb`, so soll der Inhalt des `head` auf aufeinanderfolgende `Überschrift ...`-Absätze aufgeteilt werden.

### Teil / Akt
(Zueignung, ..., Teil- und Aktüberschrift) 

Formatierung: `Teil / Akt` soll immer auf einer rechten Seite stehen.

### Szene
(Szenenüberschrift)

Output: 
* Seitenwechsel
* 3 Zeilenumbrüche am Anfang des Absatzes

### Szene nach Akt
(Szenenüberschrift nach Aktüberschrift)
XML müsste eigentlich sein: `div[@type='act']/div[@type='scene' and not(position()=(1))]/head[1]`.

Immer `head` oder auch `stage`?

### Unterszene
XML: `div[@type='subscene']/head`.

(Unterszenenüberschrift, 4. Stelle in der Szenenzählung)

### Unterszene nach Szene
(Unterszenenüberschrift nach Szenenüberschrift)

## (Verse)

### Vers
XML: `l`.

### Vers Abstand
XML: zweite, dritte, ... `lg`, erstes `l`.

Formatierung: halbzeiliger Abstand nach oben (ca. 2,3 mm)

### Vers Einrückung
XML: `parent::lg[@rend="indented"]`.

Im InDesign-Template stehen drei (?) Tabs davor, letztlich sollen sie auf optische Mitte kommen.

### Vers Einrückung Abstand

### Vers Antilabe
XML: `l[@part="M"]` oder `l[@part="M"]` (`l[@part="I"]` bleibt unverändert). 

Die Verse mit `part="M"` und `part="F"` werden gemäß der Länge des vorherigen Teils einer Antilabe eingerückt.

Wenn vorhergehende `l[@part]`-Textknoten mit n-dash enden, wird der folgende `l[@part]` um ein Leerzeichen mehr eingerückt.

## Zentriert
(entfallen)

# (Absatzformate Sonderfälle)

## BA zentr. 0,0 nach Teil (Vorspiel/Prolog)
(eigens für `before_33_b` "Director, ..." und `before_243_b`)

XML:
* `stage[@n='before_33_b']` 
* `stage[@n='before_243_b']`

Output:
* Seitenwechsel
* 3 Zeilenumbrüche am Anfang des Absatzes

Formatierung: Abstand nach unten wie `BA ...` mit `Auftritt` (siehe 
[#251 (comment)](https://github.com/faustedition/faust-gen-html/issues/251#issuecomment-364304733)).

Dieser Abstand kommt zu dem Replikenabstand hinzu, den der jeweils folgende Absatz von sich aus hat:
* `Sprecher` (`before_33_c` "Director") 
* `BA`(`before_243_c` "Die drey Erzengel ...")

## (BAs vor 350)
XML: `stage before_350_a` ("Der Himmel schließt, ...").

--> `BA zentr. 1,5` (ausnahmsweise Replikenabstand nach oben)

XML: `before_350_b` zusammen mit `before_350_c` ("Mephistopheles allein.")
--> `BA zentr. 0,0` (ausnahmsweise keinen Replikenabstand nach oben, da Einheit mit vorhergehender BA).

Der Grund ist, dass die XML-Auszeichnung die Struktur des Textes hier nicht voll adäquat abbildet.

## Szene (Finis)
(entfällt vorläufig)
Bedeutet, dass Finis wie Szene behandelt wird.

## Szene nach Teil (Nacht)
= neue rechte Seite (Leerseite nach Teiltitel)

## Walpurgisnachtstraum

### (WNT-Titel)
XML: `head[@n="before_4223_a"]/hi[1]`.

Output: `Teil / Akt`.

### Zwischenzeile (WNT)
(für das "oder")

XML: `head[@n="before_4223_a"]/hi[2][text()[contains(.,'oder')]]`.

### Szene nach Zwischenzeile (WNT)
für "Oberons ..."

### (Sprecher nach WNT-Titel)

## Titel (Faust)
XML: `before_1_a`.

## Untertitel (Eine Tragödie)
XML: `before_1_b`.


## Vers nach Teil (Zueignung)
Extra-Abstand nach oben.

## (Sonderfälle, die keine sind)

### (TTF)
Siehe https://github.com/faustedition/faust-gen-html/issues/259. 

### (before_4666_a)
("Ungeheures Getöse")

Siehe https://github.com/faustedition/faust-gen-html/issues/256.

Gehört zum Typ BA nach Replik (s.o.).

# Zeichenformate

## (Apparateinträge)
(Zeichenformate in der ungefähren Reihenfolge, wie sie im Apparateintrag vorkommen)

### Zeilenreferenz
XML: `ref`.

Output: erstmal ohne besondere Formatierung, danach ein `em` Abstand.

### Lemma-Lesart
XML:
* `lem`
* `rdg`

Output:
* ohne besondere Formatierung
* wenn `lem`
  * danach 1/6 oder 1/8 Geviert Abstand 
  * danach das Zeichen `]` mit Zeichenformat `Lemmaklammer` 
  * danach ein Leerzeichen
* wenn `rdg`
  * davor 1 `em` Abstand (variable Abstände zwischen Siglen und folgender Lesart bei zeilenfüllende Apparateinträgen?)
  * danach ein Leerzeichen

### Lemma-Lesart BA
XML: `*[self::lem or self::rdg]/stage`.

Output: wie `Lemma-Lesart`, nähere Formatierung noch festzulagen, u.a. abhängig von der Schriftgröße im Apparat.

### Lemma-Lesart Sprecher
XML: `*[self::lem or self::rdg]/speaker`.

Output:
* wenn `lem`, Formatierung Großbuchstaben
* nähere Formatierung festzulegen, siehe `Lemma-Lesart BA`

### Lemma-Lesart Sperrung
XML: `*[self::lem or self::rdg]/emph`.

Output: vorläufig analag zu `Sperrung`.

### Sigle
XML: `wit`. 

Output: kursiv.

### Sigle Grundtext
XML: `wit[@f:is-base='true']`. 

Output: kursiv.

### Siglenziffer
(die hochgestellte arabische, evtl. Buchstaben statt Ziffern, evtl. mit Suffixen)

XML: `wit/hi[@rend='superscript']`.

Output: hochgestellt.

### Editortext
XML: `app//note`.

Output: kursiv.

### Typenbezeichnung
XML: `rdg/@type`

Output:
* in `(...)` hinter die betreffende `Lemma-Lesart`
* wenn diese `Lemma-Leart` die letzte des `Apparat`-Absatzes ist: 1 `em` Abstand vor Typenbezeichnung 

### (Sonderwünsche)
Eventuell enthalten Apparateinträge nicht nur Zeichenformate, sondern wiederum eigene Absätze:
* https://github.com/faustedition/faust-gen-html/issues/276
* https://github.com/faustedition/faust-gen-html/issues/277

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

## Auslassungspunkte
XML: `g`

Formatierung: [#267](https://github.com/faustedition/faust-gen-html/issues/267).

## NN (Bibelstelle in Zeile)
betrifft (Kontext jeweils `BA zentr. 1,5`)
* `before_12037_b` "(St Lucae VII. 36)"
* `before_12045_b` "(St. Joh. IV." ohne schließende Klammer
* `before_12053_b` "(Acta Sanctorum)"
 
XML: `note[not(@type='textcrit') and not(ancestor::app) and @rend='inline']`

Formatierung: zusammen zentriert wie übrige `BA zentr.` ohne besondere Auszeichnung und ohne vergrößerten Abstand. 

## Doppelunterstreichung
(individuelle Vorkommen im Faust II, siehe [xml/issues/66](https://github.com/faustedition/xml/issues/66)) 

XML: `*[self::hi or self::stage or self::speaker]/emph`.

Formatierung: vorläufig wie `Auftritt`.

## Figur
(Hervorhebungen in BA) 

XML: `stage/hi`.

Formatierung: Sperrung.

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
(entfällt)

## Kursiv (Apparat)

## (Antiqua / lateinisch)
(= Antiqua und lateinische Schrift in Versen, Sprechern, BA und Finis)

XML: `*[@rend="antiqua" or @rend="latin"]`.

Nicht durchgängig so kodiert, keine Umsetzung vorgesehen.

## Sperrung
XML: `l/emph`.

## Sprecher
XML-Pattern: `speaker`.

Merke: `speaker` ist Zeichenformat als Teil der Absatzformate `BA ...`.

Formatierung: Versalien, 8,5 pt, Laufweite +25 (Sperrung).

## Sprecher lateinisch
(entfällt vorläufig)

## Sprecher lateinisch gesperrt
TODO Auftritt-Analogon im Faust II bennen. 

## Vers lateinisch
(entfällt vorläufig)

## Verszahl
Wert von `@n` ausgeben, wenn `self::l and matches(@n, '^\d+') and @n mod 5 = 0`.

## Weiß
Siehe https://github.com/faustedition/faust-gen-html/issues/207#issuecomment-361256998

# (Zeilenumbruch)
XML: `lb`.

Output: Zeilenumbruch.

# Seitengestaltung 

## Absenkung
Siehe [#210](https://github.com/faustedition/faust-gen-html/issues/210).

# Sonderphänomene

## Replik (`sp`) ohne Sprecher (`speaker`)
sind grundsätzlich möglich, kommen aber nur vereinzelt vor (siehe 
[#197](https://github.com/faustedition/faust-gen-html/issues/197)).

# XML-Elemente, die in der XML-Vorlage nicht mehr vorkommen (sollen)
Für diese braucht in der Transformation nichts zu geschehen, also auch keine Regel geschrieben werden.
* `abbr` (siehe [#195](https://github.com/faustedition/faust-gen-html/issues/195). Bitte gerne zurückmelden, wenn es nach dem Fix von 
[#112](https://github.com/faustedition/faust-gen-html/issues/112) doch noch auftreten sollte.)
* `add`
* `br` (
[#265](https://github.com/faustedition/faust-gen-html/issues/265))
* `c` (
[#266](https://github.com/faustedition/faust-gen-html/issues/266))
* `choice`
* `corr`
* `expan`
* `del`
* `sic`
* `subst`
* `titlePart`, siehe [#270](https://github.com/faustedition/faust-gen-html/issues/270)

# XML-Elemente, die keine besondere Behandlung benötigen
* `TEI`
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

# Feinsatz
* Seitenumbrüche
* Einfügen von Leerzeilen (wo?)
* Zeilenumbrüche bei Bühnenanweisungen
* optische Mitte der Liedverse
* Einrichtung der Szene "Trüber Tag. Feld" (verkleinerter Satzspiegel?)
