# Pragmas for ixml

2021-11-16, rev. most recently 2021-11-30


This document describes a proposal for adding *pragmas* to the
Invisible-XML specification.

It was prepared (or rather, is being prepared) by Tom Hillman and
Michael Sperberg-McQueen. It is currently not finished.

The general idea of pragmas is to provide a channel for information
that is not a required part of the ixml specification but can be used
by some implementations to provide useful behavior, without
interfering with the operation of other implementations for which the
information is irrelevant.  Pragmas can also be used to provide
optional features in the ixml specification.  The additional
information contained in pragmas may be used to control options in a
processor or to extend the specification (in roughly the same way as
pragmas and structured comments in C or Pascal programs may be used to
control optimization levels in some compilers).

On this view, pragmas are a form of annotation, and we use the terms
*pragma* and *annotation* accordingly.

The proposal described here is inspired in part by the `xsl:fallback`
and `use-when` mechanisms of XSLT and the *extension expression*
and *annotation* mechanisms of XQuery. SGML and XML processing
instructions have also contributed to our thinking.


## Use cases

Among the use cases that motivate the proposal are these.

Note that some of these use cases may in practice be handled by
changes to the core syntax of ixml. We include them in the list of use
cases for pragmas not because we think they are best handled by
pragmas but because they are (a) plausible ideas for things one might
want to do which are (b) not supported by ixml in its current form,
and thus (c) natural examples of the kinds of things an extension
mechanism like pragmas ought ideally to be able to support.

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
of other rules.  (Example: John Lumley's grammar rewriting for XPath.)

* Tokenization annotation

  Using pragmas to annotate nonterminals in an ixml grammar to 
indicate that they (a) define a regular language and (b) can be safely 
recognized by a greedy regular-expression match. 

* Alternative formulations

  Using pragmas to provide alternative formulations of rules in an
ixml grammar to allow different annotation or better optimization.

* Text injection

  Using pragmas to indicate that a particular string should be
injected into the XML representation of the input as (part of) a text
node, or as an attribute or element. (This can help make the output of
an ixml parse conform to a pre-existing schema.)

* Attribute grammar specification

  Using pragmas to annotate a grammar with information about
grammatical attributes to be associated with nodes of the parse tree,
whether they are inherited from an ancestor or an elder sibling or
synthesized from the children of a node, and what values should be
assigned to them. (Note that grammatical attributes are not to be
confused with XML attributes, although in particular cases it may be
helpful to render a grammatical attribute as an XML attribute.)

*Are there other use cases that need to be mentioned here?*

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
included if possible, but which does not doom the proposal to
pointlessness if it proves impossible to achieve.

Requirements:

* It must be straightforward for processors to ignore pragmas they do 
not understand, and to determine whether they 'understand' a given 
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
individual writing a grammar than for this proposal.  The desideratum
for a pragmas proposal is to make it easy (or at least not
unnecessarily hard) to write useful fallbacks.

* It should ideally be possible to specify pragmas as annotations
applying to a symbol, a rule, or a grammar as a whole, and it should
be possible to know which is which. It is not required that the
distinction be a syntactic one, however, since it can also be
expressed by the semantics of the particular pragma.

## Design questions

Several design questions can be distinguished; they are not completely
orthogonal.

* What information should be encodable with pragmas?

* What syntax should pragmas have in invisible XML? 

* What representation should pragmas have in the XML serialization of
an ixml grammar?

* Where can pragmas appear?


## Proposal(s)

The current proposal is given the arbitrary name of 'brackets QName' for
discussion; an earlier proposal (the 'hash-QName' proposal) has been
withdrawn, though traces of it may remain in other documents in this
branch.

### The brackets-QName proposal 

In this proposal, pragmas take the form of a left square bracket, an
optional mark, a QName, the pragma's data, and a right square bracket.
Nested pairs of square brackets are allowed, so pragmas can nest
arbitrarily deep.

#### The ixml form

In the ixml form of a grammar, pragmas can occur within whitespace in
several locations:

* before the first rule of the grammar, after the last rule of the
  grammar, or between rules; these pragmas apply to the grammar
  as a whole or to the rules following the pragma.

* before a terminal or nonterminal symbol on the right-hand side of a
  rule, before or after the mark if any; these pragmas apply to that
  occurrence of the symbol.

* between the mark on the left-hand side of a rule and the 
  nonterminal; these pragmas apply to the rule. 

* immediately before the full stop of a rule; these pragmas apply to
  the rule.

Two locations are allowed for pragmas applying to rule in order to
allow them to appear either first or last; this is essentially a
rhetorical choice, as it can make a large difference to readability.

#### Marks on pragmas

Depending on the mark used in the ixml pragma, it may correspond to
various XML constructs in the XML form of the grammar:

* An ixml pragma marked `^` corresponds to an extension element. 

* An ixml pragma marked `@` corresponds to an extension attribute. 

* An ixml pragma marked `?` corresponds to a processing instruction.

#### The XML form

These XML constructs may occur in locations corresponding to those in
which pragmas may appear in the ixml grammar:

* as a child or attribute of the `ixml` element before, between, or
  after `rule` elements.

* as a child or attribute of a `rule` element.  An ixml pragma marked 
  `^` or `?` occurring on the left-hand side of a rule corresponds to an
  extension element or processing instruction occurring before the
  first `alt` child of the `rule` element; if it occurs immediately
  before the full stop of the rule, it corresponds to an element or
  processing instruction occurring after the last `alt` of the `rule`.

* as a child or attribute of a `nonterminal`, `literal`, `inclusion`,
  or `exclusion` element.

To ensure that the ixml grammar has an XML representation, any two
pragmas marked `@` and attached to the same construct must have
different expanded names.

When a grammar in XML form is serialized into ixml form, extension
attributes appearing on the `rule` element may be serialized either on
the left-hand side of the rule or before the full stop.  Pragmas
attached to a symbol in the right-hand side of a rule may be
serialized either before or after the mark; the two positions are
equivalent.

For attributes, the attribute name is the QName of the ixml pragma 
and the attribute value is the pragma data. 

For processing instructions, the PI name is the QName of the 
ixml pragma and the PI value is the pragma data. 

For extension elements, the element name is the QName of the ixml
pragma and the pragma data appears as character data within a child
named `pragma-data`.  Other child elements may follow the
`pragma-data` element; their content is required to be reconstructible
from the pragma data and the fallback expression, but they may express
the information in a more convenient form.  (For example, the pragma
data may be a structured expression which a conforming application
will parse; the parsed form of the pragma data may be enclosed in the
pragma.)  In this way we ensure that the ixml and XML forms of a
grammar contain the same information, although the XML form of the
grammar may be easier to process by machine.

#### Annotating symbols, rules, or grammars

Viewed the other way around, as described in the Desiderata, pragmas
can apply to symbols, rules, to a subset of rules, or to the grammar
as a whole, as follows:

* Pragmas applicable to one occurrence of one symbol appear in ixml 
  before that symbol, either before or after the mark if any; in XML
  they appear as attributes or children of the corresponding XML
  element (`nonterminal`, `literal`, etc.).

* Pragmas applicable to one rule appear in ixml either before the 
  left-hand side of that rule (after the mark) or before the full stop 
  of the rule; in XML they appear as attributes or children of the 
  `rule` element.

  Note that while we speak of the pragma as applying to the rule,
  it may in practice apply more narrowly to the symbol on the
  left-hand side of the rule, e.g. to provide a default value for
  some property which may be overridden on individual occurrences
  of the nonterminal, just as marks in ixml do now.

* Pragmas applicable to a set of rules appear in ixml before the first
  rule of the set and in XML before the first `rule` element of the
  set.  N.B. there is no syntactic method for specifying the last rule
  of the set.  If it matters, it must be handled semantically in the
  specification of the pragma.  Any software that does not understand
  or implement the pragma in question may and should assume that the
  pragma applies to all following rules.  (It is not clear exactly
  what use a parser that doesn't understand the pragma would make of
  that information; we specify this only out of an abundance of
  caution.)
  
* Pragmas applicable to the grammar as a whole appear the first rule.

#### An example

For example:

````
    [my:pitch C#]
    ^ [my:color blue] a = b, [@my:flavor vanilla] c? [my:spin ...].
````

The corresponding XML form is:

````
    <my:pitch>
        <pragma-data>C#</pragma-data>
    </my:pitch>
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

Annotations appearing between rules in the ixml correspond to nodes in
the XML appearing as children or attributes of the `ixml` element. In
the example, this is the case for the `my:pitch` pragma.

Annotations appearing in the ixml between the mark and the nonterminal
on the left-hand side of a rule correspond in the XML to attributes or
children of `rule` elements. In the example, this is the case for the
`my:color` pragma.

Annotations appearing immediately before an occurrence of a symbol in  
the right-hand side of an ixml rule pertain to the occurrence of that
symbol and correspond to attributes or children of the corresponding
element in the XML grammar.  In the example, this is the case for the
`my:flavor` pragma on the nonterminal *c*.

Annotations appearing before the full stop at the end of the rule
pertain to the rule as a whole and correspond to extension elements
appear as the last children of a `rule` element.  In the example, this
is the case for the `my:spin` pragma.


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

We define the namespace 'http://example.com/ixml-namespaces" (*final
decision on namespace name pending*) as providing for namespace
bindings, and we adopt the convention that a prefix `ppp` is bound to
a namespace name `nnn` if a pragma of the form

````
[@nsd:ppp nnn]
````

is encountered in a context where the prefix *nsd* is bound to
"`http://example.com/ixml-namespaces`".

To bootstrap the process, we adopt the principle that a 
pragma of the form

````
    [@ns:ns http://example.com/ixml-namespaces]
````

binds the prefix *ns* to that namespace.

That is, a pragma-aware processor must be on the alert for pragmas
with the following properties:

* In the pragma's QName, the prefix and local name are the same 
  NCName (non-colonized name). 

* The pragma's data is the magic namespace name
  "`http://example.com/ixml-namespaces`".

When that pragma is found, it is interpreted as binding prefix *ns*
(whatever it might be) to the indicated namespace.  Any subsequent
pragma with a QName using that prefix and a URI as pragma data is to
be interpreted as a namespace declaration in the obvious way.

The corresponding constructs in the XML grammar are (a) a namespace
declaration binding the prefix *ns* to the given namespace and (b) an
attribute with the qualified name *ns:ns* with the value
"`http://example.com/ixml-namespaces`".

*(Alternatively, we could follow the example of XML namespaces and
reserve some string for namespace bindings, but this example is trying
to show a way to do this that does not trample over what should be the
user's choice of names.  Note that either way, at least one thing must
be specified in the spec for the bootstrapping process to work:
either a magic prefix, analogous to the* `xmlns` *prefix of the XML
Names recommendation, or a magic URI as shown here.)*

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
    <ixml
        nsd:nsd="http://example.com/ixml-namespaces"
        nsd:x="http://example.org/NS/existential"
        nsd:y="http://example.com/NS/yoyo" >
      <rule name="x:sentence" >
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

An ixml parser supporting these namespace pragmas will emit
appropriate namespace bindings on the `x:sentence` element and the
prefixed names in the grammar will serialize in instances as prefixed
names in the XML, with appropriate namespace bindings.

This example does not define a capability for changing namespace
bindings within a document.  It's an example.

		  
### Renaming 

Using pragmas to specify that an element or attribute name
serializing a nonterminal should be given a name different from the
nonterminal itself. (As in Steven Pemberton's proposal for element
renaming.)

In the following grammar, the two forms of month have different 
syntaxes, so they are required to have different nonterminal names, 
and so they are required to be serialized using different XML element 
names.

We define a renaming pragma which specifies the name to be used
when serializing a nonterminal as XML.  A parser which does not
support the pragma will produce results in which some months
are named `month` and others `nmonth`; a parser which does
support the pragma will call them all `month`.

````
    [@nsd:nsd http://example.com/ixml-namespaces]
    [@nsd:sp https://lists.w3.org/Archives/Public/public-ixml/2021Oct/0014.html]

	date: day, " ", month, " ", year.
	day: d, d?.
	month: "January"; "February"; etc.
	year: d, d, d, d.

	iso: year, "-", [sp:rename month] nmonth, "-", day.
	nmonth: d, d.
````

The namespace bindings in the example assume namespace pragmas as
described above.  Since we require pragmas to be associated with
extended names, some mechanism for binding shortnames to namespaces is
required for convenience.  If we wish, however, we can formulate this
example with a literal URI-qualified name.  In that case, the *iso*
rule would read as follows.

````
	iso: year, "-", 
        [Q{https://lists.w3.org/Archives/Public/public-ixml/2021Oct/0014.html}:rename month] nmonth, 
        "-", day.
````

### Name indirection 

Using pragmas to specify that an element or attribute name should be
taken not from the grammar but from the string value of a given
nonterminal.

### Rule rewriting

Using pragmas to specify that a rule as given is shorthand for a set
of other rules.  Consider the following simple grammar for
arithmetic expressions.

````
expr: term; expr, addop, term.
term: factor; term, mulop, factor.
factor: number; var; -'(', -expr, -')'.
...
````

We might find it inconvenient that the number 42 is represented as
````
<expr>
    <term>
        <factor>
            <number>42</number>
        </factor>
    </term>
</expr>
````

One simple rule to simplify the XML representation of sentences in
this language is to specify that if an element *E* has only one child,
*E* should not be tagged and only the child should appear in the XML.

We can do this in ixml by expanding the grammar, splitting each
nonterminal into two rules, one producing a visible serialization and
one hiding the nonterminal on serialization.

````
-EXPR: TERM; expr.
expr: EXPR, addop, TERM. 
-TERM: FACTOR; term.
term: TERM, mulop, FACTOR. 
-FACTOR: number; var; -'(', EXPR, -')'. 
...
````

Now 42 parses more simply as `<number>42</number>`.

The rewrite is mechanical enough that we can automate it, and
error-prone enough that it may be worth automating.  If a rule has
some right-hand sides guaranteed to produce at most one child each and
some guaranteed to produce at least two children each, it's split into
two rules.  The first gets a new nonterminal and has the original
single-child right-hand sides as alternatives, as well as a reference
to the original nonterminal.  It's marked hidden.  The second rule
gets the original nonterminal.  All references to the original
nonterminal are changed to be references to the new nonterminal.

If we call the relevant pragma *rewrite:no-unit-rules*, or more
briefly *r:nur*, the grammar takes the following form.  Note that in
order to ensure that the first pragma is correctly interpreted as
belonging to the first rule and not to the grammar as a whole, we must
specify an explicit mark for the first rule.  We specify one for the
second rule as well just for visual parallelism.  (In practice, we
also need a rule that means "don't rewrite the entire rule, but
replace references to rules rewritten using *r:nur*; we call this
second pragma *r:ref*.)

````
^ [r:nur] expr: term; expr, addop, term.
^ [r:nur] term: factor; term, mulop, factor.
- [r:ref] factor: number; var; -'(', -expr, -')'.
...
````

The XML representation of this grammar can plausibly exploit the
ability of extension elements to contain an XML representation of the
new rules.  Both the `r:nur` and the `r:ref` elements within a rule
instruct the implementation to replace the enclosing rule with the
rules appearing as children of the extension elements.

````
    <ixml xmlns:r="...">
      <rule name="expr" mark="^">
    
        <r:nur>
          <pragma-data/>
      
          <rule name="EXPR" mark="-">
            <alt><nonterminal name="TERM"/></alt>
            <alt><nonterminal name="expr"/></alt>
          </rule>
      
          <rule name="expr" mark="^">
            <alt>
              <nonterminal name="EXPR"/>
              <nonterminal name="addop"/>
              <nonterminal name="TERM"/>
            </alt>
          </rule> 
        </r:nur>
    
        <alt><nonterminal name="term"/></alt>
        <alt>
          <nonterminal name="expr"/>
          <nonterminal name="addop"/>
          <nonterminal name="term"/>
        </alt>
      </rule>
  
      <rule name="term" mark="^">
        <r:nur>
          <pragma-data/>
          
          <rule name="TERM" mark="-">
            <alt><nonterminal name="factor"/></alt>
            <alt><nonterminal name="term"/></alt>
          </rule>
          
          <rule name="term" mark="^">
            <alt>
              <nonterminal name="TERM"/>
              <nonterminal name="mulop"/>
              <nonterminal name="factor"/>
            </alt>
          </rule>
        </r:nur>
        
        <alt><nonterminal name="factor"/></alt>
        <alt>
          <nonterminal name="term"/>
          <nonterminal name="mulop"/>
          <nonterminal name="factor"/>
        </alt>
      </rule>
      
      <rule name="factor" mark="-">
        <r:ref>
          <pragma-data/>
          <rule name="factor" mark="-">
            <alt><nonterminal name="number"/></alt>
            <alt><nonterminal name="var"/></alt>
            <alt>
              <literal sstring="(" tmark="-"/>
              <nonterminal name="EXPR" mark="-"/>
              <literal sstring="-" tmark="-"/>
            </alt>
          </rule>
        </r:ref>
        <alt><nonterminal name="number"/></alt>
        <alt><nonterminal name="var"/></alt>
        <alt>
          <literal sstring="(" tmark="-"/>
          <nonterminal name="expr" mark="-"/>
          <literal sstring="-" tmark="-"/>
        </alt>
      </rule>
      ...
    </ixml>
````



### Tokenization annotation and alternative formulations.

We can use pragmas to annotate nonterminals in an ixml grammar to
indicate that they define a regular language and can be safely
recognized by a greedy regular-expression match.

For example, consider the grammar for a simple programming language.
A processor might read programs a little faster if it could read
identifiers in a single operation; this will be true if when an
identifier is encountered, the identifier will always consist of the
longest available sequence of characters legal in an identifier.  In
the toy Program.ixml grammar, the rule for identifiers is:

````
    identifier:  letter+, S.
````

We can annotate *identifier* to signal that it's safe to consume an
identifier using a single regular-expression match by using a pragma
in a 'lexical scanning' (ls) namespace:

````
    [ls:token] identifier:  letter+, S.
````

The rules for comments in ixml itself offer another wrinkle.  

````
      comment: -"{", (cchar; comment)*, -"}".
      -cchar: ~["{}"].
````

Within a comment, any sequence of characters matching *cchar* can be
recognized in a single operation; there is no need to look for
alternate parses that consume only some of the characters.  So we
annotate the grammar and supply an alternative formulation of
*comment* that replaces it with two new rules:

````
      ^ [ls:rewrite
              comment: -"{", (cchars; comment)*, -"}". 
              [ls:token] cchars:  cchar+. 
		  ]
      comment: -"{", (cchar; comment)*, -"}".
      -cchar: ~["{}"].
````

Or we may find it easier to read if we inject the alternative
formulation after, not before, the existing rule:

````
      comment: -"{", (cchar; comment)*, -"}"
          [ls:rewrite 
                  comment: -"{", (cchars; comment)*, -"}". 
                  [ls:token] cchars:  cchar+. 
		  ].
      -cchar: ~["{}"].
````

Either way, the rewrite contains an alternative formulation of the
grammar which recognizes the same sentences and provides the same XML
representation but may be processed faster by some processors.


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


*Example:  synthesized value attribute and inherited environment
 attribute with variable bindings, for arithmetic expressions with
 'let'.*

[Left as an exercise for the reader.]


## Open issues

* Ideally we would prefer to allow annotations on rules to precede the
mark on the left-hand side; an earlier version of the bracket-QName
proposal did allow them there, rather than after the mark.  The
current version was changed in order to allow pragmas at the beginning
of a grammar to be attached to the grammar as a whole.

* One result is that while for pragmas on symbols in a right-hand side
  it doesn't matter whether they come before or after the mark, on the
  left-hand side it does matter.  It might be less confusing to
  require that pragmas follow the mark on the right-hand side, to make
  it parallel to the left-hand side.  Or it might be less irritating
  to allow them either before or after the mark.  At the moment, the
  proposal takes the second course.

* The fact that extension elements can contain things that are
implicit but not explicit in the ixml form means that a schema for
the visible-XML form of a grammar, as described here, requires
manual intervention and not just a mechanical derivation from the
ixml grammar for ixml.  That will make some people nervous, as
it makes us.  But at the moment, it says here that this is the right
compromise.

## Decisions to be made by the group

* What name should be used for the magic namespace-binding namespace?
  In the examples, we use "`http://example.com/ixml-namespaces`".

* Alternatively, should the spec provide a magic namespace-binding
  prefix analogous to `xmlns`?

* *I could have sworn there were more things to put here.*
