## Work plan
* [ ] adapt `apply-edits` to the establishment of the reading texts
   * exclude `creation`
   * handle `l/hi/rend=big`
   * keep `choice-sic-corr`, `strip-space` from `choice`
   * keep posthumous revisions as they are
* [ ] define content of `<teiHeader>`
* [ ] import DP's notes from DOCX

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
