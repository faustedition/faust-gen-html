## Work plan
* [ ] import DP's notes from DOCX
* [ ] adapt `apply-edits` to the establishment of the reading texts
   * handle `l/hi/rend=big`
   * keep `choice-sic-corr`, `strip-space` from `choice`
   * keep posthumous revisions as they are
* [ ] define content of `<teiHeader>`

##  Overview of procedures

### XPROC
1. Transform 2 H into Technical Base Text (modified apply-edits, see Work plan).
2. Transform H.0a and C4 (1, 2alpha, 3) into presumptive base texts 
   * keep choice-sic-corr as in (1)

### TXSTEP
...

Transform established text into XML

### XSL
* Normalize white space
