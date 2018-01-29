IDML-Synthese
=============================

Hier werden die zur IDML-Synthese notwendigen Festlegungen getroffen. 

# Fragen
Siehe https://github.com/faustedition/faust-gen-html/labels/c%3Aidml

# Verwendete Kürzel und Bezeichnungen
* BA = Bühnenanweisung (`stage`)
* Sprecher = Sprecherbezeichnung (`speaker`)
* Musterseite / Stammseite in InDesign: Seiten, auf denen Gestaltungen definiert werden, die für alle Seiten gelten sollen, auf die sich die Stammseite bezieht (`Musterseite A` mit Kolumnenzeile und Pagina, `Musterseite B` ohne Kolumnenzeile). 
# Regeln

## Abkürzungen (`abbr` / `expan`)
Sollen in der Vorlage nicht mehr vorkommen, siehe [#195](https://github.com/faustedition/faust-gen-html/issues/195). Bitte zurückmelden, wenn es nach dem Fix von 
[#112](https://github.com/faustedition/faust-gen-html/issues/112)doch noch auftreten sollte.

## Figurenreden (`sp`) ohne Sprecher (`speaker`)
sind grundsätzlich möglich, kommen aber nur vereinzelt vor (siehe 
[#197](https://github.com/faustedition/faust-gen-html/issues/197)).

## Sprecher

## BA
### Position
Bühnenanweisungen erscheinen zentriert, u.U. gemeinsam mit davorstehender Sprecherbezeichnung.

Lange BA (ab drei Zeilen im Output) stehen im Blocksatz mit linksbündiger letzter Zeile.

## Sprecher mit BA in derselben Zeile
Bsp.:

                            <speaker n="before_350_b">Mephistopheles</speaker>
                            <stage n="before_350_c" rend="inline small">allein.</stage>

Erkennungszeichen `@rend`-Wert `inline`.

Umsetzung: `speaker` und `stage`-Inhalt zusammen in einen Absatz mit `BA zentr. 0,0`. Der Inhalt von `speaker` erhält das Zeichenformat `Sprecher`. 

## Antilaben
Die Verse mit `part="M"` und `part="F"` werden gemäß der Länge des vorherigen Teils einer Antilabe eingerückt.

Wenn vorhergehende `l[@part]`-Textknoten mit n-dash enden, wird der folgende //l[@part] um ein Leerzeichen mehr eingerückt.

## Kolumnentitel
* entfallen bei Akt- und Szenenanfängen 
