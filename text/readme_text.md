## Work plan

* [ ] define content of `<teiHeader>`
* [ ] import DP's note from DOCX
* [ ] adapt apply-edits to the establishment of the reading texts
   * [ ] handle `l/hi/rend=big`

##  Overview of procedures

### XPROC
1. Transform 2 H into Technical Base Text (modified apply-edits).
   * keep choice-sic-corr, strip space from choice
   * keep posthumous revisions as they are
2. Transform H.0a and C4 (1, 2alpha, 3) into presumptive base texts 
   * keep choice-sic-corr as in (1)

### TXSTEP
1. #ko TBT and C1-4 as base text for #ve
2. #ko H.0a, C2alpha-4 and C3-4 as comparison texts for #ve

Collate C4 with variants being stored in one file "diff"

Transform established text into XML
