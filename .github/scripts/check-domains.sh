#!/usr/bin/env bash

# Colors
CSI='\033['
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CEND="${CSI}0m"

# Files
DIR=$(dirname "$0")
ALL="$DIR/../../all.txt"
TMPFILE=$(mktemp)

# Pre-Process
if [ ! -f "$ALL" ]; then
  echo -e "${CRED}Could not find required file \"$ALL\". Aborting.${CEND}"

  exit 1;
fi

cp "$ALL" "$TMPFILE"

# Process
DOMAIN_COUNTER=0
PROCESS_COUNTER=0

while IFS= read -r LINE
do
  let PROCESS_COUNTER++
  DOMAIN=${LINE,,}

  if (( "$PROCESS_COUNTER" % 1000 == 0 ))
  then
    echo -ne "Still working...\n"
  fi

  if [[ "$(dig +short @1.1.1.1 A "$DOMAIN")" =~ ^52\.48\.64\.111|54\.171\.90\.223 ]]; then
    let DOMAIN_COUNTER++

    echo "$DOMAIN" >> "$TMPFILE"
  else
    echo -ne "${CRED}🛑${CEND} $DOMAIN is obsolete and will be removed.\n"
  fi
done < "$ALL"

# Post-Process
if [ "$DOMAIN_COUNTER" eq 0 ]; then
  echo -e "\n${CRED}Something went wrong. Aborting.${CEND}"

  exit 1;
fi

sort -u "$TMPFILE" > "$ALL"

rm "$TMPFILE"

# Regenerate filter list
. "$DIR/generate-filter.sh"

exit 0;
