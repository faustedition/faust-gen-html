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

## Apparat
XML: `note type="textcrit"`.

Output: Fußnotenartiges Konstrukt ohne Anmerkungsziffer.

## (BA)

### (allgemeines)

Die für die `BA`-Formate relevanten XML-Elemente sind `speaker` (gut 2100 Vorkommen) und `stage` (gut 700).

Nicht aus jedem `speaker` oder `stage`-Element ergibt sich ein Absatz des Formats `BA ...`.

Deswegen lautet die Frage abgewandelt: Haben wir hier _eine_ BA oder _zwei_ BAs?

Oft ergibt sich ein `BA ...`-Absatz aus der Kombination aus beiden.
Nämlich dann, wenn Sprecherbezeichnung (`speaker`) und eine Bühnenanweisung zusammen in derselben Zeile stehen:
* bezogen auf die `stage`: `stage[matches(@rend, 'inline')]`
* bezogen auf den `speaker`: `speaker[following-sibling::*[1][self::stage[matches(@rend,'inline')]]]`
Bsp.:
    <speaker n="before_482f_a">Faust</speaker>
    <stage n="before_482f_b" rend="inline small">abgewendet.</stage>
In allen derartigen Fällen (gut 170 Vorkommen) steht eine Bühnenanweisung in derselben Zeile mit der Sprecherbezeichnung.

### (Länge)
Je nach Länge werden BAs unterschiedlich behandelt:
* `BA zentr.` (für zentriert)
* `BA Blocks.` (für Blocksatz)

Lange BA (ab drei Zeilen im Outputba mit ) stehen im Blocksatz mit linksbündiger letzter Zeile. Als ungefähre Heuristik wird eine Zahl von Zeichen genommen, ab der mit hoher Wahrscheinlichkeit im Umbruch mehr als drei Zeilen entstehen. 
Momentane Heuristik: 210 Zeichen als Richtwert, der zur Zuweisung von `BA Blocks. ...` führt.
(Könnte sich evtl. verschieben in Abhängigkeit von [#209](https://github.com/faustedition/faust-gen-html/issues/209)!).

### (Abstände)
Die Krux bei der Formatzuweisung liegt in den Abständen.
Entscheidend für die Zuweisung der richtigen Abstände ist zweierlei:
* Was enthält die BA? (Figur, Auftritt)
* In welche Kontext steht die BA?

Hier gibt es noch Abstimmungsbedarf ([#298](https://github.com/faustedition/faust-gen-html/issues/298)).

Bemerkungen zu @markusciupke|s Vorschlag stehen auf einer [eigenen Seite](https://github.com/faustedition/faust-gen-html/blob/master/idml/ba-diskussion.md).

Die folgende XML-basierte Typeneinteilung beruht auf den Formaten vom Stand vor 13.2.18.

### (BA unterschieden nach Kontext und Inhalt)
Momentan sind es gut 700 `stage`-Elemente, die Mehrheit davon (gut 460) innerhalb von Repliken.

#### (BA **in** Replik)
* Kombination von Sprecherbezeichnung und Bühnenanweisung auf derselben Zeile (`speaker/following-sibling::*[1][self::stage and @rend[contains(.,'inline')]]`)
  * → BA zentr. 1,5
* dasselbe, dabei Sprecher- zugleich Auftrittsbezeichnung  (`move/following-sibling::*[1][self::sp]/speaker/following-sibling::*[1][self::stage and @rend[contains(.,'inline')]]`)
  * → BA zentr. **evtl. mit ganzzeiligem Abstand nach oben**
* direkt nach Sprecherbezeichnung auf eigener Zeile (`speaker/following-sibling::*[1][self::stage and not(@rend[contains(.,'inline')])]`)
  * → BA zentr. 0,0
* BA auf eigener Zeile, nach Kombination von Sprecherbezeichnung und Bühnenanweisung auf derselben Zeile (`//speaker/following-sibling::*[1][self::stage and matches(@rend,'inline')]/following-sibling::*[1][self::stage]`)
  * → BA zentr. 0,0  
* zwischen Versen ohne Figur (`stage[not(hi)][preceding-sibling::*[1][self::l] and following-sibling::*[1][self::l]]`)
  * Bspp.: `before_430` "Er schlägt ...", `before_447` "Er beschaut ..."   
  * → BA zentr. 0,0
* zwischen Versen mit Figur (`stage[hi][preceding-sibling::*[1][self::l] and following-sibling::*[1][self::l]]`) 
* zwischen Versgruppen (`stage[preceding-sibling::*[1][self::lg] and following-sibling::*[1][self::lg]]`)
  * → BA Abstand
* am Ende von Repliken (`sp/*[self::stage and position()=last()]`)
  * kommt regulär nicht vor 

#### (BA im Anschluss an Replik, ohne Figur)
z.B. 
* `before_514_a` "Verschwindet."
* `before_4666_a` "Ungeheures Getöse ..."
* Auch `before_4412` "er ergreift ... Es singt inwendig", worauf keine Sprecherbezeichnung folgt, wird nach demselben allgemeinen Prinzip behandelt.

XML: `sp/following-sibling::*[1][self::stage[not(hi)]]`.

→ `BA zentr. ...`, abhängig von [#299](https://github.com/faustedition/faust-gen-html/issues/299) 

→ (bei entsprechender Länge) `BA Blocks. ...` 

#### (BA nach Replik, mit Figur)
(Quasi-Replik)
z.B.
* `before_993_a` "Das Volk ..."

XML: `stage[hi and preceding-sibling::*[1][self::sp] and following-sibling::*[1][self::sp or self::move[following-sibling::*[1][self::sp]]]]`.

→ `BA zentr. 1,5`

→ (bei entsprechender Länge) `BA Blocks. 1,5` 

#### (freie BA, ohne Figur)
(z.B. `before_7040_a` "Die Luftfahrer oben", oft auch vor der ersten Replik)

XML: `stage[not(ancestor::sp) and not(hi) and not(preceding-sibling::*[1][self::sp or self::move or self::head])]`

Format: `C BA zentr. 2,3 / 0,0`

#### (BA nach Überschrift, kein Auftritt)
(Bsp.: `before_4613_f` "Faust auf blumigen ...")

XML: `//head/following-sibling::*[1][self::stage]`.

→ `BA zentr. 0,0` oder (bei entsprechender Länge) `BA Blocks. 0,0`.

Generelle Andersbehandlung von BA nach Überschriften ist fragwürdig, da weitere BAs direkt nachfolgen können.

#### (BA mit Auftritt, nicht zugleich Sprecher)
* `before_354_c`
* `before_482i_a`
* `before_522_a`
* `before_2337_b`
* nicht `before_2465_a`

XML: `move/following-sibling::*[1][self::stage]`

Priority: niedriger als die rule für BA mit Auftritt nach Überschrift ...

Format: `C BA zentr. 2,3 / 0,0`

#### (BA mit Auftritt nach Überschrift, nicht zugleich Sprecher)

XML: `head/following-sibling::*[1][self::move]/following-sibling::*[1][self::stage]`

→ `BA zentr. 0,0 / ?? unten` (`??` = Abstand nach unten, der zum normalen Replikenabstand hinzukommt)

#### (BA mit Auftritt, nicht Sprecher **nach** BA mit Auftritt, nicht Sprecher) 
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

#### BA Blocks. 0,0

#### BA Blocks. 1,5

#### BA Abstand
(für BA zwischen Versgruppen)

Zuweisungsprinzip s.o. [(BA in Replik)](https://github.com/faustedition/faust-gen-html/blob/master/idml/idml.md#ba-in-replik), Punkt 5.

Abstand nach oben wie `Vers Abstand`.

## Bandtitel
XML: `title`.

Output: einfach zentrierte Absätze o.ä., nach dem letzten `title` ein Seitenumbruch. 

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
(die mit `Sprecher` beginnenden Absatzformate werden voraussichtlich in `BA ...` aufgelöst)

### Sprecher 0,5
(entfällt, siehe [#203](https://github.com/faustedition/faust-gen-html/issues/203))

### Sprecher 1,5
(normale reine Sprecher, d.h. nicht zugleich Auftrittsbezeichnung und nicht mit BA in einer Zeile) 

XML:
```
speaker[
not(parent::sp/preceding-sibling::*[1][self::move])
and not(following-sibling::*[1][self::stage and matches(@rend,'inline')])
]
``` 

## (Überschriften)
Bei `head/lb` wird innerhalb des betreffenden Absatzes ein Zeilenumbruch eingefügt.

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

XML: `div/div[@type='scene' and not(@f:n='1.1.22')]/*[1][self::head]`

Formatierung: 
* neue Seite (kann auch eine linke sein)
* 3 Zeilenumbrüche am Anfang des Absatzes

### Szene nach Akt
(Szenenüberschrift nach Aktüberschrift)

XML: `div[@type='act']/div[@type='scene' and position()=(1)]/head[1]`

Formatierung: 
* *keine* neue Seite
* *keine* 3 Zeilenumbrüche am Anfang des Absatzes

### Szenenunter

XML: `div[@type='scene']/head[2]` (sollte auch ein `type="sub"` tragen)

### Unterszene
XML: `div[@type='subscene']/*[1][self::head]`

### Unterszene nach Szene
(Unterszenenüberschrift nach Szenenüberschrift)

XML:
* `head[@n='before_4728_b']` 
*  `head[matches(@n,'before_7005_b')]`

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

#### Weiter eingerückte Verse
An einer Stelle werden Verse weiter eingerückt als die vorherigen eingerückten Verse.

XML: `lg[@rend='indented']/l[@rend='indented']`

Umsetzung: 
>  linksbündigen Tab ... auf 28 mm

([#337, comment](https://github.com/faustedition/faust-gen-html/issues/337#issuecomment-372939872))

### Vers Einrückung Abstand
`lg[@rend='indented' and preceding-sibling::lg]/*[1][self::l]`

Priority: siehe `Vers Einrückung`.

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

## Individualregeln für BAs

### (BAs vor 350)
XML: `stage before_350_a` ("Der Himmel schließt, ...").

--> `BA zentr. 1,5` (ausnahmsweise Replikenabstand nach oben)

XML: `before_350_b` zusammen mit `before_350_c` ("Mephistopheles allein.", standardmäßig kombiniert wg. `inline`)
--> `BA zentr. 0,0` (ausnahmsweise keinen Replikenabstand nach oben, da Einheit mit vorhergehender BA).

Der Grund ist, dass die XML-Auszeichnung die Struktur des Textes hier nicht voll adäquat abbildet.

Alternativ können auch `before_350_b`+`before_350_c` zusammen mit `stage before_350_a` in einen BA-Absatz genommen werden mit Zeilenumbruch nach dem Inhalt von `stage before_350_a` (je nachdem, was für @pglatza einfacher ist).

### (BA vor 949)
XML: `before_949_c`.

Umsetzung: entweder etwas sperren oder etwas Abstand davor und danach.

### (BAs vor 2284)
Betrifft:
* `before_2284_a` ("Nachdem die Löcher ... sind,")
* `before_2284_b` + `before_2284_c` (da mit `inline`)

Umsetzung genau analog zu [BAs vor 350](https://github.com/faustedition/faust-gen-html/blob/master/idml/idml.md#bas-vor-350).

### (BAs zu "Innerer Burghof" und "Schattiger Hain")
Dies sind eigentlich normale BAs in Anschluss an Repliken.
Für die Kolumnentitel wurden aber `div`s eingefügt, deren erste Kind-Elemente die BAs sind.

XML: `div[@n='2.3']/div/*[1][self::stage]`

Format: `F BA zentr. 1,15 / 0,0`

## Szene (Finis)
(entfällt vorläufig)
Bedeutet, dass Finis wie Szene behandelt wird.

## Szene nach Teil (Nacht)
= neue rechte Seite (Leerseite nach Teiltitel)

## Walpurgisnachtstraum

### (WNT-Titel)
XML: `head[@n="before_4223_a"]/hi[1]`.

### Zwischenzeile (WNT)
(für das "oder")

XML: `head[@n="before_4223_a"]/hi[2][text()[contains(.,'oder')]]`.

### Szene nach Zwischenzeile (WNT)
für "Oberons ..."

### (Sprecher nach WNT-Titel)

## Titel (Faust)
XML: `titlePart[@n='before_1_a']`.

## Untertitel (Eine Tragödie)
XML: `titlePart[@n='before_1_b']`.

Formatierung: am Anfang des Absatzes 7 Zeilenumbrüche einfügen.

## Vers nach Teil (Zueignung)
XML: `l[@n='1']`

Umsetzung:
* Seitenwechsel (neue rechte Seite)
* 3 Zeilenumbrüche am Anfang des Absatzes

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

### (Zeichenformate mit Sperrung)
* Auftritt
* Doppelunterstreichung
* Figur
* Sperrung
* Sprecher
* (veraltet: Sprecher gesperrt)

Allgemeine Regeln zur Umsetzung:
* Umgebende Leerzeichen werden mitgesperrt (#321).
* todo: Interpunktion ([#321 (comment)](https://github.com/faustedition/faust-gen-html/issues/321#issuecomment-372240044))

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

## NN (Bibelstelle in Zeile)
(jetzt: "Bibelstelle")

## NN (Bibelstelle eigene Zeile)
(zeitweise als Absatzformat vorgesehen; entfallen, siehe "Bibelstelle")

Die Differenzierung zwischen `@rend='inline'`-Bibelstellen und denen auf eigener Zeile wurde aufgegeben.

## Doppelunterstreichung
(individuelle Vorkommen im Faust II, siehe [xml/issues/66](https://github.com/faustedition/xml/issues/66)) 

XML: `*[self::hi or self::stage or self::speaker]/emph`.

Formatierung: vorläufig wie `Auftritt`.

## Figur
(Hervorhebungen in BA) 

XML: `stage/hi`, `speaker`

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
Vermutlich überholt; siehe oben unter [(Apparateinträge)](https://github.com/faustedition/faust-gen-html/blob/master/idml/idml.md#apparateintr%C3%A4ge).

## (Antiqua / lateinisch)
(= Antiqua und lateinische Schrift in Versen, Sprechern, BA und Finis)

XML: `*[@rend="antiqua" or @rend="latin"]`.

Nicht durchgängig so kodiert, keine Umsetzung vorgesehen.

## Sperrung
XML: `l/emph`.

## Sprecher
XML-Pattern:
* `speaker[not(hi)]`
* `speaker/hi`

Merke: Das Zeichenformat `Sprecher` kommt vor  
* im Absatzformat `Sprecher`
* in den Absatzformaten `BA ...`

Formatierung:
* Zeichenformat `Sprecher`: Versalien, 8,5 pt, Laufweite +25 (Sperrung).
* Zeichenformat `[No character style]` im Absatzformat `Sprecher` (`//speaker[hi]/text()`): normale Schriftgröße (nicht verkleinert) (siehe [#293](https://github.com/faustedition/faust-gen-html/issues/293))

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

# Weitere Regelungen
* BA mit Sprecher (content aus `speaker`) nicht vom ersten Vers trennen (siehe [#304](https://github.com/faustedition/faust-gen-html/issues/304), zum folgenden ebd.).
* ersten Vers einer Replik (sp/l[1]) nicht vom nächsten Absatz trennen
* ersten Vers einer Versgruppe (`lg/l[1]`) nicht vom nächsten Absatz trennen
* letzten Vers einer Replik / einer Versgruppe nicht vom vorletzten trennen
* Reimpaare nicht auseinanderreißen (ausnahmsweise mal nicht kodiert :-) 
* BAs nach Repliken (s.o.) in vielen Fällen nicht vom letzten Vers / Prosa-Absatz der vorhergehenden Replik trennen  

# Feinsatz
* Seitenumbrüche
* Einfügen von Leerzeilen (wo?)
* Zeilenumbrüche bei Bühnenanweisungen
* optische Mitte der Liedverse
* Einrichtung der Szene "Trüber Tag. Feld" (verkleinerter Satzspiegel?)
