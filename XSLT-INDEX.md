## Stylesheet Overview

### TEI massage

### TEI to HTML transformation

#### [apparatus.xsl](apparatus.xsl)

* __entry point__ for generating the Einblendungsapparat
* transforms TEI that is lightly preprocessed
* contains rendering rules for edits etc: `addSpan` `add` `alt` `delSpan` `del` `ge:transpose/ptr` `restore` `subst` 

#### [print2html.xsl](print2html.xsl)

* __entry point__ for rendering the versions of the text that will have the variant apparatus
* transforms TEI that is fully preprocessed to the last edit step
* rules for lines with canonical numbering, and `alt`

#### [variant-fragments.xsl](variant-fragments.xsl)

* __entry point__ for creating the HTML fragment that make up the variant apparatus
* works on the master collections of all TEI lines with canonical numbering that is processed by extract-lines.xsl 
* rules for lines with canonical numbering
* creates apparatus, and sigil links

##### [html-common.xsl](html-common.xsl)

* included in all three HTML transformation scenarios
* contains rules for elements that are treated alike in all cases
* rules for `app` `choice` `choice|app` `corr` `figure` `fw` `gap` `lb` `pb` `space` `supplied` `unclear`

##### [split.xsl](split.xsl)

* included in `print2html.xsl` and `apparatus.xsl`
* contains rules to split a large-ish TEI file to several HTML files, including navigation and table of contents
* rules for `/TEI` `div` `lb`

##### [utils.xsl](utils.xsl)

* included in almost everything
* contains functions used globally
* contains code to calculate the global HTML classes, the HTML tag name, and local styles


##### [html-frame.xsl](html-frame.xsl)
* template rules to generate the edition specific headers and footers

####[index.xsl](index.xsl)
* __entry point__ that generates the (internal) lists of transcripts etc.
* works on a transcript list like produced by `collect-metadata.xpl`

### TEI preprocessing

1. [harmonize-antilabes.xsl](harmonize-antilabes.xsl) converts antilabes created using `<join type="antilabe">` into the form using `part="I|M|F"` attributes. The TEI to HTML stylesheets only deal with that one.
2. [textTranscr_pre_transpose.xsl](textTranscr_pre_transpose.xsl) converts the `ptr`s inside `ge:transpose` that contain multiple target in one pointer to multiple pointers with one target each. This is required for both textTranscr_transpose.xsl and apparatus.xsl. 
3. [textTranscr_transpose.xsl](textTranscr_transpose.xsl) applies transpositions by reordering elements referenced inside a `ge:transpose` group into the order in which they appear in the `ge:transpose`.
4. [textTranscr_fuer_Drucke.xsl](textTranscr_fuer_Drucke.xsl) contains most of the other rules that create the last step of a text, with all the edits applied. Here we have rules for `del` `ex` `expan` `facsimile` `g` `node()` `note` `subst` `restore` `s` `seg` `subst/add/del` `subst/del/restore` `subst`
5. [text-emend.xsl](text-emend.xsl) (mainly by Wendell Piez) removes text within `delSpan` covered areas.
6. [clean-up.xsl](clean-up.xsl) removes elements that have been left blank by `text-emend.xsl`.
7. [prose-to-lines.xsl](prose-to-lines.xsl) converts code using canonical line numbers, but encoded as prose with `<milestone type="refline"/>` to the same `<l>` based form used for the verse parts. While not being philologically correct, this allows to deal with this kind of structure in the same way as with real verse text.
8. [resolve-pb.xsl](resolve-pb.xsl) tries to augment the `<pb/>`s in a TEI file with a `f:docTranscriptNo` attribute containing the consecutive page number used in the edition's web app. It takes that information from the metadata files, so these must be present.

### Other Stylesheets

* [extract-lines.xsl](extract-lines.xsl) takes a TEI file and extracts those elements that will be the base of the variant apparatus. Each of these elements (we call them _lines_) will be augmented with some provenance attributes. The concatenated result of running tis stylesheet on all textual transcripts forms the input of `variant-fragments.xsl`.
* [pagemap.xsl](pagemap.xsl) collects page information from a transcript that has run through `resolve-pb.xsl`. This information is then collected for all files and converted to a compact JSON format by [pagelist2json.xsl](pagelist2json.xsl). The result can be used by the webapp to load the correct text file for a given page number.

### Auxilliary stuff – not required for text generation

* [sigil-list.xsl](sigil-list.xsl) collects information regarding the preferred sigils from the output of `collect-metadata.xpl`. Use this to see the preferred and alternative signatures and to detect duplicates.
* [transcript2csv.xsl](transcript2csv.xsl) converts the `collect-metadata.xpl` output to a simple CSV.
