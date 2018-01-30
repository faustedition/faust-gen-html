IDML-Synthese
=============================

Hier werden die zur IDML-Synthese notwendigen Festlegungen getroffen. 

# Fragen
Siehe https://github.com/faustedition/faust-gen-html/labels/c%3Aidml

# Verwendete Kürzel und Bezeichnungen
* BA = Bühnenanweisung (`stage`)
* Sprecher = Sprecherbezeichnung (`speaker`)
* Musterseite / Stammseite in InDesign: Seiten, auf denen Gestaltungen definiert werden, die für alle Seiten gelten sollen, auf die sich die Stammseite bezieht (`Musterseite A` mit Kolumnenzeile und Pagina als Textvariablen definiert, `Musterseite B` ohne Kolumnenzeile). 

# Regeln

## Abkürzungen (`abbr` / `expan`)
Sollen in der Vorlage nicht mehr vorkommen, siehe [#195](https://github.com/faustedition/faust-gen-html/issues/195). Bitte zurückmelden, wenn es nach dem Fix von 
[#112](https://github.com/faustedition/faust-gen-html/issues/112)doch noch auftreten sollte.

##Absenkung
Siehe 
[#210](https://github.com/faustedition/faust-gen-html/issues/210).

## Figurenreden (`sp`) ohne Sprecher (`speaker`)
sind grundsätzlich möglich, kommen aber nur vereinzelt vor (siehe 
[#197](https://github.com/faustedition/faust-gen-html/issues/197)).

## Sprecher
Zeichenformat: `Sprecher`, Formatierung: Versalien, 8,5 pt, Laufweite +25 (Sperrung).

## BA
### Position
Bühnenanweisungen erscheinen zentriert, u.U. gemeinsam mit davorstehender Sprecherbezeichnung.

Lange BA (ab drei Zeilen im Output) stehen im Blocksatz mit linksbündiger letzter Zeile.

### Hervorhebungen in BA (`//stage/hi`)
Output: Zeichenformat `Figur`.

### Auftritt (`move`)
Grundsätzliches pattern: `//move/following-sibling::*[1]`, d.h. der `move` bekommt nichts, sondern das folgende Element (wohl immer `stage`, wäre übrigens interessant zu wissen -- `speaker`?).

Das Zeichenformat `Auftritt` bekommt nun entweder der 
* der Inhalt der ganzen `stage` (wenn `//stage[not(hi)]`) oder
* `stage/hi` (wenn `//stage[hi]`)

Output: Zeichenformat `Auftritt` innerhalb von Absatzformat `BA ...`.

Satzzeichen, die vom pattern miterfasst werden, (z.B. `<hi>Der Herr, die himmlischen Heerscharen,</hi>`) erhalten das Zeichenformat nicht.

## Sprecher mit BA in derselben Zeile
Bsp.:

                            <speaker n="before_350_b">Mephistopheles</speaker>
                            <stage n="before_350_c" rend="inline small">allein.</stage>

Erkennungszeichen `@rend`-Wert `inline`.

Umsetzung: `speaker` und `stage`-Inhalt zusammen in einen Absatz mit `BA zentr. 0,0`. Der Inhalt von `speaker` erhält das Zeichenformat `Sprecher`. 

## Verse 

### Eingerückte Verse (parent::lg[@rend="indented"])
Im InDesign-Template stehen drei (?) Tabs davor, letztlich sollen sie auf optische Mitte kommen.

### Antilaben
Die Verse mit `part="M"` und `part="F"` werden gemäß der Länge des vorherigen Teils einer Antilabe eingerückt.

Wenn vorhergehende `l[@part]`-Textknoten mit n-dash enden, wird der folgende //l[@part] um ein Leerzeichen mehr eingerückt.

Absatzformat im InDesign-Template: "Vers Antilabe".

## Zwischenzeile
> Das Format Zwischenzeile kommt nur einmal vor, nämlich beim »oder« zwischen Walpurgisnachtstraum und Oberons und Titanias goldne Hochzeit.

## Finis
> kommt nur einmal vor, ganz am Schluss

## Sperrung (`l/emph` / `stage/hi`)
Umgebende Leerzeichen werden mitgesperrt.

## Kolumnentitel
* entfallen bei Akt- und Szenenanfängen (= Absenkung)
* in modernisierter Schreibweise

Links:
* Faust. Eine Tragödie (Vorspann Faust I)
* Der Tragödie erster Teil
* Der Tragödie zweiter Teil)

Rechts:
* Szene (Faust I)
* Akt · Szene / Unterszene (?) (Faust II)

## Feinsatz
* Seitenumbrüche
* Einfügen von Leerzeilen (wo?)
* Zeilenumbrüche bei Bühnenanweisungen
* optische Mitte der Liedverse
* Einrichtung der Szene "Trüber Tag. Feld" (verkleinerter Satzspiegel?)