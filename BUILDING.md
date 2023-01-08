# Building the Invisible XML specification

The Invisible XML specification is built automatically for publication by a
[GitHub workflow](https://docs.github.com/en/actions/using-workflows).

## tl;dr

1. In your
   [fork](https://docs.github.com/en/get-started/quickstart/fork-a-repo)
   of the Invisible XML
   [repository](https://github.com/invisibleXML/ixml), make
   [a branch](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-branches).
2. Edit `ixml-specification.html` (in the `src` folder) to your
      heart’s content. (If necessary, edit the grammars, CSS, etc. as well.)
3. Create a [pull request](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/about-pull-requests) with your changes.
   
That’s all you need to do. Your pull request will be formatted
automatically, with change markup, and published on the [dashboard](https://invisiblexml.org/dashboard).

## Building it yourself

The Invisible XML specification is authored in XHTML, so there isn’t
actually _that_ much difference between what you see if you view the
source in a browser and what you see if you view the formatted
specification. The changes include:

* The publication date.
* The table of contents (there’s a ToC in the source, but that’s an
  authoring convenience, the published document has a ToC constructed
  from the headings).
* Perhaps various forms of syntax highlighting.

If you want to build the specification locally, you need a recent
version of Java. (Anything after about Java 8 should be fine.)

Run `./gradlew publish` (or `.\gradlew publish` on Windows).

[Gradle](https://gradle.org/) will download any necessary dependencies
and build the specification.

The output will be in `build/current`. You can open
`build/current/index.html` directly in your browser, but most modern
browsers won’t load JavaScript off the filesystem. You might want to do it
in a [a webserver](https://github.com/ndw/webserver). (There’s no
JavaScript in the specification itself, but there’s a small amount of
progressive enhancement in some of the ancillary pages.)

