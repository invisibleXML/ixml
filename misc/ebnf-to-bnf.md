# Converting EBNF to BNF

Invisible XML is defined in terms of an “EBNF” notation. If you want
to implement Invisible XML using a parsing technique that’s only
defined for grammars using a “BNF” notation, you have to convert the
Invisible XML EBNF grammar into BNF.

## Background

Notations for context-free grammars are a little like mathematical
notations in that usage varies somewhat in different communities and
different groups. Some variations affect only the choice of
delimiters; others involve larger changes which can make a big
difference in the compactness of the grammar, though the set of
languages they can describe is the same. Some variations increase the
expressive power of the notation, but then the languages they can
describe are no longer always context-free.

Broadly speaking, most notations for context-free grammars fall into
two groups.

* [Backus-Naur Form](https://en.wikipedia.org/wiki/Backus%E2%80%93Naur_form) (or
  BNF) and related notations allow nothing on the right-hand side of a
  production rule but a sequence of symbols, or a top-level choice
  among sequences of symbols.

* [Extended Backus-Naur](https://en.wikipedia.org/wiki/Extended_Backus%E2%80%93Naur_form) (or
  EBNF) notations provide a number of syntactic conveniences: markings
  to make nonterminals or subexpressions optional, or repeatable, or
  both, and nested choices. Invisible XML falls into this class, and
  goes beyond some other EBNF notations in providing syntax for
  textual insertions and for repetition with separators.

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

Now consider this rule:

```
S = 'a', 'b'* .
```

An “S” is an “a” followed by zero or more “b”s. The syntactic shortcut
“zero or more” (`*`) is also not present in BNF. In order to rewrite
this one, it will be convenient to introduce a new nonterminal symbol.

The new nonterminal isn’t strictly necessary. The following BNF
grammar accepts the same inputs as the original:

```
S = ('a' | -S), 'b' .
```

However, the specification introduces a nonterminal. The name of the
nonterminal is irrelevant as long as it isn’t a name used elsewhere by
the grammar author. In an Invisible XML context, we can always mark
the rule with “`-`” so that it never appears in the serialization.

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

To ensure that an iXML processor can produce the required XML output
from a rewritten grammar, it is helpful to adopt some general
principles in our rewrites:

* Every nonterminal in the input grammar will reappear in the
  rewritten grammar and matches the same input strings. (Exception: if
  the nonterminal is marked hidden, this is not important.)
* It is often helpful to add new nonterminals as part of rewriting the
  grammar, often (as in the example above) adding a nonterminal to
  replace exactly one `repeat0` or `repeat1` construct in the input
  grammar.
* Every nonterminal added in the rewritein the input grammar will be
  marked hidden. (Since the new nonterminal does not appear in the
  input grammar, it can never be correct for it to produce an element
  or an attribute in the XML output.)

The first example, rewriting optionality, didn’t introduce a new
nonterminal because that example was simpler to explain without doing
so. However, in practice, the factor that is optional may be an
expression in parenthesis that’s much more complicated than just “b”.
We could have rewritten it using a new nonterminal as shown here:

```
S = 'a' | 'a', b-option .
-b-option = 'b' | () .
```

That formulation is simpler in the general case.

## Rewriting Invisible XML

Invisible XML has five syntactic conventions that are not present in
BNF:

* Optionality, `?`
* Zero or more, `*`
* One or more, `+`
* Zero or more with a separator, `**`
* One or more with a separator, `++`

We need to find rewrite rules for each of these. Note that in many
cases, the order of the rewrites is significant. If zero-or-more is
rewritten in terms of optionality, for example, it is important to
rewrite zero-or-more first, or else multiple passes over the set of
rules will be required.

## The iXML formulation

In the section “Hints for Implementors”, the Invisible XML (1.0)
specification gives a set of rewrite rules.

Every occurrence of optionality can be rewritten as we saw above,
replace `f?` with `f-option`:

```
-f-option = f | ().
```

An `f-option` is an `f` or nothing.

Every occurrence of zero-or-more can be rewritten by replacing `f*`
with `f-star`:

```
-f-star = (f, f-star)?.
```

An `f-star` is an optional `f` followed by `f-star`.

Every occurrence of one-or-more, `f+`, can be replaced with `f-plus`:

```
-f-plus = f, f*.
```

An `f-plus` is an `f` followed by an `f*`.

Every occurrence of zero or more with a separator, `f**sep`, can be
replaced with `f-star-sep`:

```
-f-star-sep = (f++sep)?.
```

An `f-star-sep` is an optional `f++sep`.

Every occurrence of one or more with separator, `f++sep`, can be
replaced with `f-plus-sep`:

```
-f-plus-sep = f, (sep, f)*.
```

An `f-plus-sep` is an `f` followed by zero-or-more of `sep` followed by `f`.

## The BTW formulation

Bethan Tovey-Walsh proposed the following set of rules. Some
implementors report that these rules lead to better performance with
an Earley parser.

This formulation uses the same rules as in the iXML formulation, except:

Every occurrence of zero-or-more can be rewritten by replacing `f*`
with `f-star`:

```
-f-star = f+ | ().
```

An `f-star` is an `f+` or nothing.

Every occurrence of one-or-more, `f+`, can be replaced with `f-plus`:

```
-f-plus = f | (f, f-plus).
```

An `f-plus` is an `f` or an `f` followed by an `f-plus`.

Every occurrence of zero or more with separator, `f**sep`, can be
replaced with `f-star-sep`:

```
-f-star-sep = f++sep | ().
```

An `f-star-sep` is an `f++sep` or nothing.

## The JωL formulation

John Lumley observes that there’s another possibility for zero-or-more
avoiding the optionality from the iXML rules and the path through `f+`
from the BTW formulation:

Every occurrence of zero-or-more can be rewritten by replacing `f*`
with `f-star`:

```
-f-star = f, f-star | ().
```

An `f-star` is an `f` followed by an `f-star` or nothing.
