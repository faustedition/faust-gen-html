IDML-Synthese
=============================

Hier werden die zur IDML-Synthese notwendigen Festlegungen getroffen. 

# Fragen
Siehe https://github.com/faustedition/faust-gen-html/labels/c%3Aidml

# Verwendete Kürzel und Bezeichnungen
* BA = Bühnenanweisung (`stage`)
* Sprecher = Sprecherbezeichnung (`speaker`)
* Musterseite / Stammseite in InDesign: Seiten, auf denen Gestaltungen definiert werden, die für alle Seiten gelten sollen, auf die sich die Stammseite bezieht (`Musterseite A` mit Kolumnenzeile und Pagina als Textvariablen definiert, `Musterseite B` ohne Kolumnenzeile). 

# Absatzformate

## BA ...
Die folgend beschriebenen `BA ...`-Absatzformate können dem XML-Pattern `speaker`, `stage`, aber auch `speaker`+`stage` entsprechen. 

`BA ...` aus dem Pattern `speaker`+`stage` hat folgende Form (Bsp.):

                            <speaker n="before_350_b">Mephistopheles</speaker>
                            <stage n="before_350_c" rend="inline small">allein.</stage>

Erkennungszeichen `@rend`-Wert `inline`.

Umsetzung: `speaker` und `stage`-Inhalt zusammen in einen Absatz mit `BA zentr. 0,0`. Der Inhalt von `speaker` erhält das Zeichenformat `Figur`. 

### BA zentr. 0,0
evtl. nur für den Feinsatz.

### BA zentr. 0,5

### BA Blocks. ...
Lange BA (ab drei Zeilen im Output) stehen im Blocksatz mit linksbündiger letzter Zeile.

#### BA Blocks. 0,0 

#### BA Blocks. 1,5 

## Sprecher ... 
XML: `speaker` ohne folgende `stage` mit `@rend`-Wert `inline`.

### Sprecher 1,5

### Sprecher 0,5

## Vers ...

### Vers
XML: `l`.

### Vers eingerückt (so?)
XML: `parent::lg[@rend="indented"]`

Im InDesign-Template stehen drei (?) Tabs davor, letztlich sollen sie auf optische Mitte kommen.

### Vers Antilabe
XML: `l[@part="M"]` oder `l[@part="M"]` (`l[@part="I"]` bleibt unverändert). 

Die Verse mit `part="M"` und `part="F"` werden gemäß der Länge des vorherigen Teils einer Antilabe eingerückt.

Wenn vorhergehende `l[@part]`-Textknoten mit n-dash enden, wird der folgende `//l[@part]` um ein Leerzeichen mehr eingerückt.

### Verszahlen
`@n` wenn `self::l and matches(@n, '^\d+') and @n mod 5 = 0`

# Zeichenformate

## Figur
(Hervorhebungen in BA) 

XML: `//stage/hi`.

Formatierung: Sperrung. Umgebende Leerzeichen werden mitgesperrt.

## Nomen nominandum
(= "Hervorhebung Vers" o.ä.)

XML: `l/emph`.

## Auftritt
(innerhalb von Absatzformat `BA ...`)

Grundsätzliches XML-Pattern: `//move/following-sibling::*[1]`, d.h. der `move` bekommt nichts, sondern das folgende Element (wohl immer `stage`, wäre übrigens interessant zu wissen -- `speaker`?).

Das Zeichenformat `Auftritt` bekommt nun entweder der 
* der Inhalt der ganzen `stage` (wenn `//stage[not(hi)]`) oder
* `stage/hi` (wenn `//stage[hi]`)

Formatierung: Satzzeichen, die vom pattern miterfasst werden, (z.B. `<hi>Der Herr, die himmlischen Heerscharen,</hi>`) erhalten das Zeichenformat nicht.

## Sprecher
XML-Pattern: `speaker`.

Merke: `speaker` ist Zeichenformat als Teil der Absatzformate `BA ...`..

Formatierung: Versalien, 8,5 pt, Laufweite +25 (Sperrung).

### lateinisch
(= Antiqua und lateinische Schrift in Versen, Sprechern, BA und Finis)

XML: `//*[@rend="antiqua" or @rend="latin"]`.

Nicht durchgängig so kodiert; wer mag, kann auf fehlende Auszeichnungen hinweisen.

## Zwischenzeile

## Finis
XML: `trailer`.

# Seitengestaltung 

## Absenkung
Siehe 
[#210](https://github.com/faustedition/faust-gen-html/issues/210).

## Kolumnentitel
* entfallen bei Akt- und Szenenanfängen (= Absenkung)
* in modernisierter Schreibweise

Links:
* Faust. Eine Tragödie (Vorspann Faust I)
* Der Tragödie erster Teil
* Der Tragödie zweiter Teil

Rechts:
* Szene (Faust I)
* Akt · Szene / Unterszene (?) (Faust II)

# Sonderphänomene

## Abkürzungen (`abbr` / `expan`)
Sollen in der Vorlage nicht mehr vorkommen, siehe [#195](https://github.com/faustedition/faust-gen-html/issues/195). Bitte zurückmelden, wenn es nach dem Fix von 
[#112](https://github.com/faustedition/faust-gen-html/issues/112)doch noch auftreten sollte.

## Figurenreden (`sp`) ohne Sprecher (`speaker`)
sind grundsätzlich möglich, kommen aber nur vereinzelt vor (siehe 
[#197](https://github.com/faustedition/faust-gen-html/issues/197)).

# Feinsatz
* Seitenumbrüche
* Einfügen von Leerzeilen (wo?)
* Zeilenumbrüche bei Bühnenanweisungen
* optische Mitte der Liedverse
* Einrichtung der Szene "Trüber Tag. Feld" (verkleinerter Satzspiegel?)