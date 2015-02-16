Faust-Edition: Lesetextdarstellung
==================================

Diese Scripte erzeugen die Lesetextdarstellung der Faustedition, in HTML-Form.

Zielarchitektur
---------------

- Ein Ordner ``variants`` enthält HTML-Fragmente mit den Varianten, nach Zeilen gruppiert. In diesem Ordner sind Dateien der Form ``gruppe.html``. Dabei entsteht _gruppe_, indem aus der Zeilenbezeichnung (``n``-Attribut in TEI) die erste Dezimalzahl extrahiert und ganzzahlig durch 10 geteilt wird (``number(replace(@n, '\D*(\d+).*', '$1')) idiv 10``). Beispieldatei:

```html
<?xml version="1.0" encoding="UTF-8"?><div xmlns="http://www.w3.org/1999/xhtml" xmlns:f="http://www.faustedition.net/ns" class="groups" data-group="1211">
   <div class="variants" data-n="12110" data-size="3">
      <div class="variant ann-l linenum-12110 " data-n="12110" data-source="document/archival/bb_cologny/G-30_18.xml">Das Ewig-Weibliche <a class="sigil" href="https://faustedition.uni-wuerzburg.de/new/document/archival/bb_cologny/G-30_18.xml">2 V H.g</a></div>
      <div class="variant ann-l linenum-12110 " data-n="12110" data-source="document/archival/gm_duesseldorf/KK8107.xml">Das Ewig-Weibliche <a class="sigil" href="https://faustedition.uni-wuerzburg.de/new/document/archival/gm_duesseldorf/KK8107.xml">KK 8107</a></div>
      <div class="variant ann-l linenum-12110 " data-n="12110" data-source="document/faust/2/gsa_391098.xml">Das Ewig-Weibliche <a class="sigil" href="https://faustedition.uni-wuerzburg.de/new/document/faust/2/gsa_391098.xml">2 H</a></div>
   </div>
   <div class="variants" data-n="12111" data-size="3">
      <div class="variant ann-l linenum-12111 " data-n="12111" data-source="document/archival/bb_cologny/G-30_18.xml">Zieht uns hinan. <a class="sigil" href="https://faustedition.uni-wuerzburg.de/new/document/archival/bb_cologny/G-30_18.xml">2 V H.g</a></div>
      <div class="variant ann-l linenum-12111 " data-n="12111" data-source="document/archival/gm_duesseldorf/KK8107.xml">Zieht uns hinan. <a class="sigil" href="https://faustedition.uni-wuerzburg.de/new/document/archival/gm_duesseldorf/KK8107.xml">KK 8107</a></div>
      <div class="variant ann-l linenum-12111 " data-n="12111" data-source="document/faust/2/gsa_391098.xml">Zieht uns hinan. <a class="sigil" href="https://faustedition.uni-wuerzburg.de/new/document/faust/2/gsa_391098.xml">2 H</a></div>
   </div>
   <div class="variants" data-n="after_12111" data-size="1">
      <div class="variant ann-trailer linenum-after_12111 " data-n="after_12111" data-source="document/faust/2/gsa_391098.xml">Finis <a class="sigil" href="https://faustedition.uni-wuerzburg.de/new/document/faust/2/gsa_391098.xml">2 H</a></div>
   </div>
</div>
```

- Für jeden Druck gibt es eine (später ggf. mehrere) HTML-Dateien, die die Zeilenbezeichnung in Attributen enthält. Bei Click wird, per onClick-Handler, 
	- evtl. vorhandene Variantendarstellung entsorgt
	- die Variantendarstellung für die entsprechende Zeile per AJAX aus der variants-Datei geladen und eingeblendet

Generierung der Architektur
---------------------------

… wird durch verschiedene Pipelines gesteuert, die nacheinander aufgerufen werden müssen:

1. ``collect-metadata.xpl`` generiert aus dem documents/-Ordner eine einzelne XML-Datei mit den verschiedenen URIs und Siglen der Transkripte.
2. ``collect-lines.xpl`` erzeugt aus dieser Datei und den tatsächlichen Transkripten ``variants/*.html``
3. ``print2html.xpl`` erzeugt aus einer TEI-Datei und den ``variants/*.html`` die Lesetextdarstellung für jene TEI-Datei.
