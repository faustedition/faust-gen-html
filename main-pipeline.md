## completely independent stuff

... that does not have to do anything with most of the other tasks

a) archives.xml – create-archives-metadata.xsl → www/data/archives.js
b) xslt/scenes.xml – scene-line-mapping.xsl → www/data/scene_line_mapping.js


## Main pipeline

1. collect-metadata (f:list-transcripts) → faust-transcripts.xml
2. generate-reading-text
    * extra outputs: lesetext/*
3. generate-search: faust-transcripts -> faust-transcripts
    * sorts transcript list via xslt/utils.xsl
    * extra requirements:
        - reading text
    * outputs:
	* `prepared/textTranscript/*.xml` (add-metadata)
	* `search/textTranscript/*.xml`
	* bargraph json. TODO check what is really req's here
4. emended version (needs to be factored out): faust-transcripts -> faust-transcripts
    * outputs:
        * `emended/*`
	* `grundschicht/*` (this could be factored out of the loop)
	* `grundschicht-instant/*` (this could be factored out of the loop)
5. collate-variants.xpl: faust-transcripts -> faust-transcripts
    * extra requirements:
        * `prepared/*`
	* `emended/*`
    * outputs:
	* (`collected-lines.xml`)
	* `www/print/variants/*.html`
6. generate-print.xpl: faust-transcripts ->
    * extra requirements:
        * `emended/*.xml`
	* `www/print/variants/*.html`
    * outputs:
        * `www/print/*.html`

## Sidetracks

Depend on specified step of the main pipeline

a)  generate-app.xpl: faust-transcripts ->
    * depends on: 3. generate-search
    * extra requirements:
        * `prepared/textTranscript/*`
b) pages.json
    * depends on: 3. generate-search
    * extra requirements:
        * `prepared/textTranscript/*`
c) reading-text-applist. Maybe c, d, e, f can be grouped together?
    * depends on: 2. generate-reading-text (or 3., for the few real 'lines' in the app?)
    * extra requirements:
        * `prepared/textTranscript/faust.xml`
    * outputs:
        * lesetext/faust-md.xml
        * `www/print/app.html`
d) reading text apparatus reflist
e) reading text app list by scene
f) reading text word index
g) metadata-html.
    * depends on: 1. (faust-transcripts) (for resolving links!)
h) prints index. 
    * depends on: 1. (faust-transcripts) 
i) testimony
    * depends on: 1. (faust-transcripts)
j) generate-htaccess
l) bibliography
    * depends on: 
         - c) reading-text-md 
	 - g) metadata-html      XXX
	 - i) testimony          XXX
	 * reading-text-citations XXX
	 * (extra stuff from content?)
	 * (extra stuff from macrogenesis?)
m) paralipomena table
    * depends on: 4. emended version (bad, we need paralipomena for macrogenesis!)
n) word index
    * depends on: 4. emended version 
