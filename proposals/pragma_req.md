# iXML Pragma Requirements
*Updated draft - 2025-02-18*
##### Bethan Tovey-Walsh

----

## Notes on terms
***Annotate*** - a pragma annotates some construct in an iXML grammar, which means that the construct provides the scope for the pragma’s effect. 

***Attach*** - In an iXML grammar, a pragma is always "attached" to some syntactic construct  (which may be the grammar as a whole). This is reflected in the XML version of the same grammar, where the pragma  becomes the child of the construct to which it is attached.

***Recognize*** - a processor “recognizes” a pragma when it identifies the pragma name as the trigger for a behaviour, the details of which are defined by the implementation. 

***Remove*** - A pragma is "removed" from a grammar either a) in fact, by deleting the characters representing the pragma from the grammar itself; or b) in effect, as when the pragma is ignored by a processor because it is unrecognized. 

----

***must (not)*** - indicates a requirement: a proposal for adding pragmas to iXML cannot be accepted if it does something it “must not” do, or leaves undone something that it “must” do, according to the list of requirements accepted by the CG. 

***should (not)*** - indicates a desideratum: failure to satisfy a desideratum is not sufficient reason to reject a proposal for adding pragmas, but competing proposals may be judged in part on how well they satisfy the list of desiderata accepted by the CG. 

***need not*** - a behaviour or feature that “need not” be present is not prohibited, and neither its presence nor its absence affects the validity of an iXML grammar or the conformance of an iXML processor. However, the presence or the absence of such a behaviour or feature is irrelevant in adjudicating between differing proposals for adding pragmas.

----

## Preliminary notes
- The points below are phrased as requirements or as desiderata based on the preference of the person who proposed them for inclusion in this list.
- The CG might therefore make the decision either a) to adopt one of the numbered items as is; or b) to adopt the item with amendments, which might include changing its status from requirement to desideratum or vice versa; or c) to reject the item.

## Foundational rules for pragma behaviour
1. A pragma must not change the semantics of an iXML grammar - that is, it must not cause the processor to produce a parse tree which could never be produced, using the same grammar according to the specification, if the pragma were removed.
   - Examples:
     - A pragma providing dynamic attribute values ***would not*** be conformant. 
     - A pragma to translate all element names into another language ***would not*** be conformant. 
     - A pragma to add namespaces to the XML output of the parse ***would not*** be conformant. 
     - A pragma providing a regex to replace some section of an iXML rule’s right-hand side ***would*** ***only*** be conformant ***if*** the language recognized by the regex were identical to the language recognized by the grammar fragment it was replacing. 
     - A pragma to enforce alphabetical ordering of a given element’s attribute names ***would*** be conformant. 
     - A pragma with rules for selecting a specific parse tree from an ambiguous parse ***would*** be conformant. 
2. Removing a pragma from an iXML grammar must not affect the syntactic validity of that grammar.
   - Examples:
     - A pragma to import rules from an external file ***would not*** be conformant **if** removing the pragma would therefore leave one or more nonterminals undefined in the source grammar. 

## Requirements and desiderata: theoretical principles

### Status of pragmas
3. Support for pragmas must be optional.
4. Pragmas must only be used for communicating with software.
5. Pragmas must be defined in the iXML specification without consideration of, or reference to, the needs of any particular processing software. 

### Parsing and processors
6. It should be straightforward for processors to ignore pragmas they do not recognize.
7. Processors must be able to determine unambiguously whether they recognize a given pragma or not.
8. A pragma must be distinguishable as such from all other grammar constructs, even if the processor in question does not recognize the specific pragma. 

### Attachment
9. Pragmas must be able to attach to an iXML grammar as a whole, individual rules in a grammar, and nonterminals. 
10. Pragmas should also be able to attach to any grammar constructs for which robust use cases can be put forward, bearing in mind the importance of balancing succinctness, expressive power, and readability of grammars. 

### Pragma structure
11. A pragma must have a name (a string by which the processor can recognize the pragma). 
12. A pragma must also permit optional pragma data (a string which can be provided as an input to the code block which the processor will attempt to execute in response to recognizing the pragma name).
13. The legal form of a pragma name must be defined in the specification. 
14. The structure of the optional pragma data following the pragma name must not be defined in the specification.
15. There must be a mechanism by which implementers can ensure that a chosen pragma name will not conflict with any pragma name used in other implementations. 

## Requirements and desiderata: implementation and design details

### Designing pragmas
16. Simplicity of syntax and semantics should be the most important priority in adding pragmas to iXML. 

### Communication with the user
17. The processor need not inform the user that it has encountered an unrecognized pragma. 
18. Recognized but ill-formed pragmas need not cause the parse to fail, or cause the processor to issue a warning. That is, if a processor recognizes a pragma identifier, but the pragma data cannot be parsed successfully as input to the relevant code block, the response is wholly a matter for the implementer. 

### Attachment
19. A pragma’s attachment to a specific syntactic construct must be unambiguous to software for parsing iXML grammars.
20. The relationship between a pragma and the construct it attaches to should be clear and unambiguous to human readers, in both iXML and XML notation. 



