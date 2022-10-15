#!/bin/bash

SPEC=$1
PID=$$
OUTFN=autodiff.html

if [ "$SPEC" = "" ]; then
    SPEC=current
fi

# Get the current version of the base spec
curl -s -o /tmp/A.$PID.html https://invisiblexml.org/$SPEC/index.html

# Make the diff version
java -jar tools/deltaxml/command-12.0.1.jar compare xhtml-patch \
     /tmp/A.$PID.html build/current/index.html /tmp/autodiff.$PID.html

# Patch the diff version and make it HTML5
java -jar tools/deltaxml/saxon9pe.jar \
     -s:/tmp/autodiff.$PID.html -xsl:build-tools/patchdiff.xsl -o:build/current/autodiff.html \
     spec=$SPEC

rm -f /tmp/A.$PID.html /tmp/B.$PID.html /tmp/autodiff.$PID.html
