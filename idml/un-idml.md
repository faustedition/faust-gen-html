# IDML-Synthese (abgeschaffte Formate)

## Bandtitel
XML: `title`.

Output: einfach zentrierte Absätze o.ä., nach dem letzten `title` ein Seitenumbruch. 

## BA zentr. 0,0 nach Teil (Vorspiel/Prolog)
(eigens für `before_33_b` "Director, ..." und `before_243_b`)

XML:
* `stage[@n='before_33_b']` 
* `stage[@n='before_243_b']`

Output:
* Seitenwechsel
* 3 Zeilenumbrüche am Anfang des Absatzes

## Szene nach Teil (Nacht)
= neue rechte Seite (Leerseite nach Teiltitel)

### Szene nach Akt
(Szenenüberschrift nach Aktüberschrift)

XML: `div[@type='act']/div[@type='scene' and position()=(1)]/head[1]`

Formatierung: 
* *keine* neue Seite
* *keine* 3 Zeilenumbrüche am Anfang des Absatzes

## Vers nach Teil (Zueignung)
XML: `l[@n='1']`

Umsetzung:
* Seitenwechsel (neue rechte Seite)
* 3 Zeilenumbrüche am Anfang des Absatzes

## (Sonderfälle, die keine sind)

### (before_4666_a)
("Ungeheures Getöse")

Siehe https://github.com/faustedition/faust-gen-html/issues/256.

Gehört zum Typ BA nach Replik (s.o.).

## (Sonderwünsche)
Eventuell enthalten Apparateinträge nicht nur Zeichenformate, sondern wiederum eigene Absätze:
* https://github.com/faustedition/faust-gen-html/issues/276
* https://github.com/faustedition/faust-gen-html/issues/277

## Auslassungspunkte
XML: `g`

Formatierung: [#267](https://github.com/faustedition/faust-gen-html/issues/267).

## NN (Bibelstelle eigene Zeile)
(zeitweise als Absatzformat vorgesehen; entfallen, siehe "Bibelstelle")

Die Differenzierung zwischen `@rend='inline'`-Bibelstellen und denen auf eigener Zeile wurde aufgegeben.

## (Antiqua / lateinisch)
(= Antiqua und lateinische Schrift in Versen, Sprechern, BA und Finis)

XML: `*[@rend="antiqua" or @rend="latin"]`.

Nicht durchgängig so kodiert, keine Umsetzung vorgesehen.

## Sprecher lateinisch
(entfällt vorläufig)

## Sprecher lateinisch gesperrt
TODO Auftritt-Analogon im Faust II bennen. 

## Vers lateinisch
(entfällt vorläufig)

## Replik (`sp`) ohne Sprecher (`speaker`)
sind grundsätzlich möglich, kommen aber nur vereinzelt vor (siehe 
[#197](https://github.com/faustedition/faust-gen-html/issues/197)).

## Weitere Regelungen
* BA mit Sprecher (content aus `speaker`) nicht vom ersten Vers trennen (siehe [#304](https://github.com/faustedition/faust-gen-html/issues/304), zum folgenden ebd.).
* ersten Vers einer Replik (sp/l[1]) nicht vom nächsten Absatz trennen
* ersten Vers einer Versgruppe (`lg/l[1]`) nicht vom nächsten Absatz trennen
* letzten Vers einer Replik / einer Versgruppe nicht vom vorletzten trennen
* Reimpaare nicht auseinanderreißen (ausnahmsweise mal nicht kodiert :-) 
* BAs nach Repliken (s.o.) in vielen Fällen nicht vom letzten Vers / Prosa-Absatz der vorhergehenden Replik trennen  

## Feinsatz
* Seitenumbrüche
* Zeilenumbrüche bei Bühnenanweisungen
* optische Mitte der Liedverse