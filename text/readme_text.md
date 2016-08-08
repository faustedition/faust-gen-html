## Work plan

* [ ] define content of `<teiHeader>`
* [ ] import DP's note from DOCX
* [ ] adapt `apply-edits` to the establishment of the reading texts
   * [ ] handle `l/hi/rend=big`
   * keep `choice-sic-corr`, `strip-space` from `choice`
   * keep posthumous revisions as they are

##  Overview of procedures

### XPROC
1. Transform 2 H into Technical Base Text (modified apply-edits, see Work plan).
2. Transform H.0a and C4 (1, 2alpha, 3) into presumptive base texts 
   * keep choice-sic-corr as in (1)

### TXSTEP
1. Transform TBT and C1-4 into base texts for collation (`#ko`)
2. Transform H.0a, C2alpha-4 and C3-4 into comparison texts for collation (`#ko`)
3. Collate TBT and H.0a (`#ve`, `#va`)
4. Correct TBT (`#ka`)
5. Collate C4 (1, alpha, 3) (`#ve`, `#va`)
Collate C4 with variants being stored in one file "diff"

Transform established text into XML
