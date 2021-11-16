# Pragmas for ixml

2021-11-16


This document describes a proposal for adding *pragmas* to the
Invisible-XML specification.

It was prepared (or rather, is being prepared) by Tom Hillman and
Michael Sperberg-McQueen. It is currently not finished.

The general idea of pragmas is to provide a channel for information
that is not part of the ixml specification but can be used by some
implementations to provide useful behavior, without getting in the way
of other implementations for which the information is irrelevant. The
additional information contained in pragmas may be used to control
options in a processor (like optimization levels in a C compiler) or
to extend the specification.

The proposal described here is inspired in part by the `xsl:fallback`
and `use-when` mechanisms of XSLT and the *extension expression*
and *annotation* mechanisms of XQuery.

## Use cases

Among the use cases that motivate the proposal are these.

* Namespace declarations.

  Using pragmas to specify that all or some elements of the XML
returned by an ixml processor should go into a specified namespace.

* Renaming 

  Using pragmas to specify that an element or attribute name
serializing a nonterminal should be given a name different from the
nonterminal itself. (As in Steven Pemberton's proposal for element
renaming.)

* Name indirection 

  Using pragmas to specify that an element or attribute name should be
taken not from the grammar but from the string value of a given
nonterminal.

* Rule rewriting

  Using pragmas to specify that a rule as given is shorthand for a set
of other rules.  (As in John Lumley's grammar rewriting for XPath.)

* Tokenization annotation.

  Using pragmas to annotate nonterminals in an ixml grammar to
indicate that they (a) define a regular language and (b) can be safely
recognized by a greedy regular-expression match.

* Text injection.

  Using pragmas to indicate that a particular string should be
injected into the XML representation of the input as (part of) a text
node, or as an attribute or element. (This can help make the output of
an ixml parse conform to a pre-existing schema.)

* Attribute grammar specification.

  Using pragmas to annotate a grammar with information about
grammatical attributes to be associated with nodes of the parse tree,
whether they are inherited from an ancestor or an elder sibling or
synthesized from the children of a node, and what values should be
assigned to them. (Note that grammatical attributes are not to be
confused with XML attributes, although in particular cases it may be
helpful to render a grammatical attribute as an XML attribute.)

*Are there other use cases that need to be mentioned here?*

Note that some of these use cases may in practice be handled by
changes to the syntax of ixml. We include them in the list of use
cases for pragmas not because we think they are best handled by
pragmas (although for some of these cases, that may be true) but
because they are (a) plausible ideas for things one might want to do
which are (b) not supported by ixml in its current form, and thus (c)
natural examples of the kinds of things an extension mechanism oughtly
ideally to support.

Some of these use cases seem most naturally handled by annotations
which apply to a grammar as a whole, some by annotations which apply
to individual rules, and some by annotations which apply to individual
symbols in the grammar.

We do not see a strong use case for annotations which apply to
arbitrary expressions in a grammar.

## Requirements and desiderata

Our tentative list of requirements and desiderata is as follows.

By *requirement* we mean a property or functionality which must be
achieved for a pragmas proposal to be worth adopting.  
By *desideratum* we mean a property or functionality that should be
included if possible, but which need not lead to the rejection of the
proposal if it proves impossible to achieve.

Requirements:

* It must be straightforward for processors to ignore pragmas they do 
not understand, and to determine whether they `understand' a given 
pragma or not. 

* It must be clear to human readers and software which expressions in
standard ixml notation are and are not affected or overridden by a
given pragma.

* Any pragma must thus specify (explicitly or implicitly) both what
should be done by a processor that understands and processes the
pragma and what should be done by a processor that does not understand
and process the pragma. We refer to the latter as the *fallback
expression*.


Desiderata:

* Ideally, the result of evaluating the fallback expression should be
a useful and meaningful result, but this is more a matter for the
individual writing a grammar than for this proposal.

* It should ideally be possible to specify pragmas as annotations
applying to a symbol, a rule, or a grammar as a whole, and it should
be possible to know which is which. It is not required that the
distinction be a syntactic one, however, since it can also be
expressed by the semantics of the particular pragma.

## Design questions

Several design questions can be distinguished, not necessarily
completely orthogonal.

* What syntax should pragmas have in invisible XML?

* What representation should pragmas have in the XML serialization of
an ixml grammar?

### ixml syntax of pragmas

*Watch this space.*

### XML syntax of pragmas

*Attachment to symbols as attribute.*

*Insertion of elements as children of `rule`.*

*Insertion of elements as children of `ixml`.*


## Proposal


*Discussion of `#qname 'string'` proposal.*

*Discussion of `*qname data*` proposal.*

*Discussion of XML translation depending on position.*

## Worked examples

*This section should contain, for some or all of the use cases, fully
worked examples showing simple grammars that use the annotations in
question.*


