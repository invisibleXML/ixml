# The Ambiguous Umbrella

At the iXML CG meeting of
[11 November 2025](https://www.w3.org/2025/11/11-ixml-minutes.html),
it was proposed that several of the topics that have come up are, in one way or
another, related to resolving ambiguity.

This document is an attempt to formulate an “umbrella” topic for collecting
together examples (especially), thoughts, and ideas.

The examples below are not necessarily in iXML syntax and shouldn’t be construed
as syntax proposals.

## Priority examples

[Issue #310](https://github.com/invisiblexml/ixml/issues/310) raises the
question of setting priorities. Consider this grammar:

```ixml
        number       = decimal | hexadecimal .
{high} decimal      = ["0"-"9"]+ .
{low}  hexadecimal = ["0"-"9" | "a"-"f" | "A"-"F"]+ .
```

The `{high}` and `{low}` comments indicate that the author would like any input
that matches both `decimal` and `hexadecimal` to be parsed as `decimal`.

## Exclusion examples

[Issue #249](https://github.com/invisiblexml/ixml/issues/249) asks for a
mechanism to exclude some patterns from the parse.

```ixml
functionName = [L]+ ¬ ("if" | "while" ) .
```

This example expresses that a function name is any sequence of letters, except
that ~if~ and ~while~ cannot be function names.

