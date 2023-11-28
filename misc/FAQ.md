Frequently asked questions about Invisible XML

And also some questions that deserve to be asked more frequently than
they are.

# What is invisible XML?

Invisible XML (or ixml) is a method of describing data
(i.e. information in files or data streams) using a grammar,
processing the data using the grammar, and obtaining an XML
representation of the data.

An ixml processor takes an *input string* and an *input grammar* as
inputs, and produces an XML representation of a parse tree as output,
if the grammar describes the input.  If the grammar does not describe
the input, it produces an XML document saying so.

# What is the input string?

The input *string* is a sequence of Unicode characters.

As a consequence of this, code points explicitly identified by the
Unicode spec as non-characters, and 16-bit values used in UTF-8 to
represent surrogate characters, are not allowed in the input string.
(For more details see below.)

Which version of Unicode is used is implementation-defined.

# What is the input grammar?

The input grammar is also a sequence of Unicode characters, which is
an ixml grammar.  That is, it is described by the invisible-XML
specification grammar (which is itself an ixml grammar).

Like any string described by an ixml grammar, the input grammar has an
XML representation which can be produced by an ixml processor.  Some
processors may allow grammars to be supplied in this XML
representation.

# What is the output?

The ixml spec says that the output of a conforming ixml processor is
an XML document.

# What restrictions are there on ixml grammars?

Any context-free grammar can be handled by an ixml processor.

The ixml input grammar is not required to be an LL(1) grammar, or an
LALR(1) grammar, or LL((_k_) or LALR(_k_) for some positive integer
_k_.  It is not required to be unambiguous.

An ixml processor does check for some properties of the grammar that
are likely to indicate mistakes made in preparing the grammar.  Each
nonterminal symbol must be defined exactly once: multiple definitions
are not allowed, nor are undefined symbols.

# Are ixml processors required to detect ambiguous grammars?

Not quite.  A grammar *G* is ambiguous if there is any sentence in the
language defined by *G* that has more than one parse tree (or, more
formally, more than one left-most derivation).  For a language with
infinitely many sentences, it is a hard problem to detect whether such
a sentence exists.  So, no, ixml processors are /not/ required to
detect ambiguous grammars.

On the other hand, given some input string /s/ and some input grammar
*G*, it's not terribly difficult to detect whether /s/ is ambiguous
against *G*.  Processors are encouraged but not required to detect
ambiguity of the input string, and to report it by including the
keyword ~ambiguous~ in the value of the ~ixml:state~ attribute.

However, note that ixml processors are allowed to rewrite the input
grammar however they like, as long as they produce the correct output
XML.  Many processors rewrite the ixml grammar into Backus/Naur form
(BNF) in order to use parsing algorithms defined for BNF but not for
extended grammar formats like ixml. Because ambiguity of a string is
always ambiguity of that string *when parsed against a given grammar*,
the rewrites performed may affect whether an ambiguity is detected.

For example, consider the following grammar, which is not in BNF
because it uses ~repeat0~ operators.

#+begin_src 
S = -'(', (A* | B*), -')'.
A = 'a'.
B = 'b'.
#+end_src

Parsed against this grammar, the string '()' will produce the XML

```
<S/>
```

This grammar can be rewritten in BNF form as follows:

```
S = -'(', As-or-Bs, -')'.
-As-or-Bs = Astar | Bstar.
-Astar = (); A, Astar.
-Bstar = (); B, Astar.
A = 'a'.
B = 'b'.
```

Against this BNF grammar, the string "()" is ambiguous because from
`As-or-Bs` the empty string can be derived either through
`Astar` or through `Bstar`.

Here is another BNF grammar which recognizes the same language as
the first and allows the correct XML to be generated:

#+begin_src 
S = -'(', As-or-Bs, -')'.
-As-or-Bs = () | As | Bs.
-As = A; A, As.
-Bs = B; B, As.
A = 'a'.
B = 'b'.
#+end_src

Against this BNF grammar, the grammar is unambiguous because from
`As-or-Bs` there is only one way to derive the empty string.

Processors which rewrite the grammar in one way may report an
ambiguity; processors which rewrite the grammar the other way will
report none.

And processors which do not rewrite to BNF at all may also differ in
their view of whether this grammar is ambiguous or not.  Theoretical
computer scientists who work on automata and formal languages
typically define the term /ambiguity/ only in terms of parsing against
a BNF grammar, and provide no definition of ambiguity directly
applicable to parsing against an extended BNF grammar.  In practice,
existing processors differ in their treatment of the example just
given.

# Is ixml case-sensitive or case-insensitive?

Like XML, Invisible XML is case-sensitive.

The only place this becomes an issue is in the recogntion of
nonterminal symbols.  So concretely, the case-sensitivity of ixml
means: Nonterminals are case-sensitive.

So, for example, the nonterminal /x/ and the nonterminal /X/ are
distinct.

# Can I parse binary input?

Binary formats can often be described using context-free grammars.

But the ixml spec assumes that the input to the parsing process is a
sequence of characters in the 'universal character set' described by
ISO 10646 and Unicode.  So binary output cannot be described by a
standard ixml grammar.

An ixml processor may offer extensions to support parsing of binary
input, but that is outside the scope of the ixml specification.

# What about non-Unicode characters?  Or Unicode non-characters?

Both the input string and the input grammar are sequences of Unicode
characters.

*Non-Unicode characters* -- that is, characters used in some writing
system but not assigned code points in the (applicable version of the)
universal character set -- can be represented using code points in the
Unicode private-use area.  In most applications, such characters are
vanishingly rare.

*Unicode non-characters* are code points explicitly identified by the
Unicode spec as reserved for internal use, which will never be
assigned to represent characters.  There are 66 such code points:

  - the range U+FDD0 to U+FDEF;
    
  - the last two code points in the Basic Multilingual Plane, i.e.
    U+FFFE and U+FFFF; and
    
  - the last two code points in each of the 16 supplementary planes, i.e.
    U+01FFFE, U+01FFFF,
    U+02FFFE, U+02FFFF,
    U+03FFFE, U+03FFFF,
    ...   
    U+0FFFFE, U+0FFFFF,
    U+10FFFE, U+10FFFF.

Note that the 16-bit values used in UTF-8 to represent surrogate
characters are not non-characters in the technical sense (they have a
defined use in Unicode) but since they do not individually represent
characters, they cannot appear individually in the input string.  If
they appear in syntactically well formed UTF-8 input, then for
purposes of ixml processing what is present in the input is a
character in one of the 16 supplementary planes of the Unicode space.


# Can I produce non-XML output?

Some processors may provide additional output formats, e.g. JSON, but
those formats and the behavior that produces them are not defined by
the ixml spec.

# Can I use invisible XML from inside XSLT?  XQuery?

There are ixml processors which can be called from within XSLT or
XQuery, either by using an extension function or by loading an XQuery
or XSLT library which defines an ixml parsing function.

There is currently (October 2023) work afoot to add ixml parsing
functions to the standard XPath 4.0 function library.

# What do 'implementation-defined' and 'implementation-dependent' mean?

A feature is *implementation-defined* if the precise specification of
the feature is provided by the documentation of the ixml
implementation.  For example: which version of Unicode is used by the
processor?

A behavior is *implementation-dependent* if it can vary from one
processor to another, but the precise behavior is not defined --
neither by the ixml specification nor by the documentation of the
processor.  Sometimes things are described as implementation-dependent
because it is impossible to predict what will happen in any given
case: the behavior of a processor that runs out of memory is an
example.  In other cases, something is described as
implementation-dependent (and not implementation-defined) in order to
signal that processor behavior should not be relied upon.  

