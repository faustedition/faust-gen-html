% Faust Inline Apparatus – Technical Concept
% Thorsten Vitt
% Summer 2016

The idea of the inline apparatus is to render the base level of the textual transcript (i.e. _before_ any editings), and then visualize the subsequent editings via inline notes in 〈angled brackets〉. This convention has been developed bei Siegfried Scheibe et al. for a printed edition, and we are slightly adopting this for a first visualization of the textual transcription.

### Implementation Overview

The implementation reuses most of the code developed for the reading version of the text (that visualizes the _last_ stage of the text, after applying all editings), however, we obviously skip most of the preprocessing steps that produce the emended XML. Instead, we need visualizations for `<add>`, `<del>`, `<subst>` and the likes that have been edited out by the emendation scripts in the reading version.

### Target visual structure

Simple stuff should look like this:

> Eine <span style="color:grey;">〈</span>einfache <span style="color:grey"><i>erg</i>〉</span> Ergänzung.
> Eine <span style="border-bottom: 1px solid grey;">einfache</span><span style="color:gray">〈<i>tilgt</i>〉</span> Tilgung.

I.e.: 

1. All characters that are not part of the text, but editorial signs and additions are grey.
2. Apparatus aside from the text's base level is delimited by 〈angled brackets〉.
3. Editorial signs and notes apart from brackets are in _italics_.
4. Spans of the base text that are affected by the editorial remark that follows is underlined in grey.

There are some cases that are a little more complex: E.g., restored and nested edits. To make the short but maybe cryptic editorial markup easier to understand, we offer tooltip help for exactly the edit that the user hovers over. This edit is also highlighted on hover.

### Target HTML structure

#### Container: `span.appnote`

Everything that belongs to one apparatus entry is surrounded by a `<span class="appnote">`. This includes both the potential underlined text and the editorial remark. This span's `title` attribute contains the explaining tooltip for the apparatus. Everything that follows is inside this outer span.

#### Affected base text: `span.affected.deleted`, `span.affected.restored`

The part of the base level text that is affected by the current edit is enclosed with a `<span class="affected deleted">` or a `<span class="affected restored">`, depending on whether the text has been deleted or restored. This is always underlined, solid for deleted and dotted for restored stuff. The underline depth depends on the nesting level.

#### Editorial notes and marks: `span.generated-text`, `.app`

Everything that has never been in the original text is marked using `<span class="generated-text">`. This includes marks like the 〈angled brackets〉 as well as notes like _tilgt_. Editorial marks are additionally marked using the `app` class, this will render them in italics.

Note that this _does not_ mean that all text inside 〈·〉 is always gray – in stuff like

> Eine <span style="color:grey;">〈</span>einfache <span style="color:grey"><i>erg</i>〉</span> Ergänzung.

we have original text (although not from the base level) inside the brackets, and this is, like all original text, rendered in the normal text color.

### Highlighting current change

On a _hover_ event, we highlight everything that is affected by the current change. To do so, we add the `current` class to the closest `.appnote` element reachable when moving from the hovered element outward. 

Additionally, we would like to highlight all ‘related’ `.appnote` elements. This includes:

* for transpositions, all parts affected by the transposition
* for `addSpan`/`delSpan`, start and end marker
* for related changes marked with `@ge:stage`, everything with the same value of `@ge:stage`

This is implemented by adding an id and a proprietary `data-also-highlight` attribute to each `.appnote` involved in a common highlighting. The `data-also-highlight` attribute contains the space-separated list of ids of all _other_ elements that need to be highlighted synchronous to the current element.

### Practical guidance
* [#119 (comment)](https://github.com/faustedition/faust-gen-html/issues/119#issuecomment-356986496)
* [dito](https://github.com/faustedition/faust-gen-html/issues/119#issuecomment-357749252)
* [#119 ("Suchmuster")](https://github.com/faustedition/faust-gen-html/issues/119#issuecomment-358938705)