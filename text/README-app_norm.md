## Aufbau des app_norm.txt-Formats

Das Format beschreibt sowohl die Ersetzungsvorgänge, die auf dem aus den großen Stücken zusammengesetzten Text durchgeführt werden, als auch die Apparateinträge, die daraus erzeugt und in das entstehende faust.xml eingefügt werden.

Jede Zeile beschreibt einen Apparateintrag. Jede Zeile hat grundsätzlich diese Form:

> versnr`[`replace`]{`insert`}` <i>reference</i> lemmapart`]` readings

Eine Zeile, die nicht dieser Form genügt, wird mit dem Fehler _No match_ quittiert und in allen folgenden Verarbeitungsschritten nicht berücksichtigt.

Dabei ist:

__versnr__: 'technische' Bezugszeile für den Eintrag und Apparat
* aus dem `n`-Attribut
* mehrere Werte durch `|` getrennt → gleichviele Werte in _insert_ und _replace_ nötig

__replace__: Zu ersetzender Text / Anker im Text
* _exakt_ wie im Vorstufen-XML (`without-app.xml`)
* kein XML, kein `^`, kein sonstiges Markup möglich
* alternativ besondere Werte:
    * (leere `[]`): nur Apparat in Zeile einfügen, keine Ersetzung/Verankerung im Text
    * `^` oder `$`: Inhalt aus `{insert}`  vor/nach dem benannten Element einfügen
    * `@lg`: Attribute aus `{insert}` in umgebende lg eintragen bzw (`{name=}`) löschen

__insert__: Statt _replace_ einzusetzender Text
* kann wohlgeformtes TEI-Markup enthalten

__reference__: "Menschenlesbare" Versangabe

### lemmapart, reading

Der __lemmapart__ und ein __reading__ folgen grundsätzlich jeweils dieser Form: 

> lesart <i>sigle und notes [type=typnr]</i>

* Es kann mehrere Readings geben, die Aufteilung erfolgt durch den Aufrecht/Kursiv-Wechsel – __ohne lesart muss ein aufrechtes Leerzeichen oder so gesetzt werden!__
* ] muss vorhanden und aufrecht sein, auch wenn es kein Lemma gibt

__lesart__: Darf ein wohlgeformtes TEI-Fragment sein

__sigle und notes__:

Der <i>Text der notes</i> in wird an Leerzeichen zerlegt und jedes Token überprüft, ob es eines der folgenden ist:
* _Sigle_, exakt in der Schreibweise der 'linken' Seite von [sigils.json](http://dev.digital-humanities.de/ci/job/faust-gen-fast/lastSuccessfulBuild/artifact/src/main/xproc/text/sigils.json)
* `:`, steht für letzte Sigle
* _Schreibersigle_, [Liste hier](https://github.com/faustedition/faust-gen-html/blob/master/text/app2xml.py#L163), Auflösung noch nötig
* Abkürzung, #232
