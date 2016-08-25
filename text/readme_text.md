## Work plan
* [ ] import DP's note from DOCX
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
1. Transform TBT and C.1-4 into base texts for collation (`#ko`)
2. Transform H.0a, C.2alpha-4 and C.3-4 into comparison texts for collation (`#ko`)
3. Collate TBT and H.0a (`#ve`, `#va`)
4. Correct TBT (`#ka`)
5. Collate C4 with variants being stored in one file "diff" (1, alpha, 3) (`#ve`, `#va`) 
6. Detect variants that are common to C.2alpha and C.3 (`#ko`)
7. Exclude typographical and other parallel corrections made by the publisher (`#ko`)
8. Add correction based on H.45a but not shared by C.3 (`#ko`?)
9. Transform corrections of X.2 into note-like apparatus entries (`#ko`)
10. Reconstruct X.2 (`#ka`)
11. Collate TBT and X.2 (`#ve`, `#va`)
12. Correct TBT = generate base text (`#ka`)
13. Transform `sic-corr` and posthumous revisions into `note`s (`#ko`)
14. Add notes for occasional emendations (`#ko`)
15. Transform TUSTEP file into XML (`#ko`)

### XSL
* Normalize white space

Transform established text into XML
