# Combining Grammars
## A selection of use cases

This document aims to provide a selection of plausible use cases for
combining grammars. “Combining grammars” in this context means
incorporating some or all of one grammar into another by reference.

## Sample grammar

In an effort to make some of the use cases a little more concrete, and
consequently easier to understand, the following simple grammar
*dates.ixml* is introduced:

```
date: day, sep, month, sep, year .
day: -"0"?, digit | ["1"|"2"], digit | "3", ["0"-"1"] .
-digit: ["0"-"9"] .
month:   "Jan" | "Feb" | "Mar" | "Apr" | "May" | "Jun" 
       | "Jul" | "Aug" | "Sep" | "Oct" | "Nov" | "Dec" .
year: "19" | "20", digit, digit .
-sep: -" " .
```

## Use Cases

There is no significance to the order of the use cases that follow.
The presence of a use case here does not represent a committment on
the part of the CG to support that use case. It is possible, likely
even, that the mechanism for combining grammars, if one is eventually
adopted, will support only some of the use cases here.

### INC-BY-REF. Incorporate a grammar by reference

Many small grammars are used in the context of larger grammars.
A format for describing “todo lists”, for example, might include
a due date. An author writing an iXML grammar to parse the todo list
format might like to incorporate *dates.ixml* by reference in order
to parse due dates.

### TRANSITIVE. Combining grammars is transitive

If a grammar “A” is defined by combining it with a grammar “B”, it
should still be able to combine another grammar with “A”. The rules
for combining grammars should support this kind of transitivity as
straightforwardly as practical.

### OVERRIDE-NT. Override a nonterminal

When combinging a grammar, it may be useful to override one or more of
the nonterminals in the grammar being combined. For example, I might
wish to incorporate *dates.ixml* but spell out the month names in full,
or allow them to be spelled in French.

### AVOID-COLLISION. Avoid a collision in nonterminal names

If reuse becomes common, it’s likely that some grammars will define
the same nonterminal names in different ways. A user might, for example,
wish to combine *dates.ixml* into a grammar even though that grammar
has a different, and independent, nonterminal named “day”.

### NT-COMBINE. Define an alternative for a nonterminal

Sometimes, it will be useful if the host grammar can override a nonterminal
(OVERRIDE-NT). Sometimes, it will be useful if the nonterminal can be
brought in without a collision (AVOID-COLLISION).

Another possibility is that the grammar author may want the imported
nonterminal to be taken as an alternative for a nonterminal already
defined in the host grammar.

### RENAME-NT. Rename a nonterminal

A user might wish to combine a grammar with *dates.ixml* but to
(effectively) change the name of the “date” nonterminal. That is, to
arrange for a nonterminal named “prose-date” that matches the
same input as the “date” nonterminal in *dates.ixml*.

### NT-VISIBILITY-EXPORT. Define the visibility of nonterminals

The author of a grammar like *dates.ixml* might wish to limit the
nonterminals visible when it’s combined with other grammars. In other
words, the author might wish to stipulate that the nonterminals
“date”, “year”, “month”, and “day” are exposed, but to keep the
definition of (and perhaps even the existence of) the nonterminals
“digit” and “sep” private.

This is analogous to the way APIs in many programming languages allow
a module author to make explicit commitments about a public API while
keeping implementation details hidden so that they may be changed
without breaking code that uses them.

### NT-VISIBILITY-ACCEPT. Define the visibility of nonterminals

An author importing a grammar like *dates.ixml* might want to
limit the nonterminals that are visible. Pulling all of the (exported)
nonterminals into the host grammar may be undesirable.
