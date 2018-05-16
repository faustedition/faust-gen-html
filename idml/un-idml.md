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

## Vers nach Teil (Zueignung)
XML: `l[@n='1']`

Umsetzung:
* Seitenwechsel (neue rechte Seite)
* 3 Zeilenumbrüche am Anfang des Absatzes