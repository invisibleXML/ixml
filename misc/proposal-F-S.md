# A namespaces + pragmas proposal for ixml

Tom Hillman, Michael Sperberg-McQueen

15 December 2021

This document describes a proposal for adding namespace declarations
and pragmas to ixml. For background, use cases, some discussion of
design choices, and examples of how pragmas as defined here could be
used in the use cases, see the document (pragmas.md)[pragmas.md] in
this directory. (In that document, the proposals made here are
referred to as namespaces proposal S and pragmas proposal F.)

## Pragmas

Pragmas are a syntactic device to allow grammar writers to communicate
with processors without interfering with the operation of other
processors. To avoid interference with other processors, pragmas must
be syntactically identifiable as such, and it must be possible for
processors to distinguish pragmas directed at them from other
pragmas. This proposal uses namespaces, QNames, and URI-qualified
names to allow grammar writers and implementations to avoid
collisions.

Pragmas may affect the behavior of a processor in any way, either in
ways that leave the meaning of a grammar unchanged or in ways that
change the meaning of the grammar in which the pragmas appear.
Processors should be capable, at user option, of ignoring all pragmas
and processing a grammar using the standard rules of ixml.

### Syntax in ixml

In ixml, pragmas are enclosed in square brackets, which contain an
optional mark, a qualified name in some form, and optionally
additional data, which takes the form of a sequence of
square-bracket-balanced characters. The relevant part of the ixml
grammar is:

````
pragma: -"[", @pmark?, @pname, (s, pragma-data)?, -"]". 
@pname: -QName; -UQName. 
@pmark: ["@^?"].
pragma-data: (-pragma-chars; -bracket-pair)*. 
-pragma-chars: ~["[]"]*.
-bracket-pair: '[', -pragma-data, ']'.

-QName: -name, ':', -name.
-UQName: 'Q{', -ns-name, '}', -name.
-ns-name: ~["{}"; '"'; "'"]* 
````

For example:

````
[?my:blue]
````

or

````
[?Q{http://example.org/NS/mine}blue]
````

or

````
[@my:color blue]
````

or

````
[ls:rewrite
              comment: -"{", (cchars; comment)*, -"}". 
              [ls:token] -cchars:  cchar+. 
]
````

Pragmas may appear:

* immediately before a terminal or nonterminal symbol in the
right-hand side of a rule, before or after its mark if any, or

* immediately before the nonterminal symbol on the left-hand side of a
rule, before or after its mark if any, or

* after the final alternative of a rule, before the full stop ending
the rule, or

* before the first rule of the grammar.

In the final case, each pragma must be followed by a full stop.

Each of these requires some changes to the grammar of ixml. To allow
pragmas immediately before symbols, we change the grammatical
definitions of symbols, both nonterminals:

````
nonterminal: annotation, name, s.
-annotation:   (pragma, sp)?, (mark, sp)?.
-sp:  (s; pragma)*. 
````

and terminals:

````
-quoted: tannotation, -string.
-encoded: tannotation, -"#", @hex, s.
inclusion: tannotation,          set.
exclusion: tannotation, -"~", s, set.
-tannotation:  (pragma, sp)?, (mark, sp)?. 
````

To allow pragmas on the left-hand side of a rule and before its
closing full stop, we modify the definition of *rule*:

````
rule: annotation, name, s, -["=:"], s, -alts, (pragma, sp)?, -".". 
````

To allow pragmas before the first rule and to distinguish them from
pragmas occurring on the left-hand side of the first rule, we modify
the definition of *ixml*:

````
ixml: prolog, rule+s, s. 
prolog:  s, ppragma+s, s. 
-ppragma:  pragma, s, -'.'. 
````


### Syntax in XML

Following the normal rules of ixml, pragmas are serialized as elements
named `pragma`, with attributes named `pmark` and `pname` and a child
element named `pragma-data`. In addition, in XML grammars `pragma`
elements may contain any number of XML elements following the
`pragma-data` element.

For example:

````
<pragma pname="my:blue" pmark="?">
    <pragma-data/>
</pragma>
````

or

````
<pragma pname="my:color" pmark="@">
    <pragma-data>blue</pragma-data>
</pragma>
````

or

````
<pragma pname="ls:rewrite">
    <pragma-data>comment: -"{", (cchars; comment)*, -"}". 
              [ls:token] -cchars:  cchar+. 
</pragma-data>
</pragma>

````

Pragma-oblivious processors and processors which do not implement the
pragma in question will as a matter of course produce `pragma`
elements with just the one child element. But processors which
implement a given pragma are free to inject additional XML elements
into the XML form of the pragma. It is to be assumed that the XML
elements contain no additional information, only a mechanically
derived XML form which makes the information in the pragma easier to
process. It is to be expected that any software to serialize XML
grammars in ixml form will discard the additional XML elements.

It should be noted that the *pmark* allowed by the syntax has no
effect on the XML representation produced by the core rules of ixml.
Pragma-oblivious processors will always produce XML representation of
pragmas of the form described here. Pragma-aware processors may
implement pragmas which modify the standard XML representation
('pragmas for pragma'). See (pragmas.md)[pragmas.md] for an example.


### Static semantics

In this proposal, pragmas always apply explicitly to some part of a
grammar:

* to a symbol occurrence in the right-hand side of a rule, or

* to a rule

* to the grammar as a whole

The relation between a pragma and the part of the grammar to which it
applies is reflected in the XML form of a grammar: pragmas appear as
child elements of the part of the grammar they apply to (an element
named `ixml`, `rule`, `nonterminal`, `literal`, `inclusion`, or
`exclusion`).

These associations are specified here for clarity and to enable
clearer discussion of pragmas, but they have no effect on the
operational semantics of ixml processors.


### Operational semantics 

In describing the operational semantics of pragmas, we distinguish
different classes of ixml processor:

* *pragma-oblivious* processors recognize pragmas syntactically but 
otherwise ignore them all. Informally, they do not 'understand' any 
pragmas, and their only obligation is not to trip over pragmas when 
they encounter them. 

* *pragma-aware* processors recognize pragmas syntactically and modify
their behavior in accordance with some pragmas. Informally, they
'understand' some pragmas but not all. For each pragma they recognize,
they must determine whether it is one they 'understand' and implement,
or not.

With regard to a given pragma, processors either *implement* that
pragma or they do not. A processor *implements* a pragma iff it
adjusts its behavior as specified by that pragma. In the ideal case
there will be some written specification of the pragma which describes
the operational effect of the pragma clearly. This proposal assumes
that a processor can use the qualified name of a pragma to determine
whether the processor implements the pragma or not and thus decide
whether to modify its normal operation or not.

The obligation of pragma-oblivious processors is to accept pragmas
when they occur in the ixml form of a grammar, and (if they are
producing an XML form of the grammar) produce the correct XML form of
each pragma, just as they produce the corresponding XML form for any
construct in the grammar.

Pragma-aware processors must similarly to accept pragmas when they
occur in the ixml form of a grammar, and (if they are producing an XML
form of the grammar) produce the correct XML form of each pragma, just
as they produce the corresponding XML form for any construct in the
grammar. As already noted, however, pragmas may modify this behavior
like any other.


## Namespace declarations

Namespace declarations take the form of a pragma appearing in the
prolog of a grammar and using the reserved prefix *ixmlns* in their
QName.  Their pragma data is interpreted an an IRI.

For example the following namespace declarations bind the prefix
"`xsd`" to the namespace for the XSD schema definition language, and
"`rng`" to that for Relax NG:

````
[ixmlns:xsd http://www.w3.org/2001/XMLSchema]
[ixmlns:rng http://relaxng.org/ns/structure/1.0]
````

As is the case for for XML namespaces generally, the pragma data
should be a legal URI, but ixml processors are not obligated to check
the URI for syntactic correctness (although they are may do so), and
normally should not attempt to dereference it.

The effect of a namespace declaration is to bind the local part of the 
QName to the given namespace and allow it to be used as a prefix in 
QNames to denote qualified names in the given namespace. 

The following rules apply:

* The prefix *ixmlns* is understood by all conforming ixml software as
  bound to the namespace-binding namespace
  '`http://example.com/ixml-namespaces`".

* A pragma with the unprefixed *ixmlns* is interpreted as defining a
  default namespace.

* All namespace declarations pertain to the grammar as a whole and
  must be given before the first rule of the grammar.  

* No two namespace declarations may bind the same prefix.

* A nonterminal taking the lexical form of a QName must if serialized
  be serialized as an XML element name with the same local name and
  with a prefix bound to the same namespace.  Normally the prefix
  should be as given in the grammar.  *(If all namespaces are declared
  before the first rule, there should be no reason it should be
  impossible to use the same prefix.  Perhaps we can make this a
  'must'.)*

  The ixml processor is responsible for including appropriate
  namespace declarations in the XML output.

* In the XML form of an ixml grammar, all namespaces bound in in the
  ixml grammar should be bound in the XML form of the grammar.

  This should normally take the form of namespace declarations on the
  `ixml` element.  The pragmas should also be represented in the usual
  way, if that differs from being realized as a namespace-binding
  attribute.

