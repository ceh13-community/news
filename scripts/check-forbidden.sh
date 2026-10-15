#!/usr/bin/env bash
# Fails the build if the site text leaks who writes it or where from.
# Keep the list to terms that are safe to publish: this file is public.
set -uo pipefail

targets=(content i18n layouts hugo.toml README.md)

# case-insensitive terms, matched on word boundaries
terms_i='switzerland|swiss|schweiz|suisse|svizzera|швейцар|u_daw|udawpk|zurich|zürich'
# case-sensitive terms
terms_s='\bUBS\b'

status=0

if hits=$(grep -rniE "(${terms_i})" "${targets[@]}" 2>/dev/null); then
  echo "forbidden terms found (location or identity):"
  echo "$hits"
  status=1
fi

if hits=$(grep -rnE "(${terms_s})" "${targets[@]}" 2>/dev/null); then
  echo "forbidden terms found (employer):"
  echo "$hits"
  status=1
fi

if [ "$status" -eq 0 ]; then
  echo "no forbidden terms in site sources"
fi
exit "$status"
