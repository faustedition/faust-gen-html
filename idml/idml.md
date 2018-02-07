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

## NN (Abstand)
XML: `space`

## Apparat
XML: `note type="textcrit"`.

Output: Fußnotenartiges Konstrukt ohne Anmerkungsziffer.

## (Bühnenanweisungen)
Die folgend beschriebenen `BA ...`-Absatzformate können dem XML-Pattern `speaker`, `stage`, aber auch `speaker`+`stage` entsprechen. 

`BA ...` aus dem Pattern `speaker`+`stage` hat folgende Form (Bsp.):

    <speaker n="before_350_b">Mephistopheles</speaker>
    <stage n="before_350_c" rend="inline small">allein.</stage>

Erkennungszeichen `@rend`-Wert `inline`.

Umsetzung: `speaker` und `stage`-Inhalt zusammen in einen Absatz mit `BA zentr. 0,0`. Der Inhalt von `speaker` erhält das Zeichenformat `Figur`. 

### BA zentr. 0,0
Vorkommen:
* angeblich "Normalfall"; also einfach `stage` und für die anderen `BA`-Fälle Sonderregeln? 
* jedenfalls für alle `stage` mit erstem `preceding` und erstem `following-sibling::l` (BA zwischen Versen, nicht zwischen Versgruppen)

### BA zentr. 0,0 / 2,3 unten

### BA zentr. 0,5
Wenn Antilabenvers (`l[@part and not(@part="F")]`) vorhergeht, der weiter links als die BA endet ([#213](https://github.com/faustedition/faust-gen-html/issues/213#issuecomment-362507356)).

### BA zentr. 1,5 
Siehe 
[#247](https://github.com/faustedition/faust-gen-html/issues/247):
* before_243_c (da auf eine BA mit Auftritt)
* before_2337_c Faust. Meph in der Hexenküche 
* vor before_4666_a Ungeheures Getöse (?)
* alle Bühnenanweisungen, die auf eine Szenenüberschrift folgen, sollen Abstand nach unten haben? Dann aber mehr als 1,5

Normaler Replikenabstand, auch für Auftritte. Zu überlegen, ob Auftritte einen größeren erhalten.

### BA Blocks. ...
Lange BA (ab drei Zeilen im Output) stehen im Blocksatz mit linksbündiger letzter Zeile. Als ungefähre Heuristik wird eine Zahl von Zeichen genommen, ab der mit hoher Wahrscheinlichkeit im Umbruch mehr als drei Zeilen entstehen. (Hängt ab von [#209](https://github.com/faustedition/faust-gen-html/issues/209)!)

#### BA Blocks. 0,0
(Standardfall von `BA Blocks. ...`)

XML: `stage` ohne `@rend`-Wert `inline`.

#### BA Blocks. 1,5

#### BA Abstand
(für BA zwischen Versgruppen)

Abstand nach oben wie `Vers Abstand`.

## NN (Bibelstelle eigene Zeile)
Betrifft:
* `after_10094` "(Ephes. 6. 12)" [in FA in derselben Zeile]
* `after_10131` "(Matth. 4)"
* `before_10323_b` "Sam. II. 23. 8." ohne Klammern [in WA in Klammern und zentriert]
* `after_11287` "(Regum I. 21.)"

XML: `note[not(@type='textcrit') and not(ancestor::app) and not(@rend='inline')]`

Formatierung: rechtsbündig.

## Kolumne
Kolumnentitel mit Text. Alles weitere unten zu den dazugehörigen Zeichenformaten.

## Kolumne weiß
Nicht relevant für XML.

## Leerzeilen
(entfallen)

## Prosa
Absätze in "Trüber Tag. Feld".

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

Szenenüberschriften beginnen immer auf einer neuen Seite und führen zur Absenkung.

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
("Director, ..." / "Der Herr, ...")

XML:
* `stage[@n="before_33_b]`
* `stage[@n="before_243_b]`

Output: Mit beiden BA soll jeweils eine neue rechte Seite anfangen. 

Hier gibt es ein Problem: Wenn das Absatzformat eine neue Seite verlangt, 
kann kein Abstand zum oberen Satzspiegelrand definiert werden. 
Genau dies ist hier aber gewünscht ("Absenkung").

Lösung:
* Der Seitenwechsel wird mit dem Format `Szene` angewiesen.
* Zeilenumbrüche am Anfang des betreffenden Absatzes

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

### (WNT-Text)
Text der Szene "Walpurgisnachtstraum" soll bekommen `Szene nach Teil`. 

## Titel (Faust)

## Untertitel (Eine Tragödie)

## Vers nach Teil (Zueignung)
Extra-Abstand nach oben.

# Zeichenformate

## Auftritt
(innerhalb von Absatzformat `BA ...`)

Grundsätzliches XML-Pattern: `move/following-sibling::*[1]`, d.h. der `move` bekommt nichts, sondern das folgende Element (wohl immer `stage`, wäre übrigens interessant zu wissen -- `speaker`?).

Das Zeichenformat `Auftritt` bekommt nun entweder der 
* der Inhalt der ganzen `stage` (wenn `stage[not(hi)]`) oder
* `stage/hi` (wenn `stage[hi]`)  <!-- tel. besprochen am 5.2.18 -->

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

# Seitengestaltung 

## Absenkung
Siehe [#210](https://github.com/faustedition/faust-gen-html/issues/210).

# Sonderphänomene

## Figurenreden (`sp`) ohne Sprecher (`speaker`)
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
* `subst`

# XML-Elemente, die keine besondere Behandlung benötigen
* `TEI`
* `body`
* `date`
* `div`
* `fileDesc`
* `###`
* `###`
* `###`
* `###`

# Feinsatz
* Seitenumbrüche
* Einfügen von Leerzeilen (wo?)
* Zeilenumbrüche bei Bühnenanweisungen
* optische Mitte der Liedverse
* Einrichtung der Szene "Trüber Tag. Feld" (verkleinerter Satzspiegel?)
