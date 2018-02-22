Diskussion der Datei Bühnenanweisungen.xlsx 
=============================

# Aufschlüsselungen
BA prom.
* Bühnenanweisung vor dem 1. Vers einer Szene oder Unterszene
* `div/sp[1]/preceding-sibling::*[self::stage or self::speaker]`
* und auch `div/sp[1]/l[1]/preceding-sibling::*[self::stage or self::speaker]`
* mit BA kann auch die Kombination aus `speaker` und `stage` sein, s.o.

BA normal	
* Bühnenanweisung innerhalb einer Szene oder Unterszene
* alle übrigen `speaker` und `stage` (weiß ich keinen XPath-Ausdruck)

A
* Auftritt, siehe idml.md#auftritt

F	
* Figur, siehe idml.md#figur

Sp
* Sprecher (dieses Formats gibt es doch nicht mehr?)

V
* Vers, idml.md#vers

# 1. BA prom. mit A/F vor BA / Sp
(0,0 / 2,3)
* vor 33a (`before_33_b`)
* 243a	
* 2337a	
* 2337b	
* 3205	
* 3544a	
* 4728c	
* 4728d

# 2. BA prom. mit A/F vor V
(0,0 / 0,0)

leer?

# 3. BA prom. ohne A/F vor BA-mit-A
(1,5 / 4,6)

leer?

# 4. BA prom. ohne A/F vor BA-ohne-F
(1,5 / 2,3)
* vor 4728a

# 5. BA prom. ohne A/F vor BA-mit-F / Sp / V
(1,5 / 0,0)
* vor 243b	
* 4728b

# 6. BA normal mit A/F vor BA-mit-A
(2,3 / 4,6)

leer?

# 7. BA normal mit A/F vor BA-ohne-F
(2,3 / 2,3)

leer?

# 8. BA normal mit A/F vor BA-mit-F / Sp / V
(1,5 / 0,0)
XML: `stage[hi and not(matches(@rend,'inline'))][following-sibling::*[1][self::stage[hi] or self::sp or self::l]]` [und außerdem noch 'nichtprominent', XPath-Ausdruck dafür weiß ich nicht]

In Tabelle genannte Beispiele:
* vor 350 [Sonderfall, braucht Individualregel, s.u. [idml.md#bas-vor-350](https://github.com/faustedition/faust-gen-html/blob/master/idml/idml.md#bas-vor-350)]	
* 482 (`before_482i_a`) = BA mit Auftritt, nicht Sprecher (s.o. [idml.md#ba-mit-auftritt-nicht-sprecher](https://github.com/faustedition/faust-gen-html/blob/master/idml/idml.md#ba-mit-auftritt-nicht-sprecher))
* 514 (`before_514_b`+`before_514_b` "Faust zusammenstürzend.") = Sprecherbezeichnung + Bühnenanweisung auf derselben Zeile (s.o. [idml.md#ba-in-replik](https://github.com/faustedition/faust-gen-html/blob/master/idml/idml.md#ba-in-replik), Punkt 1)
* 522 = BA mit Auftritt, nicht Sprecher
* 602 = Sprecherbezeichnung + Bühnenanweisung auf derselben Zeile, Sprecher- zugleich Auftrittsbezeichnung (s.o. [idml.md#ba-in-replik](https://github.com/faustedition/faust-gen-html/blob/master/idml/idml.md#ba-in-replik), Punkt 2)
* 737b	(`before_737_b` "Glockenklang ...") = BA mit Auftritt, nicht Sprecher 
* 2465 (`before_2465_a` "Der Kessel ...") = BA nach Replik mit Figur (s.o. [idml.md#ba-nach-replik-mit-figur](https://github.com/faustedition/faust-gen-html/blob/master/idml/idml.md#ba-nach-replik-mit-figur)) (kein Auftritt!) 	
* 2532 = BA nach Replik mit Figur

Kommentar: Gruppe umfasst Auftritte, die möglicherweise einen größeren (einzeiligen) Abstand nach oben und unten bekommen sollen.

# 9. BA normal ohne A/F vor BA-ohne-F
(0,0 / 2,3)
* vor 737a

# 10. BA normal ohne A/F vor BA-mit-F / Sp / V
(0,0 / 0,0)
XML: `stage[not(hi) and not(matches(@rend,'inline')) and not(preceding-sibling::*[1][self::move])][following-sibling::*[1][self::stage[hi]
or self::sp or self::l]]` [und außerdem noch 'nichtprominent', XPath-Ausdruck dafür weiß ich nicht]

In Tabelle genannte Beispiele:
* vor 429 = zwischen Versen (s.o. [idml.md#ba-in-replik, Punkt 3](https://github.com/faustedition/faust-gen-html/blob/master/idml/idml.md#ba-in-replik))
* 447 = zwischen Versen
* 459 = zwischen Versen
* 514 (`before_514_a`) = BA nach Replik ohne Figur (!) (s.o. [idml.md#ba-nach-replik-ohne-figur](https://github.com/faustedition/faust-gen-html/blob/master/idml/idml.md#ba-nach-replik-ohne-figur))
* 518 = zwischen Versen 
* 602 (`after_601`?) = BA nach Replik ohne Figur (!)  
* 2378 = zwischen Versen
* 2380 = zwischen Versen

Kommentar:
* klare Mitglieder einfacher zu definieren (zwischen Versen)
* 2 fragliche Mitglieder, wo Abstand nach oben sinnvoll sein dürfte (würde bedeuten: Gruppe ist heterogen)
* Abstand 0,0 / 0,0 außerdem auch dann erforderlich, wenn `Figur` vorkommt, aber BA innerhalb einer Replik steht (`stage[hi][ancestor::sp and not(matches(@rend,'inline'))]`) 