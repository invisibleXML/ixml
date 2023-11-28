# Converting EBNF to BNF

Invisible XML is defined in terms of an “EBNF” notation. If you want
to implement Invisible XML using a parsing technique that’s only
defined for grammars using a “BNF” notation, you'll need to extend the
algorithm to cover EBNF grammars, or (usually much easier) convert the
Invisible XML EBNF grammar into BNF before parsing.

This document discusses that conversion.

## Background

Notations for context-free grammars are a little like mathematical
notations in that usage varies somewhat in different communities and
different groups. Some variations affect only the choice of
delimiters; others involve larger changes which can make a big
difference in the compactness of the grammar, though the set of
languages they can describe is the same. 

Broadly speaking, most notations for context-free grammars fall into
two groups.

* [Backus-Naur
  Form](https://en.wikipedia.org/wiki/Backus%E2%80%93Naur_form) (or
  BNF) and related notations allow nothing on the right-hand side of a
  production rule but a sequence of symbols, or a top-level choice
  among sequences of symbols.

* [Extended
  Backus-Naur](https://en.wikipedia.org/wiki/Extended_Backus%E2%80%93Naur_form)
  (or EBNF) notations provide a number of syntactic conveniences:
  markings to make nonterminals or subexpressions optional, or
  repeatable, or both, and nested choices. Invisible XML falls into
  this class, and goes beyond some other EBNF notations in also
  providing syntax for textual insertions and for repetition with
  separators.

Most standard parsing algorithms that can be used to implement an
Invisible XML parser are defined for BNF grammars. Unless you want to
extend the algorithm to handle EBNF constructs, you will need to
convert the input grammar supplied by the user into an equivalent BNF
form by eliminating the opeators for repetition, optionality, and
alternation (except at the top level), doing so in such a way that the
BNF grammar you construct accepts the same language as the input
grammar supplied by the user, and in such a way that you can produce
the correct XML representation of the input.

Converting the grammar means replacing EBNF rules that use syntactic
conveniences not present in BNF with different rules that do not use
those conveniences.

The rest of this document explores what it means to rewrite a grammar
and enumerates different rewriting rules that can be used for
Invisible XML. There are many ways to rewrite an EBNF grammar into an
equivalent BNF grammar; any rewriting rules that produce an equivalent
grammar are equally correct, and the choice of rewriting rules is up
to the implementor. However, experience has shown that different
approaches to rewriting Invisible XML grammars may have dramatic
effects on parser performance, so implementors may find it helpful to
experiment with different sets of rewriting rules.

### Examples of converting EBNF to BNF

It will be easiest to describe what we mean by “converting EBNF into
BNF” if we first look at a couple of examples.

Consider this small grammar expressed with the conventions of the
Invisible XML EBNF:

```
S = 'a', 'b'? .
```

An “S” is an “a” followed optionally by a single “b”. The syntactic
shortcut “optionally” (`?`) is not present in BNF. That’s the part we
need to rewrite. We can easily rewrite this rule using only sequences
and choices as follows:

```
S = 'a' | 'a', 'b' .
```

An “S” is an “a” or an “a” followed by a single “b”. That’s a
reformulation of the original rule that matches the same inputs.

Now consider this second example:

```
S = 'a', 'b'* .
```

An “S” is an “a” followed by zero or more “b”s. The syntactic shortcut
“zero or more” (`*`) is also not present in BNF. In order to rewrite
this one, it will be convenient to introduce a new nonterminal symbol.

The name of the new nonterminal can be anything, as long as it isn’t a
name used elsewhere in the grammar. In an Invisible XML context, we
will mark the rule with “`-`” so that it never appears in the
serialization.

```
S = 'a', b-star .
-b-star = 'b', b-star | () .
```

An “S” is a an “a” followed by a “b-star”. A “b-star” is either a “b”
followed by a “b-star” or empty.

Consider how this matches the same inputs as our original:

* `a` => an “a” followed by a “b-star” where the “b-star” is empty.
* `ab` => an “a” followed by a “b-star” where the “b-star” is a “b”
  followed by a “b-star” where the (second) “b-star” is empty.
* `abb` => an “a” followed by a “b-star” where the “b-star” is a “b”
  followed by a “b-star” where the (second) “b-star” is a “b” followed
  by a “b-star” where the (third) “b-star” is empty.
* And so on.

Note that in this case, the new nonterminal isn’t strictly
necessary. The following BNF grammar accepts the same inputs as the
original:

```
S = ('a' | -S), 'b' .
```

To ensure that an iXML processor can produce the required XML output
from a rewritten grammar, it is helpful to adopt some general
principles in our rewrites:

* Every nonterminal in the input grammar will reappear in the
  rewritten grammar and matches the same input strings. (Exception: if
  the nonterminal is marked hidden, this principle can be fudged.  But
  most peoplf find it less confusing to follow it anyway.)
  
* It is often helpful to add new nonterminals as part of rewriting the
  grammar, often (as in the example above) adding a nonterminal to
  replace exactly one `repeat0` or `repeat1` construct in the input
  grammar.
  
* Every nonterminal added in the rewritten grammar will be marked
  hidden. (Since the new nonterminal does not appear in the input
  grammar, it can never produce an element or attribute in the XML
  output of a correct processor.)

The first example above, rewriting optionality, didn’t introduce a new
nonterminal because that example was simpler to explain without doing
so. However, in practice, the factor that is optional may be an
expression in parenthesis that’s much more complicated than just “b”.
We could have rewritten it using a new nonterminal as shown here:

```
S = 'a' | 'a', b-option .
-b-option = 'b' | () .
```

That formulation is simpler to apply in the general case.

## Rewriting Invisible XML

Invisible XML has several syntactic conventions that are not present
in BNF:

* Optionality, `?`
* Zero or more, `*`
* One or more, `+`
* Zero or more with a separator, `**`
* One or more with a separator, `++`
* Nested choices.

A translation into BNF will need to find rewrite rules for each of
these.

Note that in many cases, the order of the rewrites is significant. If
zero-or-more is rewritten in terms of optionality, for example, it is
important to rewrite zero-or-more first, or else multiple passes over
the set of rules will be required.

In preparing the lists of rewrite rules given below, rules have been
gathered from several sources:

  * The rules given in the Invisible XML specification in January
    2021.

    Concretely:  rules O2a, S1a, P1a, SS1a, PP1a.
    
  * The rules given in the Invisible XML 1.0 specification: 02a, S2a, P2a, 
  
  * Some variations on those rules suggested by membes of the ixml
    community group, notably S1a, S2a, P3a
    
  * An EBNF-to-BNF translation in the Gingersnap tools for working
    with ixml grammars (used in generating test cases):  O2b, S4b, P4aw
    
  * Pete Jinks, "BNF/EBNF variants) (web page at
    http://www.cs.man.ac.uk/~pjj/bnf/ebnf.html).  Jenks does not
    explicitly discuss translation into BNF but supplies descriptions
    of ways to handle optionality and repetition in BNF which can be
    taken as implicitly defining rules for that translation.

    Concretely, his examples show applications of rules 01a, S1b, Pa
    
  * Niklaus Wirth's 1997 article "What can we do about the unnecessary
    diversity of notation for syntactic definitions?" CACM (1977)
    20.11:822f.  Wirth does not discuss rules translation into BNF but
    his glosses on constructs in his proposed EBNF can be taken as
    impliclitly defining such rules.

In the discussion below, we illustrate the rewrite rules by
translating ixml grammars and fragments into ixml grammars which have
no occurrences of any of the non-BNF constructs listed above.  In some
rule sets, including that given in the 1.0 spec for ixml, the rewrite
rules use other non-BNF operators which must then be eliminated by
further rewrite steps

## Rewrite rules for non-BNF constructs

### Translating optionality (`?`)

Consider the following grammar fragment:
```
S = A, B?, C.
```
The definitions of `A`, `B`, and `C` are immaterial and are not
considered here.

The fragment can be translated into BNF in any of the following ways.
We give the rules labels for later reference.

(O1a) Inline, by duplicating the context:
```
S = A, B, C
  | A, C.
```

(O1b) Also inline, but with the expansion in the other order.
```
S = A, C
  | A, B, C.
```

(O2a) With the help of an ancillary nonterminal.
```
S = A, opt-B, C.
opt-B = B; ().
```

Note: Here and elsewhere, we assume that names beging `opt-` and
similar do not collide with any nonterminals already present in the
grammar.

(O2b) The same, but with the empty sequence first.
```
S = A, opt-B, C.
opt-B = (); B.
```

(O3a) With an ancillary nonterminal that covers not just the optional
expression but the rest of the sequence in which it appears:
```
S = A, x-BC.
x-BC = B, C; C.
```

(O3b) The same in the other order.
```
S = A, x-BC.
x-BC = C; B, C.
```

(O4a) Rewriting in place with a nested choice.
```
S = A, (B | ()), C.
```

(O4b) Rewriting with the empty sequence first.
```
S = A, (() | B), C.
```

In case O4a or O4b, of course, the nested choice must later be
removed, producing in the end the same effect as one of the other
rewrites.

    
### Translating `repeat0` (`*`)

EBNF grammar:
```
S = A, B*, C.
```

Rewrite rules:

(S1a) Rewrite with an ancillary nonterminal.
```
S = A, star-B, C.
star-B = B, star-B | ().
```

This pattern has several variants which differ in the order of
components in The rule for `star-B`.

(S1b) `star-B = () | B, star-B.`

(S1c) `star-B = star-B, B | ().`

(S1d) `star-B = () | star-B, B.`

(S2a) Rewrite right-recursively, with optionality.
```
star-B = (B, star-B)?.
```

(S2b) `star-B = (star-B, B)?.

The new optional expression must be rewritten in any of the ways
illustrated above.

(S3a) Rewrite as optional `repeat0`.
```
star-B = B+ | ().
```

(S3b) `star-B = () | B+.`

(S4a) Rewrite inline and also add new nonterminal.
```
S = A, (B, more-B | ()), C.
more-B = B, more-B | ().
```
The same variations in order apply as for S1:

(S4b) ... `() | B, more-B` ...

(S4c) ... `more-B, B | ()` ...

(S4d) ... `() | more-B, B)` ...

It may be noted that one common interpretation of `B*` is as an
infinite disjunction: `() | B | B, B | B, B, B | ...`.  Unlike the
rewrites mentioned above, this produces a raw parse tree with
arbitrarily wide fanout from the parent; that is in effect the
behavior of the recursive descent parser described by Wirth in his
books on compilers.  It is also the form produced by a two-level van
Wijngaarden grammar of the form sketched below.

```
B_STAR :: EMPTY ; b B_STAR.
...
s: a, bs, c.
bs: B_STAR.
...
```

However, standard BNF parsing algorithms are no better able to handle
infinite grammars than they are to handle EBNF in the first place, so
infinite disjunctions are not really an option for the task of
translating into BNF.


### Translating `repeat1` (`+`)

Sample EBNF:
```
S = A, B+, C.
```

Rewrites:

(P1a) Rewrite with two ancillary nonterminals.

```
S = A, plus-B, C.
plus-B = B, opt-plus-B.
opt-plus-B = plus-B | ().
```

As with other rewrite rules above, the order of items on the
right-hand sides of `plus-B` and `opt-plus-B` can be reversed, so
there are three other variants:

(P1b) `plus-B = B, opt-plus-B.  opt-plus-B = () | plus-B.`

(P1c) `plus-B = opt-plus-B, B.  opt-plus-B = plus-B | ().`

(P1d) `plus-B = opt-plus-B, B.  opt-plus-B = () | plus-B.`

(P2a) Rewrite using `repeat0`.

```
plus-B = B, B*.
```

(P2b) `plus-B = B*, B.`

(P3a) Rewrite with a single ancillary nonterminal.

```
plus-B = B | B, B-plus.
```

(P3b) `plus-B = B | B-plus, B.`

(P3c) `plus-B = B, B-plus | B.`

(P3d) `plus-B = B-plus, B | B.`

(P4aw) Rewrite in place as well as with ancillary nonterminal.

```
S = A, (B | B, B, more-B), C.
more-B = () | B, more-B.
```

There are six variations of the inline rewrite:
  - (a) `B | B, B, more-B`
  - (b) `B | B, more-B, B`
  - (c) `B | more-B, B, B`
  - (d) `B, B, more-B | B`
  - (e) `B, more-B, B | B`
  - (f) `more-B, B, B | B`

And there are four variations in the definition of `more-B`:
  - (w) `() | B, more-B`
  - (x) `() | more-B, B`
  - (y) `B, more-B | ()`
  - (z) `B, more-B | ()`



### Translating `repeat0` with separator (`**`)

EBNF grammar fragment:
```
S = A, (B**C), D.
```

Rewrites:

(SS1a) Rewrite with three ancillary nonterminals.
```
S = A, sstar-BC, D.
sstar-BC = pplus-BC | ().
pplus-BC = B, sep-CB.
sep-CB = C, pplus-BC | ().
```

The disjunctions in `sstar-BC` and `sep-CB` can be re-ordered, giving
three variants of this rewrite rule.

(SS2) Rewrite inline using `?` and `++`.

```
S = A, (B++C)?, D.
```

(SS3) Rewrite inline using choice and `++`.

```
S = A, (B++C | ()), D.
```

(SS4) Rewrite with ancillary nonterminal using `?` and `++`.

```
S = A, sstar-BC, D.
sstar-BC = (B++C)?.
```

(SS5) Rewrite with ancillary nonterminal using choice and `++`.

```
S = A, sstar-BC, D.
sstar-BC = B++C | ().
```

Depending on how `?` and `++` are rewritten, (SS2) through (SS5) may
end up producing the same result as (SS1) (modulo variations in
order of sequences and disjuncts).

(SS6a) Rewrite using two ancillary nonterminals.
```
S = A, sstar-BC, D.
sstar-BC = () | B, more-CB.
more-CB = () | C, B, more-CB.
```
Order variants are of course also possible.

(SS7a) Rewrite inline and using a single ancillary nonterminal.
```
S = A, (() | B, more-CB), D.
more-CB = () | C, B, more-CB.
```
Again, order variants are possible.


### Translating `repeat1` with separator (`++`)

Starting EBNF:
```
S = A, B++C, D.
```

Rewrites:

(PP1a) Rewrite with two ancillary nonterminals.
```
S = A, pplus-BC, D.
-pplus-BC = B, sep-CB.
-sep-CB = C, pplus-BC | ().
```

The disjunction in `sep-CB` can be re-ordered.

(PP2) Rewrite inline using and `*`.

```
S = A, B, (C, B)*, D.
```

It may be noted that this is the idiom usually adopted by Wirth for
repetitions with separators.

(PP3) Rewrite using two ancillary nonterminals.
This differs from (PP1) in the recursion pattern.

```
S = A, pplus-BC, D.
-pplus-BC = B, more-CB.
-more-CB = () | C, B, more-CB.
```

(PP4) Like PP3, but expand `pplus-BC` inline.

```
S = A, B, more-CB, D.
-more-CB = () | C, B, more-CB.
```

(PP5) Rewrite inline using a nested choice.
```
S = A, (B | B, C, B, more-CB), D.
-more-CB = () | C, B, more-CB.
```


### Translating nested choices

Starting EBNF:
```
S = A, (B | C | D), E.
```

Rewrites:

(C1) Rewrite inline by pushing disjunction outwards.
```
S = A, B, E
  | A, C, E
  | A, D, E.
```

(C2) Rewrite using ancillary nonterminal.

```
S = A, choice-BCD, E.
-choice-BCD = B | C | D.
```










## Some defining properties

Many though not all of the rewrite rules just given vary in a few
systematic ways:

- They may rewrite the expression inline or use an ancillary
  nonterminal (or more than one), or both.
  
- When the rewrite rule introduces a choice between the empty sequence
  `()` and something else, the empty sequence may be written on the
  left or on the right.

- When the rewrite rule uses directly or indirectly recursive rules to
  handle repetition, those rules may be left- or right-recursive.

- Some rewrite rules avoid writing the same base expression (`B` in 
  all the examples above) more than once; others do not avoid this.
  
  Similarly (and possibly related) some rewrite rules introduce
  disjunctions in which multiple disjucts have the same prefix
  (as in `plus-B = B | B, plus-B.`); other rewrite rules avoid this.

These variations suggest a sort of multi-dimensional space in which
the rewrite rules given above may be located, and within which other
rules might be searched for.  (And indeed, many of the variants given
above are generated by attempting to vary things like order and the
use of inline rewriting vs ancillary nonterminals.)


## Concluding remarks

Some implementors report that the performance of Earley parsers may
vary significantly with different choices of rewrite rules.  In
particular, the use of S3a, P3a, and SS3 has been reported to be
helpful. Others report no effect, or more modest effects.  And the
effect of the rewrite rules on the performance of other parsers is not
currently well understood.

In the meantime, implementors may find it helpful to experiment with
different sets of rewriting rules to find rules that are easily seen
to be correct and that have good performance characteristics.
