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
and *annotation* mechanisms of XQuery. SGML and XML processing
instructions are also possible models.


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

* Where can pragmas appear?


## Proposal(s)

Two concrete proposals have been made; they have been given arbitrary
names for discussion.

### The hash-QName proposal

In this proposal, pragmas take the form of a hash mark, a QName, and a
string. Because ixml has two string delimiters, pragmas can nest, but
only two deep.

They can occur immediately before a terminal or nonterminal symbol,
before the mark if any.

In the XML form, they are realized as extension attributes whose name
is the QName given in the pragma and whose value is the value of the
string.

For example:

````
    #my:color 'blue' a = b, #my:flavor 'vanilla' c?.
````

The corresponding XML form is:

````
    <rule name="a" my:color="blue">
        <alt>
            <nonterminal name="b"/>
            <option>
                <nonterminal name="c" my:flavor="vanilla"/>
            </option>
		</alt>
    </rule>
````
	
Annotations pertaining to a particular occurrence of a symbol appear 
immediately before that occurrence, as here the `my:flavor` pragma. 

Annotations pertaining to a rule as a whole, or which provide a 
nonterminal with default value for some property appear immediately 
before the nonterminal on the left-hand side of a rule, as here the 
`my:color` pragma. 

Annotations pertaining to the grammar as a whole appear immediately
before the first rule, and thus appear as attributes on the first
`rule` element of the grammar.

There are no syntactic distinctions among these cases: if the rule
shown is the first rule in the grammar, `my:color` might be supplying
a default property value for `a`, or annotating the rule, or
annotating the grammar as a whole. The difference must be carried by
the semantics of the pragma: those defining the `my:color` pragma
should be clear about what it means and what its scope is.

### The brackets-QName proposal 

In this proposal, pragmas take the form of a left square bracket, an
optional mark, a QName, the pragma's data, and a right square bracket.
Nested pairs of square brackets are allowed, so pragmas can nest
arbitrarily deep.

Pragmas can occur immediately before a terminal or nonterminal symbol,
before the mark if any, or in the whitespace immediately before the
full stop of a rule.

In the XML form, the serialization of the pragma depends on its
position and the mark following the opening bracket.

* Pragmas occurring before the full stop of a rule are serialized as
extension elements following the final `alt` of the right-hand side of
the rule.

* Pragmas occurring before a symbol are serialized as attributes if 
marked `@` (ignoring marks on any nested pragmas). 

* Pragmas occurring before a symbol are not serialized at all if
marked `-`.

* Pragmas occurring before a symbol are serialized as extension
elements if unmarked or marked `^`.

  The extension elements appear as the first children of the XML
representation of the symbol. In the canonical XML representation, the
pragma data is serialized as a 'pragma-data' element within the
extension element, which will contain the pragma-data as a character
sequence. Depending on the semantics of the pragma itself, the
extension element may also contain additional elements. (See the
examples in the final section of this paper.)

For example:

````
    [my:color blue] a = b, [@my:flavor vanilla] c? [my:spin ...].
````

The corresponding XML form is:

````
    <rule name="a">
        <my:color>blue</my:color>
        <alt>
            <nonterminal name="b"/>
            <option>
                <nonterminal name="c" my:flavor="vanilla"/>
            </option>
        </alt>
        <my:spin>
            <pragma-data>...</pragma-data>
        </my:spin>
    </rule>
````
	
Annotations pertaining to a particular occurrence of a symbol appear 
immediately before that occurrence, as here the `my:flavor` pragma. 

Annotations which provide a nonterminal with default value for some
property appear immediately before the nonterminal on the left-hand
side of a rule, as here the `my:color` pragma.

Annotations pertaining to a rule as a whole may occur either before
the left-hand side of the rule, which may be preferred for
light-weight annotations, or before the full stop at the end of the
rule, which is preferable for long complicated annotations.

Annotations pertaining to the grammar as a whole appear immediately
before the first rule, and thus appear as attributes on the first
`rule` element of the grammar.

Pragmas occurring before a full stop apply to the rule as a whole.
Pragmas occurring before a symbol in the right-hand side of a rule
apply to that occurrence of that symbol. Pragmas occurring before the
left-hand side of a rule may apply to that symbol in general, or to
the rule as a whole, or (if occurring before the first rule) to the
grammar as a whole; such distinctions are conveyed semantically, not
syntactically.

## Worked examples

*This section should contain, for some or all of the use cases, fully
worked examples showing simple grammars that use the annotations in
question.*


### Namespace declarations.

Using pragmas to specify that all or some elements of the XML returned
by an ixml processor should go into a specified namespace.

For example, let's assume that we want some elements to go into one
namespace, some into another, and some into none, and that namespace
bindings should remain constant throughout the grammar (so: no
changing the default namespace in the middle of the document).

We define the namespace 'http://example.com/ixml-namespaces" as
providing for namespace bindings, and we adopt the convention that a
prefix `ppp` is bound to a namespace name `nnn` if a pragma of the form
````
    [@nsd:ppp nnn]
````

is encountered in a context where the prefix *nsd* is bound to
"'http://example.com/ixml-namespaces".

To bootstrap the process, we adopt the principle that a 
pragma of the form
````
    [@ns:ns http://example.com/ixml-namespaces]
````

binds the prefix `ns` to that namespace. (Alternatively, we could
follow the example of XML namespaces and reserve some string for
namespace bindings, but this example is trying to show a way to do
this that does not rely on a decree in the spec but could in principle
be handled as an extension.)

So a grammar in which some elements are in the *x* namespace, some in
the *y* namespace, and some in no namespace at all, might be

````
    [@nsd:nsd http://example.com/ixml-namespaces]
    [@nsd:x http://example.org/NS/existential]
    [@nsd:y http://example.com/NS/yoyo]
    x:sentence: x:a, ' ', y:b?, '.  ', c.
	x:a: 'Speed'.
	y:b: 'kills'.
	c:  'It really does.'.
````
The XML representation of the grammar might be:

````
    <ixml>
      <rule name="x:sentence"
        nsd:nsd="http://example.com/ixml-namespaces"
        nsd:x="http://example.org/NS/existential"
        nsd:y="http://example.com/NS/yoyo"
        >
        <alt>
          <nonterminal name="x:a"/>
          <literal sstring=" "/>
          <option>
            <nonterminal name="y:b"/>
          </option>
          <literal sstring=".  "/>
          <nonterminal name="c"/>
        </alt>
      </rule>
      <rule name="x:a">
        <alt>
          <literal sstring="Speed"/>
        </alt>
      </rule>
      <rule name="y:b">
        <alt>
          <literal sstring="kills"/>
          </alt>
      </rule>
      <rule name="c">
        <alt>
          <literal sstring="It really does."/>
        </alt> 
      </rule>
    </ixml>
````

*We have another bootstrapping problem here: because the prefix*
`nsd` *is not declared, the XML shown is not namespace-well-formed. We
need some way of getting it declared, preferably other than by fiat,
but I don't currently see an alternative to fiat.*

To make the XML be namespace well-formed, we will need somehow to get
at least a namespace declaration for *nsd* to be injected on the
`ixml` element, and preferably also namespace bindings for the
prefixes *x* and *y*, so the `ixml` start tag takes something like the
following form.
````
    <ixml xmlns:nsd="http://example.com/ixml-namespaces"
          xmlns:x="http://example.org/NS/existential"
          xmlns:y="http://example.com/NS/yoyo" >
 ````
		  
### Renaming 

Using pragmas to specify that an element or attribute name
serializing a nonterminal should be given a name different from the
nonterminal itself. (As in Steven Pemberton's proposal for element
renaming.)

### Name indirection 

Using pragmas to specify that an element or attribute name should be
taken not from the grammar but from the string value of a given
nonterminal.

### Rule rewriting

Using pragmas to specify that a rule as given is shorthand for a set
of other rules.  (As in John Lumley's grammar rewriting for XPath.)

### Tokenization annotation.

Using pragmas to annotate nonterminals in an ixml grammar to
indicate that they (a) define a regular language and (b) can be safely
recognized by a greedy regular-expression match.

### Text injection.

Using pragmas to indicate that a particular string should be
injected into the XML representation of the input as (part of) a text
node, or as an attribute or element. (This can help make the output of
an ixml parse conform to a pre-existing schema.)

### Attribute grammar specification.

*Example:  synthesized value attribute for arithmetic expressions.*

Consider the following simple grammar for arithmetic expressions
involving addition and multiplication over single-digit integers.

````
    expr:  expr, s, '+', s, term.
    term:  term, s, '*', s, factor.
    factor:  '0'; '1'; '2'; '3'; '4'; '5'; '6'; '7'; '8'; '9'; '(', s, expr, s, ')'.
    s:  [#20; #A; #D; #9]*.
````

In an attribute-grammar system, we might define the *value* of an
expression as a synthesized (bottom-up) grammatical attribute
following the rules:

* The value of a *factor* consisting of a single digit is the value of
the integer usually so written: '0' has the value of zero, '1` has the
value of one, etc.

* The value of a *factor* consisting of a parenthesized *expr* is the
value of the *expr*.

* The value of a *term* consisting solely of a *factor* is the value 
of the *factor*. 

* The value of a *term* consisting solely of a *term* followed by an 
asterisk and a *factor* is the product of the values of the *term* and 
the *factor*. 

* The value of an *expr* consisting solely of a *term* is the value 
of the *term*. 

* The value of an *expr* consisting solely of an *expr* followed by a
plus sign and a *term* is the sum of the values of the *expr* and
the *term*.

Extending this to handle subtraction, division, and multiple-digit
numbers would be straightforward but require a lot more rules which
would not involve any interesting new principles.

A conventional system for reading attribute grammars and making
parsers which parse input and calculate the values of grammatical
attributes might represent this grammar thus, naming the grammatical
attribute *v* (this example follows, roughly the syntax of Alblas 191,
and like Alblas assumes whitespace is someone else's problem).

````
    expr_0 →  expr_1 '+' term.
            [ expr_0.v = expr_1.v + term.v]

    term_0 →  term_1 '*' factor.
            [ term_0.v = term_1.v * factor.v]

    factor →  '0'.
            [ factor.v = 0 ]
	factor → '1'.
	        [ factor.v = 1 ]
	factor → '2'.
            [ factor.v = 2 ]
    factor → '3'.
            [ factor.v = 3 ]
    factor → '4'.
            [ factor.v = 4 ]
    factor → '5'.
            [ factor.v = 5 ]
    factor → '6'.
            [ factor.v = 6 ]
    factor → '7'.
            [ factor.v = 7 ]
    factor → '8'.
            [ factor.v = 8 ]
    factor → '9'.
            [ factor.v = 9 ]
    factor → '(' expr ')'.
            [ factor.v = expr.v ]
````

Note that some nonterminals are subscripted so that references to
their grammatical attributes can be unambiguous. To express this
grammar in ixml, we need either to allow multiple rules for the same
nonterminal, or to allow pragmas before connectors like comma or
semicolon, or we need to allow string-to-typed-value functions in the
style of XPath. I'll assume the latter two, along with a string()
function that returns the string value of a nonterminal. With these
assumptions, and the assumption that by means not specified the
prefix *ag* has been bound to an appropriate grammar for
attribute-grammar functionality, the attribute grammar could be
written thus using the brackets-QName syntax

````
    [@ag:id e0] expr:  [@ag:id e1] expr, s, '+', s, term
            [ag:rule e0.v := e1.v + term.v ].
    {@ag:id t0] term:  [@ag:id t1] term, s, '_', s, factor
            [ag:rule t0.v := t1.v * factor.v].
	factor:  digit [@ag:rule factor.v := number(string(digit))]; 
            '(', s, expr, s, ')' [@ag:rule factor.v := expr.v ].
    digit: '0'; '1'; '2'; '3'; '4'; '5'; '6'; '7'; '8'; '9'.
    s:  [#20; #A; #D; #9]_.
````

Here *ag:id* is assumed to associate a unique identifier with a
particular instance of a nonterminal, and *ag:rule* is assumed to
contain a set of assignment statements specifying the values of
particular attributes, in a subset of XPath syntax. (A more serious
proposal would need some way to distinguish *e0.v* meaning "the *v*
attribute of *e0* from the same string as a name which happens to
contain a string. This is not that serious proposal.)


*Example:  synthesized value attribute and inherited environment attribute with variable bindings, for arithmetic expressions with 'let'.*


## Open issues

* Is it really OK not to have a way to have pragmas turn into elements
before the first `rule` element?
