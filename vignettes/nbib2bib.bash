#!/bin/bash

# requires bibutils
#
#   brew install bibutils
#
#
# concatenate the nbib files,
# pass to nbib2xml
# pass to xml2bib
# save as references.bib
#
cd "$(dirname "$0")" || exit 1

for f in ./nbibs/*.nbib; do
  cat "$f"
  printf '\n\n'
done | nbib2xml | xml2bib > references.bib
