# Pragmas for ixml

2021-11-16, rev. most recently 2021-12-04

**Note, 2022-01-02:**  A more compact proposal for
pragmas is [elsewhere in this directory](proposal-S-F.md);
it presents only variants S and F of this proposal and omits
much of the design discussion and all of the samples showing
how pragmas can be used to solve specific use cases.  This
document remains relevant because it covers those topics,
but for current details of the proposed syntax for pragmas
and namespace declarations, see the other document.

This document describes a proposal for adding *pragmas* to the
Invisible-XML specification.

It was prepared by Tom Hillman and
Michael Sperberg-McQueen. It is currently as complete as we expect to make it.

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

In working out the proposal for pragmas, we have come to believe that
in order for pragmas to work as designed, some form of namespace
binding must be available in ixml.  This could be done by inventing
new syntax for namespace bindings, but what we propose here is to use
the syntax of pragmas to declare namespace bindings: the net effect is
that the spec would (a) define a syntax for pragmas and (b) define one
particular set of pragmas that all ixml processors must support.

This document thus includes both a proposal for pragmas and a proposal
for namespace binding, each of which assumes the other.  Each proposal
has two variants (F and V for the pragmas proposal, U and S for the
namespaces proposal).

Contents:
* [Use cases](#use-cases) 
* [Requirements and desiderata](#requirements-and-desiderata) 
* [Design questions](#design-questions) 
* [Pragma proposal(s)](#pragma-proposals)
    * [The brackets-QName proposal](#the-brackets-qname-proposal) 
        * [The ixml form](#the-ixml-form) 
        * [Marks on pragmas in V](#marks-on-pragmas-in-v) 
        * [Marks on pragmas in F](#marks-on-pragmas-in-f) 
        * [The XML form of pragmas in F](#the-xml-form-of-pragmas-in-f) 
        * [The XML form of pragmas in V](#the-xml-form-of-pragmas-in-v) 
        * [Pragmas and other extension mechanism](#pragmas-and-other-extension-mechanisms) 
        * [Annotating symbols, rules, or grammars](#annotating-symbols-rules-or-grammars) 
        * [An example](#an-example)
* [Worked examples](#worked-examples)
    * [Namespace declarations](#namespace-declarations) 
    * [Renaming](#renaming) 
    * [Name indirection](#name-indirection) 
    * [Rule rewriting](#rule-rewriting)
    * [Tokenization annotation and alternative formulations.](#tokenization-annotation-and-alternative-formulations)
    * [Text injection](#text-injection)
    * [Attribute grammar specification](#attribute-grammar-specification)
    * [Pragmas for proposal V](#Pragmas-for-proposal-V)
* [Namespace binding proposals](#Namespace-binding-proposals)
    * [Namespace binding, common rules](#namespace-binding-common-rules)
    * [Namespace binding in proposal U](#namespace-binding-in-proposal-u) 
    * [Namespace binding in proposal S](#namespace-binding-in-proposal-s) 
* [Open issues](#open-issues) 
* [Decisions to be made by the group](#decisions-to-be-made-by-the-group) 
* [References](#references) 

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
of other rules, which can be obtained by rewriting the rule as given.

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
an ixml parser conform to a pre-existing schema.)

* Attribute grammar specification

  Using pragmas to annotate a grammar with information about
grammatical attributes to be associated with nodes of the parse tree,
whether they are inherited from an ancestor or an elder sibling or
synthesized from the children of a node, and what values should be
assigned to them. Grammatical attributes are not to be confused with
XML attributes, although in particular cases it may be helpful to
render a grammatical attribute as an XML attribute.

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
  individual writing a grammar than for this proposal.  The
  desideratum for a pragmas proposal is to make it easy (or at least
  not unnecessarily hard) to write useful fallbacks.

* It should ideally be possible to specify pragmas as annotations
  applying to a symbol, a rule, or a grammar as a whole, and it should
  be possible to know which is which. It is not required that the
  distinction be a syntactic one, however, since it can also be
  expressed by the semantics of the particular pragma.

* It should ideally be possible for processors to generate the XML
  representation of an ixml grammar containing pragmas, even if they
  do not understand the pragmas contained.  And conversely it should
  ideally be possible for processors to write out the ixml form of an
  XML grammar containing pragmas, even if the processor does not
  understand the pragmas appearing in the grammar.

## Design questions

Several design questions can be distinguished; they are not completely
orthogonal.

* What information should be encodable with pragmas?

* What syntax should pragmas have in invisible XML? 

* What representation should pragmas have in the XML form of a
grammar?

* Where can pragmas appear?


## Pragma Proposal(s)

The current proposal for pragmas is given the arbitrary name of
'brackets QName' for discussion; an earlier proposal (the 'hash-QName'
proposal) has been withdrawn, though traces of it may remain in other
documents in this branch.

### The brackets-QName proposal 

In working out the details of the brackets-QName proposal it has
become clear that as initially conceived it requires that ixml be
extended in various ways with mechanisms for:

* Binding prefixes to namespaces so that QNames can be interpreted as
usual in XML and related specifications. (See the *Namespace
declarations* use case below.)

* Serializing a nonterminal as an element or attribute whose name 
is taken not from the grammar (as in ixml as currently specified) 
but from the input data.  (See the *Name indirection* use case below.) 

* Deciding whether to serialize a given nonterminal as an element or
as an attribute based on what is found in the data.  (This may require
nothing more elaborate than what is described in the *Renaming* use
case below.)

Some of these extensions can themselves be introduced using pragmas,
as illustrated in the *Worked examples* section below, but it is clear
that adding so much new functionality to ixml for the sake of pragmas
may feel like a heavy lift to some members of the community group. So
the discussion below describes two variants of the bracket-QName
proposal: a 'fixed-form' variant and a 'variable-form' variant, so
named for the relative fixity or variation in the XML representation
of pragmas in the two forms of the proposal. For brevity they are
often referred to as F and V respectively. Since they have a great
deal in common, they are described in parallel rather than separately.

In both forms of this proposal, pragmas in ixml take the form of a
left square bracket, an optional mark, a QName or a 'URI-qualified
name', the pragma's data, and a right square bracket. Nested pairs of
square brackets are allowed, so pragmas can nest arbitrarily deep.


#### The ixml form

In the ixml form of a grammar, pragmas can occur within whitespace in
several locations:

* before the first rule of the grammar; these pragmas apply to the
  grammar as a whole.

* before a terminal or nonterminal symbol on the right-hand side of a
  rule, before or after the mark if any; these pragmas apply to that
  occurrence of the symbol.

* on the left-hand side of a rule before the rule name, before or
  after the mark if any; these pragmas apply to the rule.

* immediately before the full stop of a rule; these pragmas apply to
  the rule.

Two locations are allowed for pragmas applying to rules, in order to
allow them to appear either first or last.  This is essentially a
rhetorical choice, but an important one as it can make a difference to
readability.

The relevant changes to the ixml grammar are these.  First, in several
rules the options `(mark, S)?` and `(tmark, S)?` are replaced by new
nonterminals which provide for both marks and pragmas.  In some
locations the nonterminal *S* is replaced by *SP* (space-or-pragma),
to allow pragmas to appear as described above.


````
         rule: annotation, name, S, ["=:"], S, -alts, (pragma, SP)?, ".".
  nonterminal: annotation, name, S.
      -quoted: tannotation, -string.
     -encoded: tannotation, -"#", @hex, S.
    inclusion: tannotation,         set.
    exclusion: tannotation, "~", S, set.

          -SP: (S; pragma)*
  -annotation: (pragma, SP)?, (mark, SP)?.
 -tannotation: (pragma, SP)?, (tmark, SP)?..
````

To allow pragmas pertaining to the grammar as a whole to precede the
first rule of the grammar, the production rule for *ixml* is changed.
To ensure that pragmas in the prolog can be distinguished
syntactically from pragmas attached to the left-hand side of the first
rule, pragmas in the prolog are required to be followed by full stops.


````
-SP: (S; pragma)*.
pragma: -"[", @pmark?, @pname, (S, pragma-data)?, -"]". 
@pname: -QName; -UQName. 
-QName: -name, ':', -name. 
-UQName: 'Q{', -ns-name, '}', -name. 
-ns-name: ~["{}"; '"'; "'"]* { oversimplification }. 
@pmark: ["@^?"].
pragma-data: (pragma-chars; pragma)*.
-pragma-chars: ~["[]"]*.
````

Note that these ixml fragments use only the marks and serialization
rules currently supported by ixml. If the variable-form proposal is
adopted, it will probably make sense to add new marks or new
serialization rules, or both.

A simple example illustrates the core syntactic ideas:
````
    [my:pitch C#]
    ^ [my:color blue] a = b, [@my:flavor vanilla] c? [my:spin ...].
````

This fragment assumes that the prefix *my* is bound to some namespace,
by means not shown here (*and to be determined*).


#### Marks on pragmas in V

In the variable-form proposal, the *pmark* signals which of various
XML constructs represents the pragma in the XML form of the grammar:

* An ixml pragma marked `^` corresponds to an extension element. 

* An ixml pragma marked `@` corresponds to an extension attribute. 

* An ixml pragma marked `?` corresponds to a processing instruction.

To ensure that the ixml grammar has an XML representation, any two
pragmas marked `@` and attached to the same construct must have
different expanded names.

Since ixml pragmas marked `@` all correspond to attributes, the
precise location at which the pragmas appear in the ixml form of a
grammar cannot (*or:* must not; *or:* by definition does not) convey
information relevant to the meaning or processing of the pragma.  A
pragma marked `@`, for example, has the same meaning whether it
appears before the first rule in the grammar or after the last rule,
or at some point between rules in the grammar.  Similarly the
positions of pragmas marked `@` relative to other pragmas attached to
the same construct carry no meaningful information.

#### Marks on pragmas in F

In the fixed-form proposal, the *pmark* is included but has no special
meaning for a standard processor, since all pragmas have the same
representation in XML grammars.


#### The XML form of pragmas in F ####

In F, all pragmas in the XML form of a grammar take the form
implicitly described by the grammar fragments shown earlier: a
`pragma` element with attributes named *pname* and *pmark* and a child
element named `pragma-data`.

It is not signaled in the ixml grammar (because ixml has no way to say
it), but other child elements may follow the `pragma-data` element.
Their content is required to be reconstructible from the pragma data
and the fallback expression, but they may express the information in a
more convenient form. (For example, the pragma data may be a
structured expression which a conforming application will parse; the
parsed form of the pragma data may be enclosed in the pragma.) In this
way we ensure that the ixml and XML forms of a grammar contain the
same information, although the XML form of the grammar may be easier
to process by machine.

For example, the ixml pragma `[my:pitch C#]` corresponds to the following
XML pragma

````
<pragma pname="my:pitch">
    <pragma-data>C#</pragma-data>
    ...
</pragma>
````

The ellipsis shows where additional elements not constrained by this
proposal may appear.  The only constraint is that it must be possible
in principle to construct them from the ixml form of the grammar.

It follows from the grammar fragments above that in an XML grammar,
pragmas may occur in different locations which annotate different
parts of the grammar.:

* as a child of the `ixml` element before, between, or
  after `rule` elements.  These correspond to ixml pragmas occurring
  before, between, or after rule elements.

* as a child of the `rule` element, either before all `alt` children
  of the rule or after them. A pragma occurring before the `alt`
  children corresponds to an ixml pragma occurring on the left-hand
  side of a rule; a pragma occurring after the last `alt` child
  corresponds to an ixml pragma appearing in the whitespace before the
  full stop of the rule.

* as a child of a `nonterminal`, `literal`, `inclusion`, or
`exclusion` element. These correspond to ixml pragmas occurring
  immediately before the terminal or nonterminal symbol in question,
  before or after the mark.


#### The XML form of pragmas in V

In the variable-form proposal, XML pragmas may occur in the same
locations when they take the form of elements or processing
instructions.  They also occur as attributes on the parent element.

When a grammar in XML form is written out into ixml form, extension
attributes appearing on the `ixml` element may be serialized either
before the first rule, after the last one, or between any two rules.
Attributes appearing on the `rule` element may be serialized either on
the left-hand side of the rule or before the full stop. Pragmas
attached to a symbol in the right-hand side of a rule may be
serialized either before or after the mark. In all of these cases, the
possible positions are all equivalent.

For attributes, the attribute name is the QName of the ixml pragma and
the attribute value is the pragma data.

For processing instructions, the PI name is the QName of the 
ixml pragma and the PI value is the pragma data. 

For extension elements, the element name is the QName of the ixml
pragma and the pragma data appears as character data within a child
named `pragma-data`. As in proposal F, the element may contain other
XML elements with a structured representation of relevant information.


#### Pragmas and other extension mechanisms

Some XML formats make the provision that any namespace-qualified
attributes and elements may occur in documents, provided their
namespace is not reserved for other purposes.  For example, both XSLT
and XSD provide that namespace-qualified attributes in other namespace
may appear on elements in the core namespace, and both allow what we
might call foreign elements in other locations, although not at all
locations in a document.

In general, the purpose of such provisions is similar to that of
pragmas, so it makes sense to ask how such foreign elements and
attributes relate to the XML pragmas described here.  In particular,
when can they be rendered as pragmas in the ixml form?

Under proposal F, pragmas in XML are always `pragma` elements; foreign 
attributes and elements are not formally pragmas and the ixml spec 
would under proposal F define no correspondence between them and any 
ixml notation. 

Under proposal V, the situation is more complex:

* Non-ixml namespaced attributes on the `ixml`, `rule`, `nonterminal`,
  `literal`, `inclusion`, and `exclusion` elements can be recognized
  as pragmas.

* Non-ixml namespaced elements can be recognized as pragmas if they
  appear in one of the specified locations.

* Processing instructions can be recognized as pragmas if they occur
  in one of the specified locations.

Any pragma recognized can be written out in ixml notation.  In the
case of attributes and processing instructions, the pragma data will
be taken from the value of the node.  In the case of elements, the
pragma data will be the string value of the `pragma-data` element
appearing as a child of the element, if there is one.

Non-ixml constructs not recognized as pragmas cannot be translated
interoperably to ixml form.

#### Annotating symbols, rules, or grammars

As described in the Desiderata, pragmas can apply to symbols, rules,
to a subset of rules, or to the grammar as a whole. There are several
cases.

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
  
* Pragmas applicable to the grammar as a whole appear before the first
  rule.

F and V are the same in this regard.

#### An example

For example:

````
    [my:pitch C#]
    ^ [my:color blue] a = b, [@my:flavor vanilla] c? [my:spin ...].
````

The corresponding XML form in proposal V is:

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

In F, the corresponding XML form is:

````
    <pragma pname="my:pitch">
        <pragma-data>C#</pragma-data>
    </pragma>
    <rule name="a">
        <pragma pname="my:color">
            <pragma-data>blue</pragma-data>
        </pragma>
        <alt>
            <nonterminal name="b"/>
            <option>
                <nonterminal name="c">
                    <pragma pname="my:flavor">
                        <pragma-data>vanilla</pragma-data>
                    </pragma>
                </nonterminal>
            </option>
        </alt>
        <pragma pname="my:spin">
            <pragma-data>...</pragma-data>
        </pragma>
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

*Note that there is a bootstrapping issue here: the proposal made in
this document requires that pragmas be identified by qualified names,
which requires some level of namespace support in ixml itself.  So
there is a certain unavoidable artificiality in the approach taken in
the following discussion, of trying to support pragmas for namespace
declarations without asssuming namespace support in the base ixml.*

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

Alternatively, the prefix *ns* might be bound to the namespace
indicate using a pragma of the form

````
    [@Q{http://example.com/ixml-namespaces}:ns http://example.com/ixml-namespaces]
````

When either form of the pragma is found, it is interpreted as binding
prefix *ns* (whatever prefix that might be) to the indicated
namespace.  Any subsequent pragma with a QName using that prefix and a
URI as pragma data is to be interpreted as a namespace declaration in
the obvious way.

In the XML form for grammars, the corresponding constructs are (a) a
namespace declaration binding the prefix *ns* to the given namespace
and (b) an attribute with the qualified name *ns:ns* with the value
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
The XML representation of the grammar might be (in form V):

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

In form F, the beginning of the grammar is different:

````
    <ixml>
        <pragma name="nsd:nsd">
            <pragma-data>http://example.com/ixml-namespaces</pragma-data>
        </pragma>
        <pragma name="nsd:x">
            <pragma-data>http://example.com/NS/existential</pragma-data>
        </pragma>
        <pragma name="nsd:y">
            <pragma-data>http://example.com/NS/yoyo</pragma-data>
        </pragma>
        ...
````

An ixml parser supporting these namespace pragmas will emit
appropriate namespace bindings on the `x:sentence` element and the
prefixed names in the grammar will serialize in instances as prefixed
names in the XML, with appropriate namespace bindings.

The fallback behavior of a parser that does not support these pragmas  
will be as under the current spec, which someone wearing a  
language-lawyer hat tells us is probably to emit output that lacks
necessary namespace declarations and is technically speaking
well-formed XML but not *namespace-well-formed* XML.

This example does not define a capability for changing namespace
bindings within a document.  It's an example.


### Renaming 

Using pragmas to specify that an element or attribute name
serializing a nonterminal should be given a name different from the
nonterminal itself. (As in Steven Pemberton's proposal for element
renaming.)

In the grammar below, the two forms of month have different 
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
    [@nsd:sp 
    https://lists.w3.org/Archives/Public/public-ixml/2021Oct/0014.html]

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
iso:
  year, "-", 
  [Q{https://lists.w3.org/Archives/Public/public-ixml/2021Oct/0014.html}:rename month] nmonth, 
  "-", day.
````

The fallback behavior of a parser that does not support these pragmas
will be to produce output using both the element name `month` and the
element name `nmonth`.

### Name indirection 

Using pragmas to specify that an element or attribute name should be
taken not from the grammar but from the string value of a given
nonterminal.

Consider the following grammar which recognizes a superset of
a simple subset of XML.  It's a subset of XML for simplicity, and it's
a superset of the subset because a grammar written at this level
cannot enforce the well-formedness constraints of XML.
````
    { A grammar for a small subset of XML, as an illustration. }
    
    element:  start-tag, content, end-tag; sole-tag.
    
    -start-tag:  "<", @gi, (ws, attribute)*, ws?, ">".
    -end-tag:  "</", @gi2, (ws, attribute)*, ws?, ">".
    -sole-tag:  "<", @gi, (ws, attribute)*, ws?, "/>".
    
    attribute:  @name, ws?, "=", ws?, @value.
    @value: dqstring; sqstring.
    -dqstring: dq, ~['"']*, dq.
    -sqstring: sq, ~["'"]*, sq.
    -dq: -['"'].
    -sq: -["'"].
    
    -content:  (PCDATA; processing-instruction; comment; element)*.
    
    PCDATA:  (~["<>&"]; "&amp;"; "&lt;"; "&gt;")*.
    processing-instruction:  "<?", @name, ws, @pi-data, "?>".
    comment:  "<--", commentdata, "-->".
    
    gi: name.
    gi2: name.
    { name is left as an exercise for the reader. }
    
    ws:  (#20; #A; #C; #9)+.
````

Among the input sequences which should be accepted
by this grammar is the following XML representation of a
haiku.

````
<haiku author="Basho" date="1686">
    <line>When the old pond</line>
    <line>gets a new frog</line>
    <line>it's a new pond.</line>
</haiku>
````

We might like an ixml processor to read this and produce
the same XML that any XML parser would produce. (This
desire makes sense only when the ixml processor's results
are supplied to a user in a DOM or XDM or SAX or other
XML API or model.)  What the grammar above will produce
is isomorphic to this result, but not the same (*WARNING:
output produced manually, may be inaccurate*):

````
<element @gi='haiku' @gi2='haiku'>
    <attribute name="author" value="Basho"/>
    <attribute name="date" value="1686"/>
    <element @gi='line' @gi2='line'>
        <PCDATA>When the old pond</PCDATA>
    </element>
    <element @gi='line' @gi2='line'>
        <PCDATA>gets a new frog</PCDATA>
    </element>
    <element @gi='line' @gi2='line'>
        <PCDATA>It's a new pond.</PCDATA>
    </element>
</element>
````

We can use the following pragmas to obtain normal XML from
parsing with the grammar:

* `xp:name` *expression* - specifies that the name under which a
nonterminal is to be serialized is given by the value of the supplied
XPath expression, interpreted with the standard ixml result element as
the context node and with the result coerced to type *xs:string*.

* `xp:serialize` *keyword* - specifies that the nonterminal is to be
serialized as specified by the keyword (which is assumed to be
`attribute`, `element`, or the name of some other XPath node test).

* `xp:drop` - specifies that the nonterminal so annotated is to be
suppressed entirely, along with the entire parse tree dominated by the
nonterminal.'

With these pragmas, we can annotate the *element* and *attribute*
rules appropriately:
````
^ [xp:name @gi] element:  start-tag, content, end-tag; sole-tag.
...
-end-tag:  "</", [xp:drop] @gi2, (ws, attribute)*, ws?, ">".
...
^ [xp:serialize attribute]
  [xp:name @name]
  attribute:  @name, ws?, "=", ws?, @value.
````

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
second rule as well just for visual parallelism.  In practice, we
also need a rule that means "don't rewrite the entire rule, but
replace references to rules rewritten using *r:nur*; we call this
second pragma *r:ref*.

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

The attentive reader will note that the XML form shown is that for the
V proposal; the form it would take in the F proposal should be easily
constructed.

The fallback behavior of a processor that doesn't support these 
pragmas will be to serialize `expr` and `term` elements even when they 
have only one child. 


### Tokenization annotation and alternative formulations

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
alternate parses that consume only some of the characters.  But there
is no nonterminal here that matches all and only non-empty sequences
of *cchar*.  In order to use the *ls:token* annotation here, we must
first rewrite the grammar at this point.  So we introduce an
annotation named *ls:rewrite* to be attached to a single grammar rule
with the meaning that the pragma data provide an alternate form of the
rule.

We can now annotate the grammar and supply an alternative formulation of
*comment* that replaces it with two new rules:

````
      ^ [ls:rewrite
            comment: -"{", (cchars; comment)*, -"}". 
            [ls:token] -cchars:  cchar+. 
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
          - [ls:token] cchars:  cchar+. 
      ].
      -cchar: ~["{}"].
````

Either way, the rewrite contains an alternative formulation of the
grammar which recognizes the same sentences and provides the same XML
representation but may be processed faster by some processors.

The fallback behavior of a processor that doesn't support these
pragmas will be to parse as usual using the grammar as specified.

Note however that there is no guarantee or requirement that the
alternate rules in an *ls:rewrite* pragma be equivalent to the
fallback rules: pragmas may change the behavior of a processor, and
they may change the meaning of an expression (or here the meaning of a
grammar or part of it).


### Text injection

Using pragmas to indicate that a particular string should be
injected into the XML representation of the input as (part of) a text
node, or as an attribute or element. (This can help make the output of
an ixml parse conform to a pre-existing schema.)

### Attribute grammar specification

*Example:  synthesized value attribute for arithmetic expressions.*

Consider the following simple grammar for arithmetic expressions
involving addition and multiplication over single-digit integers.

````
    expr:  expr, s, '+', s, term.
    term:  term, s, '*', s, factor.
    factor:  '0'; '1'; '2'; '3'; '4'; '5'; '6'; '7'; '8'; '9'; 
            -'(', s, expr, s, -')'.
    s:  [#20; #A; #D; #9]*.
````

In an attribute-grammar system, we might define the *value* of an
expression as a synthesized (bottom-up) grammatical attribute
following the rules:

* The value of a *factor* consisting of a single digit is the value of
the integer usually so written: '0' has the value of zero, '1' has the
value of one, etc.

* The value of a *factor* consisting of a parenthesized *expr* is the
value of the *expr*.

* The value of a *term* consisting solely of a *factor* is the value 
of the *factor*. 

* The value of a *term* consisting of a *term* followed by an 
asterisk and a *factor* is the product of the values of the *term* and 
the *factor*. 

* The value of an *expr* consisting solely of a *term* is the value 
of the *term*. 

* The value of an *expr* consisting of an *expr* followed by a
plus sign and a *term* is the sum of the values of the *expr* and
the *term*.

Extending this to handle subtraction, division, and multiple-digit
numbers would be straightforward but require a lot more rules which
would not involve any interesting new principles.

A conventional system for reading attribute grammars and making
parsers which parse input and calculate the values of grammatical
attributes might represent this grammar as follows.  We name the
grammatical attribute *v*. (This example follows roughly the syntax of
Alblas 1991, and like Alblas assumes whitespace is someone else's
problem.)

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
grammar in ixml, we need either (1) to allow multiple rules for the
same nonterminal, or (2) to allow pragmas before connectors like comma
or semicolon, or (3) we need to allow string-to-typed-value functions
in the style of XPath. I'll assume the latter two, along with a
string() function that returns the string value of a nonterminal. With
these assumptions, and the assumption that by means not specified the
prefix *ag* has been bound to an appropriate namespace for
attribute-grammar functionality, the attribute grammar could be
written thus using the brackets-QName syntax:

````
    [@ag:id e0] expr:  [@ag:id e1] expr, s, '+', s, term
            [ag:rule e0.v := e1.v + term.v ].
    [@ag:id t0] term:  [@ag:id t1] term, s, '_', s, factor
            [ag:rule t0.v := t1.v * factor.v].
    factor:  digit [@ag:rule factor.v := number(string(digit))]; 
            '(', s, expr, s, ')' [@ag:rule factor.v := expr.v ].
    digit: '0'; '1'; '2'; '3'; '4'; '5'; '6'; '7'; '8'; '9'.
    s:  [#20; #A; #D; #9].
````

Here *ag:id* is assumed to associate a unique identifier with a
particular instance of a nonterminal, and *ag:rule* is assumed to
contain a set of assignment statements specifying the values of
particular attributes, in a subset of XPath syntax. (A more serious
proposal would need some way to distinguish *e0.v* meaning "the *v*
attribute of *e0*" from *e0.v* occurring as a name which happens to
contain a dot. This is not that serious proposal.)


*Example:  synthesized value attribute and inherited environment
 attribute with variable bindings, for arithmetic expressions with
 'let'.*

[Left as an exercise for the reader.]

### Pragmas for proposal V

In the ideal case, it should be possible to use pragmas defined
as in proposal F to describe the behavior of processors under
proposal V.

*Example to be worked out with list of the required pragmas
and annotated version of the ixml grammar fragments given
earlier.*

The differences between proposals F and V all lie in the
XML representation of pragmas:

* In F, the element and attribute names of the pragma element
  are fixed; in V the element name is assigned dynamically.

* In F, all pragmas are elements; in V, some are attributes and some
  are processing instructions.

* In F, the *pname* and *pmark* appear as attributes on the
  pragma; in V they affect the name and form of the XML pragma 
  but do not appear as content, attributes, or children.

The section above on name indirection illustrates ways to solve the
first and third of these.  We can adapt the pragmas shown there and
add a third for the remaining item, so that we have three pragmas,
which we define in terms of their operation on an XML representation
of the raw parse tree (i.e. the one an ixml processor would produce if
it ignored all marks); a processor might implement the pragma
differently, as long as the result were the same.

The first two of these pragmas are defined to apply to a rule and they
describe the relation of the serialized XML for instances of that rule
to the raw parse tree for that instance.

* `pr:as` *pmark*?: If the *pmark* argument is `^` or absent, the
  nonterminal is serialized as an element; if it's `@`, the
  nonterminal is serialized as an attribute; if it's `?`, the
  nonterminal is serialized as a processing instruction.

* `pr:name` *pname*: The *pname* is specified by an expression (we
  will assume a small subset of XPath).  If the value is a lexical
  QName, that QName is the name of the corresponding XML node; if the
  value is a URIQualifiedName (of the form
  Q{namespace-name}local-name), then a prefix is chosen, a lexical
  QName is formed from that prefix and the specified local name, and
  any namespace declarations necessary to bind the chosen prefix to
  the specified URI are created and added to an appropriate element.

The third pragma applies to nonterminals in a right-hand side.

* `pr:drop`: The parse tree rooted in the nonterminal annotated with
  `pr:drop` does not appear in the serialization.  Since that subtree
  may be used (e.g. to supply an element name), it is important as a
  practical matter that this pragma be interpreted after the others.

With these three pragmas, the ixml rule for *pragma* can be annotated
as follows:

````
    ^ [pr:as string(pmark)]
      [pr:name string(pname)]
      pragma: "[", [pr:drop] @pmark?, [pr:drop] @pname, (S, pragma-data)?, "]". 
````

Alternatively, we could define a single pragma with a sequence of
comma-separated property/value pairs, using parenthesized
comma-separated values to specify multiple values:

````
    ^ [pr:v name: string(pname), 
        as: string(pmark),
        drop:  (pmark, pname)]
      pragma: "[", @pmark?, @pname, (S, pragma-data)?, "]". 
````

Note: The `pr:v` (for 'pragmas proposal V') pragma seems less general
than the earlier set, but it feels slightly lighter-weight.

Note: The `pr:as` pragma is very ad hoc; a more general approach would
say that its argument should be one of 'element', 'attribute',
'processing-instruction', 'comment', 'text'.  But then we would need
some way of saying "if the string value of *pmark* is '^', then
'element', otherwise ...", and that seems likely to lead to a long
slide down a slippery slope to a Turing-complete programming
language.  One of the nice things about defining your own pragmas is
that you can give them ad hoc semantics if you need to, without
spoiling things for other people.


## Namespace binding proposals

As described in the worked example for *Namespace declarations* above,
there are at least two ways for ixml to use pragmas provide the
namespace declaration functionality necessary to allow QNames to be
used in pragmas.  We call them U (for 'user-specified namespace
binding prefix') and S (for 'specification-defined namespace binding
prefix').

The two proposals differ in how pragmas are recognized as
namespace-binding pragmas but are otherwise similar.

### Namespace binding, common rules

In both proposal, the ixml spec requires that conforming processors
understand the syntax for pragmas (this is implicit in the rule that
they follow the syntax for ixml grammars) and that conforming
processors understand and implement namespace-binding pragmas which
work as follows:

* A namespace-binding pragma whose QName has the local name *n* binds
  *n* as a namespace prefix to the namespace whose name by the pragma
  data.

  As is the case for for XML namespaces generally, the pragma data
  should be a legal URI, but ixml processors are not obligated to
  check the URI for syntactic correctness (although they are may do
  so), and normally should not attempt to dereference it.

* All namespace-binding pragmas pertain to the grammar as a whole and
  must be given before the first rule of the grammar.

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

The proposals differ in their rules for how a pragma is recognized as
a namespace-binding pragma.


### Namespace binding in proposal U 

In this proposal, namespace-binding pragmas are those whose QName is
in a particular well-known namespace; a bootstrapping rule is used to
recognize the binding of a user-specified prefix to that namespace.

* A pragma whose QName has the same name as its prefix and its local
  name and whose value is the namespace-binding namespace
  '`http://example.com/ixml-namespaces`" binds the given prefix to
  that namespace.  This pragma must be marked `@`.  For example:

    ````
    [@nsd:nsd http://example.com/ixml-namespaces]
    ````

* The equivalent pragma using a URI-qualified name similarly binds the
  given prefix to that namespace.

  For example:

    ````
    [@Q{http://example.com/ixml-namespaces}:nsd 
        http://example.com/ixml-namespaces]
    ````

In the examples just given, the prefix *nsd* is only an example: the
user can specify any desired prefix to use for namespace bindings.

* Any pragma whose QName has the namespace 
  "`http://example.com/ixml-namespaces`" is recognized as a 
  namespace-binding pragma. 

* Any pragma with an unprefixed name whose local name is bound as a
  prefix to the namespace "`http://example.com/ixml-namespaces`" is
  recognized as a namespace-binding pragma defining a default
  namespace.


### Namespace binding in proposal S

In this proposal, namespace-binding pragmas are recognized by their
use of a reserved prefix in their QName.

* The prefix *ixmlns* is understood by all conforming ixml software as
  bound to the namespace-binding namespace
  '`http://example.com/ixml-namespaces`".

  *Open question: use the name 'ixmlns' or some other name?  Perhaps
  'xmlns'?*

* Any pragma whose QName has the prefix *ixmlns* is recognized as a
  namespace-binding pragma.

* Any pragma with the unprefixed *ixmlns* is recognized as a
  namespace-binding pragma defining a default namespace.



## Open issues

* The fact that extension elements can contain things that are
  implicit but not explicit in the ixml form means that a schema for
  the visible-XML form of a grammar, as described here, requires
  manual intervention and not just a mechanical derivation from the
  ixml grammar for ixml.  That will make some people nervous, as it
  makes us.

* Allow pragmas between `alt` elements / immediately before the
  separator between top-level alternatives in a right-hand side?

  Con: things are complicated enough as it is.  Pro: it would allow
  pragmas to support the attribute-grammar use case.  It would make
  occurrence before, after, or between `alt` elements within a `rule`
  parallel to occurrence before, after, or between `rule` elements
  within the `ixml` element.

  *No.  Make the attribute-grammar example work some other way.*

* How should the prolog be defined?  Several formulations have
  occurred to me, some equivalent and some not. Which is clearest and
  nicest?

  * Inline the full stop:  

        `-prolog: S, pragma*(S, (-'.', S)), S.`

  * Require only one full stop, at the end of the prolog: 

        `-prolog: S, pragma*S, S, -'.', S.`

  * Use a different name for pragmas with full stops, to simplify the
    rule for *prolog:*

        ````
          -prolog: S, Pragma*S, S.
          -Pragma: pragma, S, '.'.
        ````

  * Use the nonterminal *ppragma* rather than *Pragma:*

        ````
          -prolog: S, ppragma*S, S.
         -ppragma: pragma, S, '.'.
        ````

## Decisions to be made by the group

* If the proposal is adopted, which form of the pragmas proposal 
  should be chosen?  V or F?  Or some other variant?

* If the proposal is adopted, which form of the namespace binding 
  proposal should be chosen?  U or S?  Or some other variant?

* If proposal S is adopted, what name should be used for the magic 
  namespace-binding prefix in proposal S?  The proposal above uses 
  *ixmlns*; it might feel more convenient if we use `xmlns`.  If we do 
  so, are we violating the rule that says names beginning with 'xml' 
  are reserved for W3C Recommendations? 

* What name should be used for the magic namespace-binding namespace?
  In the examples, we use "`http://example.com/ixml-namespaces`".

  Should we use "`http://www.w3.org/2000/xmlns/`", to which the prefix 
  `xmlns` is bound by convention? 

* The group may also wish to weigh in on any of the open issues listed
  above, if any are left when this document goes to the group.

* *I could have sworn there were more things to put here.*

* Once the group has resolved the questions just listed, the remaining
  question is: should the proposal as thus refined by adopted for
  ixml 1.0 or not?
  

## References

Alblas 1991.  Henk Alblas, "Introduction to attribute grammars," in
*Attribute grammars, applications and systems:* *International summer
school SAGA, Prague, Czechoslovakia, June 4-13, 1991, Proceedings*,
ed. H. Alblas and B. Melichar (Berlin et al:  Springer, 1991) = LNCS
545, pp. 1-15. 
