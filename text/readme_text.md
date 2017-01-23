## Work plan
###Adapt apply-edits
* [ ] exclude `tei:fw`
* [ ] exclude `tei:lb`, space unless '@break="no"'
* [ ] `l/hi/@rend='big'` → `<xsl:apply-templates mode="#current"/>`
* [x] `strip-space` from `choice`
* [ ] emend steps: keep posthumous revisions as they are (`@ge:stage='#posthumous'`)
* [ ] exclude `tei:creation` (header, contains transposition etc.)
* [ ] define content of `<teiHeader>`

###Notes
* [ ] import DP's notes from DOCX
* [ ] write and insert notes into text files

##  Overview of procedures

### XPROC
1. Transform 2 H into Technical Base Text (modified apply-edits, see Work plan).
2. Transform other witnesses into presumptive base texts 
   * keep choice-sic-corr as in (1)

### TXSTEP
...

Transform established text into XML

### XSL
* Normalize white space
