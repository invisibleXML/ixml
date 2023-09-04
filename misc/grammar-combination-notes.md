# iXML: Combination of iXML grammars
John Lumley - 2023sep04

Some notes about aspects of combining iXML grammars - merely for discussion.

Combining iXML grammars involves principally two different activities:

1. Declaring which grammars should be combined ('Referencing the Grammar'), and
1. How rules from these grammars should be selected, combined and/or modified ('Altering Rulesets')

These declarations could either be made in some higher-level combination declaration, outside of iXML syntax, 
such as an XML-based syntax:

     <combine>
         <grammar href="abc.ixml" start-rule="top"/>
         <grammar href="def.ixml">
            <rename from="def" to="ghi"/>
         </grammar>
      </combine>

or added as textual but structured decorations to (the start of) one of the combining iXML grammars, 
such as in the grammar `abc.ixml`:
   
      {[ include def.ixml 
        rename def ghi ]}
      
      top: a.
      a: ghi.

where the combination decoration is separable from the grammar itself, and presumably the grammar `def.ixml`contains
a rule for the non-terminal `def`  which we rename to `ghi` to provide a matching non-terminal to that required for the rule `a`.

The rest of this discussion does not consider which of these forms should be used, 
but the examples tend to describe the declarations as text contained within a combining grammar

For some of the rest we will use an iXML grammar, `dates.ixml` as an example:

      ixml version "1.0".

      date: day, sep, month, sep, year .
      day: -"0"?, digit | ["1"|"2"], digit | "3", ["0"-"1"] .
      -digit: ["0"-"9"] .
      month:   "Jan" | "Feb" | "Mar" | "Apr" | "May" | "Jun" 
             | "Jul" | "Aug" | "Sep" | "Oct" | "Nov" | "Dec" .
      year: "19" | "20", digit, digit .
      -sep: -" " .

## Referencing the Grammars
The first requirement is to identify *which* grammars should be combined. 
I can see at least two distinct possibilities:

1. URI references to the target grammar (text) file, either absolute or relative to the import/inclusion declaration source 
    (i.e. the XML structure in the first case above or the iXML grammar file in the second.)
1. Reference though some sort of implementation-supplied 'library' of named (and versioned?) grammars.
    Similarly to XSLT package combination, this may allow for multiple versions of grammars to be handled.

The first of these is undoubtedly the simplest - implying that the 'file' containing the combination directive has some
value for its URI, against which any relative reference can be resolved.

The second requires an agreed specification for 'naming' and 'versioning' an iXML grammar, 
such that an implementation can choose an 'acceptable' or 'preferred' version of the appropriate grammar for combination. 
If this is the adopted scheme, at this stage I can see reusing the mechanism of version values and selection from [XSLT packages](https://www.w3.org/TR/xslt-30/#package-versions)
as a viable choice.

My choice  would probably be the URI reference method, as it is pretty well-understood and there are simple mechanisms 
to recover source grammars via absolute or relative URIs. The second would sorting out a naming scheme for grammars.


Norm Tovey-Walsh has listed some potential properties associated with this phase (thanks Norm!): 
- **INC-BY-REF. Incorporate another grammar by reference**:  
   URI references to other grammars may be absolute or relative to the 'incorporating'' grammar

## Altering rulesets
The second requirement, which is much more complex,
involves how the rules being combined should be chosen and potentially modified.

There are a few primary requirements, 
such as the result of combination needs itself to be a valid grammar, 
that can further be combined with other grammars, others that are more 'local' to the rules 
or incorporated grammars themselves.

Norm Tovey-Walsh has listed a number of potential properties associated with this phase (thanks Norm!): 

- **TRANSITIVE. Combining grammars is transitive**:  
  If a grammar “A” is defined by combining it with a grammar “B”, 
  it should still be able to combine another grammar with “A”. 
  The rules for combining grammars should support this kind of transitivity as straightforwardly as practical.
- **OVERRIDE-NT. Override a nonterminal** :  
  When combining a grammar, 
  it may be useful to override one or more of the nonterminals in the grammar being combined.
  For example, I might wish to incorporate `dates.ixml` but spell out the month names in full, 
  or allow them to be spelled in French.
- **AVOID-COLLISION. Avoid collision in nonterminal names**:  
   If reuse becomes common, 
   it’s likely that some grammars will define the same nonterminal names in different ways. 
   A user might, for example, wish to combine `dates.ixml` into a grammar
   even though that grammar has a different, and independent, nonterminal named “day”.
- **NT-COMBINE. Define an alternative for a nonterminal**:  
  Sometimes, it will be useful if the host grammar can override a nonterminal (OVERRIDE-NT).
  At other times, it may be useful if the nonterminal can be brought in without a collision (AVOID-COLLISION). 
  Alternatively the grammar author may want the imported nonterminal to be taken
  as an alternative for a nonterminal already defined in the host grammar.
- **RENAME-NT. Rename a nonterminal**:  
  A user might wish to combine a grammar with `dates.ixml` 
  but to (effectively) change the name of the “date” nonterminal. 
  That is, to arrange for a nonterminal named “prose-date” that matches the same input
  as the “date” nonterminal in dates.ixml.
- **NT-VISIBILITY-EXPORT. Define the exported visibility of nonterminals**:  
  The author of a grammar like `dates.ixml` might wish to limit the nonterminals visible when
  it’s combined with other grammars. In other words, the author might wish to stipulate that
  the nonterminals “date”, “year”, “month”, and “day” are exposed, 
  but to keep the definition of (and perhaps even the existence of) the nonterminals “digit” and “sep” private.  
  This is more a property of the *exporting* grammar than the incorporating and
  is analogous to the way APIs in many programming languages allow a
  module author to make explicit commitments about a public API,
  while keeping implementation details hidden so that they may be changed
  without breaking code that uses them.
- **NT-VISIBILITY-ACCEPT. Define the imported visibility of nonterminals**:  
  An author importing a grammar like `dates.ixml` might want to limit the imported nonterminals that are visible
  and thus can be referenced in the incorporating grammar.
  Pulling all of the (exported) nonterminals into the host grammar may be undesirable.

I'm going to explore these in more detail through example, where a grammar *incorporates* another.
     
     {[import "dates.ixml" 
      {accept date}
      {override @year: digit, digit, digit, digit. }
      {rename month shortMonth}   
      ]}
      
*Note*: The difference between *import* and *include* can be associated with whether
the *incorporating* grammar (in the case of *import*) or the *incorporated* grammar (in the case of *include*)
defines the *starting rule* for the combined grammar, by virtue of their rules appearing 'first' in the combined set.  
It is also possible that during importation, automatic rule overriding could be supported 
(rules in the *importing* grammar taking precedence), 
whereas under inclusion duplicately named non-terminal rules would (or should?) raise an error.


We can describe the syntax of the declaration using an iXML grammar: 

    combine: @type, s, @source, (s, param++s)?,s?.
    
    type: "include" ; "import".
    
    -s: [Zs;#9;#a;#d]+.

    {The (relative) source URI of the grammar to be imported, surrounded by discarded quotes. 
     Currently this can have a prefix 'ancestor' step, 
     but I will generalise this to a 'path' or even a relative/absolute URI.
     }
    source: -'"',"../"?,[L;'.';N]+,-'"'.
    
    -param: accept | override | rename.

    { Accept the named non-terminal, and all required non-terminals therefrom.
     In the absence of any accept, all non-terminals are included (i.e. effectively '*')
     }
    accept: -"{accept",s,@nonTerm,s?,-"}".

    {Override the named non-terminal, which will be excluded from the import.
     Either the new definition of the non-terminal can be provided in this parameter, e.g.
          override -foo:bar,'+',charlie.
     or the definition can be 'extended' (similar to the += operator) , e.g.
          override mulop |= ["%"].
     or the new definition can be provided in the body of the importing grammar.
     We could choose to link to 'rule' from the iXML grammar here, but it is easier to pickup
     all relevant text and then parse it subsequently.
    }
    override: -"{override",s,  (@nonTerm;  mark?,@nonTerm,s?,(-[":="]; @additional),-general),    -"}".
    additional: ["|,"],-[":="].
    
    { Rename the definition and *all* references to the given non-terminal, 
      with a possible new mark on the references.
    }
    rename: -"{rename",s,@from,s,mark?,@to,s?,-"}".

    nonTerm: name.
    from: name.
    to: name.

    @mark:["^@-"].

    general: ~["{}"]+.

    @name: namestart, namefollower*.
    -namestart: ["_"; L].
    -namefollower: namestart; ["-.·‿⁀"; Nd; Mn].

which, when used to parse the combination declaration above yields the following XML:

      <combine type="import" source="dates.ixml">
         <accept nonTerm="date"/>
         <override mark="@" nonTerm="year">  digit, digit, digit, digit. </override>
         <rename from="month" to="shortMonth"/>
      </combine>

### Accepting rules
A directive such as:

      accept month

requires the rule for `month` to be included from the incorporated grammar, *and all the rules that are reachable therefrom*, i.e. any rules that are needed to parse a `month`. In this case of course there are no additional rules required, but

      accept year
    
would require the rule for `digit` to be included, as well as that for `year`. A reasonable default in the absence of an `accept` directive, would imply

      accept *      
that is, include *all* rules. 

We could of course have error conditions - such as if the requested rule is absent from the incorporated grammar. We might also permit the *name* term to be a pattern or a sequence, such as:

      accept year month da*

which would add `date` and `day` by pattern match as well as `month` and `year`. (And in this case, all rules in `dates.ixml`)
 
### Renaming rules

There may be cases where we wish to rename some rules included from the incorporated grammar, such as:

      rename month shortMonth
In this case the rule for `month` in the incorporated grammar, and all references to it within that grammar, will be renamed to `shortMonth`, presumably so that the non-terminal `month` 
may be alternately defined and used in the incorporating grammar. 
A generalisation of this could use patterns and expressions to identify and perform such renaming, such as:

    rename * Dates$0
which implies that all rule names and references in the incorporated grammar will have a prefix `Dates` prepended, e.g. `Datesyear`, `Datesdigit` etc, 
where `$0` is an interpolation of (part of) the matched name - in this case following the regurlar expression convention to mean the whole pattern matched. 

Such a *whole grammar* renaming scheme could be used to implement the **AVOID-COLLISION** requirement described above.
### Overriding rules
There are several possibilities here:

- The simplest is where a *replacement* for a rule in the incorporated grammar is provided in the incorporating grammar.
   This could be declared in either of two ways:

       ...
       {override year}
       ]}
       ...
       year: digit, digit, digit, digit.
    where the rule for the replacement is provided in the main body of the grammar, or             

       ...
       {override year: digit, digit, digit, digit.}
       ]}        
     where the replacement rule is given in the `override` declaration itself. 
     Which is preferred may be a matter of style.
     
     There are issues here about whether it should be an error if the overridden rule *doesn't* exist in the incorporated grammar.
     
- The most drastic could be a declaration that *any* rule provided in the incorporating grammar supercedes (and replaces) any rule of the same name in the incorporated grammar, such as:

      ...
      {override *}
      ]}
      month: "Januar";"Februar";"Marz"....
   where we have replaced the short English month names with full-form German      
- A more complex mechanism may modify an incorporated rule by adding additional alteratives or requirements,
  in a manner akin to `+=` and similar operators in many programming languages. Two simple forms spring to mind:
 
      override month |= "January";"February"....     
  which adds full-month names as permitted values for `month` in addition to the short forms already defined, or
  
      override year ,= ("AD";"CE").
  which adds the additional requirement that a year must be suffixed with either `AD` or `CE`. 
  Both of these imply adding *to the end* of a set of alternatives within the existing rule. These are equivalent to rewrites:
  
      R |= X → R = existing R body | X.
      R ,= X → R = (existing R body), X.
      
  (Performing such rewrites in the XML parse of the existing non-terminal rule bodies is likely to be easier.) 
  More complex modification schemes could be considered, such as a *prepend*:
  
      R =, X → R = X, (existing R body).
      
  (Perhaps the *append* should be `=,` and the *prepend* `,=`.)
  Anything more complex is likely to prove cumbersome.      

- Overiding an imported rule with reuse of its imported declaration could be another option:

      override month = -"Month of ", $original.
  where `$original` refers to the non-terminal `month` rule in the imported grammar. 
  This would mean that only `Month of Jan`, `Month of Feb` etc. would be recognised. 
  Presumably the imported `month` non-terminal rule would be renamed, an its direct serialisation suppressed.
  This is similar to the use of the [$xsl:original](https://www.w3.org/TR/xslt-30/#refer-to-overridden) reference construct used in XSLT package overriding.
  (*Note* - this particular overriding case could also be declared by a *prepend* form as described in the previous case.)
  ) 