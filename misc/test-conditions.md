# Test conditions for ixml parsers

C. M. Sperberg-McQueen

2021-07-01

This is a list of the conditions that I think need to be exhibited in positive test cases, in order to reach the grammatical equivalent of what Glenford J. Myers calls 'condition coverage'.  Condition coverage (in case you have misplaced your copy of Myers just for the moment) is a white-box coverage measure saying that for every condition tested in the code, there should be test cases making that condition take on each possible value at least once.  (So if you have code governed by IF A > 0 and B = 2, you need test cases for A > 0, A =< 0, B = 2, and B <> 2, which don’t all need to be separate.)

With respect to positive test cases, I take the grammatical equivalent of that coverage level to be that for each RHS of a reachable nonterminal NT, expressions of the form shown below require tests as described:

- `E?`  (one *E*, no _E_)
- `E+` (one _E_, more than one _E_)
- `E*` (no _E_, one _E_, more than one _E_)
- `E; F` (NT is an _E_; NT is an _F_)
- `["ab"]` (NT is realized using "`a`"; NT is realized using "`b`")
- `["a" - "f"; "0" = "9"]` (NT is realized using something in the range "`a`" - "`f`"; NT is realized using the range "`0`" - "`9`")

Adding descriptions of negative test cases is relatively straightforward, but I did this exercise manually, not automatically, and I did not attempt to make a list of negative cases to be covered.  It produced a list of 87 conditions that should be exercised by positive test cases.

Because I worked manually, not automatically, I may well have glided over some things that should not be glided over, but for what it's worth, these are the conditions I noted.  Those marked !! are those that are *not* exhibited in the grammar of 9 June 2021 as I went through it just now.

To do:

- Automate generation of lists of this kind (from a grammar, generate a list of conditions to be tested in positive test cases).

- Automate generation of tool to examine a set of ixml test cases (specifically, the parse trees in the expected results) and produce a coverage report for the test case.


From *ixml*:

1. !! An ixml grammar with a single rule.  (XPath: `ixml[count(rule) = 1]`)

2. An ixml grammar with multiple rules. (XPath:  `ixml[count(rule) gt 1)]`)

From *S*:

3. *S* consisting of empty string. (XPath:  `//S[not(node())]`)

4. *S* consisting of single whitespace character (or single comment).

5. *S* consisting of multiple whitespace character possibly interleaved with comments.

From *whitespace*:

6. *whitespace* including a character in Unicode class Zs (space separators).

7. !! *whitespace* containing a tab.

8. !! _whitespace_ containing a linefeed character.  

9. !! _whitespace_ containing a carriage return character.  

From *comment*:

10. !! empty comment (i.e. "`{}`").

11. comment containing one or more _cchar_ characters.

12. !! nested comment.

From *rule*:

13. A rule with an explicit mark on the left-hand side.

14. A rule with no explicit mark on the left-hand side.

15. !! A rule using "`=`" to separate left- and right-hand sides.

16. A rule using "`:`" to separate left- and right-hand sides.

From *mark*:

17. A mark of "`@`" on a left- or right-hand nonterminal.

18. !! A mark of "`^`" on a left- or right-hand nonterminal.

19. A mark of '`-`' on a left- or right-hand nonterminal.

From *alts*:

20. A set of alternatives containing a single alternative.

21. !! Multiple alternatives separated by vertical bar (`|`).

22. Multiple alternatives separated by semicolon (`;`).

From _alt_:

23. An alternative consisting of a single term.

24. !! An alternative consisting of zero terms.

25. An alternative consisting of more than one term.

From _term_:

26.  A _term_ consisting of a _factor_.

27. A _term_ consisting of an _option_.

28. A _term_ consisting of a _repeat0_.

29. A _term_ consisting of a _repeat1_.

From _factor_:

30. _factor_ realized as _terminal_.

31. _factor_ realized as _nonterminal_.

32. _factor_ realized as parenthesized _alts_.

From _repeat0_:

33. _repeat0_ with separator (_sep_).

34. _repeat0_ with no separator (_sep_).

From _repeat1_:

35. _repeat1_ with a separator (_sep_).

36. _repeat1_ with no separator (_sep_).

From _nonterminal_:

37.  Nonterminal with a mark.

38.  Nonterminal with no mark.

From _terminal_:

39. _terminal_ realized as _literal_.

40. _terminal_ realized as _charset_.

From _literal_:

41. Quoted literal (i.e. _literal_ realized as _quoted_).

42. Encoded literal (i.e. _literal_ realized as _encoded_).

From _quoted_:

43. _quoted_ string realized with a _mark_.

44. _quoted_ string realized with no _mark_.

From *name*:

45. Single-character name.

46. Two-character name.

47. Name with three or more characters.

From *namestart*:

48. !! Name containing the namestart character underscore (`_`).

49. Name containing a namestart character from the Unicode class Ll (lowercase letters).

50. Name containing a namestart character from the Unicode class Lu (uppercase letters).

51. !! Name containing a namestart character from class Lm (modifier letters). 

52. !! Name containing a namestart character from class Lt (titlecase letters). 

53. !! Name containing a namestart character from class Lo (other letters). 

From *namefollower*:

54. Name containing a namestart character (after the initial position).

55. !! Name containing the namefollower character -. 

56. !! Name containing the namefollower character '.' (full stop). 

57. !! Name containing the namefollower character middle dot. 

58. !! Name containing the namefollower character undertie. 

59. !! Name containing the namefollower character overtie. 

60. Name containing a character in Unicode class Nd (decimal digits).

61. !! Name containing a namefollower character from class Mn (nonspacing marks).

From _tmark_:

62. !! A _tmark_ realized as '`^`'.

63. A _tmark_ realized as '`-`'.

From *string*:

64.  A double-quoted string.

65.  A single-quoted string.

From *dstring*:

66.  A string containing a single character. 

67.  A string containing multiple characters.

(Oops.  *sstring* appears to be missing.)

From *dchar*: 

68. !! A double-quoted string containing a doubled double-quote character. 

From *schar*: 

69. !! A single-quoted string containing a doubled single-quote character. 


From *encoded*:

70.  An occurrence of _encoded_ (a character specified in hex) with an explicit _tmark_. 

71.  !! An occurrence of _encoded_ (a character specified in hex) with no _tmark_. 

From *hex*:

72. A _hex_ character in the range 0-9.

73. !! A _hex_ character in the range 'A' - 'F' (as distinct form 'a' - 'f').

74. A _hex_ character in the range 'a' - 'f' (as distinct form 'A' - 'F').

From *charset*:

75.  Character set (*charset*) realized as inclusion.

76.  Character set (*charset*) realized as exclusion.

From *inclusion*:

77. A character set inclusion with an explicit _tmark_.

78.  A character set inclusion with no explicit _tmark_.

From *exclusion*:

79. !! A character set exclusion with an explicit _tmark_. 

80. A character set exclusion with no explicit _tmark_. 

From *set*:

81. !! A character set exclusion or inclusion with no members.

82. A character set exclusion or inclusion with one member.

83. A character set exclusion or inclusion with multiple members, separated by semicolon (`;`).

84. !! A character set with multiple members, separated by vertical bar (`|`).

From *member*:

85. _member_  realized as literal.

86.  _member_  realized as range.

87.  _member_  realized as class.

